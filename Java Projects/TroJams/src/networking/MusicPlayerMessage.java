package networking;

import logic.Party;

public class MusicPlayerMessage extends Message{
	private Party p;
	private String songName;

	public MusicPlayerMessage(String name, Party p, String name1) {
		super(name1);
		this.p = p;
		this.songName = name1;
	}
	
	public String getSongName() {
		return songName;
	}
	
	public Party getParty() {
		return p;
	}

}
