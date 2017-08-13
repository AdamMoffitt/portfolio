package networking;

public class LoginMessage extends Message{
	private String username, password;
	
	public LoginMessage(String username, String password) {
		super("loginMessage");
		this.username = username;
		this.password = password;
	}
	
	public String getUsername(){
		return username;
	}
	
	public String getPassword(){
		return password;
	}
	

}
