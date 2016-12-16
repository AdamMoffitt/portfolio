package messages;

public class RestartGameMessage implements Message{

	private int firstTeam;
	public RestartGameMessage(int team){
		this.firstTeam = team;
	}
	
	public int getFirstTeam(){
		return firstTeam;
	}
}
