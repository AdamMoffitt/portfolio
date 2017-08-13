package other_gui;

import java.awt.Image;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.HashMap;

import javax.swing.ImageIcon;
import javax.swing.Timer;

import frames.MainGUI;
import game_logic.GameData;
import messages.BuzzInMessage;
import messages.NoOneBuzzedInInTimeMessage;
import messages.QuestionAnsweredMessage;
import messages.QuestionClickedMessage;
import server.Client;

//inherits from QuestionGUIElement
public class QuestionGUIElementNetworked extends QuestionGUIElement {

	private Client client;
	// very similar variables as in the AnsweringLogic class
	public Boolean hadSecondChance;
	private TeamGUIComponents currentTeam;
	private TeamGUIComponents originalTeam;
	private int timerCounter;
	private int clockCounter;
	private int animationCounter;
	int teamIndex;
	int numTeams;
	public boolean playAnimation;
	public boolean playClock;
	private Timer startTimerTimer;
	private Timer startAnimationTimer;
	private Timer startClockTimer;
	// stores team index as the key to a Boolean indicating whether they have
	// gotten a chance to answer the question
	private HashMap<Integer, Boolean> teamHasAnswered;

	public QuestionGUIElementNetworked(String question, String answer, String category, int pointValue, int indexX,
			int indexY) {
		super(question, answer, category, pointValue, indexX, indexY);
		startTimer();
		startTimerTimer.stop();
		startClock();
		startClockTimer.stop();
		startWaitingAnimation();
		startAnimationTimer.stop();
	}

	// set the client and also set the map with the booleans to all have false
	public void setClient(Client client, int numTeams) {
		this.client = client;
		this.numTeams = numTeams;
		teamIndex = client.getTeamIndex();
		teamHasAnswered = new HashMap<>();
		for (int i = 0; i < numTeams; i++)
			teamHasAnswered.put(i, false);
	}

	// returns whether every team has had a chance at answering this question
	public Boolean questionDone() {
		Boolean questionDone = true;
		for (Boolean currentTeam : teamHasAnswered.values())
			questionDone = questionDone && currentTeam;
		return questionDone;
	}

	// overrides the addActionListeners method in super class
	@Override
	public void addActionListeners(MainGUI mainGUI, GameData gameData) {
		passButton.addActionListener(new ActionListener() {

			@Override
			public void actionPerformed(ActionEvent e) {
				// send a buzz in message
				client.sendMessage(new BuzzInMessage(teamIndex));
			}

		});

		gameBoardButton.addActionListener(new ActionListener() {

			@Override
			public void actionPerformed(ActionEvent e) {
				// send a question clicked message

				client.sendMessage(new QuestionClickedMessage(getX(), getY()));

			}
		});

		submitAnswerButton.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent e) {
				// send question answered message
				//System.out.println("submit button pressed");
				client.sendMessage(new QuestionAnsweredMessage(answerField.getText()));
			}

		});
	}

	public void restartTimer() {
		System.out.println("restart timer");
		timerCounter = 20;
		startTimerTimer.restart();
	}

	public void startTimer() {
		timerCounter = 20;
		timerLabel.setText(":" + Integer.toString(timerCounter));
		startTimerTimer = new Timer(1000, new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent e) {
				//System.out.print("@");
				if (timerCounter > 0) {
					timerCounter--;
					timerLabel.setText(":" + Integer.toString(timerCounter));
					timerLabel.revalidate();
					timerLabel.repaint();
				} else if (timerCounter <= 0) {
					System.out.println("timer ran out");
					startTimerTimer.stop();
					if(passButton.isEnabled()){ //if this is the original team, set buzz in.
						System.out.println("current team is same as original team");
						currentTeam.deductPoints(client.getCurrentQuestion().getPointValue());
						client.getMainGUI().addUpdate("Team " + currentTeam.getTeamName() + " didn't answer in time.");
						setBuzzInPeriod();
					}
					else{
						System.out.println("no one buzzed in in time!!!!");
						client.sendMessage(new NoOneBuzzedInInTimeMessage());
					}

				}
			}
		});
		startTimerTimer.start();
	}

	public void startClock() {
		//System.out.println("start clock in questionGUIElement");
		teamLabel.makeClock();
		playClock = true;
		startClockTimer = new Timer(1000, new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent e) {
				//System.out.print("$");
				teamLabel.update();
				teamLabel.revalidate();
				teamLabel.repaint();
			}
		});
		startClockTimer.start();
	}

	public void startWaitingAnimation() {
		animationCounter = 0;
		playAnimation = true;
		//System.out.println("Start ANIMATION WOOOHOOOO");
		startAnimationTimer = new Timer(30, new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent e) {
				animationCounter = animationCounter % 16 + 1;
				Image temp = new ImageIcon("images/animation_images/win_" + animationCounter + ".png").getImage();
				ImageIcon temp1 = new ImageIcon(temp.getScaledInstance(80, 80, Image.SCALE_SMOOTH));
				announcementsLabel.setIcon(temp1);
				animationCounter++;
			}
		});
		startAnimationTimer.start();
	}

	// override the resetQuestion method
	@Override
	public void resetQuestion() {
		super.resetQuestion();
		hadSecondChance = false;
		currentTeam = null;
		originalTeam = null;
		teamHasAnswered.clear();
		// reset teamHasAnswered map so all teams get a chance to anaswer again
		for (int i = 0; i < numTeams; i++)
			teamHasAnswered.put(i, false);
	}

	@Override
	public void populate() {
		super.populate();
		passButton.setText("Buzz In!");
		timerLabel.setText("20");

	}

	public int getOriginalTeam() {
		return originalTeam.getTeamIndex();
	}

	public void updateAnnouncements(String announcement) {
		announcementsLabel.setText(announcement);
	}

	public void setOriginalTeam(int team, GameData gameData) {
		originalTeam = gameData.getTeamDataList().get(team);
		updateTeam(team, gameData);
		restartTimer();
	}

	// update the current team of this question
	public void updateTeam(int team, GameData gameData) {
		currentTeam = gameData.getTeamDataList().get(team);
		passButton.setVisible(false);
		answerField.setText("");
		startTimerTimer.stop();
		startTimer();
		// if the current team is this client
		if (team == teamIndex) {
			AppearanceSettings.setEnabled(true, submitAnswerButton, answerField);
			announcementsLabel.setText("You have 20 seconds to answer the question!");
			// if your turn, no animation
			playAnimation = false;
			startAnimationTimer.stop();
			announcementsLabel.setIcon(null);
		}
		// if the current team is an opponent
		else {
			AppearanceSettings.setEnabled(false, submitAnswerButton, answerField);
			announcementsLabel.setText("It's " + currentTeam.getTeamName() + "'s turn to try to answer the question.");
			playAnimation = true;
			//System.out.println("Start animating por favor here in update team");
			// startAnimationTimer.restart();
			startAnimationTimer.stop();
			startWaitingAnimation();
		}

		// mark down that this team has had a chance to answer
		teamHasAnswered.replace(team, true);
		hadSecondChance = false;
		teamLabel.setText(currentTeam.getTeamName());
		playClock = false;
		startClockTimer.stop();
		teamLabel.setIcon(null);
	}

	// called from QuestionAnswerAction when there is an illformated answer
	public void illFormattedAnswer() {

		if (currentTeam.getTeamIndex() == teamIndex) {
			announcementsLabel.setText("You had an illformatted answer. Please try again");
		} else {
			announcementsLabel
					.setText(currentTeam.getTeamName() + " had an illformatted answer. They get to answer again.");
		}
	}

	// set the gui to be a buzz in period, also called from QuestionAnswerAction
	public void setBuzzInPeriod() {
		System.out.println("setting buzz in period");
		passButton.setVisible(true);
		// restartTimer();
		restartTimer();
		playClock = true;
		startClock();
		teamLabel.setText("");
		// startClockTimer.restart();

		playAnimation = false;
		startAnimationTimer.stop();
		announcementsLabel.setIcon(null);
		if (teamHasAnswered.get(teamIndex)) {
			AppearanceSettings.setEnabled(false, submitAnswerButton, answerField, passButton);
			announcementsLabel.setText("It's time to buzz in! But you've already had your chance..");
		} else {
			announcementsLabel.setText("Buzz in to answer the question!");
			passButton.setEnabled(true);
			AppearanceSettings.setEnabled(false, submitAnswerButton, answerField);
		}
	}

	public TeamGUIComponents getCurrentTeam() {
		return currentTeam;
	}

	public void stopTimers() {
		startTimerTimer.stop();
		startAnimationTimer.stop();
		startClockTimer.stop();
	}
}