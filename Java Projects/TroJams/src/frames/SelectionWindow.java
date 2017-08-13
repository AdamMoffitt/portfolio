package frames;

import java.awt.BorderLayout;
import java.awt.CardLayout;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.Graphics;
import java.awt.Image;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.io.File;
import java.util.ArrayList;
import java.util.Vector;

import javax.swing.BorderFactory;
import javax.swing.BoxLayout;
import javax.swing.ButtonGroup;
import javax.swing.DefaultListModel;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JFileChooser;
import javax.swing.JFrame;

/*
 * SELECTION WINDOW: THIS IS OUR MAIN WINDOW, WHERE WE CHOOSE WHICH PARTY TO JOIN/CREATE A PARTY
 */

import javax.swing.JLabel;
import javax.swing.JList;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JRadioButton;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.JTextField;
import javax.swing.SwingConstants;
import javax.swing.border.Border;
import javax.swing.event.DocumentEvent;
import javax.swing.event.DocumentListener;
import javax.swing.filechooser.FileNameExtensionFilter;

import listeners.ExitWindowListener;
import listeners.TextFieldFocusListener;
import logic.Account;
import logic.Party;
import logic.PrivateParty;
import logic.PublicParty;
import logic.User;
import networking.NewPartyMessage;
import networking.PlayNextSongMessage;
import networking.SongVoteMessage;
import networking.TrojamClient;
import resources.AppearanceConstants;
import resources.AppearanceSettings;


public class SelectionWindow extends JFrame {

	private static final long serialVersionUID = 1L;

	private JPanel swMainPanel;

	JPanel cards;
	public JList<SinglePartyPanel> swcurrentParties;
	private JButton createAPartyButton;
	private JScrollPane partyScrollPane;
	public JPanel endPartyPanel;

	Account account;

	private JPanel cpwMainPanel, cpwTopPanel, cpwBottomPanel, cpwRadioButtonPanel;
	private JLabel dummyLabel1, dummyLabel2, dummyLabel3, dummyLabel4, dummyLabel5, dummyLabel6;
	private JTextField cpwPartyNameTextField;
	private JTextField cpwPasswordTextField;
	private JRadioButton cpwPublicRadioButton;
	private JRadioButton cpwPrivateRadioButton;
	private JButton cpwCreateButton, cpwBackButton;
	private JLabel imageLabel, imageText;
	private ImageIcon partyImage;
	private String imageFilePath;
	private JFileChooser fileChooser;
	private JPanel swRightPanel;
	public PartyWindow pw;

	private DefaultListModel <SinglePartyPanel> model;

	public CardLayout cl;

	private JPanel pwMainPanel;
	private JLabel pwUsernameLabel, pwNameLabel, profileLabel, profileIconLabel;
	private ImageIcon profileIcon;

	private SelectionWindow sw;
	public TrojamClient client;

	public SelectionWindow(Account account, ArrayList<Party> parties, TrojamClient client){
		super("TroJams");
		this.account = account;
		sw = this;
		this.client = client;
		client.setSelectionWindow(this);

		model = new DefaultListModel<>();
		swcurrentParties = new JList<>(model);
		swcurrentParties.setLayout(new FlowLayout());
		initializeComponents();
		createGUI();
		addActionListeners();
	}

	public void addNewParty(Party p) {
		addParty(p);
	}

	public TrojamClient getClient() {
		return this.client;
	}

	private void initializeComponents(){

		this.setContentPane(new JPanel() {
			private static final long serialVersionUID = 1L;

			public void paintComponent(Graphics g) {
				super.paintComponent(g);
				Image image = new ImageIcon("images/backgroundImage.png").getImage();
				new ImageIcon(image.getScaledInstance(1280, 800, java.awt.Image.SCALE_SMOOTH));
				g.drawImage(image, 0, 0, 1280, 800, this);
			}
		});

		swRightPanel = new JPanel();
		swRightPanel.setLayout(new BoxLayout(swRightPanel, BoxLayout.PAGE_AXIS));
		swRightPanel.setOpaque(false);

		swMainPanel = new JPanel();
		swMainPanel.setLayout(new BorderLayout());
		createAPartyButton = new JButton();
		ImageIcon createButtonImage = new ImageIcon("images/button_create-a-party.png");
		createAPartyButton.setIcon(createButtonImage);
		createAPartyButton.setOpaque(false);
		createAPartyButton.setContentAreaFilled(false);
		createAPartyButton.setBorderPainted(false);
		cards = new JPanel(new CardLayout());


		//create party image selection
		cpwMainPanel = new JPanel();
		cpwTopPanel = new JPanel();
		cpwBottomPanel = new JPanel();
		dummyLabel1 = new JLabel();
		dummyLabel2 = new JLabel();
		dummyLabel3 = new JLabel("Create a Party!");

		AppearanceSettings.setFont(AppearanceConstants.fontLarge, dummyLabel3);
		dummyLabel3.setHorizontalAlignment(JLabel.CENTER);
	    dummyLabel3.setVerticalAlignment(JLabel.CENTER);
	    dummyLabel3.setForeground(Color.WHITE);
		dummyLabel4 = new JLabel();
		dummyLabel5 = new JLabel();
		dummyLabel6 = new JLabel();
		cpwRadioButtonPanel = new JPanel();
		cpwPartyNameTextField = new JTextField();
		cpwPasswordTextField = new JTextField();
		cpwPublicRadioButton = new JRadioButton("Public");
		cpwPrivateRadioButton = new JRadioButton("Private");
		cpwCreateButton = new JButton();
		ImageIcon cButtonImage = new ImageIcon("images/button_create-a-party.png");
		cpwCreateButton.setIcon(cButtonImage);
		cpwCreateButton.setContentAreaFilled(false);
		cpwCreateButton.setBorderPainted(false);
		cpwCreateButton.setOpaque(false);

		cpwBackButton = new JButton();
		ImageIcon bButtonImage = new ImageIcon("images/button_nah-never-mind.png");
		cpwBackButton.setIcon(bButtonImage);
		cpwBackButton.setContentAreaFilled(false);
		cpwBackButton.setBorderPainted(false);
		cpwBackButton.setOpaque(false);

		fileChooser = new JFileChooser();
		imageText = new JLabel("<html>Click to upload a party picture</html>");
		imageText.setForeground(Color.white);
		imageLabel = new JLabel();

		pwMainPanel = new JPanel();
		pwUsernameLabel = new JLabel();
		pwUsernameLabel.setText("Username");
		if (client.getAccount() instanceof User) {
			pwUsernameLabel.setText(((User)client.getAccount()).getUsername());
		}
		pwNameLabel = new JLabel();

		if (client.getAccount() instanceof User) {
			pwNameLabel.setText(((User)client.getAccount()).getFirstName() + " " + ((User)client.getAccount()).getLastName());
		} else {
			pwNameLabel.setText("Guest");
		}
		profileLabel = new JLabel("Profile");
		profileIcon = new ImageIcon("images/silhouette.png");
		if (client.getAccount() instanceof User) {
			profileIcon = new ImageIcon(((User)client.getAccount()).getImageFilePath());
		}
		profileIconLabel = new JLabel();
		profileIconLabel.setIcon(profileIcon);
	}

	private void createGUI(){
		setSize(AppearanceConstants.GUI_WIDTH, AppearanceConstants.GUI_HEIGHT);
		setLocation(100, 100);
		setLayout(new BorderLayout());
		System.out.println("sending party request");
		client.partyRequest();
		createCPWMenu();
		createSWPanel();
		AppearanceSettings.setNotOpaque(swMainPanel, cards);
		endPartyPanel = new EndPartyWindow(this, false);
		cards.add(swMainPanel, "selection window");
		cards.add(cpwMainPanel, "create party window");
		cards.add(endPartyPanel, "end party panel");

		add(cards, BorderLayout.CENTER);
		cl = (CardLayout) cards.getLayout();
		cl.show(cards, "selection window");
	}

	// creates Profile Window
	private void createPWPanel() {
		// Appearance settings for size and opaqueness
		AppearanceSettings.setSize((AppearanceConstants.GUI_WIDTH)/5, AppearanceConstants.GUI_HEIGHT, pwMainPanel);
		AppearanceSettings.setSize((AppearanceConstants.GUI_WIDTH)/5, AppearanceConstants.GUI_HEIGHT/5, profileLabel);
		AppearanceSettings.setSize((AppearanceConstants.GUI_WIDTH)/5, AppearanceConstants.GUI_HEIGHT/3, profileIconLabel);
		AppearanceSettings.setSize((AppearanceConstants.GUI_WIDTH)/5, AppearanceConstants.GUI_HEIGHT/10, pwUsernameLabel, pwNameLabel);
		AppearanceSettings.setNotOpaque(pwMainPanel);
		AppearanceSettings.setOpaque(pwUsernameLabel, pwNameLabel, profileLabel);
		// centers text in labels
		pwUsernameLabel.setHorizontalAlignment(JLabel.CENTER);
	    pwUsernameLabel.setVerticalAlignment(JLabel.CENTER);
		pwNameLabel.setHorizontalAlignment(JLabel.CENTER);
	    pwNameLabel.setVerticalAlignment(JLabel.CENTER);
	    profileLabel.setHorizontalAlignment(JLabel.CENTER);
	    profileLabel.setVerticalAlignment(JLabel.CENTER);
	    // Appearance settings for font/color
	    AppearanceSettings.setFont(AppearanceConstants.fontSmall, pwUsernameLabel, pwNameLabel);
	    AppearanceSettings.setFont(AppearanceConstants.fontMedium, profileLabel);
	    AppearanceSettings.setForeground(Color.WHITE, pwUsernameLabel, pwNameLabel, profileLabel);
	    AppearanceSettings.setNotOpaque(pwUsernameLabel, pwNameLabel, profileLabel);
		pwMainPanel.add(profileLabel);
		pwMainPanel.add(profileIconLabel);
		pwMainPanel.add(pwUsernameLabel);
		pwMainPanel.add(pwNameLabel);
		pwMainPanel.setBorder(BorderFactory.createLineBorder(Color.WHITE, 4));
	}

	private void addParty(Party p) {
		SinglePartyPanel spp = new SinglePartyPanel(p);
		swcurrentParties.add(spp);
	}


	public void setParties(Vector <Party> parties) {
		swcurrentParties.removeAll();

		//add parties to list

		for (int i = 0; i < parties.size(); i++) {
			Party p = parties.get(i);
			addParty(p);
		}
		revalidate();
	}

	// creates the main panel
	private void createSWPanel() {


		AppearanceSettings.setSize(AppearanceConstants.GUI_WIDTH*(4/5), AppearanceConstants.GUI_HEIGHT, swMainPanel);


		// getting the panel that holds the scroll pane with parties
		swcurrentParties.setPreferredSize(new Dimension (600, 1000));
		swcurrentParties.setOpaque(false);
		partyScrollPane = new JScrollPane(swcurrentParties);
		AppearanceSettings.setSize(AppearanceConstants.GUI_WIDTH * (3/4), AppearanceConstants.GUI_HEIGHT, partyScrollPane);
		partyScrollPane.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED);
		partyScrollPane.setOpaque(false);
		partyScrollPane.getViewport().setOpaque(false);
		partyScrollPane.setBorder(BorderFactory.createEmptyBorder());

		//custom scroll bar
//		partyScrollPane.getVerticalScrollBar().setUI(new MyScrollBarUI());
//		UIManager.put("ScrollBarUI", "my.package.MyScrollBarUI");

		//partyScrollPane.getVerticalScrollBar().setPreferredSize (new Dimension(0,0));
		swRightPanel.add(partyScrollPane);

		// getting the panel that holds the "create a party" button
		JPanel topPanel = new JPanel();
		AppearanceSettings.setFont(AppearanceConstants.fontMedium, createAPartyButton);
		createAPartyButton.setOpaque(true);
			topPanel.add(createAPartyButton);
		createAPartyButton.setOpaque(false);
		createAPartyButton.setContentAreaFilled(false);
		createAPartyButton.setBorderPainted(false);
		if (client.getAccount().isGuest) {
			createAPartyButton.setEnabled(false);
			createAPartyButton.setText("Log in as a user to create parties");
		}
		topPanel.setOpaque(false);
		AppearanceSettings.setBackground(Color.WHITE, topPanel);
		topPanel.setOpaque(false);

		swRightPanel.add(topPanel);
		swMainPanel.add(swRightPanel, BorderLayout.CENTER);

		if(account instanceof User){
			ProfilePanel profilePanel = new ProfilePanel((User)account, this);
			profilePanel.setOpaque(false);
			AppearanceSettings.setSize(AppearanceConstants.GUI_WIDTH/4, AppearanceConstants.GUI_HEIGHT, profilePanel);
			swMainPanel.add(profilePanel, BorderLayout.WEST);
		}
		else{
			GuestPanel guestPanel = new GuestPanel();
			guestPanel.setOpaque(false);
			guestPanel.setMaximumSize(new Dimension(AppearanceConstants.GUI_WIDTH/4, AppearanceConstants.GUI_HEIGHT));
			swMainPanel.add(guestPanel, BorderLayout.WEST);
		}

	}

	public class SinglePartyPanel extends JPanel {

		private static final long serialVersionUID = 1L;
		private Party party;
		private JButton partyButton;
		private JLabel hostLabel, hostImageLabel;
		private JLabel partyIconLabel;
		private boolean isPublic;

		public SinglePartyPanel (Party p) {
			this.party = p;
			isPublic = (p instanceof PublicParty);
			this.setOpaque(false);
			AppearanceSettings.setSize(400, 400, this);
			setLayout(new BoxLayout(this, BoxLayout.PAGE_AXIS));

			partyButton = new JButton("Join: " + party.getPartyName());
			AppearanceSettings.setSize(200, 50, partyButton);

			Image img1 = new ImageIcon(party.getImageFilePath()).getImage();
			ImageIcon pimg = new ImageIcon(img1.getScaledInstance(200, 200, java.awt.Image.SCALE_SMOOTH));
			partyIconLabel = new JLabel(pimg, JLabel.CENTER);

			Image image = new ImageIcon(party.getHost().getImageFilePath()).getImage();
			ImageIcon img = new ImageIcon(image.getScaledInstance(100, 100, java.awt.Image.SCALE_SMOOTH));
			hostImageLabel = new JLabel(img, JLabel.CENTER);

			hostLabel = new JLabel("Host: " + party.getHostName());
			AppearanceSettings.setFont(AppearanceConstants.fontMedium, hostLabel);
			AppearanceSettings.setSize(200, 50, hostLabel);
			System.out.println(party.getImageFilePath() + "*************");

			JPanel panel1 = new JPanel();
			panel1.setLayout(new BoxLayout(panel1, BoxLayout.LINE_AXIS));
			JPanel panel2 = new JPanel();
			panel2.setLayout(new BoxLayout(panel2, BoxLayout.LINE_AXIS));
			JPanel panel3 = new JPanel();
			panel3.setLayout(new BoxLayout(panel3, BoxLayout.LINE_AXIS));
			JPanel panel4 = new JPanel();
			panel4.setLayout(new BoxLayout(panel4, BoxLayout.LINE_AXIS));
			AppearanceSettings.setNotOpaque(panel1,panel2,panel3,panel4);

			partyButton.addActionListener(new ActionListener() {
				@Override
				public void actionPerformed(ActionEvent e) {
					//join that party
					//switch gui so it shows that party (asking for password if the party is private)
					//create a new client for that party

					//let the server know that the party has a new guest

					if (!isPublic) {
						String givenPassword = JOptionPane.showInputDialog(SelectionWindow.this, "Please "
								+ "enter the password for " + party.getPartyName(), "Join "+ party.getPartyName(),
								JOptionPane.QUESTION_MESSAGE);
						PrivateParty pp = (PrivateParty) party;
						if (pp.verifyPassword(givenPassword)) {
							//join party
							System.out.println("setting party window!!!");
							SelectionWindow.this.pw = new PartyWindow(party, sw);
							cards.add(pw, "party window");
							CardLayout cl = (CardLayout) cards.getLayout();
							cl.show(cards,  "party window");
							revalidate();
						}
					} else {
						System.out.println("setting party window!!!");
						SelectionWindow.this.pw = new PartyWindow(party, sw);
						cards.add(pw, "party window");
						CardLayout cl = (CardLayout) cards.getLayout();
						cl.show(cards,  "party window");
						revalidate();
					}
					client.addNewPartier(party.getPartyName());

				}
			});
			AppearanceSettings.setForeground(Color.white, hostLabel);
			AppearanceSettings.setForeground(AppearanceConstants.trojamPurple, partyButton);
			//AppearanceSettings.setBackground(AppearanceConstants.trojamPurple, partyButton, hostLabel);
			AppearanceSettings.setSize(100, 40, partyButton, hostLabel);
			AppearanceSettings.setNotOpaque(partyButton, hostLabel);
			AppearanceSettings.setFont(AppearanceConstants.fontSmall, partyButton, hostLabel);

			AppearanceSettings.addGlue(panel1, BoxLayout.X_AXIS, true, partyIconLabel);
			panel2.add(partyButton);
			panel3.add(hostLabel);
			AppearanceSettings.addGlue(panel4, BoxLayout.X_AXIS, true, hostImageLabel);
			AppearanceSettings.addGlue(this, BoxLayout.Y_AXIS, true, panel1,panel2,panel3,panel4);

			Border raisedbevel, loweredbevel;
			raisedbevel = BorderFactory.createRaisedBevelBorder();
			loweredbevel = BorderFactory.createLoweredBevelBorder();
			Border compound = BorderFactory.createCompoundBorder(
                    raisedbevel, loweredbevel);
			this.setBorder(compound);

		}
	}

	private void addActionListeners(){

		setDefaultCloseOperation(DO_NOTHING_ON_CLOSE);
		addWindowListener(new ExitWindowListener(this, this.client));

		createAPartyButton.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent e) {
				CardLayout cl = (CardLayout) cards.getLayout();
				cl.show(cards, "create party window");
			}
		});

		//focus listeners for create a party
		cpwPartyNameTextField.addFocusListener(new TextFieldFocusListener("Party name", cpwPartyNameTextField));
		cpwPasswordTextField.addFocusListener(new TextFieldFocusListener("Password", cpwPasswordTextField));

		//document listeners for create a party
		cpwPartyNameTextField.getDocument().addDocumentListener(new MyDocumentListener());
		cpwPasswordTextField.getDocument().addDocumentListener(new MyDocumentListener());

		cpwPrivateRadioButton.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent e) {
			// If private, show password field
				cpwPasswordTextField.setVisible(true);
			// Check if text fields are filled: enable create button
				if (canPressButtons()) {
					cpwCreateButton.setEnabled(true);
				} else {
					cpwCreateButton.setEnabled(false);
				}
				revalidate();
			}
		});

		cpwPublicRadioButton.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent e) {
				// If public, get rid of password field
				cpwPasswordTextField.setVisible(false);
				// Check if text fields are filled: enable create button
				if (canPressButtons()) {
					cpwCreateButton.setEnabled(true);
				} else {
					cpwCreateButton.setEnabled(false);
				}
				revalidate();
			}
		});

		cpwBackButton.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent e) {
				cl.show(cards, "selection window");

				cpwPartyNameTextField.addFocusListener(new TextFieldFocusListener("Party name", cpwPartyNameTextField));
				cpwPasswordTextField.addFocusListener(new TextFieldFocusListener("Password", cpwPasswordTextField));

				cpwPublicRadioButton.setSelected(true);
				cpwPasswordTextField.setVisible(false);
			}
		});

		cpwCreateButton.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent e) {
				// CHANGE TO PARTY WINDOW
				String pName = cpwPartyNameTextField.getText();
				Party p = null;
				System.out.println("storing image path: " + imageFilePath + " in party");
				if(cpwPublicRadioButton.isSelected()){
					p = new PublicParty(pName, (User)account, imageFilePath);
					System.out.println("CLAIRISSE: " + p.getImageFilePath());
				}
				else if(cpwPrivateRadioButton.isSelected()){
					String password = cpwPasswordTextField.getText();
					p = new PrivateParty(pName, password, (User)account, imageFilePath);
					System.out.println("CLAIRISSE: " + p.getImageFilePath());
				}
				((User) account).setHostedParty(p);
				String password = "";
				if (cpwPrivateRadioButton.isSelected()) {
					password = cpwPasswordTextField.getText();
				}
				System.out.println("about to send new party info to server");
				client.sendNewPartyMessage(new NewPartyMessage("newParty", pName, password, imageFilePath));

				client.addNewPartier(p.getPartyName());
				SelectionWindow.this.pw = new PartyWindow(p, sw);
				cards.add(pw, "party window");
				CardLayout cl = (CardLayout) cards.getLayout();
				cl.show(cards, "party window");

				cpwPartyNameTextField.addFocusListener(new TextFieldFocusListener("Party name", cpwPartyNameTextField));
				cpwPasswordTextField.addFocusListener(new TextFieldFocusListener("Password", cpwPasswordTextField));

				cpwPublicRadioButton.setSelected(true);
				cpwPasswordTextField.setVisible(false);

				// TODO reset party image and image label
				imageText.setVisible(true);
				setPartyImage("images/party-purple.jpg");

			}
		});

		imageLabel.addMouseListener(new MouseAdapter() {
			 @Override
           public void mouseClicked(MouseEvent e) {
				fileChooser.showOpenDialog(SelectionWindow.this);
				File f = fileChooser.getSelectedFile();
				System.out.println("FILE F IS " + f.toString());
				if (f != null) {
					System.out.println("f.getName() " + f.getName());
					setPartyImage(f.getPath());
					imageFilePath = f.getName();
					System.out.println("IMAGEFILEPATH IN IMAGE LABEL AL: " + imageFilePath);
					imageText.setVisible(false);
				}
           }
		});
	}



	public void createCPWMenu() {
		cpwMainPanel.setLayout(new BoxLayout(cpwMainPanel, BoxLayout.Y_AXIS));

		AppearanceSettings.setSize(1280, 50, dummyLabel1, dummyLabel2, dummyLabel3, dummyLabel5, dummyLabel6);
		AppearanceSettings.setSize(1280, 20, dummyLabel4);
		AppearanceSettings.setSize(300, 50, cpwPartyNameTextField, cpwPasswordTextField);
		AppearanceSettings.setSize(1280, 250, cpwTopPanel);

		// Creates top panel with dummy labels so that the text field is at the bottom of the panel

		//file chooser settings
		fileChooser.setPreferredSize(new Dimension(400, 500));
		fileChooser.setCurrentDirectory(new File(System.getProperty("user.dir")));
		fileChooser.setFileFilter(new FileNameExtensionFilter("IMAGE FILES", "jpeg", "png", "jpg"));
		setPartyImage("images/party-purple.jpg");
		JPanel cpwImagePanel = new JPanel();
		cpwImagePanel.add(imageLabel);
		cpwImagePanel.setOpaque(false);
		cpwTopPanel.add(dummyLabel3);
		cpwTopPanel.add(cpwImagePanel);
		cpwTopPanel.add(dummyLabel4);
		cpwTopPanel.add(cpwPartyNameTextField);
		cpwMainPanel.add(cpwTopPanel);

		// Makes it so you can only select one button
		ButtonGroup bg = new ButtonGroup();
		bg.add(cpwPublicRadioButton);
		bg.add(cpwPrivateRadioButton);
		cpwPublicRadioButton.setSelected(true);
		AppearanceSettings.setFont(AppearanceConstants.fontSmall, cpwPublicRadioButton,
				cpwPrivateRadioButton, imageLabel, cpwPartyNameTextField, cpwPasswordTextField, imageText);

		// Adds radio buttons horizontally
		cpwRadioButtonPanel.setLayout(new BoxLayout(cpwRadioButtonPanel, BoxLayout.X_AXIS));
		cpwRadioButtonPanel.setPreferredSize(new Dimension(1280,50));
		cpwRadioButtonPanel.add(cpwPublicRadioButton);
		cpwRadioButtonPanel.add(cpwPrivateRadioButton);
		cpwMainPanel.add(cpwRadioButtonPanel);

		// Creates the bottom panel with password text field and create party button
		JPanel tempPanel1 = new JPanel();
		tempPanel1.add(cpwPasswordTextField);
		cpwPasswordTextField.setVisible(false);
		cpwBottomPanel.add(tempPanel1);
		JPanel tempPanel2 = new JPanel();
		tempPanel2.add(cpwCreateButton);
		tempPanel2.add(cpwBackButton);
		cpwBottomPanel.add(tempPanel2);
		AppearanceSettings.setNotOpaque(tempPanel1, tempPanel2);
		cpwMainPanel.add(cpwBottomPanel);
		AppearanceSettings.setSize(1280, 80, cpwBottomPanel);
		AppearanceSettings.setSize(1280, 100, tempPanel1, tempPanel2);

		// Appearance settings
		cpwMainPanel.setSize(new Dimension(500,800));
		AppearanceSettings.setNotOpaque(cpwTopPanel, cpwMainPanel, cpwBottomPanel, cpwRadioButtonPanel);
		cpwPrivateRadioButton.setForeground(Color.white);
		cpwPublicRadioButton.setForeground(Color.white);

	}

	private void setPartyImage(String filepath) {
		this.imageFilePath = filepath;
		Image image = new ImageIcon(filepath).getImage();
		partyImage = new ImageIcon(image.getScaledInstance(200, 200, java.awt.Image.SCALE_SMOOTH));
		imageLabel.setIcon(partyImage);
		imageText.setSize(imageLabel.getPreferredSize());
		imageText.setLocation(imageText.getLocation());
		imageLabel.add(imageText);
		if (canPressButtons()) {
			cpwCreateButton.setEnabled(true);
		} else {
			cpwCreateButton.setEnabled(false);
		}
	}

	private boolean canPressButtons() {
		if (cpwPrivateRadioButton.isSelected()) {
			if (!cpwPartyNameTextField.getText().equals("Party name") && cpwPartyNameTextField.getText().length() != 0) {
				if (!cpwPasswordTextField.getText().equals("Password") && cpwPasswordTextField.getText().length() != 0) {
					if(imageLabel.getIcon() != null){
						return true;
					}
				}
			}
		} else if (cpwPublicRadioButton.isSelected()) {
			if (!cpwPartyNameTextField.getText().equals("Party name") && cpwPartyNameTextField.getText().length() != 0) {
				if(imageLabel.getIcon() != null){
					return true;
				}
			}
		}

		return false;
	}

	//sets the buttons enabled or disabled
	private class MyDocumentListener implements DocumentListener{

		@Override
		public void insertUpdate(DocumentEvent e) {
			cpwCreateButton.setEnabled(canPressButtons());
		}

		@Override
		public void removeUpdate(DocumentEvent e) {
			cpwCreateButton.setEnabled(canPressButtons());
		}

		@Override
		public void changedUpdate(DocumentEvent e) {
			cpwCreateButton.setEnabled(canPressButtons());
		}
	}

	public Account getAccount() {
		return this.account;
	}


	private class GuestPanel extends JPanel{
		ImageIcon profilePic;
		JLabel profileName, dummyLabel;
		JButton logout;
		JTextArea infoTextArea;
		JScrollPane guestSP;
		JLabel profilePanelTitle;

		public GuestPanel(){
			Image image = new ImageIcon("Images/JeffreyMiller-cropped.png").getImage();
			profilePic = new ImageIcon(image.getScaledInstance(200, 200, java.awt.Image.SCALE_SMOOTH));

			profilePanelTitle = new JLabel("Profile Info:");
			profilePanelTitle.setHorizontalAlignment((int) this.LEFT_ALIGNMENT);
			profilePanelTitle.setForeground(Color.white);
			AppearanceSettings.setFont(AppearanceConstants.fontLarge, profilePanelTitle);

			dummyLabel = new JLabel(" ");

			profileName = new JLabel("Guest", SwingConstants.CENTER);
			AppearanceSettings.setFont(AppearanceConstants.fontMedium, profileName);
			profileName.setForeground(Color.white);

			infoTextArea = new JTextArea(5,20);
			infoTextArea.setOpaque(false);
			infoTextArea.setFont(AppearanceConstants.fontMedium);
			infoTextArea.setForeground(Color.white);
			infoTextArea.append("Sorry, you are not logged in. Log in or create an account to unleash your full party potential!");
			infoTextArea.setLineWrap(true);
			infoTextArea.setWrapStyleWord(true);
			infoTextArea.setEditable(false);

			guestSP = new JScrollPane(infoTextArea);
			guestSP.setOpaque(false);
			guestSP.getViewport().setOpaque(false);
			Border border = BorderFactory.createEmptyBorder( 10, 10, 10, 10 );
			guestSP.setViewportBorder( border );
			guestSP.setBorder( border );

			logout = new JButton();
			ImageIcon logoutButtonImage = new ImageIcon("images/button_log-out.png");
			logout.setIcon(logoutButtonImage);
			logout.setOpaque(false);
			logout.setBorderPainted(false);
			logout.setContentAreaFilled(false);

			logout.addActionListener(new ActionListener() {
				@Override
				public void actionPerformed(ActionEvent e) {
					new LoginScreenWindow(client).setVisible(true);
					dispose();
				}
			});

			setLayout(new BoxLayout(this, BoxLayout.PAGE_AXIS));
			this.add(profilePanelTitle);
			this.add(new JLabel(profilePic));
			this.add(profileName);
			this.add(guestSP);
			this.add(dummyLabel);
			this.add(logout);
			this.setSize(AppearanceConstants.GUI_WIDTH/4, AppearanceConstants.GUI_HEIGHT);
		}

	}

	public void showEndWindow() {
		CardLayout cl = (CardLayout) cards.getLayout();
		cl.show(cards, "end party panel");
	}

	public void showSelectionWindow() {
		CardLayout cl = (CardLayout) cards.getLayout();
		cl.show(cards, "selection window");
	}

	public void sendCurrentlyPlayingUpdate(PlayNextSongMessage psm) {
		if (pw != null) {
			pw.updateCurrentlyPlaying(psm);
		}
	}

	public void sendSongVoteUpdate(SongVoteMessage svm) {
		System.out.println(this.pw);
		if (pw != null) {
			this.pw.sendSongVoteUpdate(svm);
		}
	}

	public void updatePanel(Party party) {
		System.out.println("#HunterRox");
		if (pw != null) {
			System.out.println();
			this.pw.updatePartyPanelForReturningGuest(party);
		}
	}

	public PartyWindow getPartyWindow(){
		return pw;
	}

	public void endParty() {
		System.out.println("pw is " + pw);
		pw.endParty();
	}

//FOR CUSTOM SCROLL BAR - DECIDED NOT TO IMPLEMENT
	//CITE: http://www.java2s.com/Tutorials/Java/Swing_How_to/JScrollPane/Create_custom_JScrollBar_for_JScrollPane.htm
//	public class MyScrollBarUI extends BasicScrollBarUI {
//
//		private final Dimension d = new Dimension();
//
//		  @Override
//		  protected JButton createDecreaseButton(int orientation) {
//		    return new JButton() {
//		      @Override
//		      public Dimension getPreferredSize() {
//		        return d;
//		      }
//		    };
//		  }
//
//		  @Override
//		  protected JButton createIncreaseButton(int orientation) {
//		    return new JButton() {
//		      @Override
//		      public Dimension getPreferredSize() {
//		        return d;
//		      }
//		    };
//		  }
//
//
//	    @Override
//	    protected void paintTrack(Graphics g, JComponent c, Rectangle trackBounds) {
//	        // your code
//	    }
//
//	    @Override
//	    protected void paintThumb(Graphics g, JComponent c, Rectangle r) {
//	    	  Graphics2D g2 = (Graphics2D) g.create();
//	    	    g2.setRenderingHint(RenderingHints.KEY_ANTIALIASING,
//	    	        RenderingHints.VALUE_ANTIALIAS_ON);
//	    	    Color color = null;
//	    	    JScrollBar sb = (JScrollBar) c;
//	    	    if (!sb.isEnabled() || r.width > r.height) {
//	    	      return;
//	    	    } else if (isDragging) {
//	    	      color = Color.DARK_GRAY;
//	    	    } else if (isThumbRollover()) {
//	    	      color = Color.LIGHT_GRAY;
//	    	    } else {
//	    	      color = Color.GRAY;
//	    	    }
//	    	    g2.setPaint(color);
//	    	    g2.fillRoundRect(r.x, r.y, r.width, r.height, 10, 10);
//	    	    g2.setPaint(Color.WHITE);
//	    	    g2.drawRoundRect(r.x, r.y, r.width, r.height, 10, 10);
//	    	    g2.dispose();
//	    }
//
//	    @Override
//	    protected void setThumbBounds(int x, int y, int width, int height) {
//	      super.setThumbBounds(x, y, width, height);
//	      scrollbar.repaint();
//	    }
//	}

}
