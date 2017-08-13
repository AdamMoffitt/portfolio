package listeners;

import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;

import javax.swing.JFrame;
import javax.swing.JOptionPane;

import other_gui.AppearanceConstants;
//pop-up for when user clicks the red X on a frame
public class ExitWindowListener extends WindowAdapter{

	private JFrame frame;
	
	public ExitWindowListener(JFrame frame) {
		this.frame = frame;
	}
	
	 @Override
	public void windowClosing(WindowEvent e) {
		 int answer = JOptionPane.showConfirmDialog(frame, "Are you sure you want to quit?", "Quit", JOptionPane.YES_NO_OPTION, JOptionPane.QUESTION_MESSAGE, AppearanceConstants.exitIcon);
	     
		 if (answer == JOptionPane.YES_OPTION){
			 System.exit(0);
		 }
	 }

}
