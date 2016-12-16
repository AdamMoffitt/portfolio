package action_factory;

import frames.MainGUINetworked;
import game_logic.ServerGameData;
import messages.Message;
import server.Client;

//abtract method class for the action class
public abstract class Action {

	public abstract void executeAction(MainGUINetworked mainGUI, ServerGameData gameData, 
			Message message, Client client);
}

