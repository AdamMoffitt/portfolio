package Test;

import java.io.File;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.net.Socket;
import java.nio.file.Files;
import java.util.Scanner;

public class Test_Client extends Thread {

	private ObjectInputStream ois;
	private ObjectOutputStream oos;
	public Test_Client(String hostname, int port) {
		Socket s = null;
		Scanner scan = null;
		try {
			s = new Socket(hostname, port);
			oos = new ObjectOutputStream(s.getOutputStream());
			ois = new ObjectInputStream(s.getInputStream());
			this.start();
			//scan = new Scanner(System.in);
//			while(true) {
//				String line = scan.nextLine();
//				ChatMessage message = new ChatMessage("Hunter", line);
//				oos.writeObject(message);
//				oos.flush();
//			}
		} catch (IOException ioe) {
			System.out.println("ioe: " + ioe.getMessage());
		} finally {
			try {
				if (s != null) {
					s.close();
				}
				if (scan != null) {
					scan.close();
				}
			} catch (IOException ioe) {
				System.out.println("ioe: " + ioe.getMessage());
			}
		}
	}
	
	public void run() {
		try {
			while(true) {
				
//				ChatMessage message = (ChatMessage)ois.readObject();
//				System.out.println(message.getName() + ": " + message.getMessage());
				byte[] content = (byte[]) ois.readObject();
				File f = new File("song_bin/curr_song.mp3");
				Files.write(f.toPath(), content);
				System.out.println("line 54 test_client");
				
			}
		} catch (ClassNotFoundException cnfe) {
			System.out.println("cnfe: " + cnfe.getMessage());
		} catch (IOException ioe) {
			System.out.println("ioe: " + ioe.getMessage());
		}
	}
	
	public static void main(String [] args) {
		new Test_Client("localhost", 1111);
	}
}