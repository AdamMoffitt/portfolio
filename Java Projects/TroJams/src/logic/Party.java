package logic;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map.Entry;

import javax.swing.ImageIcon;

import music.SongData;

public abstract class Party implements Serializable{

	/**
	 *
	 */
	private static final long serialVersionUID = 1L;
	private String partyName;
	public User host;
	public ArrayList <SongData> partySongList = new ArrayList<SongData>();
	public HashMap <String, Integer> songSet = new HashMap<String, Integer>();
	private HashSet <Account> partyMembers;
	private ImageIcon partyImage;
	private String imageFilePath;

	//abstract class for a party
	public Party (String partyName, User host) {
		this.partyName = partyName;
		this.host = host;
		partyMembers = new HashSet<Account>();
		//partyImage = new ImageIcon("images/party-purple.jpg");
		imageFilePath = "party_pics/party-purple.jpg";
	}

	public Party (String partyName, User host, String fp) {
		this(partyName, host);
		System.out.println("filepath in constructor for party is: "+fp);
		this.imageFilePath = "party_pics/"+fp;
	}

	public String getImageFilePath(){
		return imageFilePath;
	}

	public ArrayList<SongData> getSongs() {
		return partySongList;
	}

	public HashSet <Account> getPartyMembers() {
		return partyMembers;
	}

	public User getHost() {
		return host;
	}

	public String getPartyName() {
		return partyName;
	}

	public String getHostName() {
//		if (host == null) {
//			host = new User("u", "u", "u", "u");
//		}
		return host.getUsername();
	}

	public ImageIcon getPartyImage() {
		return partyImage;
	}

	public void setPartyImage(ImageIcon partyImage) {
		this.partyImage = partyImage;
	}

	public void leaveParty(Account account) {
		partyMembers.remove(account);
	}

	//add a user to the party
	public void addAccount(Account account) {
		partyMembers.add(account);
	}

	public void addSong(SongData song) {
		if (songSet.containsKey(song)) {
			return;
		}
		System.out.println("adding song " + song.getName() + " by " + song.getArtist());
		partySongList.add(song);
		songSet.put(song.getName(), partySongList.size()-1);
	}

	public void upvoteSong(SongData song) {

		int loc = songSet.get(song.getName());
		System.out.println("loc is ..." + loc);
		partySongList.get(loc).upvote();
		
		System.out.println("loc is " + loc);
		//if already at first location, do nothing
		if (loc == 1) {
			return;
		}
		
		//look at the indices before in the array and keep swapping while the
		//number of votes of loc - 1 is less than the number of votes of song
		while (loc > 1 && partySongList.get(loc - 1).getVotes() < partySongList.get(loc).getVotes()) {
			SongData tempSong = partySongList.get(loc-1);
			songSet.put(tempSong.getName(), loc);
			songSet.put(song.getName(), loc - 1);
			partySongList.set(loc, tempSong);
			partySongList.set(loc - 1, song);
			loc --;
		}
	}

	public void downvoteSong(SongData song) {
		int loc = songSet.get(song.getName());
		partySongList.get(loc).downvote();
		//if already at last location, do nothing
		if (loc == partySongList.size()-1) {
			return;
		}
		//look at the indices after in the array and keep swapping while the
		//number of votes of loc + 1 is greater than the number of votes of song
		while (loc < (partySongList.size() -1) && partySongList.get(loc + 1).getVotes() > partySongList.get(loc).getVotes()) {
			SongData tempSong = partySongList.get(loc+1);
			songSet.put(tempSong.getName(), loc);
			songSet.put(song.getName(), loc + 1);
			partySongList.set(loc, tempSong);
			partySongList.set(loc + 1, song);
			loc ++;
		}
	}

	public void playNextSong() {
		//String fp = "music/"+partySongList.get(0).getName()+".mp3";
		partySongList.remove(0);
		//decrement indices of songs since the 0th song has been removed from the array
		for (Entry<String, Integer>  e: songSet.entrySet()) {
			e.setValue(e.getValue()-1);
		}
	}

	public void setImageFilePath(String imageFilePath) {
		this.imageFilePath = imageFilePath;
	}


}
