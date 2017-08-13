package other_gui;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import game_logic.GameData;
import messages.FJAnswerMessage;
import messages.SetBetMessage;
import server.Client;

public class TeamGUIComponentsNetworked extends TeamGUIComponents{
	
	private Client client;
	
	public TeamGUIComponentsNetworked(Integer team, int totalPoints, String teamName){
		super(team, totalPoints, teamName);
	}
	
	public void setClient(Client client){
		this.client = client;
	}
	
	//override the method to add the actionlistener
	@Override
	protected void addButtonActionListeners(FinalJeopardyGUI finalJeopardyGUI, GameData gameData){
		fjBetButtonActionListener = new ActionListener(){

			@Override
			public void actionPerformed(ActionEvent e) {
				client.sendMessage(new SetBetMessage(teamIndex, fjBetSlider.getValue()));
			}
			
		};
		
		submitFJAnswerButtonActionListener = new ActionListener(){

			@Override
			public void actionPerformed(ActionEvent e) {
				client.sendMessage(new FJAnswerMessage(fjAnswerTextField.getText().trim().toLowerCase(), teamIndex));
				finalJeopardyGUI.getAnswerUpdateLabel().setText("Waiting for other teams to answer...");
			}
			
		};
	}
	
}
