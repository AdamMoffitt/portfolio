package logic;

import java.util.ArrayList;

public class Playlist {
	
	private ArrayList <Song> songs;
	private String name;
	private User user;
	
	public Playlist(String name, User user) {
		this.name = name;
		this.user = user;
	}
	
	public String getName() {
		return name;
	}
	
	public User getUser() {
		return user;
	}
	
	public void addSong(Song song) {
		songs.add(song);
	}
	
}
