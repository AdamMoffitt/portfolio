package networking;

public class RuthMessage extends Message{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	String partyName;

	public RuthMessage(String name, String partyName) {
		super(name);
		this.partyName = partyName;
	}
	
	public String getPartyName() {
		return partyName;
	}

}
