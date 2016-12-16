package server;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.net.Socket;

import game_logic.ServerGameData;
import messages.Message;

public class ServerToClientThread extends Thread{

	private ObjectInputStream ois;
	private ObjectOutputStream oos;
	private int teamIndex;
	private String teamName;
	private Boolean close;
	private Boolean isHost;
	private HostServer hostPlayer;
	
	public ServerToClientThread(Socket clientSocket, HostServer hostThread, ServerGameData gameData, int index) {
		this.teamIndex = index;
		this.hostPlayer = hostThread;
		close = false;
		
		try {
			oos = new ObjectOutputStream(clientSocket.getOutputStream());
			oos.flush();
			ois = new ObjectInputStream(clientSocket.getInputStream());
			//right away we are going to read the team name and whether they are the host
			//this way, we are guaranteed to have all the team names after the loop ends in the server's run method
			try {
				teamName = (String)ois.readObject();
				isHost = (Boolean) ois.readObject();
				//write back with their team index and how many teams are needed
				oos.writeObject(teamIndex);
				oos.flush();
				oos.writeObject(hostPlayer.getNumTeamsNeeded());
				oos.flush();
			} catch (ClassNotFoundException e) {}
			
			this.start();

		} catch (IOException e) {}
		
	}                                                              
	
	public Boolean isHost(){
		return isHost;
	}
	
	@Override
	public void run(){
		try {
			while (!close){
				Message message = (Message) ois.readObject();
				hostPlayer.processMessage(message);
			}
			
		} 
		catch (ClassNotFoundException e) {}
		catch (IOException e) {
			try {
				hostPlayer.clientLeft(this);
				this.close();
			} catch (IOException e1) {
				System.out.println("exception in client leaving in server thread");
			}
		}
	}
	
	public void close() throws IOException{
		oos.close();
		ois.close();
		close = true;
	}
	
	public String getTeamName(){
		return teamName;
	}
	
	public void sendNumTeamsNeeded(int num) throws IOException{
		oos.writeObject(num);
		oos.flush();
	}
	
	public void startGame(ServerGameData gameData) throws IOException{
		oos.writeObject(gameData);
		oos.flush();
	}
	
	public void sendMessage(Message message){
		try {
			oos.reset();
			oos.writeObject(message);
			oos.flush();
		} catch (IOException e) {}
	}
	
	public int getTeamIndex(){
		return teamIndex;
	}

}
