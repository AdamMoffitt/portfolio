package networking;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.swing.ImageIcon;

public class FoundSongMessage extends Message{
	private String song_name, artist, album, artwork_filepath, mp3_filepath;
	boolean found_song;
	private byte[] file;
	
	public FoundSongMessage(ResultSet rs) {
		super("FoundSong");
		try {
			song_name = rs.getString("song_name");
			artist = rs.getString("artist");
			album = rs.getString("album");
			artwork_filepath = rs.getString("artwork_filepath");
			mp3_filepath = rs.getString("mp3_filepath");
			found_song = true;
			try {
				File f = new File(artwork_filepath);
				this.file = Files.readAllBytes(f.toPath());
				
			} catch (IOException e) {
				//TODO we should probably have some better sort of catch block here
				System.out.println("File not found");
				e.printStackTrace();
			}
			
		} catch (SQLException e) {
			found_song = false;
			e.printStackTrace();
		}
		
		
	}

	public FoundSongMessage(boolean b) {
		super("FoundSong");
		found_song = b;
	}
	
	public boolean getFoundSong(){
		return found_song;
	}
	
	public String getSongName(){
		return song_name;
	}
	
	public String getArtist(){
		return artist;
	}
	
	public String getAlbum(){
		return album;
	}
	
	public String getArtworkFilepath(){
		return artwork_filepath;
	}
	
	public String getmp3FilePath(){
		return mp3_filepath;
	}
	
	public ImageIcon getActualImage(){
		//writes the image to a file
		//TODO comment out the return null and find a way to read the image from file and return that
		File f = new File("junk_bin/"+artwork_filepath);
		System.out.println("Trying to write to file at path: junk_bin/"+ artwork_filepath);
		try {
			Files.write(f.toPath(), file);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return null;
	}

}
