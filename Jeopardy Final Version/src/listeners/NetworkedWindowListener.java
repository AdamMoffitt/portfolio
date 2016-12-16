package listeners;

import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;

import javax.swing.JFrame;

import messages.PlayerLeftMessage;
import server.Client;
//used as the window listner on MainGUINetworked and WinnersAnd RatingGUINetworked
public class NetworkedWindowListener extends WindowAdapter{

	private Client client;
	private JFrame jframe;
	
	public NetworkedWindowListener(Client client, JFrame jframe) {
		this.client = client;
		this.jframe = jframe;
	}

	@Override
	public void windowClosing(WindowEvent e) {
		client.sendMessage(new PlayerLeftMessage(client.getTeamIndex()));
		jframe.dispose();
	}

}
