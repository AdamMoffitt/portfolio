package networking;

public class SearchSongMessage extends Message{

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private String songName;
	
	public SearchSongMessage(String songName) {
		super("searchSongMessage");
		this.songName = songName;
	}
	
	public String getSongName(){
		return songName;
	}

}
