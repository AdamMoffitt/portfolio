package action_factory;

import frames.LeaveGamePopUp;
import frames.MainGUINetworked;
import game_logic.ServerGameData;
import messages.Message;
import messages.PlayerLeftMessage;
import server.Client;
//for when a player clicks any of the menu items on the main gui
public class PlayerLeftAction extends Action{

	@Override
	public void executeAction(MainGUINetworked mainGUI, ServerGameData gameData, Message message, Client client) {
		PlayerLeftMessage plm = (PlayerLeftMessage) message;
		//pass over to the pop-up which team left
		String teamName = gameData.getTeamName(plm.getTeamWhoLeft());
		new LeaveGamePopUp(client, teamName, mainGUI);
	}
}
