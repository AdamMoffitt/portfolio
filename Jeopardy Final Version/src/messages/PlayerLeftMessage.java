package messages;

public class PlayerLeftMessage implements Message{
	private int team;
	
	public PlayerLeftMessage(int team){
		this.team = team;
	}
	
	public int getTeamWhoLeft(){
		return team;
	}
}
