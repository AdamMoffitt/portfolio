package frames;

import java.awt.Color;
import java.awt.Graphics;
import java.awt.Image;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.Box;
import javax.swing.BoxLayout;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;

import logic.Account;
import logic.User;
import resources.AppearanceConstants;
import resources.AppearanceSettings;

public class EndPartyWindow extends JPanel {

	private static final long serialVersionUID = 1L;
	private Account account;

	private JLabel thanksLabel;
	private JButton quitButton, joinAnotherPartyButton;
	private JPanel thanksPanel, endPartyButtonPanel;
	private SelectionWindow sw;
	private boolean endedByHost;


	public EndPartyWindow (SelectionWindow selectionWindow, boolean endedByHost){
		this.sw = selectionWindow;
		this.account = selectionWindow.getAccount();
		this.endedByHost = endedByHost;
		initializeComponents();
		createGUI();
		addListeners();
	}

	private void initializeComponents(){
		if(sw.getAccount() instanceof User){
			if(((User)sw.getAccount()).isHost()){
				thanksLabel = new JLabel("Thanks for Hosting, " + ((User)sw.getAccount()).getFirstName() + "!");
			}
			else{
				if (endedByHost) {
					thanksLabel = new JLabel("The host has ended your party!");
				} else {
					thanksLabel = new JLabel("Thanks for Listening, " + ((User)sw.getAccount()).getFirstName() + "!");
				}
			}
		}
		else {
				thanksLabel = new JLabel("Thanks for Listening!");
		}

		AppearanceSettings.setFont(AppearanceConstants.fontHuge, thanksLabel);
		thanksLabel.setForeground(Color.black);
		quitButton = new JButton();
		ImageIcon quitButtonImage = new ImageIcon("images/button_quit-trojams.png");
		quitButton.setIcon(quitButtonImage);
		quitButton.setOpaque(false);
		quitButton.setBorderPainted(false);
		quitButton.setContentAreaFilled(false);

		joinAnotherPartyButton = new JButton();
		ImageIcon joinAnotherPartyButtonImage = new ImageIcon("images/button_join-another-party.png");
		joinAnotherPartyButton.setIcon(joinAnotherPartyButtonImage);
		joinAnotherPartyButton.setOpaque(false);
		joinAnotherPartyButton.setBorderPainted(false);
		joinAnotherPartyButton.setContentAreaFilled(false);

		AppearanceSettings.setSize(600, 400, quitButton, joinAnotherPartyButton);
		AppearanceSettings.setForeground(AppearanceConstants.trojamPurple, quitButton, joinAnotherPartyButton);

		thanksPanel = new JPanel();
		thanksPanel.setOpaque(false);
		thanksPanel.setLayout(new BoxLayout(thanksPanel, BoxLayout.LINE_AXIS));

		endPartyButtonPanel = new JPanel();
		endPartyButtonPanel.setOpaque(false);
		endPartyButtonPanel.setLayout(new BoxLayout(endPartyButtonPanel, BoxLayout.LINE_AXIS));
	}

	private void createGUI(){
		setSize(AppearanceConstants.GUI_WIDTH, AppearanceConstants.GUI_HEIGHT);
		setLayout(new BoxLayout(this, BoxLayout.PAGE_AXIS));

		AppearanceSettings.addGlue(endPartyButtonPanel, BoxLayout.LINE_AXIS, true, quitButton, joinAnotherPartyButton);
		AppearanceSettings.addGlue(thanksPanel, BoxLayout.LINE_AXIS, true, thanksLabel);
		this.add(Box.createVerticalGlue());
		AppearanceSettings.addGlue(this, BoxLayout.PAGE_AXIS, true, thanksPanel, endPartyButtonPanel);

	}

	protected void addListeners(){

		quitButton.addActionListener(new ActionListener(){
			@Override
			public void actionPerformed(ActionEvent ae){
				sw.client.close();
				sw.dispose();
				System.exit(0);
			}
		});

		joinAnotherPartyButton.addActionListener(new ActionListener(){
			public void actionPerformed(ActionEvent ae){
				if (sw.client.getAccount() instanceof User) {
					((User)sw.client.getAccount()).setHost(false);
				}
				sw.showSelectionWindow();
			}
		});

	}

	//Paint background image -- needs to be outside of other methods
		@Override
		  protected void paintComponent(Graphics g) {
			super.paintComponent(g);
			Image image = new ImageIcon("images/dj.jpg").getImage();
			//backgroundImage = new ImageIcon(image.getScaledInstance(1280, 800, java.awt.Image.SCALE_SMOOTH));
			g.drawImage(image, 0, 0, this.getWidth(), this.getHeight(), this);
		};

		//for testing purposes
		/*
		public static void main(String [] args) {
			JFrame test = new JFrame();
			//EndPartyWindow epw = new EndPartyWindow(new SelectionWindow(new User("a", "b"), null));
			//test.add(epw);
			test.setSize(1280, 800);
			test.setVisible(true);
		}*/
}
