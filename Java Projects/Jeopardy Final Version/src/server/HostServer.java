package server;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.Stack;

import frames.StartWindowGUI;
import game_logic.RateGameFile;
import game_logic.ServerGameData;
import messages.BuzzInMessage;
import messages.HostCancelledMessage;
import messages.Message;
import messages.PlayerLeftMessage;
import messages.QuestionAnsweredMessage;
import messages.RatingMessage;

public class HostServer extends Thread{
	
	private ServerGameData gameData;
	private int numPlayers;
	private StartWindowGUI startWindowGUI;
	private String port;
	private ServerToClientThread[] communicationThreads;
	private Stack<Integer> availableTeamSpots;
	private ServerSocket serverSocket;
	private Boolean teamBuzzedIn;
	private Boolean gameInProgress;
	private int totalRating;
	private int numTeamsRated;
	
	public HostServer(ServerGameData gameData, String port, int numTeams, StartWindowGUI startWindowGUI) {
		this.gameData = gameData;
		this.numPlayers = numTeams;
		this.port = port;
		this.startWindowGUI = startWindowGUI;
		teamBuzzedIn = false;
		gameInProgress = false;
		totalRating = 0;
		numTeamsRated = 0;
		availableTeamSpots = new Stack<>();
		//push indices for the server threads. 
		//use a stack so when a client exists, we can take their assigned index and push it back on the stack
		for (int i = 0; i<numPlayers; i++){
			availableTeamSpots.push(i);
		}
		
		communicationThreads = new ServerToClientThread[numTeams];
		this.start();
	}
	
	public int getNumTeams(){
		return numPlayers;
	}
	
	public void sendNumTeamsNeeded(int index) throws IOException{
		//we don't want to send the number of teams needed to the server to client thread
		//that was just created (at index) because the client is sent that information in the constructor
		//of the server to client thread
		for (ServerToClientThread currentThread : communicationThreads){
			if (currentThread != null) {
				if (currentThread.getTeamIndex() != index) currentThread.sendNumTeamsNeeded(getNumTeamsNeeded());
			}
		}
	}
	
	public int getNumTeamsNeeded(){
		return availableTeamSpots.size();
	}
	
	@Override
	public void run(){
		try {
			serverSocket = new ServerSocket(Integer.parseInt(port));
			//while there are still spots left in the game
			while (!availableTeamSpots.isEmpty()){
				Socket socket = serverSocket.accept();
				//create a server to client thread with the popped index
				int index = availableTeamSpots.peek();
				availableTeamSpots.pop();
				ServerToClientThread newThread = new ServerToClientThread(socket, this, gameData, index);
				//set the server to client thread in the array
				communicationThreads[index] = newThread;
			
				startWindowGUI.updateNetworkMessage(availableTeamSpots.size());
				sendNumTeamsNeeded(index);
			}

			gameData.setTeams(communicationThreads);
			gameData.chooseFirstTeam();
			startGame();
			gameInProgress = true;

		} catch (NumberFormatException | IOException e) {
			System.out.println("io in server "+e.getMessage());
		}
	}

	
	public void startGame() throws IOException{
		for (ServerToClientThread currentThread : communicationThreads){
			if (currentThread != null) currentThread.startGame(gameData);
		}
	}
	
	public void sendMessage(messages.Message message){
		for (ServerToClientThread currentThread : communicationThreads){
			if (currentThread != null) currentThread.sendMessage(message);
		}
	}
	//if a client leaves during the game
	public void clientLeft(ServerToClientThread serverThread) throws IOException{
		communicationThreads[serverThread.getTeamIndex()] = null;
		//if the game is not in progress yet, that the means the client logged out or exited from the start screen
		if (!gameInProgress){
			
			if (serverThread.isHost()){
				//if the client was also the host, set everyone know the host left and close the server socket
				sendMessage(new HostCancelledMessage());
				close();
			}
			else{
				//push their index back on the stack
				availableTeamSpots.push(serverThread.getTeamIndex());
				startWindowGUI.updateNetworkMessage(availableTeamSpots.size());
				sendNumTeamsNeeded(serverThread.getTeamIndex());
			}
		}
	}
	
	public void close(){
		try {
			serverSocket.close();
		} catch (IOException e) {
			System.out.println("exception closing server socket: "+e.getMessage());
		}
	}
	
	//process the message from the client
	public void processMessage(Message message){
		Boolean sendMessage = true;
		//if a team buzzed in, make sure no one has tried to buzz in yet and then let all clients know
		if (message instanceof BuzzInMessage){
			if (!teamBuzzedIn) teamBuzzedIn = true;
			else sendMessage = false;
		}
		//reset teamBuzzedIn everytime a new question is chosen
		else if (message instanceof QuestionAnsweredMessage) teamBuzzedIn = false;
		//if a client rated the game, take their rating and then disconnect them from the server
		else if (message instanceof RatingMessage){
			RatingMessage rateMessage = (RatingMessage) message;
			communicationThreads[rateMessage.getTeamWhoRated()] = null;
			totalRating += rateMessage.getRating();
			numTeamsRated++;
			//if we have all the ratings from all clients, write to the file
			if (numTeamsRated == numPlayers){
				RateGameFile rgf = new RateGameFile();
				rgf.writeToFile(gameData, totalRating, numPlayers);
				this.close();
			}
			//don't need to send a message after this
			sendMessage = false;
		}
		else if (message instanceof PlayerLeftMessage){
			PlayerLeftMessage plm = (PlayerLeftMessage) message;
			
			try {
				communicationThreads[plm.getTeamWhoLeft()].close();
			} catch (IOException e) {}
			
			communicationThreads[plm.getTeamWhoLeft()] = null;
	
		}
		//only send a message to everyone is sendMessage is true
		if (sendMessage) sendMessage(message);
	}
}
