package frames;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.GridLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.List;

import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JSlider;
import javax.swing.JTextPane;
import javax.swing.SwingConstants;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;
import javax.swing.text.SimpleAttributeSet;
import javax.swing.text.StyleConstants;
import javax.swing.text.StyledDocument;

import game_logic.GameData;
import game_logic.RateGameFile;
import game_logic.TeamData;
import listeners.ExitWindowListener;
import other_gui.AppearanceConstants;
import other_gui.AppearanceSettings;

public class WinnersAndRatingGUI extends JFrame{

	protected JLabel andTheWinnersAre;
	protected JTextPane winners;
	protected GameData gameData;
	protected JButton okay;
	private JLabel ratingChoiceLabel;
	protected JSlider ratingSlider;
	protected JLabel currentRatingLabel;
	
	public WinnersAndRatingGUI(GameData gameData){
		make(gameData);
	}
	
	public WinnersAndRatingGUI(){}
	
	protected void make(GameData gameData){
		this.gameData = gameData;
		initializeComponents();
		createGUI();
		addListeners();
	}
	
	//private methods
	private void initializeComponents(){
		andTheWinnersAre = new JLabel("");
		winners = new JTextPane();
		okay = new JButton("Okay");
		ratingChoiceLabel = new JLabel("3");
		ratingSlider = new JSlider();
	}
	//moved this into a protected method so WinnersAndRatingGUINetworked can override it
	protected void createRatingLabel(){
		currentRatingLabel = new JLabel(gameData.getGameFile().getNumberOfRatings() == -1 ? "no rating" : "current average rating : " + gameData.getGameFile().getAverageRating()+"/5", SwingConstants.CENTER);
	}
	
	private void createGUI(){
		//initialize local variables
		createRatingLabel();
		JPanel mainPanel = new JPanel(new GridLayout(3, 1));
		JLabel ratingInstructionsLabel = new JLabel ("Please rate this game file on a scale from 1 to 5", SwingConstants.CENTER);
		JPanel ratingInstructionsPanel = new JPanel();
		JPanel sliderPanel = new JPanel(new BorderLayout());
		JPanel bottomPanel = new JPanel(new GridLayout(2, 1));
		JPanel topPanel = new JPanel(new GridLayout(2, 1));
		JPanel okayPanel = new JPanel();
		
		//set appearance of all local and member variables
		AppearanceSettings.setBackground(AppearanceConstants.lightBlue, okayPanel, winners, andTheWinnersAre, ratingChoiceLabel,mainPanel, sliderPanel, ratingInstructionsLabel, currentRatingLabel, ratingInstructionsPanel);
		AppearanceSettings.setBackground(Color.darkGray, winners, ratingChoiceLabel, okay);
		
		AppearanceSettings.setFont(AppearanceConstants.fontMedium, okay, andTheWinnersAre, currentRatingLabel);
		AppearanceSettings.setFont(AppearanceConstants.fontSmall, ratingChoiceLabel, ratingInstructionsLabel);
		
		AppearanceSettings.setOpaque(currentRatingLabel, okay, winners, ratingChoiceLabel, andTheWinnersAre);
		AppearanceSettings.setSliders(1, 5, 3, 1, AppearanceConstants.fontSmall, ratingSlider);
		AppearanceSettings.setForeground(Color.lightGray, okay, winners, ratingChoiceLabel);
		AppearanceSettings.setTextAlignment(ratingInstructionsLabel, currentRatingLabel, ratingChoiceLabel, andTheWinnersAre);
		
		//other appearance settings
		okay.setEnabled(false);
		okay.setBorder(null);
		okay.setPreferredSize(new Dimension(70, 70));
		
		winners.setFont(AppearanceConstants.fontLarge);
		winners.setEditable(false);
		winners.setPreferredSize(new Dimension(600, 100));
		setWinnersLabelText();
		
		ratingChoiceLabel.setPreferredSize(new Dimension(60, 100));
		
		//centers the text
		//sourced from: http://stackoverflow.com/questions/3213045/centering-text-in-a-jtextarea-or-jtextpane-horizontal-text-alignment
		StyledDocument doc = winners.getStyledDocument();
		SimpleAttributeSet center = new SimpleAttributeSet();
		StyleConstants.setAlignment(center, StyleConstants.ALIGN_CENTER);
		doc.setParagraphAttributes(0, doc.getLength(), center, false);
		//adding components to containers
		okayPanel.add(okay);
		
		sliderPanel.add(ratingSlider, BorderLayout.CENTER);
		sliderPanel.add(ratingChoiceLabel, BorderLayout.EAST);
		
		ratingInstructionsPanel.setLayout(new BoxLayout(ratingInstructionsPanel, BoxLayout.PAGE_AXIS));
		ratingInstructionsPanel.add(ratingInstructionsLabel);
		ratingInstructionsPanel.add(sliderPanel);

		bottomPanel.add(currentRatingLabel);
		bottomPanel.add(okayPanel);
		
		topPanel.add(andTheWinnersAre);
		topPanel.add(winners);
		
		mainPanel.add(topPanel);
		mainPanel.add(ratingInstructionsPanel);
		mainPanel.add(bottomPanel);

		setSize(600, 600);
		add(mainPanel, BorderLayout.CENTER);
	}
	
	protected void setWinnersLabelText(){
		this.setWinnersText();
	}
	//sets the text of the winners label to who the winners are (if any)
	protected void setWinnersText(){

		List<TeamData> winnersList = gameData.getFinalistsAndEliminatedTeams().getWinners();
		//no winners
		if (winnersList.size() == 0){
			andTheWinnersAre.setText("Sad!");
			winners.setText("There were no winners!");
		}
		//at least 1 winner
		else{
			String winnersAre = winnersList.size() == 1 ? "And the winner is..." : "And the winners are...";
			//string builder to create string with all the winners
			StringBuilder teamsBuilder = new StringBuilder();
			teamsBuilder.append(winnersList.get(0).getTeamName());
			
			for (int i = 1; i<winnersList.size(); i++){
				teamsBuilder.append(" and "+winnersList.get(i).getTeamName());
			}
			
			andTheWinnersAre.setText(winnersAre);
			winners.setText(teamsBuilder.toString());
		}
		
	}
	
	protected void addOkayListener(){
		//add windowlistener
		addWindowListener(new ExitWindowListener(this));
		okay.addActionListener(new ActionListener(){

			@Override
			public void actionPerformed(ActionEvent e) {
				new RateGameFile().writeToFile(gameData, ratingSlider.getValue(), 1);
				dispose();
			}
			
		});
	}
	
	private void addListeners(){
		setDefaultCloseOperation(DO_NOTHING_ON_CLOSE);
	
		//action listener
		addOkayListener();
		//change listener
		ratingSlider.addChangeListener(new ChangeListener(){

			@Override
			public void stateChanged(ChangeEvent e) {
				okay.setEnabled(true);
				ratingChoiceLabel.setText(Integer.toString(ratingSlider.getValue()));
			}
			
		});
	}
}
