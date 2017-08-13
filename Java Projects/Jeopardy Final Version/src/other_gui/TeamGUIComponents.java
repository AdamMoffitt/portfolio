package other_gui;

import java.awt.Color;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.FocusListener;

import javax.swing.JButton;
import javax.swing.JLabel;
import javax.swing.JSlider;
import javax.swing.JTextField;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;

import game_logic.GameData;
import game_logic.TeamData;
import listeners.TextFieldFocusListener;

public class TeamGUIComponents extends TeamData{
	//members for the main screen
	transient private JLabel mainTotalPointsLabel;
	transient private JLabel mainTeamNameLabel;
	//members for the final jeopardy screen
	
	//bug fix: all components with listeners need to have their listener stored, so we can remove it later
	transient protected JButton fjBetButton;
	transient protected ActionListener fjBetButtonActionListener;
	
	transient protected JButton submitFJAnswerButton;
	transient protected ActionListener submitFJAnswerButtonActionListener;
	
	transient protected JTextField fjAnswerTextField;
	transient private FocusListener fjAnswerTextFieldFocusListener;
	
	transient protected JSlider fjBetSlider;
	transient private ChangeListener fjBetSliderChangeListener;
	
	transient private JLabel fjBetLabel;
	transient private JLabel fjTeamNameLabel;
	
	public TeamGUIComponents(Integer team, int totalPoints, String teamName){
		super(team, totalPoints, teamName);
		populate();
		//addActionListeners() called from prepareForFinalJeopardy()
	}
	
	public void populate(){
		initializeComponents();
		createGUI();
	}
	
	//public methods
	//called from MainGUI when the user click the 'Restart This Game' option on the menu
	public void resetTeam(){
		fjBetLabel.setText("$1");
		fjBetSlider.setValue(1);
		fjBetSlider.setEnabled(true);
		//remove all listeners from the components, we will add a new listener next time around
		fjBetSlider.removeChangeListener(fjBetSliderChangeListener);
		fjAnswerTextField.removeFocusListener(fjAnswerTextFieldFocusListener);
		fjBetButton.removeActionListener(fjBetButtonActionListener);
		submitFJAnswerButton.removeActionListener(submitFJAnswerButtonActionListener);
		
		fjAnswerTextField.setText(teamName+"'s answer");
		fjBetButton.setEnabled(true);
		submitFJAnswerButton.setEnabled(false);
		
		totalPoints = 0;
		correctFJAnswer = false;
		updatePointsLabel();
	}
	//override addPoints and deductPoints from TeamData so it can also update the total points label
	@Override 
	public void addPoints(int points){
		super.addPoints(points);
		updatePointsLabel();
	}
	
	@Override 
	public void deductPoints(int points){
		super.deductPoints(points);
		updatePointsLabel();
	}
	
	public void updatePointsLabel(){
		mainTotalPointsLabel.setText("$"+totalPoints);
	}
	//called from FinalJeopardyGUI constructor
	public void prepareForFinalJeopardy(FinalJeopardyGUI gui, GameData gameData){
		initializeBetSlider();
		addActionListeners(gui, gameData);
	}
	
	//GETTERS
	public JLabel getTotalPointsLabel() {
		return mainTotalPointsLabel;
	}

	public JButton getBetButton() {
		return fjBetButton;
	}

	public JButton getFJAnswerButton() {
		return submitFJAnswerButton;
	}

	public JTextField getFJAnswerTextField() {
		return fjAnswerTextField;
	}
	
	public JSlider getBetSlider() {
		return fjBetSlider;
	}

	public JLabel getBetLabel() {
		return fjBetLabel;
	}

	public JLabel getFJTeamNameLabel() {
		return fjTeamNameLabel;
	}
	
	public JLabel getMainTeamNameLabel(){
		return mainTeamNameLabel;
	}
	
	//private methods
	private void initializeComponents(){
		mainTotalPointsLabel = new JLabel("$"+Long.toString(totalPoints));
		fjBetButton = new JButton("Set Bet");
		submitFJAnswerButton = new JButton("Submit Answer");
		fjAnswerTextField = new JTextField(teamName + "'s answer");
		fjBetSlider = new JSlider();
		fjBetLabel = new JLabel("$1");
		fjTeamNameLabel = new JLabel(teamName + "'s bet");
		mainTeamNameLabel = new JLabel(teamName);
	}
	
	private void createGUI(){
		//set appearances of components
		AppearanceSettings.setBackground(Color.darkGray, mainTeamNameLabel, mainTotalPointsLabel, fjTeamNameLabel, fjBetLabel);
		AppearanceSettings.setFont(AppearanceConstants.fontSmallest, fjTeamNameLabel, fjBetButton, submitFJAnswerButton, fjBetSlider);
		AppearanceSettings.setForeground(Color.lightGray, mainTeamNameLabel, fjTeamNameLabel, fjBetLabel, fjBetSlider);
		AppearanceSettings.setFont(AppearanceConstants.fontSmall, fjAnswerTextField, mainTeamNameLabel, fjBetLabel);
		AppearanceSettings.setTextAlignment(mainTeamNameLabel, fjTeamNameLabel, fjBetLabel, mainTotalPointsLabel);
		
		mainTeamNameLabel.setBorder(null);
		mainTotalPointsLabel.setForeground(AppearanceConstants.lightBlue);
		mainTotalPointsLabel.setFont(AppearanceConstants.fontMedium);
		fjAnswerTextField.setForeground(Color.gray);

		mainTotalPointsLabel.setBorder(null);
		submitFJAnswerButton.setEnabled(false);
		AppearanceSettings.setSize(500, 90, fjBetSlider);
		
		//and that's it! The components are added to panels is MainGUI and FinalJeopardyGUI
	}

	//set the bet amount, so disable slider and button
	@Override
	public void setBet(int bet){
		super.setBet(bet);
		fjBetButton.setEnabled(false);
		fjBetSlider.setEnabled(false);
	}

	//slider has been moved, so updated fjBetLabel
	private void changeBet(int bet){
		//if they moved the slider to 0, change it 1, since their bet can't be 0
		if (bet == 0){
			fjBetSlider.setValue(1);
			fjBetLabel.setText("$1");
		}
		else{
			fjBetLabel.setText("$"+bet);	
		}
		
	}
	
	protected void addButtonActionListeners(FinalJeopardyGUI finalJeopardyGUI, GameData gameData){
		fjBetButtonActionListener = new ActionListener(){

			@Override
			public void actionPerformed(ActionEvent e) {
				setBet(fjBetSlider.getValue());
				finalJeopardyGUI.increaseNumberOfBets(teamName+" bet $"+bet);
			}
			
		};
		
		submitFJAnswerButtonActionListener = new ActionListener(){

			@Override
			public void actionPerformed(ActionEvent e) {
				submitFJAnswerButton.setEnabled(false);
				String answer = fjAnswerTextField.getText().trim().toLowerCase();
				//answer can only be correct if it has valid format
				if (gameData.validAnswerFormat(answer)){
					//check if answer is correct
					if (answer.endsWith(gameData.getFinalJeopardyAnswer())){
						correctFJAnswer = true;
					}
				}
				
				finalJeopardyGUI.increaseNumberOfAnswers();
			}
			
		};
	}
	
	private void addActionListeners(FinalJeopardyGUI finalJeopardyGUI, GameData gameData){
		
		addButtonActionListeners(finalJeopardyGUI, gameData);
		//slider change listener, set member variable to anonymous class
		fjBetSliderChangeListener = new ChangeListener(){

			@Override
			public void stateChanged(ChangeEvent e) {
				changeBet(fjBetSlider.getValue());
			}
		};
		//add the change listener
		fjBetSlider.addChangeListener(fjBetSliderChangeListener);
		//add the action listener
		fjBetButton.addActionListener(fjBetButtonActionListener);
		//text field focus listener member variable initialization
		fjAnswerTextFieldFocusListener = new TextFieldFocusListener(teamName+"'s answer", fjAnswerTextField);
		//add focus listener
		fjAnswerTextField.addFocusListener(fjAnswerTextFieldFocusListener);
		//add action listener
		submitFJAnswerButton.addActionListener(submitFJAnswerButtonActionListener);
	}
	
	//initialize the bet slider for this team
	private void initializeBetSlider(){
		//else, divide their total by 6 as the major tick spacing
		if (totalPoints > 20){
			AppearanceSettings.setMinTickSliders(totalPoints/18, fjBetSlider);
			AppearanceSettings.setSliders(0, totalPoints, 1, totalPoints/6, AppearanceConstants.fontSmall, fjBetSlider);
		}
		//if their points total is small, the tick spacing should be small
		else{
			AppearanceSettings.setSliders(0, totalPoints, 1, 1, AppearanceConstants.fontSmall, fjBetSlider);
		}

	}
}
