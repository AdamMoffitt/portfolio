package networking;

import logic.Account;
import logic.Party;

public class NewPartyMessage extends Message{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private String partyName, partyPassword, filepath;

	public NewPartyMessage(String name, String partyName, String partyPassword, String filepath) {
		super(name);
		this.partyName = partyName;
		this.partyPassword = partyPassword;
		this.filepath = filepath;
	}
	
	public String getPartyName() {
		return partyName;
	}
	
	public String getPartyPassword() {
		return partyPassword;
	}
	
	public String getFilePath(){
		return filepath;
	}

}
