package messages;

public class QuestionClickedMessage implements Message{
	private int xIndex;
	private int yIndex;
	
	public QuestionClickedMessage(int x, int y){
		this.xIndex = x;
		this.yIndex = y;
	}
	
	public int getX(){
		return xIndex;
	}
	
	public int getY(){
		return yIndex;
	}
}
