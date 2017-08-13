package logic;

import java.awt.Image;
import java.util.HashSet;

import javax.swing.ImageIcon;

public class User extends Account{
	
	private static final long serialVersionUID = 1L;
	private String username, firstName, lastName, imageFilePath, email;
	public ImageIcon userImage;
	private boolean isHost;
	public Party hostedParty; //null if user is hosting no parties
	
	public User(String username, boolean isGuest) {
		super(isGuest);
		this.username = username;
		//this.password = password;
		if (imageFilePath == null) {
			imageFilePath = "images/silhouette.png";
		}
		//To whoever put this code here, I commented it out because a user cannot have an imageIcon
		//that makes it not serializable and brings up a bunch of errors
		//I just have getImage() create an image from the filepath and return that
//		Image image = new ImageIcon(imageFilePath).getImage();
//		userImage = new ImageIcon(image.getScaledInstance(200, 200, java.awt.Image.SCALE_SMOOTH));
	}
	
	public User(String username, String firstName, String lastName, String imageFilePath, boolean isGuest) {
		this(username, isGuest);
		this.firstName = firstName;
		this.lastName = lastName;
		this.email = "defaultEmail@default.com";
		this.imageFilePath = imageFilePath;
		if (imageFilePath == null) {
			imageFilePath = "images/silhouette.png";
		}
}

	public String getUsername() {
		return username;
	}
	
	//pass in a string to see if password matches the user's password
//	public boolean verifyPassword(String pass) {
//		return pass.equals(password);
//	}

//	public String getPassword() {
//		return password;
//	}

	public String getFirstName() {
		return firstName;
	}

	public void setFirstName(String firstName) {
		this.firstName = firstName;
	}

	public String getLastName() {
		return lastName;
	}

	public void setLastName(String lastName) {
		this.lastName = lastName;
	}

	public ImageIcon getUserImage() {
		Image image = new ImageIcon(imageFilePath).getImage();
		userImage = new ImageIcon(image.getScaledInstance(200, 200, java.awt.Image.SCALE_SMOOTH));
		return userImage;
	}

	public void setUserImage(ImageIcon userImage) {
		this.userImage = userImage;
	}

	public Party getHostedParty() {
		return hostedParty;
	}

	public void setHostedParty(Party hostedParty) {
		setHost(true);
		this.hostedParty = hostedParty;
	}

	public void setUsername(String username) {
		this.username = username;
	}

//	public void setPassword(String password) {
//		this.password = password;
//	}

	public String getImageFilePath() {
		return imageFilePath;
	}

	public void setImageFilePath(String imageFilePath) {
		this.imageFilePath = imageFilePath;
	}

	public boolean isHost() {
		return isHost;
	}

	public void setHost(boolean isHost) {
		this.isHost = isHost;
	}
	
	public void setEmail(String newEmail){
		email = newEmail;
	}

	public String getEmail() {
		return email;
	}
	
	
	
	
}
