package networking;

import logic.Party;

public class PartyMessage extends Message {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private Party party;

	public PartyMessage(String name, Party party) {
		super(name);
		this.party = party;
	}
	
	public Party getParty() {
		return party;
	}

}
