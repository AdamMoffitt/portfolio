package networking;

import logic.Account;

public class NewPartierMessage extends Message{
	
	private Account account;
	private String partyName;

	public NewPartierMessage(String name, Account account, String partyName) {
		super(name);
		this.account = account;
		this.partyName = partyName;
	}
	
	public Account getAccount() {
		return account;
	}
	
	public String getPartyName() {
		return partyName;
	}

}
