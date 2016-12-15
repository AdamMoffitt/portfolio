package networking;

import logic.Party;
import logic.PartySong;
import music.SongData;

public class SongVoteMessage extends Message{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	
	private Party party;
	private SongData song;

	public SongVoteMessage(String name, Party party, SongData song) {
		super(name);
		this.party = party;
		this.song = song;
	}
	
	public Party getParty() {
		return party;
	}
	
	public SongData getSong() {
		return song;
	}

	

}
