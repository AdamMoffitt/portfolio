package other_gui;

import java.awt.Color;
import java.awt.GridLayout;
import java.util.HashMap;

import javax.swing.JLabel;
import javax.swing.JPanel;

import frames.MainGUI;
import frames.WinnersAndRatingGUINetworked;
import game_logic.ServerGameData;
import server.Client;

//JPanel that contains the final jeopardy gui elements and functionality
public class FinalJeopardyGUINetworked extends FinalJeopardyGUI {

	private Client client;
	private HashMap<Integer, JLabel> teamToBetLabelMap;
	private ServerGameData serverGameData;
	
	public FinalJeopardyGUINetworked(ServerGameData gameData, MainGUI mainGUI, Client client){	
		super();
		this.client = client;
		serverGameData = gameData;
		teamToBetLabelMap = new HashMap<Integer, JLabel>();
		answerUpdateLabel = new JLabel();
		make(gameData, mainGUI);
	}
	
	@Override
	protected JPanel createAnswerPanel(){
		JPanel answerPanel = new JPanel(new GridLayout(2, 1));
		
		for (int i = 0; i < gameData.getFinalistsAndEliminatedTeams().getFinalists().size(); i++){
			TeamGUIComponents team = gameData.getFinalistsAndEliminatedTeams().getFinalists().get(i);
			TeamGUIComponentsNetworked teamNetworked = (TeamGUIComponentsNetworked) team;
			teamNetworked.setClient(client);
			if (team.getTeamIndex() == client.getTeamIndex()){
				answerPanel.add(createTeamAnswerPanel(team));
			}
		}

		answerUpdateLabel.setFont(AppearanceConstants.fontMedium);
		answerUpdateLabel.setForeground(Color.lightGray);
		answerPanel.setBackground(Color.darkGray);
		answerPanel.add(answerUpdateLabel);
		return answerPanel;
	}
	
	@Override
	public void increaseNumberOfAnswers(){
		numTeamsAnswered++;
		//checks to see if all teams have answered the question
		if (allTeamsAnswered()){
			mainGUI.addUpdate("All teams have answered. The Final Jeopardy answer is: "+gameData.getFinalJeopardyAnswer());
			gameData.addOrDeductTeamBets(mainGUI);
			new WinnersAndRatingGUINetworked(serverGameData, mainGUI,client, true).setVisible(true);
		}
	}

	//update the label that displays the current state of this team's bet
	public void updateTeamBet(TeamGUIComponents team){
		if (team.getTeamIndex() != client.getTeamIndex()){
			JLabel label = teamToBetLabelMap.get(team.getTeamIndex());
			label.setText(team.getTeamName()+" bet $"+team.getBet());
		}
		increaseNumberOfBets(team.getTeamName()+" bet $"+team.getBet());
	}
	
	@Override
	protected void addBetPanels(){
		for (int i = 0; i < gameData.getFinalistsAndEliminatedTeams().getFinalists().size(); i++){
			TeamGUIComponents team = gameData.getFinalistsAndEliminatedTeams().getFinalists().get(i);
			team.prepareForFinalJeopardy(this, gameData);
			//add this client's slider and button
			if (team.getTeamIndex() == client.getTeamIndex()){
				add(createTeamBetPanel(team));
			}
			//add a label for each other team
			else{
				JLabel teamLabel = new JLabel("Waiting for "+team.getTeamName()+" to set their bet..");
				JPanel teamLabelPanel = new JPanel();
				AppearanceSettings.setTextAlignment(teamLabel, answerUpdateLabel);
				AppearanceSettings.setBackground(Color.darkGray, teamLabel, teamLabelPanel, answerUpdateLabel);
				teamLabel.setFont(AppearanceConstants.fontSmall);
				teamLabel.setForeground(Color.lightGray);
				teamLabelPanel.add(teamLabel);
				teamToBetLabelMap.put(team.getTeamIndex(), teamLabel);
				add(teamLabelPanel);
			}
			
		}
	}
}