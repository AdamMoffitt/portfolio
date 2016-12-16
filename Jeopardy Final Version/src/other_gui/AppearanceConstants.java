package other_gui;

import java.awt.Color;
import java.awt.Font;
import java.awt.Image;

import javax.swing.BorderFactory;
import javax.swing.ImageIcon;
import javax.swing.border.Border;

public class AppearanceConstants {
	
	//colors, fonts, ect that can be statically referenced by other classes
	private static final ImageIcon exitIconLarge = new ImageIcon("images/question_mark.png");
	private static final Image exitImage = exitIconLarge.getImage();
	private static final Image exitImageScaled = exitImage.getScaledInstance(50, 50,  java.awt.Image.SCALE_SMOOTH);
	
	public static final ImageIcon exitIcon = new ImageIcon(exitImageScaled);
	
	public static final Color darkBlue = new Color(0,0,139);
	public static final Color lightBlue = new Color(135,206,250);
	public static final Color mediumGray = new Color(100, 100, 100);
	
	public static final Font fontSmall = new Font("Palatino", Font.BOLD,18);
	public static final Font fontSmallest = new Font("Palatino", Font.BOLD,14);
	public static final Font fontMedium = new Font("Palatino", Font.BOLD, 22);
	public static final Font fontLarge = new Font("Palatino", Font.BOLD, 30);
	//added a blue border variable used in StartWindowGUI
	public static final Border blueLineBorder = BorderFactory.createLineBorder(darkBlue);
}
