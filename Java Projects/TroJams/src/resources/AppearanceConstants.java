package resources;

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
    public static final Color darkGray = new Color(51, 51, 51);
    
    //TROJAM PURPLE
    public static final Color trojamPurple = new Color(178,	58,	238);

    public static final Color trojamComplement = new Color(255, 51, 102);
  //  public static final Color trojamLightPurple = new Color(210, 129, 450);
    
    public static final Font fontSmall = new Font("Futura", Font.BOLD,18);
    public static final Font fontSmallest = new Font("Futura", Font.BOLD,14);
    public static final Font fontMedium = new Font("Futura", Font.BOLD, 22);
    public static final Font fontLarge = new Font("Futura", Font.BOLD, 30);
    public static final Font fontHuge = new Font("Futura", Font.BOLD, 50);
    
    //added a blue border variable used in StartWindowGUI
    public static final Border blueLineBorder = BorderFactory.createLineBorder(darkBlue);
    
    public static final Integer GUI_WIDTH = 1280;
    public static final Integer GUI_HEIGHT = 800;

}
