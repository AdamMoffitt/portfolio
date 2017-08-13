package networking;

import java.sql.ResultSet;
import java.sql.SQLException;

public class AuthenticatedLoginMessage extends Message {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private boolean authenticated;
	private String firstName, lastName, imageFilePath, username;
	
	
	public AuthenticatedLoginMessage(boolean loggedIn) {
		super("AuthenticatedLoginMessage");
		authenticated = loggedIn;
	}
	
	public AuthenticatedLoginMessage(ResultSet rs) {
		super("AuthenticatedLoginMessage");
		//username, password, first_name, last_name, filepath_to_pic
		try {
			//System.out.println("in try bloack alm");
			username = rs.getString("username");
			firstName = rs.getString("first_name");
			lastName = rs.getString("last_name");
			imageFilePath = rs.getString("filepath_to_pic");
			authenticated = true;
		} catch (SQLException e) {
			//System.out.println("caught exception");
			authenticated = false;
		}
	}
	
	public String getUsername() {
		return username;
	}

	public boolean isAuthenticated(){
		return authenticated;
	}
	
	public String getfirstName(){
		return firstName;
	}
	
	public String getLastName(){
		return lastName;
	}
	
	public String getFilepath(){
		return imageFilePath;
	}
}
