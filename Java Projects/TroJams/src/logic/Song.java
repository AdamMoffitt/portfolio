package logic;

import java.io.Serializable;

//regular song, gets uploaded to playlists but not parties!
public class Song implements Serializable{
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	protected String name;
	
	public Song(String name) {
		this.name = name;
	}
	
	public Song() {
		
	}
	
	public String getName() {
		return name;
	}
	
}
