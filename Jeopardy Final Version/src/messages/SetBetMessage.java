package messages;

public class SetBetMessage implements Message{
	private int team;
	private int bet;
	
	public SetBetMessage(int team, int bet){
		this.team = team;
		this.bet = bet;
	}
	
	public int getTeamThatBet(){
		return team;
	}
	
	public int getBet(){
		return bet;
	}
}
