package action_factory;

import frames.MainGUINetworked;
import game_logic.ServerGameData;
import messages.BuzzInMessage;
import messages.Message;
import server.Client;

public class BuzzInAction extends Action{

	@Override
	public void executeAction(MainGUINetworked mainGUI, ServerGameData gameData,
			Message message, Client client) {
		BuzzInMessage buzzMessage = (BuzzInMessage) message;
		//update the team on the current question to be the one who buzzed in
		client.getCurrentQuestion().updateTeam(buzzMessage.getBuzzInTeam(), gameData);
		mainGUI.setTitle("Jeopardy!!" + buzzMessage.getBuzzInTeam());
		System.out.println("Buzz in action");
		mainGUI.showClocks();
		mainGUI.showClocks(buzzMessage.getBuzzInTeam());

	}

}
