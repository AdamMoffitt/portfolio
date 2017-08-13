package networking;

import java.util.Vector;

import logic.Party;

public class AllPartiesMessage extends Message {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	
	private Vector <Party> parties;

	public AllPartiesMessage(String name, Vector <Party> parties) {
		super(name);
		this.parties = parties;
	}

	public Vector<Party> getParties() {
		return parties;
	}

}
