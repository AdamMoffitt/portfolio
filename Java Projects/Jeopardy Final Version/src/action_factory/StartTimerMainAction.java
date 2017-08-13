package action_factory;

import frames.MainGUINetworked;
import game_logic.ServerGameData;
import messages.Message;
import server.Client;

public class StartTimerMainAction extends Action{

	public StartTimerMainAction(){

	}

	@Override
	public void executeAction(MainGUINetworked mainGUI, ServerGameData gameData, Message message, Client client) {
		System.out.println("received start timer main message");
		mainGUI.restartTimer();

	}
}
