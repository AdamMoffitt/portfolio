package action_factory;

import frames.MainGUINetworked;
import game_logic.ServerGameData;
import messages.FJAnswerMessage;
import messages.Message;
import server.Client;

public class FJAnswerAction extends Action{

	@Override
	public void executeAction(MainGUINetworked mainGUI, ServerGameData gameData, Message message, Client client) {
		FJAnswerMessage fjMessage = (FJAnswerMessage) message;
		if (!client.isEliminated()){
			if (gameData.validAnswerFormat(fjMessage.getAnswer())){
				//check if answer is correct
				if (fjMessage.getAnswer().endsWith(gameData.getFinalJeopardyAnswer())){
					gameData.getTeam(fjMessage.getTeamThatAnswered()).setCorrectFJAnswer(true);
				}
			}
			//increase the number if fj answers (checking too if the game is done)
			mainGUI.getFJGUI().increaseNumberOfAnswers();
		}
	}
}
