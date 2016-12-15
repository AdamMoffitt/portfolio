package networking;

import logic.Party;

public class UpdatePartyMessage extends Message {
	private Party party;
	public UpdatePartyMessage(Party p) {
		super("upm");
		this.party = p;
		
	}
	
	public Party getParty(){
		return party;
	}

}
