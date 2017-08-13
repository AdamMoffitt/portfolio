package logic;

import javax.swing.ImageIcon;

public class PrivateParty extends Party{

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private String password;
	
	public PrivateParty(String partyName, String password, User host, String filepath) {
		super(partyName, host, filepath);
		this.password = password;
	}
	
	//pass in a string to see if it equals the party password
	public boolean verifyPassword(String pass) {
		System.out.println("");
		return pass.equals(password);
	}

}
