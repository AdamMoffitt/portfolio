package networking;

import logic.Party;

public class PlayNextSongMessage extends Message {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private Party party;
	private String songName;

	public PlayNextSongMessage(Party p, String songName) {
		super("nextSong");
		this.party = p;
		this.songName = songName;
	}
	
	public Party getParty() {
		return party;
	}
	
	public String getSongName() {
		return songName;
	}
	

}
