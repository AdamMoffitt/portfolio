package frames;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.GridLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.Map;
import javax.swing.BorderFactory;
import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.ScrollPaneConstants;
import game_logic.Category;
import game_logic.GameData;
import game_logic.User;
import listeners.ExitWindowListener;
import other_gui.AppearanceConstants;
import other_gui.AppearanceSettings;
import other_gui.QuestionGUIElement;
import other_gui.TeamGUIComponents;

public class MainGUI extends JFrame {

	private JPanel mainPanel;
	private JPanel currentPanel;

	private JPanel questionsPanel;
	protected GameData gameData;
	protected JButton[][] questionButtons;

	protected static final int QUESTIONS_LENGTH_AND_WIDTH = 5;

	protected JTextArea updatesTextArea;
	protected JMenuBar menuBar;
	protected JMenu menu;

	protected JMenuItem logoutButton;
	protected JMenuItem exitButton;
	protected JMenuItem restartThisGameButton;
	protected JMenuItem chooseNewGameFileButton;
	//in case we need to know which user is logged in
	protected User loggedInUser;

	protected JPanel jeopardyPanel;

	public MainGUI(GameData gameData) {
		super("Jeopardy!!");
		System.out.println("main gui constructor");
		make(gameData);
	}
	//called from constructor of MainGUINetworked
	public MainGUI(User loggedInUser){
		super("Jeopardy!!  "+loggedInUser.getUsername());
		System.out.println("main gui constructor called from networked");
	}

	//move constructor logic to a protected method so MainGUINetworked can call it
	protected void make(GameData gameData){
		this.gameData = gameData;
		System.out.println("make main gui");
		initializeComponents();
		createGUI();
		addListeners();
	}

	// public methods
	public void addUpdate(String update) {
		updatesTextArea.append("\n" + update);
	}

	// this method changes the current panel to the provided panel
	public void changePanel(JPanel panel) {
		setTitle("Jeopardy!! " + gameData.getCurrentTeam().getTeamName());
		remove(currentPanel);
		currentPanel = panel;
		add(currentPanel, BorderLayout.CENTER);
		// must repaint or the change won't show
		repaint();
		revalidate();
	}

	public void showMainPanel() {
		changePanel(mainPanel);
	}

	// private methods
	private void initializeComponents() {
		mainPanel = new JPanel();
		currentPanel = mainPanel;
		exitButton = new JMenuItem("Exit Game");
		restartThisGameButton = new JMenuItem("Restart This Game");
		chooseNewGameFileButton = new JMenuItem("Choose New Game File");
		logoutButton = new JMenuItem("Logout");
		updatesTextArea = new JTextArea("Welcome to Jeopardy!");
		menu = new JMenu("Menu");
		questionButtons = new JButton[QUESTIONS_LENGTH_AND_WIDTH][QUESTIONS_LENGTH_AND_WIDTH];
		menuBar = new JMenuBar();
		questionsPanel = new JPanel(new GridLayout(QUESTIONS_LENGTH_AND_WIDTH, QUESTIONS_LENGTH_AND_WIDTH));
	}

	private void createGUI() {

		createMenu();
		createMainPanel();

		add(mainPanel, BorderLayout.CENTER);
		add(createProgressPanel(), BorderLayout.EAST);
		setSize(1500, 825);
	}

	// creating the JMenuBar
	protected void createMenu() {

		menu.add(restartThisGameButton);
		menu.add(chooseNewGameFileButton);
		menu.add(logoutButton);
		menu.add(exitButton);
		menuBar.add(menu);
		setJMenuBar(menuBar);
	}

	// creating the main panel (the game board)
	private void createMainPanel() {
		mainPanel.setLayout(new BorderLayout());

		// getting the panel that holds the 'jeopardy' label
		jeopardyPanel = createJeopardyPanel();
		// getting the cateogries panel
		JPanel categoriesPanel = createCategoriesAndQuestionsPanels();
		JPanel northPanel = new JPanel();

		northPanel.setLayout(new BorderLayout());
		northPanel.add(jeopardyPanel, BorderLayout.NORTH);
		northPanel.add(categoriesPanel, BorderLayout.SOUTH);

		mainPanel.add(northPanel, BorderLayout.NORTH);
		mainPanel.add(questionsPanel, BorderLayout.CENTER);
	}

	// creates the panel with the jeopardy label
	private JPanel createJeopardyPanel() {
		jeopardyPanel = new JPanel();
		JLabel jeopardyLabel = new JLabel("Jeopardy ");

		AppearanceSettings.setBackground(AppearanceConstants.lightBlue, jeopardyPanel, jeopardyLabel);
		jeopardyLabel.setFont(AppearanceConstants.fontLarge);
		jeopardyPanel.add(jeopardyLabel);

		return jeopardyPanel;
	}

	//we want to override this in MainGUINetworked which is why I pulled the logic out into its own method
	protected void populateQuestionButtons(){
		// place the question buttons in the proper indices in 'questionButtons'
		for (QuestionGUIElement question : gameData.getQuestions()) {

			// adding action listeners to the question
			question.addActionListeners(this, gameData);
			questionButtons[question.getX()][question.getY()] = question.getGameBoardButton();
		}

	}

	// creates both the categories panel and the questions panel
	private JPanel createCategoriesAndQuestionsPanels() {
		JPanel categoriesPanel = new JPanel(new GridLayout(1, QUESTIONS_LENGTH_AND_WIDTH));
		AppearanceSettings.setBackground(Color.darkGray, categoriesPanel, questionsPanel);

		Map<String, Category> categories = gameData.getCategories();
		JLabel[] categoryLabels = new JLabel[QUESTIONS_LENGTH_AND_WIDTH];

		// iterate through the map of categories, and place them in the correct index
		for (Map.Entry<String, Category> category : categories.entrySet()) {
			categoryLabels[category.getValue().getIndex()] = category.getValue().getCategoryLabel();
		}

		populateQuestionButtons();
		// actually adding the categories and questions into their respective panels
		for (int i = 0; i < QUESTIONS_LENGTH_AND_WIDTH; i++) {

			categoryLabels[i].setPreferredSize(new Dimension(100, 70));
			categoryLabels[i].setIcon(Category.getIcon());
			categoriesPanel.add(categoryLabels[i]);

			for (int j = 0; j < QUESTIONS_LENGTH_AND_WIDTH; j++) {
				// have to use opposite indices because of how GridLayout adds components
				questionsPanel.add(questionButtons[j][i]);
			}
		}

		return categoriesPanel;
	}

	// creates the panel with the team points, and the Game Progress area
	protected JPanel createProgressPanel() {
		// create panels
		JPanel pointsPanel = new JPanel(new GridLayout(gameData.getNumberOfTeams(), 3));
		JPanel southEastPanel = new JPanel(new BorderLayout());
		JPanel eastPanel = new JPanel();
		// other local variables
		JLabel updatesLabel = new JLabel("Game Progress");
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
			System.out.println(":: " +  gameData.getNumberOfTeams());
			TeamGUIComponents team = gameData.getTeamDataList().get(i);
			pointsPanel.add(team.getMainTeamNameLabel());
			pointsPanel.add(team.getTotalPointsLabel());
		}

		eastPanel.add(pointsPanel);
		eastPanel.add(southEastPanel);

		return eastPanel;
	}

	public void resetGame(){
		updatesTextArea.setText("Game has been restarted.");
		gameData.restartGame();
		// reset all data
		// repaint the board to show updated data
		showMainPanel();
		addUpdate("The team to go first will be " + gameData.getCurrentTeam().getTeamName());
	}
	// adding even listeners, made this protected so MainGUINetworked can override it
	protected void addListeners() {

		setDefaultCloseOperation(DO_NOTHING_ON_CLOSE);
		//add window listener
		addWindowListener(new ExitWindowListener(this));
		//add action listeners
		exitButton.addActionListener(new ActionListener() {

			@Override
			public void actionPerformed(ActionEvent e) {
				dispose();
				System.exit(0);
			}

		});

		restartThisGameButton.addActionListener(new ActionListener() {

			@Override
			public void actionPerformed(ActionEvent e) {
				resetGame();
			}

		});

		chooseNewGameFileButton.addActionListener(new ActionListener() {

			@Override
			public void actionPerformed(ActionEvent e) {
				dispose();
				new StartWindowGUI(loggedInUser).setVisible(true);
			}

		});

		logoutButton.addActionListener(new ActionListener(){

			@Override
			public void actionPerformed(ActionEvent e) {
				dispose();
				new LoginGUI().setVisible(true);
			}

		});

	}
	public GameData getGameData() {
		return gameData;
	}
	public void setGameData(GameData gameData) {
		this.gameData = gameData;
	}
	public User getLoggedInUser() {
		return loggedInUser;
	}
	public void setLoggedInUser(User loggedInUser) {
		this.loggedInUser = loggedInUser;
	}


}
