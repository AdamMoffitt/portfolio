package logic;

public class Guest extends Account{
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private Party party;

	public Guest() {
		super(true);
	}
	
	//called when a guest logs out
	public void leaveParty() {
		party.leaveParty(this);
	}
	

}
