package Test;



import java.io.File;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.net.Socket;
import java.nio.file.Files;

public class ServerThread extends Thread {

	private ObjectInputStream ois;
	private ObjectOutputStream oos;
	private Test_Server cs;
	public ServerThread(Socket s, Test_Server cs) {
		try {
			this.cs = cs;
			oos = new ObjectOutputStream(s.getOutputStream());
			ois = new ObjectInputStream(s.getInputStream());
			this.start();
		} catch (IOException ioe) {
			System.out.println("ioe: " + ioe.getMessage());
		}
	}
	
	public void sendMessage(File mp3File) {
		try {
			System.out.println("in sendmessage");
			File f = mp3File;
			byte[] content = Files.readAllBytes(f.toPath());
			oos.writeObject(content);
			System.out.println("pre-flush");
			oos.flush();
			System.out.println("flushed");
		} catch (IOException ioe) {
			System.out.println("ioe: " + ioe.getMessage());
		}
	}

	public void run() {
		
		while(true) {
				//ChatMessage message = (ChatMessage)ois.readObject();
				//cs.sendMessageToAllClients(message);
			}
//		} catch (ClassNotFoundException cnfe) {
//			System.out.println("cnfe in run: " + cnfe.getMessage());
//		} catch (IOException ioe) {
//			System.out.println("ioe in run: " + ioe.getMessage());
//		}
	}
}