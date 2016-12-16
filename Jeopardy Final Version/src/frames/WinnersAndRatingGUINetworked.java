package frames;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.JLabel;
import javax.swing.SwingConstants;

import game_logic.ServerGameData;
import listeners.NetworkedWindowListener;
import messages.RatingMessage;
import server.Client;

public class WinnersAndRatingGUINetworked extends WinnersAndRatingGUI{

	private Client client;
	private Boolean isGameOver;
	private ServerGameData serverGameData;
	private MainGUI mainGUI;
	
	public WinnersAndRatingGUINetworked(ServerGameData gameData, MainGUI mainGUI, Client client, Boolean isGameOver){
		super();
		this.isGameOver = isGameOver;
		this.serverGameData = gameData;
		this.mainGUI = mainGUI;
		this.client = client;
		make(gameData);
	}
	
	@Override
	protected void createRatingLabel(){
		currentRatingLabel = new JLabel( serverGameData.getAverageRating()== -1 ? "no rating" : "current average rating : " + serverGameData.getAverageRating()+"/5", SwingConstants.CENTER);
	}

	@Override
	protected void addOkayListener(){
		addWindowListener(new NetworkedWindowListener(client, WinnersAndRatingGUINetworked.this));
		okay.addActionListener(new ActionListener(){

			@Override
			public void actionPerformed(ActionEvent e) {
				client.sendMessage(new RatingMessage(ratingSlider.getValue(), client.getTeamIndex()));
				dispose();
				mainGUI.dispose();
				client.goToStart();
			}
			
		});
	}
	
	@Override
	protected void setWinnersLabelText(){
		if (!isGameOver){
			andTheWinnersAre.setText("");
			winners.setText("You were eliminated from the game!");
		}
		else{
			setWinnersText();
		}
	}
}
