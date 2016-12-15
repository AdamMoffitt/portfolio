package networking;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.net.Socket;

import logic.Account;
import logic.Party;
import logic.User;
import music.MusicPlayer;

public class TrojamServerThread extends Thread{
	private Socket socket;
	private TrojamServer trojamServer;
	private ObjectOutputStream oos;
	private ObjectInputStream ois;
	public Account account;
	private int threadNum;
	private boolean close;
	
	public TrojamServerThread(Socket socket, TrojamServer trojamServer, int numThreads) {
		this.socket = socket;
		this.trojamServer = trojamServer;
		this.account = null;
		this.threadNum = numThreads;
		this.close = false;
		try {
			oos = new ObjectOutputStream(socket.getOutputStream());
			oos.flush();
			ois = new ObjectInputStream(socket.getInputStream());
			
			this.start();

		} catch (IOException e) {}
	}
	
	public void setAccount(Account a) {
		System.out.println("setting account");
		this.account = a;
	}
	
	@Override
	public void run(){
		try {
			while (!close){
				Object obj = ois.readObject();
				 if (obj instanceof Account) {
					 System.out.println("received account");
					this.account = (Account) obj;
					//this.account.st = this;
				} 
				 else if (obj instanceof LeavePartyMessage) {
					 LeavePartyMessage lpm = (LeavePartyMessage) obj;
					 if (lpm.isHost()) {
						System.out.println("host left");
						trojamServer.hostLeft(this);
					 } else {
						System.out.println("partygoer left");
						trojamServer.clientLeft(this);
					 }
				 }
				 else if (obj instanceof AddSongMessage) {
					System.out.println("received song!");
					trojamServer.addNewSong((AddSongMessage)obj);
				}
				else if (obj instanceof RuthMessage) {
					System.out.println("ruth message");
					RuthMessage rm = (RuthMessage) obj;
					trojamServer.nextSong(rm.getPartyName());
				}
				 else if (obj instanceof String) {
					 String str = (String) obj;
					 if (str.equals("partyRequest")) {
						 sendMessage(new AllPartiesMessage("allParties", trojamServer.parties));
					 }
					 if (str.equals("guestMessage")) {
						 System.out.println("guest message");
						 String name = ((User)this.account).getUsername();
						 trojamServer.accountToThreadMap.put(name, this);
					 }
				 }
				else if (obj instanceof NewPartyMessage) {
					System.out.println("new party received by serverthread");
					NewPartyMessage pm = (NewPartyMessage) obj;
					User user = (User) account;
					user.setHost(true);
					trojamServer.addParty(user, pm);
					user.p = trojamServer.partyNamesToObjects.get(pm.getPartyName());
				} 
				else if (obj instanceof NewPartierMessage) {
					NewPartierMessage npm = (NewPartierMessage) obj;
					trojamServer.addPartyGuest(npm);
					account.p = trojamServer.partyNamesToObjects.get(npm.getPartyName());
					System.out.println("number of songs in party being sent of new partier = " + account.p.getSongs().size());
					sendMessage(new UpdatePartyMessage(account.p));
					
				} 
				else if (obj instanceof LoginMessage) {
					System.out.println("login message received by serverthread");
					//returns a boolean saying whether or not the password matched
					AuthenticatedLoginMessage login = trojamServer.authenticateLogin((LoginMessage)obj, this);
					sendMessage(login);
				} 
				else if(obj instanceof CreateAccountMessage){ 
					CreateAccountMessage cam = (CreateAccountMessage) obj;
					//returns a boolean of whether or not the account was created
					boolean accountCreated = trojamServer.createAccount(cam, this);
					sendMessage(new AccountCreatedMessage(accountCreated, cam.getUser()));
				} 
				else if (obj instanceof SongVoteMessage) {
					trojamServer.voteOnSong((SongVoteMessage) obj);
				}
				else if(obj instanceof SearchSongMessage){
					FoundSongMessage fsm = trojamServer.searchForSong(((SearchSongMessage) obj).getSongName());
					sendMessage(fsm);
				}
				else if (obj instanceof Message) {
					System.out.println("got a generic message");
					Message message = (Message) obj;
					trojamServer.sendMessageToAll(message);
				} 
			}
		} 
		catch (ClassNotFoundException e) {}
		catch (IOException e) {
			System.out.println("ioexception");
			try {
				System.out.println("in here");
				trojamServer.removeServerThread(this);
				this.close();
			} catch (IOException e1) {
				System.out.println("exception in client leaving in server thread");
			}
		}
	}
	
	private void close() throws IOException {
		System.out.println("closing serverthread");
		oos.close();
		ois.close();
		close = true;
	}

	public void sendMessage(Message message){
		try {
			System.out.println("sending a message with name : " + message.getName());
			if (this.account instanceof User) {
				System.out.println("sending message to " + ((User)account).getUsername());
			}
			oos.reset();
			oos.writeObject(message);
			oos.flush();
			System.out.println("message was sent to client");
		} catch (IOException e) {
			System.out.println("exception in sendMessage in server: " + e.getMessage() + " " + e.getLocalizedMessage());
			e.printStackTrace();
		}
	}

	public Account getAccount() {
		return account;
	}
	
	public int getThreadNum(){
		return threadNum;
	}

	public void hostPlayNextSong(Party p, String name) {
		MusicPlayerMessage mpm = new MusicPlayerMessage("blah", p, name);
		sendMessage(mpm);
	}

}
