package action_factory;

import java.util.HashMap;

import messages.BuzzInMessage;
import messages.FJAnswerMessage;
import messages.NextTurnMessage;
import messages.NoOneBuzzedInInTimeMessage;
import messages.PlayerLeftMessage;
import messages.QuestionAnsweredMessage;
import messages.QuestionClickedMessage;
import messages.RestartGameMessage;
import messages.SetBetMessage;
import messages.StartTimerMainMessage;
import messages.StartTimerQuestionMessage;

//this is not like the factory code, completely unrelated!!
//this technique is called a factory pattern, helpful for OO programming and takes advantage of polymorphism
//helpful link: http://best-practice-software-engineering.ifs.tuwien.ac.at/patterns/factory.html
//basically instead of having an if statement in my client's run() that does different things depending on the
//class of the message, I have this factory class with a singleton map that correlates the class of the message
//with the appropriate action that the program should take. All the actions inherit from the the abstract
//class Action, and all implement the execute() method. Now, instead of an if or switch statement in my client,
//I can have an ActionFactory member variable, and simply get the appropriate action from the map, and call
//execute with the appropriate parameters. This is a much more efficient and scalable solution than a switch statement!
//if in the future, my client needs to be able to handle new messages and actions, I don't have to touch my client
//code at all! All I have to do is create the Message, and the Action classes, and add them to my map in here

public class ActionFactory {

private static HashMap<Class<?>, Action> actionMap;

	public ActionFactory(){

		if (actionMap == null){
			actionMap = new HashMap<>();
			actionMap.put(QuestionClickedMessage.class, new QuestionClickedAction());
			actionMap.put(QuestionAnsweredMessage.class, new QuestionAnsweredAction());
			actionMap.put(BuzzInMessage.class, new BuzzInAction());
			actionMap.put(RestartGameMessage.class, new RestartGameAction());
			actionMap.put(PlayerLeftMessage.class, new PlayerLeftAction());
			actionMap.put(SetBetMessage.class, new SetBetAction());
			actionMap.put(FJAnswerMessage.class, new FJAnswerAction());
			actionMap.put(NextTurnMessage.class, new NextTurnAction());
			actionMap.put(StartTimerQuestionMessage.class, new StartTimerQuestionAction());
			actionMap.put(StartTimerMainMessage.class, new StartTimerMainAction());
			actionMap.put(NoOneBuzzedInInTimeMessage.class, new NoOneBuzzedInInTimeAction());
		}
	}

	public Action getAction(Class<?> messageClass){
		return actionMap.get(messageClass);
	}

}
