package action_factory;

import frames.MainGUINetworked;
import game_logic.ServerGameData;
import messages.Message;
import messages.NextTurnMessage;
import other_gui.QuestionGUIElementNetworked;
import other_gui.TeamGUIComponents;
import server.Client;

public class NextTurnAction extends Action{

	private ServerGameData gameData;
	private MainGUINetworked mainGUI;
	private QuestionGUIElementNetworked currentQuestion;
	private TeamGUIComponents currentTeam;
	private String answer;
	private Client client;

	public void executeAction(MainGUINetworked mainGUI, ServerGameData gameData, Message message,
			Client client) {
		//set variables
		NextTurnMessage qAnsweredMessage = (NextTurnMessage) message;
		this.gameData = gameData;
		this.client = client;
		this.mainGUI = mainGUI;
		currentQuestion = client.getCurrentQuestion();
		currentTeam = currentQuestion.getCurrentTeam();

		mainGUI.showClocks();
		//deduct points, add update in Game Progress
		currentTeam.deductPoints(currentQuestion.getPointValue());
		mainGUI.addUpdate(currentTeam.getTeamName()+" did not answer in time. $"+currentQuestion.getPointValue()+" will be deducted from their total. ");
		//check if all teams have gotten a chance to answer
		questionDone();
	}

	private void questionDone(){
		//check the current question to see if all teams have had a chance, and if so
		if (currentQuestion.questionDone()){
			System.out.println("question done");
			//set the next turn to be the team in clockwise order from original team, add an update, and see whether it is time for FJ
			gameData.setNextTurn(gameData.nextTurn(currentQuestion.getOriginalTeam()));
			mainGUI.setTitle("Jeopardy!! " + gameData.getCurrentTeam().getTeamName());
			mainGUI.showClocks();
			mainGUI.addUpdate("No one answered the question correctly. The correct answer was: "+currentQuestion.getAnswer());
			checkReadyForFJ();
		}
		//if question has not been attempted by everyone, go to next playercounter clockwise
		else{
			System.out.println("question not done");
			gameData.setNextTurn(gameData.nextTurn(gameData.getCurrentTeam().getTeamIndex()));
			client.getCurrentQuestion().updateTeam(gameData.getCurrentTeam().getTeamIndex(), gameData);
			mainGUI.addUpdate(gameData.getCurrentTeam().getTeamName() + "'s turn!");
		}
	}


	private void checkReadyForFJ(){
		System.out.println("check final jeopardy");
		//check with the game data if we are ready for FJ, if so have the mainGUI set it up
		if (gameData.readyForFinalJeoaprdy()){
			mainGUI.startFinalJeopardy();
		}
		//if not ready, move on to another question
		else{
			//add update to Game Progress, determine whether the game board buttons should be enabled or disabled, and change the main panel
			mainGUI.addUpdate("It is "+gameData.getCurrentTeam().getTeamName()+"'s turn to choose a question.");

			if (gameData.getCurrentTeam().getTeamIndex() != client.getTeamIndex()) mainGUI.disableAllButtons();

			currentQuestion.stopTimers();
			mainGUI.showMainPanel();
			mainGUI.restartTimer();
		}
	}
}
