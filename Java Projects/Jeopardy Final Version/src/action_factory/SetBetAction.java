package action_factory;

import frames.MainGUINetworked;
import game_logic.ServerGameData;
import messages.Message;
import messages.SetBetMessage;
import server.Client;

public class SetBetAction extends Action {

	@Override
	public void executeAction(MainGUINetworked mainGUI, ServerGameData gameData, Message message, Client client) {
		SetBetMessage sbMess = (SetBetMessage) message;
		//set the bet of the passed team with the passed bet
		if (!client.isEliminated()) mainGUI.setBet(sbMess.getTeamThatBet(), sbMess.getBet());
		
	}

}
