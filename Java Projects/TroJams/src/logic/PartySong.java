package logic;

//to be added to song queues for parties
public class PartySong extends Song{
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private int votes;

	public PartySong(String name) {
		super(name);
		votes = 0;
	}
	
	public void upvote() {
		votes++;
	}
	
	public void downvote() {
		if (votes == 0) {
			return;
		} else {
			votes--;
		}
	}

	public int getVotes() {
		return votes;
	}

}
