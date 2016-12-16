package messages;

public class QuestionAnsweredMessage implements Message{

	private String answer;
	
	public QuestionAnsweredMessage(String answer){
		this.answer = answer;
	}
	
	public String getAnswer(){
		return answer;
	}
}
