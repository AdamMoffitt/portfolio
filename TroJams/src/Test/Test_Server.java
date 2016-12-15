package Test;

import java.io.File;
import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.Vector;

public class Test_Server {
	
	private Vector<ServerThread> serverThreads;
	public Test_Server(int port) {
		ServerSocket ss = null;
		serverThreads = new Vector<ServerThread>();
		try {
			ss = new ServerSocket(port);
			while (true) {
				System.out.println("waiting for connection...");
				Socket s = ss.accept();
				System.out.println("connection from " + s.getInetAddress());
				ServerThread st = new ServerThread(s, this);
				serverThreads.add(st);
				st.sendMessage(new File("music/sunset_lover.mp3"));
			}
		} catch (IOException ioe) {
			System.out.println("ioe: " + ioe.getMessage());
		} finally {
			if (ss != null) {
				try {
					ss.close();
				} catch (IOException ioe) {
					System.out.println("ioe closing ss: " + ioe.getMessage());
				}
			}
		}
	}
	
//	public void sendMessageToAllClients(ChatMessage message) {
//		for (ServerThread st : serverThreads) {
//			st.sendMessage(message);
//		}
//	}
//	
	public static void main(String [] args) {
		new Test_Server(1111);
	}
}