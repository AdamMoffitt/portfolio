package frames;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;

import other_gui.AppearanceConstants;
import other_gui.AppearanceSettings;
import server.Client;

public class LeaveGamePopUp extends JFrame{

	private Client client;
	private String teamLeaving;
	private MainGUI mainGUI;
	
	private JButton okayButton;
	
	public LeaveGamePopUp(Client client, String teamLeaving, MainGUI mainGUI) {
		this.client = client;
		this.teamLeaving = teamLeaving;
		this.mainGUI = mainGUI;
		createGUI();
	}
	
	private void createGUI(){
		JLabel infoLabel = new JLabel(teamLeaving+" left the game!");
		JPanel mainPanel = new JPanel(new BorderLayout());
		okayButton = new JButton("Okay");
		
		AppearanceSettings.setBackground(Color.darkGray, infoLabel, mainPanel, okayButton);
		AppearanceSettings.setFont(AppearanceConstants.fontMedium, infoLabel, okayButton);
		AppearanceSettings.setForeground(AppearanceConstants.lightBlue, infoLabel, okayButton);
		AppearanceSettings.setTextAlignment(infoLabel);
		
		mainPanel.add(infoLabel, BorderLayout.NORTH);
		mainPanel.add(okayButton, BorderLayout.SOUTH);
		add(mainPanel);
		
		okayButton.addActionListener(new ActionListener(){

			@Override
			public void actionPerformed(ActionEvent e) {
				client.close();
				mainGUI.dispose();
				dispose();
				new StartWindowGUI(client.getUser()).setVisible(true);
			}
			
		});
		
		setSize(300, 300);
		setVisible(true);
		setLocation(400,  400);
	}

}
