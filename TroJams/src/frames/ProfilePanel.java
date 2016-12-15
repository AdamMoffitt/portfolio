package frames;

import java.awt.Color;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.BorderFactory;
import javax.swing.BoxLayout;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.SwingConstants;
import javax.swing.border.Border;

import logic.Party;
import logic.User;
import resources.AppearanceConstants;
import resources.AppearanceSettings;

class ProfilePanel extends JPanel{

	/**
	 *
	 */
	private static final long serialVersionUID = 1;

	ImageIcon profilePic;
	JLabel profileName, dummyLabel;
	JLabel profileUserName;
	User user;
	JScrollPane userHistorySP;
	JTextArea partiesTextArea;
	JButton logout;
	JLabel profilePanelTitle;

	public ProfilePanel(User user, SelectionWindow sw){
		this.user = user;
		profilePic = user.getUserImage();

		profilePanelTitle = new JLabel("Profile Info:");
		profilePanelTitle.setForeground(Color.white);
		AppearanceSettings.setFont(AppearanceConstants.fontLarge, profilePanelTitle);

		dummyLabel = new JLabel(" ");

		profileName = new JLabel("Name: " + user.getFirstName() + " " + user.getLastName(), SwingConstants.CENTER);
		AppearanceSettings.setFont(AppearanceConstants.fontMedium, profileName);
		profileName.setForeground(Color.white);

		profileUserName = new JLabel("Username: " + user.getUsername(), SwingConstants.CENTER);
		AppearanceSettings.setFont(AppearanceConstants.fontMedium, profileUserName);
		profileUserName.setForeground(Color.white);

		partiesTextArea = new JTextArea(5,20);
		partiesTextArea.setOpaque(false);
		partiesTextArea.setFont(AppearanceConstants.fontSmall);
		partiesTextArea.setForeground(Color.white);
		partiesTextArea.setLineWrap(true);
		partiesTextArea.setWrapStyleWord(true);
		partiesTextArea.setEditable(false);

		userHistorySP = new JScrollPane(partiesTextArea);
		userHistorySP.setOpaque(false);
		userHistorySP.getViewport().setOpaque(false);
		Border border = BorderFactory.createEmptyBorder( 0, 0, 0, 0 );
		userHistorySP.setViewportBorder( border );
		userHistorySP.setBorder( border );


		logout = new JButton();
		ImageIcon logoutButtonImage = new ImageIcon("images/button_log-out.png");
		logout.setIcon(logoutButtonImage);
		logout.setOpaque(false);
		logout.setBorderPainted(false);
		logout.setContentAreaFilled(false);

		logout.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent e) {
				new LoginScreenWindow(sw.getClient()).setVisible(true);
				sw.dispose();
			}
		});

		setLayout(new BoxLayout(this, BoxLayout.PAGE_AXIS));
		this.add(profilePanelTitle);
		JLabel woot = new JLabel(profilePic);
		this.add(woot);
		this.add(profileName);
		this.add(profileUserName);
		this.add(dummyLabel);
		this.add(logout);

		if (sw.client.getAccount().isGuest) {
			profilePanelTitle.setVisible(false);
			profileName.setVisible(false);
			woot.setVisible(false);
			profileUserName.setVisible(false);
			dummyLabel.setVisible(false);
		}
		this.setSize(AppearanceConstants.GUI_WIDTH/4, AppearanceConstants.GUI_HEIGHT);
	}

}