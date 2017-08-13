package networking;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.net.Socket;

import frames.LoginScreenWindow;
import frames.SelectionWindow;
import logic.Account;
import logic.Party;
import logic.User;
import music.MusicPlayer;
import music.SongData;

public class TrojamClient extends Thread{
	private Account account;
	private Socket s;
	private ObjectOutputStream oos;
	private ObjectInputStream ois;
	private SelectionWindow sw;
	private LoginScreenWindow lsw;
	private boolean close;
	private MusicPlayer mp;
	private Party p;

	public TrojamClient(String IPAddress, int port) {
		this.account = null;
		this.sw = null;
		close = false;
		try {
			s = new Socket(IPAddress, port);
			oos = new ObjectOutputStream(s.getOutputStream());
			//oos.flush();
			ois = new ObjectInputStream(s.getInputStream());
			//before we enter the run method, we want to request parties

			this.start();

		} catch (NumberFormatException | IOException e) {
			System.out.println("yo");
		}
	}

	public void receiveLoginScreen(LoginScreenWindow lsw){
		this.lsw = lsw;
	}

	public void setSelectionWindow(SelectionWindow sw) {
		System.out.println("setting selection window");
		this.sw = sw;
		try {
			oos.writeObject("guestMessage");
			oos.flush();
			System.out.println("guest message sent");
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public Account getAccount() {
		return account;
	}

	public void partyRequest() {
		try {
			System.out.println("got party request");
			oos.writeObject("partyRequest");
			oos.flush();
			System.out.println("party request sent");
		} catch (IOException e) {
			e.printStackTrace();
		}

	}

	public void setAccount(Account a) {
		this.account = a;
		try {
			oos.writeObject(a);
			oos.flush();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		//this.start();
	}

	@Override
	public void run() {
		try{
			while(!close) {
				Object obj = ois.readObject();
				System.out.println("got message");
				//handle different types of messages
				if (obj instanceof StringMessage) {
					StringMessage message = (StringMessage) obj;
					parseStringMessage(message);
				}
				else if (obj instanceof MusicPlayerMessage) {
					MusicPlayerMessage mpm = (MusicPlayerMessage)obj;
					mp = new MusicPlayer("music/" + mpm.getSongName() + ".mp3", mpm.getParty(), this);
				}
				else if (obj instanceof HostEndingPartyMessage) {
					sw.endParty();
					account.p = null;
					if (mp != null) {
						mp.endSong();
					}
				}
				else if (obj instanceof PlayNextSongMessage) {
					System.out.println("got a playnextsongmessage");
					sw.sendCurrentlyPlayingUpdate((PlayNextSongMessage) obj);
				}
				else if (obj instanceof AllPartiesMessage) {
					try {
						Thread.sleep(1000);
					} catch (InterruptedException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
					if (sw != null) {
						sw.setParties(((AllPartiesMessage) obj).getParties());
					}
				}
				else if (obj instanceof SongVoteMessage) {
					System.out.println("client has received song message!");
					this.sw.sendSongVoteUpdate((SongVoteMessage) obj);
				}
				else if (obj instanceof UpdatePartyMessage){
					System.out.println("Received update party message");
					System.out.println("num songs received by client = " + ((UpdatePartyMessage) obj).getParty().getSongs().size());
					this.sw.updatePanel(((UpdatePartyMessage) obj).getParty());
				}
				else if (obj instanceof PartyMessage) {
					PartyMessage pm = (PartyMessage) obj;
					sw.addNewParty(pm.getParty());
				}
				else if(obj instanceof AuthenticatedLoginMessage){
					System.out.println("client received loginmessage");
					AuthenticatedLoginMessage alm = (AuthenticatedLoginMessage) obj;
					lsw.attemptLogIn(alm);
				}
				else if(obj instanceof AccountCreatedMessage){
					System.out.println("client received account created message");
					AccountCreatedMessage acm = (AccountCreatedMessage) obj;
					lsw.createAccount(acm.accountCreated(), acm.getUser());
				}
				else if(obj instanceof FoundSongMessage){
					System.out.println("client received found song message");
					sw.getPartyWindow().receiveSongInfo((FoundSongMessage)obj);
				}
			}
		}catch (ClassNotFoundException | IOException e) {}
	}

	public void attemptToLogin(String username, String password){
		try {
			oos.writeObject(new LoginMessage(username, password));
			oos.flush();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public void leaveParty() {
		try {
			boolean ih = false;
			if ((account instanceof User) && (account.p != null)) {
				ih = ((User)account).getUsername().equals(account.p.host.getUsername());
				System.out.println("host is " + ih);
			}
			oos.writeObject(new LeavePartyMessage("lpm", ih));
			oos.flush();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public void close(){
		try {
			close = true;
			s.close();
			oos.close();
			ois.close();
		} catch (IOException e) {}

	}

	public void sendNewPartyMessage(NewPartyMessage npm) {
		try {
			oos.writeObject(npm);
			oos.flush();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	//handle string messages sent to the client
	private void parseStringMessage(StringMessage message) {
		String name = message.getName();
		String content = message.getContent();
		if (name.equals("teamLeft")) {
			//perform action for when an account leaves the party
		} else if (name.equals("songAdded")) {
			//perform action for when a song is added to the party
		} else if (name.equals("songUpvoted")) {
			//perform action for when a song is upvoted
		} else if (name.equals("songDownvoted")) {
			//perform action for when a song is downvoted
		}

	}

	public void createAccount(User newUser, String password) {
		try {
			oos.writeObject(new CreateAccountMessage(newUser, password));
			oos.flush();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public void sendVotesChange(Party party, SongData partySong, String voteType) {
		System.out.println(partySong.getName() + " was voted");
		try {
			oos.writeObject(new SongVoteMessage(voteType, party, partySong));
			oos.flush();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public void addNewPartier(String partyName) {
		System.out.println("adding new guest to party " + partyName);
		try {
			oos.writeObject(new NewPartierMessage("newParties", account, partyName));
			oos.flush();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public void searchForSong(SearchSongMessage ssm) {
		try{
			oos.writeObject(ssm);
			oos.flush();
		} catch (IOException e){
			e.printStackTrace();
		}
	}

	public void addNewSong(SongData songInfo, String partyName) {
		try{
			oos.writeObject(new AddSongMessage("newSong", songInfo, partyName));
			oos.flush();
		} catch (IOException e){
			e.printStackTrace();
		}

	}

	public void songEnded(String partyName) {
		try{
			System.out.println("client sending a ruthmessage");
			oos.writeObject(new RuthMessage("Song", partyName));
			oos.flush();
		} catch (IOException e){
			e.printStackTrace();
		}

	}
}
