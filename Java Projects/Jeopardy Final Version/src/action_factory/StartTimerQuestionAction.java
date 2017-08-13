package action_factory;

import frames.MainGUINetworked;
import game_logic.ServerGameData;
import messages.Message;
import other_gui.QuestionGUIElementNetworked;
import server.Client;

public class StartTimerQuestionAction extends Action{

	private QuestionGUIElementNetworked currentQuestion;

	public StartTimerQuestionAction(){

	}

	@Override
	public void executeAction(MainGUINetworked mainGUI, ServerGameData gameData, Message message, Client client) {
		System.out.println("received start timer message");
		currentQuestion = client.getCurrentQuestion();
		currentQuestion.restartTimer();
	}
}
