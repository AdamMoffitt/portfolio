package frames;

import java.awt.Color;
import java.awt.Dimension;
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

import networking.TrojamClient;
import resources.AppearanceConstants;
import resources.AppearanceSettings;

//This window is the first thing that the user should see when they start the program
public class TrojamWelcomeWindow extends JFrame{

	/**
	 *
	 */
	private static final long serialVersionUID = 1L;
	private JPanel mainPanel;
	private ImageIcon trojamsImage;
	private JLabel imageLabel;
	private JButton startButton;
	private TrojamClient client;

	public TrojamWelcomeWindow(TrojamClient trojamClient){
		 super("TroJams");
		 this.client = trojamClient;
		 initializeComponents();
	        createGUI();
	        addListeners();
	}

	private void initializeComponents(){
		setSize(AppearanceConstants.GUI_WIDTH,AppearanceConstants.GUI_HEIGHT);
		setLocation(100,100);

		//To paint Trojams photo on JFrame and make it possible to put opaque button on top of it
		this.setContentPane(new JPanel() {
	        public void paintComponent(Graphics g) {
	            super.paintComponent(g);
	        	Image image = new ImageIcon("images/TroJams.png").getImage();
				trojamsImage = new ImageIcon(image.getScaledInstance(AppearanceConstants.GUI_WIDTH, AppearanceConstants.GUI_HEIGHT, java.awt.Image.SCALE_SMOOTH));
	            g.drawImage(image, 0, 0, AppearanceConstants.GUI_WIDTH,  AppearanceConstants.GUI_HEIGHT, this);
	        }
	    });


		int width = this.getWidth();
		int height = this.getHeight();

		int buttonWidth = width / 4;
		int buttonHeight = height / 4;
		int buttonX = 440;
		int buttonY = 250;


		System.out.println(width + " " + height + " " + buttonWidth + " " + buttonHeight + " " + buttonX + " " + buttonY);
		startButton = new JButton("Click to Party");
		AppearanceSettings.setFont(AppearanceConstants.fontHuge, startButton);

		startButton.setForeground(Color.black);
		startButton.setOpaque(false);
		startButton.setContentAreaFilled(false);
		startButton.setBorderPainted(false);
		startButton.setLocation(buttonX, buttonY);
		startButton.setAlignmentX(CENTER_ALIGNMENT);
		startButton.setAlignmentY(buttonY);
		startButton.setPreferredSize(new Dimension(buttonWidth, buttonHeight));

		this.setLayout(new BoxLayout(getContentPane(), BoxLayout.PAGE_AXIS));
		this.add(Box.createGlue());
		this.add(startButton);
		this.add(Box.createGlue());
		this.add(Box.createGlue());


	}

	private void createGUI(){
		setVisible(true);
	}

	private void addListeners(){
		this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

		startButton.addActionListener(new ActionListener(){
			public void actionPerformed(ActionEvent ae){
				new LoginScreenWindow(client).setVisible(true);
				dispose();
			}
		});

	}
}

