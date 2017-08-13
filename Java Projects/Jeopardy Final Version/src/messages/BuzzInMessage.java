package messages;

public class BuzzInMessage implements Message {
	//all we need to know is which team buzzed in
	private int team;
	
	public BuzzInMessage(int team){
		this.team = team;
	}
	
	public int getBuzzInTeam(){
		return team;
	}
}
