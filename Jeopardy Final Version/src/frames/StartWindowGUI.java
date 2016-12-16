package frames;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.GridLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.util.ArrayList;
import java.util.List;

import javax.swing.BoxLayout;
import javax.swing.ButtonGroup;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JRadioButton;
import javax.swing.JSlider;
import javax.swing.JTextField;
import javax.swing.SwingConstants;
import javax.swing.border.Border;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;
import javax.swing.event.DocumentEvent;
import javax.swing.event.DocumentListener;
import javax.swing.filechooser.FileNameExtensionFilter;

import game_logic.GameData;
import game_logic.ServerGameData;
import game_logic.User;
import listeners.ExitWindowListener;
import listeners.TextFieldFocusListener;
import other_gui.AppearanceConstants;
import other_gui.AppearanceSettings;
import server.Client;
import server.HostServer;

public class StartWindowGUI extends JFrame{

	//text fields
	private JTextField port;
	private JTextField IPAddress;
	//radio buttons
	private JRadioButton notNetworked;
	private JRadioButton hostGame;
	private JRadioButton joinGame;
	//labels
	private JLabel messageLabel;
	private JLabel numberOfTeamsLabel;
	private JLabel chooseGameFileLabel;
	private JLabel fileNameLabel;
	//buttons
	private JButton startGameButton;
	private JButton clearDataButton;
	private JButton exitButton;
	private JButton fileChooserButton;
	private JButton logoutButton;
	
	//other GUI
	private JPanel mainPanel;
	private JFileChooser fileChooser;
	private JSlider slider;
	private JCheckBox quickPlay;
	
	private List<JTextField> teamNameTextFields;
	private List<JLabel> teamNameLabels;
	private static final int MAX_NUMBER_OF_TEAMS = 4;
	private int numberOfTeams;
	//now we have a different valid file boolean for the networked game data
	private Boolean haveValidNetworkedFile;
	private Boolean haveValidFile;
	//now we have a different game data object for a networked game
	private GameData gameData;
	private ServerGameData serverGameData;
	private Client client;
	private User loggedInUser;
	
	
	
	public StartWindowGUI(User user){
		
		super("Jeopardy Menu");
		loggedInUser = user;
		numberOfTeams = -1;
		haveValidFile = false;
		haveValidNetworkedFile = false;
		gameData = new GameData();
		serverGameData = new ServerGameData();
		teamNameTextFields = new ArrayList<>(4);
		teamNameLabels = new ArrayList<>(4);

		initializeComponents();
		createGUI();
		addListeners();
	}
	
	//private methods
	private void initializeComponents(){
		mainPanel = new JPanel(new GridLayout(4, 1));
		fileChooser = new JFileChooser();
		fileNameLabel = new JLabel("");
		logoutButton = new JButton("Logout");
		quickPlay = new JCheckBox("Quick Play?");
		
		for (int i = 0; i<MAX_NUMBER_OF_TEAMS; i++){
			teamNameTextFields.add(new JTextField());
			teamNameLabels.add(new JLabel("Please name Team "+(i+1)));
		}
		
		startGameButton = new JButton("Start Jeopardy");
		clearDataButton = new JButton("Clear Choices");
		exitButton = new JButton("Exit");
		fileChooserButton = new JButton("Choose File");
		slider = new JSlider();
		
		port = new JTextField();
		IPAddress = new JTextField();
		notNetworked = new JRadioButton("Not Networked");
		hostGame = new JRadioButton("Host Game");
		joinGame = new JRadioButton("Join Game");
		messageLabel = new JLabel();
		numberOfTeamsLabel = new JLabel("Please choose the number of teams that will be playing on the slider below.");
		chooseGameFileLabel = new JLabel("Please choose a game file.");
		fileNameLabel = new JLabel("");
	}
	
	private void createGUI(){
		//setting appearance of member variable gui components
		//setting background colors
		AppearanceSettings.setBackground(Color.darkGray, exitButton, logoutButton, clearDataButton, startGameButton, slider,
				teamNameLabels.get(0), teamNameLabels.get(1), teamNameLabels.get(2), teamNameLabels.get(3), fileChooserButton);
		
		AppearanceSettings.setBackground(AppearanceConstants.lightBlue, teamNameTextFields.get(0), teamNameTextFields.get(1), teamNameTextFields.get(2),
				teamNameTextFields.get(3));
		
		AppearanceSettings.setBackground(AppearanceConstants.darkBlue, fileNameLabel, mainPanel);
	
		//setting fonts
		AppearanceSettings.setFont(AppearanceConstants.fontSmall, teamNameTextFields.get(0), teamNameTextFields.get(1), teamNameTextFields.get(2), teamNameTextFields.get(3),
				teamNameLabels.get(0), teamNameLabels.get(1), teamNameLabels.get(2), teamNameLabels.get(3), 
				fileChooserButton, fileNameLabel, exitButton, clearDataButton, logoutButton, startGameButton,
				hostGame, notNetworked, joinGame, IPAddress, port, messageLabel);
		
		//other
		AppearanceSettings.setForeground(Color.lightGray, exitButton, logoutButton, clearDataButton, startGameButton,
				teamNameLabels.get(0), teamNameLabels.get(1), teamNameLabels.get(2), teamNameLabels.get(3), fileChooserButton,
				fileNameLabel, slider, messageLabel);

		AppearanceSettings.setOpaque(exitButton, clearDataButton, logoutButton, startGameButton, slider,
				teamNameLabels.get(0), teamNameLabels.get(1), teamNameLabels.get(2), teamNameLabels.get(3), fileChooserButton);

		AppearanceSettings.setSize(180, 70, exitButton, clearDataButton, startGameButton, logoutButton);
		AppearanceSettings.setSize(150, 80, 
				teamNameTextFields.get(0), teamNameTextFields.get(1), teamNameTextFields.get(2), teamNameTextFields.get(3));
		
		AppearanceSettings.setSize(250, 100, teamNameLabels.get(0), teamNameLabels.get(1), teamNameLabels.get(2), teamNameLabels.get(3));
		
		AppearanceSettings.unSetBorderOnButtons(exitButton, logoutButton, clearDataButton, startGameButton, fileChooserButton);
		AppearanceSettings.setSize(250, 50, IPAddress, port);
		AppearanceSettings.setTextAlignment(messageLabel, teamNameLabels.get(0), teamNameLabels.get(1), teamNameLabels.get(2), teamNameLabels.get(3),
				fileNameLabel);

		setAllInvisible(teamNameTextFields, teamNameLabels);
		//check box settings
		quickPlay.setFont(AppearanceConstants.fontSmallest);
		quickPlay.setHorizontalTextPosition(SwingConstants.LEFT);
		quickPlay.setPreferredSize(new Dimension(200, 30));
		
		//file chooser settings
		fileChooser.setPreferredSize(new Dimension(400, 500));
		fileChooser.setCurrentDirectory(new File(System.getProperty("user.dir")));
		fileChooser.setFileFilter(new FileNameExtensionFilter("TEXT FILES", "txt", "text"));
		
		//slider settings
		AppearanceSettings.setSliders(1, MAX_NUMBER_OF_TEAMS, 1, 1, AppearanceConstants.fontSmallest, slider);
		slider.setSnapToTicks(true);
		slider.setPreferredSize(new Dimension(500, 50));
		startGameButton.setEnabled(false);
		
		notNetworked.setSelected(true);
		AppearanceSettings.setVisible(false, port, IPAddress);

		createMainPanel();
		
		setBackground(AppearanceConstants.darkBlue);
		add(mainPanel, BorderLayout.CENTER);
		setSize(800, 825);
	}
	
	//sets the label and textField visible again
	private void setVisible(JLabel label, JTextField textField){
		//the first text field is always shown so we can use their border 
		Border border = teamNameTextFields.get(0).getBorder();
		
		textField.setBackground(AppearanceConstants.lightBlue);
		textField.setForeground(Color.black);
		textField.setBorder(border);

		label.setBackground(Color.darkGray);
		label.setForeground(Color.lightGray);
	}
	//I wanted to user BoxLayout for resizability but if you simply set a components invisble with
		// setVisible(false), it changes the size of the components that are visible. This is my way aroung that
	private void setInvisible(JLabel label, JTextField textField){
		AppearanceSettings.setBackground(AppearanceConstants.darkBlue, textField, label);
		AppearanceSettings.setForeground(AppearanceConstants.darkBlue, textField, label);
		textField.setBorder(AppearanceConstants.blueLineBorder);
	}
	//used in the constructor to set everything invisible (except the first label and text field)
	private void setAllInvisible(List<JTextField> teamNameTextFields, List<JLabel> teamNameLabels){
		
		for (int i = 1; i<4; i++) setInvisible(teamNameLabels.get(i), teamNameTextFields.get(i));
	}
	
	private void createMainPanel(){
		//initialize local panels
		JPanel teamNamesPanel = new JPanel();
		JPanel teamLabelsPanel1 = new JPanel();
		JPanel teamLabelsPanel2 = new JPanel();
		JPanel teamTextFieldsPanel1 = new JPanel();
		JPanel teamTextFieldsPanel2 = new JPanel();
		JPanel buttonPanel = new JPanel();
		JPanel teamsAndFilePanel = new JPanel(new GridLayout(3, 1));
		JPanel numberOfTeamsPanel = new JPanel();
		JPanel fileChooserPanel = new JPanel();
		JPanel northPanel = new JPanel();
		JPanel welcomePanel = new JPanel(new BorderLayout());
		JPanel titlePanel = new JPanel(new GridLayout(3, 1));
		//initialize labels
		JLabel welcomeLabel = new JLabel("Welcome to Jeopardy!");
		JLabel explainContentLabel = new JLabel("Choose whether you are joining or hosting a game or playing not-networked.");
		ButtonGroup buttonGroup = new ButtonGroup();
		JPanel radioButtonPanel = new JPanel();
		JPanel networkingPanel = new JPanel();
		JPanel messagePanel = new JPanel();
		JPanel buttonsAndMessagePanel = new JPanel(new GridLayout(2,1 ));

		//set appearances on local variables
		AppearanceSettings.setBackground(AppearanceConstants.lightBlue, radioButtonPanel, welcomeLabel, explainContentLabel, welcomePanel, titlePanel);
		AppearanceSettings.setFont(AppearanceConstants.fontSmall, explainContentLabel, chooseGameFileLabel, numberOfTeamsLabel);
		AppearanceSettings.setTextAlignment(welcomeLabel, explainContentLabel, chooseGameFileLabel, numberOfTeamsLabel);
		
		AppearanceSettings.setBackground(AppearanceConstants.darkBlue, networkingPanel, chooseGameFileLabel, numberOfTeamsLabel, numberOfTeamsPanel, fileChooserPanel, teamsAndFilePanel,
				buttonPanel, teamNamesPanel, teamLabelsPanel1, teamLabelsPanel2, teamTextFieldsPanel1, teamTextFieldsPanel2,messagePanel, buttonPanel, messageLabel);
		AppearanceSettings.setForeground(Color.lightGray, chooseGameFileLabel, numberOfTeamsLabel);
		
		AppearanceSettings.setSize(800, 60, welcomePanel, explainContentLabel);
		AppearanceSettings.setSize(800, 100, buttonPanel, numberOfTeamsPanel);
		AppearanceSettings.setSize(800, 80, fileChooserPanel);
		
		welcomeLabel.setFont(AppearanceConstants.fontLarge);
		numberOfTeamsLabel.setSize(700, 60);

		//setting box layouts of panels
		AppearanceSettings.setBoxLayout(BoxLayout.LINE_AXIS, radioButtonPanel, buttonPanel, fileChooserPanel, teamLabelsPanel1, teamLabelsPanel2, teamTextFieldsPanel1, teamTextFieldsPanel2);
		AppearanceSettings.setBoxLayout(BoxLayout.PAGE_AXIS, northPanel, teamNamesPanel, numberOfTeamsPanel);

		//method iterates through components and add glue after each one is added, bool indicates whether glue should be added at the initially as well
		AppearanceSettings.addGlue(teamLabelsPanel1, BoxLayout.LINE_AXIS, true, teamNameLabels.get(0), teamNameLabels.get(1));
		AppearanceSettings.addGlue(teamLabelsPanel2, BoxLayout.LINE_AXIS, true, teamNameLabels.get(2), teamNameLabels.get(3));
		AppearanceSettings.addGlue(teamTextFieldsPanel1, BoxLayout.LINE_AXIS, true, teamNameTextFields.get(0), teamNameTextFields.get(1));
		AppearanceSettings.addGlue(teamTextFieldsPanel2, BoxLayout.LINE_AXIS, true, teamNameTextFields.get(2), teamNameTextFields.get(3));
		AppearanceSettings.addGlue(teamNamesPanel, BoxLayout.PAGE_AXIS, true, teamLabelsPanel1, teamTextFieldsPanel1, teamLabelsPanel2, teamTextFieldsPanel2);
		
		//don't want to pass in fileNameLabel since I don't want glue after it
		AppearanceSettings.addGlue(fileChooserPanel, BoxLayout.LINE_AXIS, true, chooseGameFileLabel, fileChooserButton);
		fileChooserPanel.add(fileNameLabel);
		
		AppearanceSettings.addGlue(radioButtonPanel, BoxLayout.LINE_AXIS, true, notNetworked, hostGame, joinGame);

		networkingPanel.add(port);
		networkingPanel.add(IPAddress);
		
		teamsAndFilePanel.add(networkingPanel);
		teamsAndFilePanel.add(numberOfTeamsPanel);
		teamsAndFilePanel.add(fileChooserPanel);
		
		buttonGroup.add(hostGame);
		buttonGroup.add(joinGame);
		buttonGroup.add(notNetworked);
		
		AppearanceSettings.addGlue(buttonPanel, BoxLayout.LINE_AXIS, true, startGameButton, clearDataButton, logoutButton, exitButton);
		
		//add other components to other containers
		welcomePanel.add(welcomeLabel, BorderLayout.CENTER);
		welcomePanel.add(quickPlay, BorderLayout.EAST);

		titlePanel.add(welcomePanel);
		titlePanel.add(explainContentLabel);
		titlePanel.add(radioButtonPanel);
		
		northPanel.add(titlePanel);
		
		numberOfTeamsPanel.add(numberOfTeamsLabel);
		numberOfTeamsPanel.add(slider);
		
		messagePanel.add(messageLabel);
		
		buttonsAndMessagePanel.add(messagePanel);
		buttonsAndMessagePanel.add(buttonPanel);
		
		mainPanel.add(northPanel);
		mainPanel.add(teamsAndFilePanel);
		mainPanel.add(teamNamesPanel);
		mainPanel.add(buttonsAndMessagePanel);
	}
	
	//determines whether the chosen file is valid
	private void setHaveValidFile(File file, GameData gameData){
		
		//if they had already chosen a valid file, but want to replace it, need to clear stored data
		//figure out whether we are working with the networked file
		Boolean haveFile = (hostGame.isSelected()) ? haveValidNetworkedFile : haveValidFile;
		if (haveFile) gameData.clearData();
	
		try{
			//try parsing this file; the parseFile method could throw an exception here, in which case we know it was invalid
			gameData.parseFile(file.getAbsolutePath(), file.getName());
			//set either the networked or not networked valid file boolean
			if (hostGame.isSelected()) haveValidNetworkedFile = true;
			else haveValidFile = true;
			
			setFileNameLabel(gameData, file.getName());
			//check if the user can start the game
			startGameButton.setEnabled(ready());
		}
		
		catch (Exception e){
			//set either the networked or not networked valid file boolean
			if (hostGame.isSelected()) haveValidNetworkedFile = false;
			else haveValidFile = false;
			
			startGameButton.setEnabled(false);
			fileNameLabel.setText("");
			//pop up with error message
			JOptionPane.showMessageDialog(this,
					e.getMessage(),
					"File Reading Error",
					JOptionPane.ERROR_MESSAGE);
		}
	}
	
	private void setFileNameLabel(GameData gameData, String fileName){
		if (gameData.getGameFile().getNumberOfRatings() == -1) fileNameLabel.setText(fileName + "    no rating");

		else fileNameLabel.setText(fileName + "    average rating: "+gameData.getGameFile().getAverageRating()+"/5");
	}
	
	//returns whether the start button can be enabled depending on the radio button selection
	private boolean ready(){
		
		if (notNetworked.isSelected()){
			if (!haveValidFile) return false;
			//check to see if all relevant text fields have text in them
			for (int i = 0; i<slider.getValue(); i++){
				if (teamNameTextFields.get(i).getText().isEmpty()) return false;
			}
			return true;
		}
		
		else {
			Boolean isReady =  (!port.getText().isEmpty() && !port.getText().equals("port") && 
					!teamNameTextFields.get(0).getText().isEmpty());
			
			if (joinGame.isSelected()){
				return isReady && (!IPAddress.getText().isEmpty() && !IPAddress.getText().equals("IP Address"));
			}
			
			return isReady && haveValidNetworkedFile;
		}

	}
	
	public void updateNetworkMessage(int numTeamsNeeded){
		messageLabel.setText("We are waiting for "+numTeamsNeeded+" to join");
	}
	
	//reset the fields if the host cancelled the game
	public void gameCancelled(){
		messageLabel.setText("So sorry, the host cancelled! Please choose another game to join");
		port.setText("port");
		IPAddress.setText("IPAddress");
		AppearanceSettings.setForeground(Color.gray, port, IPAddress);
		AppearanceSettings.setEnabled(true, startGameButton, port, IPAddress, teamNameTextFields.get(0), clearDataButton, notNetworked, hostGame, joinGame, fileChooserButton); 
	}
	
	private void addListeners(){
		
		setDefaultCloseOperation(DO_NOTHING_ON_CLOSE);
		addWindowListener(new ExitWindowListener(this));
		port.addFocusListener(new TextFieldFocusListener("port", port));
		IPAddress.addFocusListener(new TextFieldFocusListener("IP Address", IPAddress));
		port.getDocument().addDocumentListener(new MyDocumentListener());
		IPAddress.getDocument().addDocumentListener(new MyDocumentListener());
		
		//adding a document listener to each text field. This will allow us to determine if the user has entered team names
		for (int i = 0; i<MAX_NUMBER_OF_TEAMS; i++){
			teamNameTextFields.get(i).getDocument().addDocumentListener(new MyDocumentListener());
		}
		
		fileChooserButton.addActionListener(new ActionListener(){

			@Override
			public void actionPerformed(ActionEvent e) {
				fileChooser.showOpenDialog(StartWindowGUI.this);
				File file = fileChooser.getSelectedFile();
				
				
				if (file != null) {
					//parse the file depending on the radio button selection
					if (notNetworked.isSelected()) setHaveValidFile(file, gameData);
					else setHaveValidFile(file, serverGameData);
				}
			}
			
		});
		
		slider.addChangeListener(new ChangeListener(){

			@Override
			public void stateChanged(ChangeEvent e) {
				//sets appropriate text fields and labels invisible
				if (notNetworked.isSelected()){
					for (int i = slider.getValue(); i<MAX_NUMBER_OF_TEAMS; i++){
						setInvisible(teamNameLabels.get(i), teamNameTextFields.get(i));
					}
					//sets appropriate text fields and labels visible
					for (int i = 0; i<slider.getValue(); i++){
						setVisible(teamNameLabels.get(i), teamNameTextFields.get(i));
					}
					//check if the user can start the game
					startGameButton.setEnabled(ready());
				}
			}
			
		});
		
		startGameButton.addActionListener(new ActionListener(){

			@Override
			public void actionPerformed(ActionEvent e) {
				
				if (notNetworked.isSelected()){
					numberOfTeams = slider.getValue();
					List<String> teamNames = new ArrayList<>(numberOfTeams);
					//getting the text in each of the visible text fields and storing them in a list
					for (int i = 0; i< numberOfTeams; i++) {
						teamNames.add(teamNameTextFields.get(i).getText());
					}
					
					gameData.setNumberOfQuestions(quickPlay.isSelected() ? 5 : 25);
					gameData.setTeams(teamNames, numberOfTeams);
					new MainGUI(gameData).setVisible(true);
					dispose();
				}
				else {
					//disable components
					AppearanceSettings.setEnabled(false, startGameButton, quickPlay, clearDataButton, joinGame, port, IPAddress, teamNameTextFields.get(0), hostGame, notNetworked, fileChooserButton);
					
					if (hostGame.isSelected()){
						messageLabel.setText("Waiting for "+ (slider.getValue() - 1)+" to join");
						serverGameData.setNumberOfQuestions(quickPlay.isSelected() ? 5 : 25);
						serverGameData.setNumberOfTeams(slider.getValue());
						//create a server and corresponding client
						new HostServer(serverGameData, port.getText(), slider.getValue(), StartWindowGUI.this);
						client = new Client(port.getText(), "localhost", teamNameTextFields.get(0).getText(), StartWindowGUI.this, true, loggedInUser);
					}
					else{
						client = new Client(port.getText(), IPAddress.getText(), teamNameTextFields.get(0).getText(), StartWindowGUI.this, false, loggedInUser);
					}
					
				}
				
			}
			
		});
		
		exitButton.addActionListener(new ActionListener(){

			@Override
			public void actionPerformed(ActionEvent e) {
				if (client != null) client.close();
				dispose();
				System.exit(0);
			}
			
		});
		
		clearDataButton.addActionListener(new ActionListener(){

			//reseting all data
			@Override
			public void actionPerformed(ActionEvent e) {
				haveValidFile = false;
				haveValidNetworkedFile = false;
				serverGameData.clearData();
				gameData.clearData();
				notNetworked.setSelected(true);
				quickPlay.setSelected(false);
				//start index at 1, we still was to show the 0th elements (team 1)
				for (int i = 1; i<MAX_NUMBER_OF_TEAMS; i++){
					setInvisible(teamNameLabels.get(i), teamNameTextFields.get(i));
					teamNameTextFields.get(i).setText("");
				}
				
				notNetworkedSelected(false);
				teamNameTextFields.get(0).setText("");
				slider.setValue(1);
				fileNameLabel.setText("");
			}
			
		});
		
		logoutButton.addActionListener(new ActionListener(){

			@Override
			public void actionPerformed(ActionEvent e) {
				if (client != null) client.close();
				new LoginGUI().setVisible(true);
				dispose();
			}
			
		});
		
		notNetworked.addActionListener(new ActionListener(){

			@Override
			public void actionPerformed(ActionEvent e) {
				notNetworkedSelected(ready());
				if (haveValidFile) setFileNameLabel(gameData, gameData.getFileName());
				else fileNameLabel.setText("");
			}
			
		});
		
		hostGame.addActionListener(new ActionListener(){

			@Override
			public void actionPerformed(ActionEvent e) {
				netWorkingSelected();
			}
			
		});
		
		joinGame.addActionListener(new ActionListener(){
			
			@Override
			public void actionPerformed(ActionEvent e) {
				netWorkingSelected();
			}
		});
		
		
	}
	
	private void notNetworkedSelected(Boolean startGame){
		AppearanceSettings.setVisible(false, port, IPAddress);
		AppearanceSettings.setVisible(true, slider, numberOfTeamsLabel, fileNameLabel, chooseGameFileLabel, fileChooserButton, quickPlay);
		startGameButton.setText("Start Game");
		startGameButton.setEnabled(startGame);
		teamNameTextFields.get(0).setText("");
		teamNameLabels.get(0).setText("Please name Team 1");
		slider.setMinimum(1);
		slider.setValue(1);
	}
	
	private void netWorkingSelected(){
		teamNameLabels.get(0).setText("Please choose a team name");
		teamNameTextFields.get(0).setText(loggedInUser.getUsername());
		setAllInvisible(teamNameTextFields, teamNameLabels);
		
		if (hostGame.isSelected()){
			AppearanceSettings.setVisible(false, IPAddress);
			AppearanceSettings.setVisible(true, slider, port, quickPlay, numberOfTeamsLabel, fileNameLabel, chooseGameFileLabel, fileChooserButton);

			if (haveValidNetworkedFile) setFileNameLabel(serverGameData, serverGameData.getFileName());
			else fileNameLabel.setText("");
			startGameButton.setText("Start Game");
			slider.setMinimum(2);

		}
		else{
			AppearanceSettings.setVisible(true, IPAddress, port);
			AppearanceSettings.setVisible(false, slider, quickPlay, numberOfTeamsLabel, fileNameLabel, chooseGameFileLabel, fileChooserButton);
			startGameButton.setText("Join Game");
		}
		startGameButton.setEnabled(ready());
	}
	
	//document listener; in each method, simply checking whether the user can start the game
	private class MyDocumentListener implements DocumentListener{
		
		@Override
		public void insertUpdate(DocumentEvent e) {
			startGameButton.setEnabled(ready());
		}

		@Override
		public void removeUpdate(DocumentEvent e) {
			startGameButton.setEnabled(ready());
		}

		@Override
		public void changedUpdate(DocumentEvent e) {
			startGameButton.setEnabled(ready());
		}
	}
}
