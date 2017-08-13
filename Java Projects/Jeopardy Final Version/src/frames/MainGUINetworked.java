package frames;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.GridLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.Vector;

import javax.swing.BorderFactory;
import javax.swing.BoxLayout;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.ScrollPaneConstants;
import javax.swing.Timer;

import game_logic.ServerGameData;
import game_logic.User;
import listeners.NetworkedWindowListener;
import messages.PlayerLeftMessage;
import messages.RestartGameMessage;
import messages.StartTimerMainMessage;
import other_gui.AppearanceConstants;
import other_gui.AppearanceSettings;
import other_gui.FinalJeopardyGUINetworked;
import other_gui.QuestionGUIElement;
import other_gui.QuestionGUIElementNetworked;
import other_gui.TeamGUIComponents;
import other_gui.clockLabel;
import server.Client;

//used only for a networked game and inherits from MainGUI
public class MainGUINetworked extends MainGUI {

	private Client client;
	// has a networked game data
	private ServerGameData serverGameData;
	// had a networked FJ panel that I need as a memeber variable
	private FinalJeopardyGUINetworked fjGUI;
	public int timerClock;
	private Vector<clockLabel> clocks;
	private JLabel jeopardyLabelTimer;
	private Timer timer;

	public MainGUINetworked(ServerGameData gameData, Client client, User loggedInUser) {
		super(loggedInUser);
		System.out.println("main gui networked constructor");
		this.serverGameData = gameData;
		this.client = client;


		// TODO Change to i < gameData.getNumberOfTeams()
		clocks = new Vector<clockLabel>();
		int number = 4;
		if (gameData != null) {
			number = gameData.getNumberOfTeams();
		}
		for (int i = 0; i < number; i++) {
			clockLabel c = new clockLabel("");
			c.makeClock();
			clocks.addElement(c);
		}

		// calls a method in MainGUI that basically acts as a constructor
		// since you can only call the super class's constructor as the first
		// line of the child constructor,
		// but I need to have serverGameData initialized before I can cosntruct
		// my GUI, this is the solution
		make(gameData);

		initializeNetworked();
	}

	public void initializeNetworked() {

		jeopardyLabelTimer = new JLabel(":" + Integer.toString(15));
		jeopardyPanel.add(jeopardyLabelTimer);
		startTimer();
		client.sendMessage(new StartTimerMainMessage());
		startProgressClock();

	}

	public void restartTimer(){
		System.out.println("restart main timer");
		timerClock = 15;
		timer.stop();
		timer.start();
	}

	public void stopTimer(){
		timer.stop();
		timerClock = 15;
	}

	public void startTimer(){
		timerClock = 15;
		timer = new Timer(1000, new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent e) {
				if (timerClock > 0) {
					timerClock--;
				}
				jeopardyLabelTimer.setText(":" + Integer.toString(timerClock));
				if (timerClock <= 0) {
					// TODO go to next player
					System.out.println("change team in main gui - didnt choose question");
					updatesTextArea.append("\n" + gameData.getCurrentTeam().getTeamName() + " didn't choose a question in time\n");
					gameData.nextTurn();
					updatesTextArea.append("Now it is " + gameData.getCurrentTeam().getTeamName() + "'s turn");
					showMainPanel();
					restartTimer();
					//client.sendMessage(new NextTurnMessage());
				}
				repaint();
				revalidate();
			}
		});
		timer.start();
	}

	public void startProgressClock(){
		Timer spc = new Timer(1000, new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent e) {
				updateClocks();
				repaint();
				revalidate();
			}
		});
		spc.start();
	}

	public void updateClocks() {
		for (int i = 0; i < clocks.size(); i++) {
			clocks.get(i).update();
		}
		revalidate();
		repaint();
	}

	@Override
	protected JPanel createProgressPanel() {
		// create panels
		JPanel pointsPanel = new JPanel(new GridLayout(gameData.getNumberOfTeams(), 3));
		JPanel southEastPanel = new JPanel(new BorderLayout());
		JPanel eastPanel = new JPanel();
		// other local variables
		JLabel updatesLabel = new JLabel("Game Progress: " + gameData.getTeam(client.getTeamIndex()).getTeamName());
		JScrollPane updatesScrollPane = new JScrollPane(updatesTextArea, ScrollPaneConstants.VERTICAL_SCROLLBAR_ALWAYS,
				ScrollPaneConstants.HORIZONTAL_SCROLLBAR_NEVER);
		// setting appearances
		AppearanceSettings.setBackground(AppearanceConstants.lightBlue, southEastPanel, updatesLabel, updatesScrollPane,
				updatesTextArea);
		AppearanceSettings.setSize(400, 400, pointsPanel, updatesScrollPane);
		AppearanceSettings.setTextComponents(updatesTextArea);

		updatesLabel.setFont(AppearanceConstants.fontLarge);
		pointsPanel.setBackground(Color.darkGray);
		updatesLabel.setBorder(BorderFactory.createLineBorder(Color.darkGray));
		updatesScrollPane.setBorder(null);

		updatesTextArea.setText("Welcome to Jeopardy!");
		updatesTextArea.setFont(AppearanceConstants.fontSmall);
		updatesTextArea.append("The team to go first will be " + gameData.getCurrentTeam().getTeamName());

		eastPanel.setLayout(new BoxLayout(eastPanel, BoxLayout.PAGE_AXIS));
		// adding components/containers
		southEastPanel.add(updatesLabel, BorderLayout.NORTH);
		southEastPanel.add(updatesScrollPane, BorderLayout.CENTER);

		// adding team labels, which are stored in the TeamGUIComponents class,
		// to the appropriate panel
		for (int i = 0; i < gameData.getNumberOfTeams(); i++) {
			TeamGUIComponents team = gameData.getTeamDataList().get(i);
			pointsPanel.add(team.getMainTeamNameLabel());
			pointsPanel.add(team.getTotalPointsLabel());
			if (clocks != null) {
				System.out.println("adding clocks: " + i);
				pointsPanel.add(clocks.get(i));
				if (gameData.getCurrentTeam().getTeamIndex() == i) {
					System.out.println("HELLO");
					clocks.get(i).setVisible(true);
				} else {
					System.out.println("YELLO");
					clocks.get(i).setVisible(false);
				}
			}
		}

		eastPanel.add(pointsPanel);
		eastPanel.add(southEastPanel);

		return eastPanel;
	}

	public void hideClocks() {
		for (int i = 0; i < clocks.size(); i++) {
			clocks.get(i).setVisible(false);
		}
	}

	public void showClocks() {
		for (int i = 0; i < gameData.getNumberOfTeams(); i++) {
			if (clocks != null) {
				if (gameData.getCurrentTeam().getTeamIndex() == i) {
					clocks.get(i).setVisible(true);
				} else {
					clocks.get(i).setVisible(false);
				}
			}
		}
	}

	//takes in int parameter of team to show clock by
	public void showClocks(int team) {
		for (int i = 0; i < gameData.getNumberOfTeams(); i++) {
			if (clocks != null) {
				if (team == i) {
					clocks.get(i).setVisible(true);
				} else {
					clocks.get(i).setVisible(false);
				}
			}
		}
	}

	public FinalJeopardyGUINetworked getFJGUI() {
		return fjGUI;
	}

	// disables all enabled buttons to have enabled icon
	public void disableAllButtons() {
		for (QuestionGUIElement question : gameData.getQuestions()) {
			if (!question.isAsked()) {
				question.getGameBoardButton().setDisabledIcon(QuestionGUIElement.getEnabledIcon());
				question.getGameBoardButton().setEnabled(false);
			}
		}
	}

	// enables all questions that have not been chosen
	public void enableAllButtons() {
		for (QuestionGUIElement question : gameData.getQuestions()) {
			if (!question.isAsked()) {
				question.getGameBoardButton().setIcon(QuestionGUIElement.getEnabledIcon());
				question.getGameBoardButton().setEnabled(true);
			}
		}
	}

	// depending on whether the current team is same at the client's team index,
	// we enable or disable all buttons
	// override showMainPanel from super class in order to always check if we
	// should enable.disbale buttons
	@Override
	public void showMainPanel() {
		System.out.println("show main panel");
		if (gameData.getCurrentTeam().getTeamIndex() != client.getTeamIndex())
			disableAllButtons();

		else
			enableAllButtons();

		super.showMainPanel();
	}

	// override from super class; only add the restart option if the client is
	// the host
	@Override
	protected void createMenu() {

		if (client.isHost()) {
			menu.add(restartThisGameButton);
		}

		menu.add(chooseNewGameFileButton);
		menu.add(logoutButton);
		menu.add(exitButton);
		menuBar.add(menu);
		setJMenuBar(menuBar);
	}

	// in the non networked game, this logic happens in the AnsweringLogic class
	// in the QuestionGUIElement
	// but we need to be able to call this from QuestionAnsweredAction class
	public void startFinalJeopardy() {
		gameData.disableRemainingButtons();
		addUpdate("It's time for Final Jeopardy!");
		gameData.determineFinalists();
		// if no one made it show the main panel and show the rating window
		if (gameData.getFinalistsAndEliminatedTeams().getFinalists().size() == 0) {
			showMainPanel();
			new WinnersAndRatingGUINetworked(serverGameData, this, client, true).setVisible(true);
		} else {
			// if this client did not make it to FJ, show the rating window
			if (gameData.getFinalistsAndEliminatedTeams().getElimindatedTeamsIndices()
					.contains(client.getTeamIndex())) {
				showMainPanel();
				client.setElimindated(true);
				new WinnersAndRatingGUINetworked(serverGameData, this, client, false).setVisible(true);
			}
			// create and store a networked fjpanel and switch to it
			else {
				fjGUI = new FinalJeopardyGUINetworked(serverGameData, this, client);
				changePanel(fjGUI);
			}
		}

	}

	// sets the bet for the provided team with the provided bet amount, called
	// from SetBetAction class
	public void setBet(int team, int bet) {
		TeamGUIComponents teamData = serverGameData.getTeam(team);
		teamData.setBet(bet);
		fjGUI.updateTeamBet(teamData);
	}

	// since we serialize over the gameData with all GUI objects transient, we
	// need to repopulate them on the client side
	// we override this from the super class in order to add different action
	// listeners to the question object
	// and so we can iterate over the networked questions instead
	@Override
	protected void populateQuestionButtons() {
		for (int x = 0; x < QUESTIONS_LENGTH_AND_WIDTH; x++) {
			for (int y = 0; y < QUESTIONS_LENGTH_AND_WIDTH; y++) {
				QuestionGUIElementNetworked question = serverGameData.getNetworkedQuestions()[x][y];
				question.setClient(client, gameData.getNumberOfTeams());
				question.addActionListeners(this, serverGameData);
				questionButtons[question.getX()][question.getY()] = question.getGameBoardButton();
			}
		}

	}

	// adding event listeners, override from MainGUI
	@Override
	protected void addListeners() {

		setDefaultCloseOperation(DO_NOTHING_ON_CLOSE);
		// add window listener
		addWindowListener(new NetworkedWindowListener(client, MainGUINetworked.this));
		// add action listeners
		exitButton.addActionListener(new ActionListener() {

			@Override
			public void actionPerformed(ActionEvent e) {
				sendPlayerLeftMessage();
				System.exit(0);
			}
		});

		restartThisGameButton.addActionListener(new ActionListener() {

			@Override
			public void actionPerformed(ActionEvent e) {
				// choose a different team to start the game
				gameData.chooseFirstTeam();
				client.sendMessage(new RestartGameMessage(gameData.getCurrentTeam().getTeamIndex()));
			}
		});

		chooseNewGameFileButton.addActionListener(new ActionListener() {

			@Override
			public void actionPerformed(ActionEvent e) {
				sendPlayerLeftMessage();
				new StartWindowGUI(loggedInUser).setVisible(true);
			}
		});

		logoutButton.addActionListener(new ActionListener() {

			@Override
			public void actionPerformed(ActionEvent e) {
				sendPlayerLeftMessage();
				new LoginGUI();
			}
		});
	}

	private void sendPlayerLeftMessage() {
		client.sendMessage(new PlayerLeftMessage(client.getTeamIndex()));
		client.close();
		dispose();
	}
//
//	private class pointsPanelClock extends JLabel{
//
//		public ImageIcon clock;
//		public ImageIcon clock0;
//		public int clockCounter;
//		//private JLabel clockLabel;
//
//		public pointsPanelClock(){
//			System.out.println("creating clock");
//			clockCounter = 0;
//			Image temp = new ImageIcon("images/clockAnimation/frame_" + clockCounter + "_delay-0.06s.jpg").getImage();
//			clock = new ImageIcon(temp.getScaledInstance(40, 40,Image.SCALE_SMOOTH));
//			//clock0 = new ImageIcon("images/clockAnimation/frame_0_delay-0.06s.jpg");
//			this.setIcon(clock);
//		}
//
//		public void update(){
//			clockCounter = clockCounter % 142;
//	    	System.out.println("1 second " + " clockCounter: " + clockCounter);
//	    	Image temp = new ImageIcon("images/clockAnimation/frame_" + clockCounter + "_delay-0.06s.jpg").getImage();
//			clock = new ImageIcon(temp.getScaledInstance(40, 40,Image.SCALE_SMOOTH));
//			this.setIcon(clock);
//			clockCounter++;
//		}
//	}
}