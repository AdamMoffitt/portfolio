package action_factory;

import frames.MainGUINetworked;
import game_logic.ServerGameData;
import messages.Message;
import server.Client;

public class NoOneBuzzedInInTimeAction extends Action{


	public NoOneBuzzedInInTimeAction(){

	}

	@Override
	public void executeAction(MainGUINetworked mainGUI, ServerGameData gameData, Message message, Client client) {
		mainGUI.addUpdate("\nno one buzzed in in time!!!\n");
		mainGUI.addUpdate("The right answer was " + client.getCurrentQuestion().getAnswer());
		System.out.println("no on buzzed in action received");
		mainGUI.showMainPanel();
		mainGUI.startTimer();
	}

}
