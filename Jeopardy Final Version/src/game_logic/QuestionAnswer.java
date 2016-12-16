package game_logic;

import java.io.Serializable;

public class QuestionAnswer implements Serializable{
	
	protected String question;
	protected String answer;
	protected Boolean asked;
	protected String category;
	protected int pointValue;
	
	//indices of this question
	private int x;
	private int y;
	
	public QuestionAnswer(String question, String answer, String category, int pointValue, int x, int y){
		this.question = question;
		this.answer = answer;
		this.category = category;
		this.pointValue = pointValue;
		this.x = x;
		this.y = y;
		
		asked = false;
	}
	
	//GETTERS
	public int getX(){
		return x;
	}
	
	public int getY(){
		return y;
	}
	
	public String getQuestion(){
		return question;
	}
	
	public String getAnswer(){
		return answer;
	}
	
	public String getCategory(){
		return category;
	}
	
	public int getPointValue(){
		return pointValue;
	}
	
	public void setAsked(){
		asked = true;
	}
	
	public boolean isAsked(){
		return asked;
	}
	
	//bug fix!
	public static boolean correctAnswer(String givenAnswer, String expectedAnswer){
		boolean correctAnswer = false;
		String [] splitAnswer = givenAnswer.trim().toLowerCase().split("\\s+");
		
		if (splitAnswer.length >= 3){
			
			StringBuilder answer = new StringBuilder();
			for (int i = 2; i< splitAnswer.length; i++) answer.append(splitAnswer[i]);
			
			if (answer.toString().equals(expectedAnswer.toLowerCase())){
				correctAnswer = true;
			}
		}
		
		return correctAnswer;
	}

}
