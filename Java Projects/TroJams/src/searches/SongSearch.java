package searches;

import javax.swing.ImageIcon;

import networking.SearchSongMessage;
import networking.TrojamClient;

/*
 * SongSearch - takes in a string from the search JTextField. Iterates through the song list to check if it exists
 * and if it does, retrieve the song name, artist, and album artwork 
 */

public class SongSearch {
	
	private String songName, songArtist, imageFilePath, mp3FilePathOnServer;
	private ImageIcon songAlbumArtwork;
	private TrojamClient client;
	
	public SongSearch(String song, TrojamClient client) {
		songName = song;
		this.client = client;
		findSong();
		
		
	}
	
	private void findSong() {
		// goes to the server to check if the string songName is contained in the table col of songNames
		// if so, grab the string songInfo and string songArtist and jpg songAlbumArtwork 
		// and assign it to the local variables here?
		// else send an error message
		client.searchForSong(new SearchSongMessage(songName)); 
	}
	
	public String getSongInfo() {
		return songName;
	}
	
	public String getSongArtist() {
		return songArtist;
	}
	
	public ImageIcon getSongAlbumArtwork() {
		return songAlbumArtwork;
	}
}
