package networking;

import logic.User;

public class AccountCreatedMessage extends Message {
	private boolean accountCreated;
	private User user;
	
	public AccountCreatedMessage(boolean accountCreated, User u) {
		super("accountCreated");
		this.accountCreated = accountCreated;
		this.user = u;
	}
	
	public boolean accountCreated(){
		return accountCreated;
	}
	
	public User getUser(){
		return user;
	}

}
