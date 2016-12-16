package server;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.net.Socket;

import action_factory.ActionFactory;
import frames.MainGUINetworked;
import frames.StartWindowGUI;
import game_logic.Category;
import game_logic.ServerGameData;
import game_logic.User;
import messages.HostCancelledMessage;
import messages.Message;
import other_gui.QuestionGUIElement;
import other_gui.QuestionGUIElementNetworked;

public class Client extends Thread{

	private int teamIndex;
	private ServerGameData gameData;
	private ObjectInputStream ois;
	private ObjectOutputStream oos;
	private int numTeamsNeeded;
	private StartWindowGUI startWindowGUI;
	private MainGUINetworked mainGUI;
	private QuestionGUIElementNetworked currentQuestion;
	private Boolean isHost;
	private ActionFactory actionFactory;
	private User loggedInUser;
	private Boolean close;
	private Boolean eliminated = false;
	private Socket s = null;

	public Client(String port, String IPAddress, String teamName, StartWindowGUI startWindowGUI, Boolean isHost, User loggedInUser) {

		this.startWindowGUI = startWindowGUI;
		this.loggedInUser = loggedInUser;
		this.isHost = isHost;
		close = false;
		actionFactory = new ActionFactory();

		try {
			s = new Socket(IPAddress, Integer.parseInt(port));
			oos = new ObjectOutputStream(s.getOutputStream());
			oos.flush();
			ois = new ObjectInputStream(s.getInputStream());
			//before we enter the run method, we want to send our team name and whether we are the host
			oos.writeObject(teamName);
			oos.flush();
			oos.writeObject(isHost);
			oos.flush();

			try {
				//read our assigned team index and how many teams are needed right now
				teamIndex = (Integer) ois.readObject();
				numTeamsNeeded = (Integer) ois.readObject();
				startWindowGUI.updateNetworkMessage(numTeamsNeeded);
			} catch (IOException e1) {
				System.out.println(e1.getMessage());
			} catch (ClassNotFoundException e) {}

			this.start();

		} catch (NumberFormatException | IOException e) {}
	}

	public User getUser(){
		return loggedInUser;
	}

	public int getTeamIndex(){
		return teamIndex;
	}

	public Boolean isHost(){
		return isHost;
	}

	public Boolean isEliminated(){
		return eliminated;
	}

	public void setElimindated(Boolean eliminated){
		this.eliminated = eliminated;
	}

	public void close(){
		try {
			close = true;
			s.close();
			oos.close();
			ois.close();
		} catch (IOException e) {}

	}

	public QuestionGUIElementNetworked getCurrentQuestion(){
		return currentQuestion;
	}

	public void setCurrentQuestion(int x, int y){
		currentQuestion = gameData.getNetworkedQuestions()[x][y];
	}

	public void sendMessage(Message message){
		try {
			oos.writeObject(message);
			oos.flush();
		} catch (IOException e) {
			System.out.println("ioe in client send mess");
		}
	}

	public void goToStart(){
		new StartWindowGUI(loggedInUser).setVisible(true);
		close();
	}

	@Override
	public void run() {

		while(numTeamsNeeded != 0 && !close){

			try {
				Object object = ois.readObject();
				if (object instanceof HostCancelledMessage){
					close = true;
					close();
					startWindowGUI.gameCancelled();
					break;
				}
				else{
					numTeamsNeeded = (Integer) object;
					startWindowGUI.updateNetworkMessage(numTeamsNeeded);
				}
			} catch (IOException | ClassNotFoundException e) {
				System.out.println(e.getMessage());
			}

		}

		try {
			gameData = (ServerGameData) ois.readObject();
			//reset game data icons, they wont show up otherwise ¯\_(ツ)_/¯
			Category.setIcon(gameData.getCategoryIconPath());
			QuestionGUIElement.setDisabledIcon(gameData.getDisabledIconPath());
			QuestionGUIElement.setEnabledIcon(gameData.getEnabledIconPath());
			//repopulate game data GUI objects since all GUI components are transient in GameData and subsequent classes
			gameData.populate();
			startWindowGUI.dispose();
			mainGUI = new MainGUINetworked(gameData, this, loggedInUser);
			//System.out.println("Here: " + mainGUI.getLoggedInUser().getUsername());
			mainGUI.setVisible(true);

			if (gameData.getCurrentTeam().getTeamIndex() != teamIndex) mainGUI.disableAllButtons();

		} catch (ClassNotFoundException | IOException e) {}

		while (!close){
			try {
				Message message = (Message) ois.readObject();
				//process the message and execute the correct action!

				System.out.println("*" + gameData.getTeamName(0));
				System.out.println("*" + message.getClass().toString());
				//System.out.println("*" + mainGUI.getLoggedInUser().getUsername());
				actionFactory.getAction(message.getClass()).executeAction(mainGUI, gameData, message, this);

			} catch (ClassNotFoundException | IOException e) {}
		}
	}

	public MainGUINetworked getMainGUI() {
		return mainGUI;
	}
}
