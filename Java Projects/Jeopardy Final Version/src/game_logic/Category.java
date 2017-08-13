package game_logic;

import java.awt.Color;
import java.awt.Image;
import java.io.Serializable;

import javax.swing.ImageIcon;
import javax.swing.JLabel;
import javax.swing.SwingConstants;

import other_gui.AppearanceConstants;

public class Category implements Serializable{

	//The category name
	private String category;
	//image icon
	private static ImageIcon icon;
	//The category's index in ordering the categories
	private int index;
	//The label displayed on the MainGUI above the game board
	transient private JLabel categoryLabel;
	
	public Category(String category, int index){
		this.category = category;
		this.index = index;
		
		populate();
	}
	
	public void populate(){
		//create the label
		categoryLabel = new JLabel(category, icon, SwingConstants.CENTER);
		categoryLabel.setHorizontalTextPosition(SwingConstants.CENTER);
		categoryLabel.setVerticalTextPosition(SwingConstants.CENTER);
		categoryLabel.setForeground(Color.lightGray);
		categoryLabel.setFont(AppearanceConstants.fontMedium);
		categoryLabel.setIcon(icon);
	}
	
	public static ImageIcon getIcon(){
		return icon;
	}
	
	public String getCategory(){
		return category;
	}
	//set the icon
	public static void setIcon(String filePath){
		Image darkBlueImage = new ImageIcon(filePath).getImage();
		icon = new ImageIcon(darkBlueImage.getScaledInstance(400, 400,  Image.SCALE_SMOOTH));
	}
	
	public static void clearIcon(){
		icon = null;
	}
	
	public int getIndex(){
		return index;
	}
	
	public JLabel getCategoryLabel(){
		return categoryLabel;
	}
}
