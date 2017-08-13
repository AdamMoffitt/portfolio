package networking;

import music.SongData;

public class AddSongMessage extends Message{
	SongData songInfo;
	public String partyName;

	public AddSongMessage(String name, SongData songInfo, String partyName) {
		super(name);
		this.songInfo = songInfo;
		this.partyName = partyName;
	}

}
