package main;

import java.awt.Image;
import java.util.ArrayList;

import javax.swing.ImageIcon;

import frames.SelectionWindow;
import logic.Party;
import logic.PartySong;
import logic.PrivateParty;
import logic.PublicParty;
import logic.User;
import networking.NewPartyMessage;
import networking.TrojamClient;

public class TestServerFunctionality {
	public static void main (String [] args) {
		User u = new User("testUser", false);
		User u2 = new User("Hunter", false);
		User u3 = new User("Clairisse", false);
		User u4 = new User("Adam", false);
		
		Image image = new ImageIcon("images/party-purple.jpg").getImage();
		ImageIcon tempImage = new ImageIcon(image.getScaledInstance(200, 200, java.awt.Image.SCALE_SMOOTH));
		//PrivateParty p1 = new PrivateParty("party1", "password1", u2, tempImage);
		//p1.addSong(new PartySong("song1", 10.0));
		//p1.addSong(new PartySong("song2", 10.0));
		PrivateParty p2 = new PrivateParty("party2", "password2", u3, "images/party-purple.jpg");
		PublicParty p3 = new PublicParty("party3", u4, "images/party-purple.jpg");
		ArrayList <Party> parties = new ArrayList <Party>();
		
		//parties.add(p1);
		parties.add(p2);
		parties.add(p3);
		TrojamClient tj = new TrojamClient("10.120.17.26", 6789);
		tj.setAccount(u);
		
		SelectionWindow sw = new SelectionWindow(u, parties, tj);
		tj.setSelectionWindow(sw);
		sw.setVisible(true);
		
		
		TrojamClient tj2 = new TrojamClient("10.120.17.26", 6789);
		tj2.setAccount(u2);
		//tj2.sendNewPartyMessage(new  NewPartyMessage("party", "party1", "password1"));
		SelectionWindow sw2 = new SelectionWindow(u, parties, tj2);
		tj2.setSelectionWindow(sw2);
		sw2.setVisible(true);
	}
	
}
