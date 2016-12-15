package music;

import java.io.Serializable;

import logic.PartySong;

public class SongData extends PartySong implements Serializable{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	String artist;
	String id;
	String imageURL;
	String playURL;

	public SongData(String name, String artist, String id, String imageURL, String playURL) {
		super(name);
		this.artist = artist;
		this.id = id;
		this.imageURL = imageURL;
		this.playURL = playURL;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getArtist() {
		return artist;
	}

	public void setArtist(String artist) {
		this.artist = artist;
	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getImageURL() {
		return imageURL;
	}

	public void setImageURL(String imageURL) {
		this.imageURL = imageURL;
	}

	public String getPlayURL() {
		return playURL;
	}

	public void setPlayURL(String playURL) {
		this.playURL = playURL;
	}

}
