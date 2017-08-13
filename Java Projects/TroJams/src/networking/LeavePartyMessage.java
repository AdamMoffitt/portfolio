package networking;

public class LeavePartyMessage extends Message{

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private boolean isHost;

	public LeavePartyMessage(String name, boolean isHost) {
		super(name);
		this.isHost = isHost;
	}
	
	public boolean isHost() {
		return isHost;
	}

}
