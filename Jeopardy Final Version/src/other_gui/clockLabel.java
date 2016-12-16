package other_gui;

import java.awt.Image;

import javax.swing.ImageIcon;
import javax.swing.JLabel;

public class clockLabel extends JLabel{

	public ImageIcon clock;
	public ImageIcon clock0;
	public int clockCounter;
	private JLabel pointsPanelClock;

	public clockLabel(String string){
		super();
	}

	public void makeClock(){
		this.removeAll();
		System.out.println("creating clock");
		clockCounter = 0;
		Image temp = new ImageIcon("images/clockAnimation/frame_" + clockCounter + "_delay-0.06s.jpg").getImage();
		clock = new ImageIcon(temp.getScaledInstance(40, 40,Image.SCALE_SMOOTH));
		//clock0 = new ImageIcon("images/clockAnimation/frame_0_delay-0.06s.jpg");
		this.setIcon(clock);
		this.revalidate();
		this.repaint();
	}

	public void update(){
		clockCounter = clockCounter % 142;
    	//System.out.println("1 second " + " clockCounter: " + clockCounter);
    	Image temp = new ImageIcon("images/clockAnimation/frame_" + clockCounter + "_delay-0.06s.jpg").getImage();
		clock = new ImageIcon(temp.getScaledInstance(40, 40,Image.SCALE_SMOOTH));
		this.setIcon(clock);
		this.revalidate();
		this.repaint();
		clockCounter++;
	}
}