package music;

import java.io.FileInputStream;

import javazoom.jl.decoder.JavaLayerException;
import javazoom.jl.player.Player;
import logic.Party;
import networking.TrojamClient;

public class MusicPlayer extends Thread{

	
	// retrieve text from search, check if vector contains that song
	// call method with that song name
	Player playMP3;
	Party p;
	private TrojamClient tc;
	public MusicPlayer(String filePath, Party p, TrojamClient tc){
	    try{
		    //FileInputStream fis = new FileInputStream("music/sunset_lover.mp3");
	    	FileInputStream fis = new FileInputStream(filePath);
	    	System.out.println("Filepath: " + filePath);
	    	this.p = p;
	    	this.tc = tc;
		    playMP3 = new Player(fis);
		    
		    this.start();
		    
	    }catch(Exception e){
	    	System.out.println(e);
	    }
	}
	
	public void run(){
		try {
			playMP3.play();
			
			while (true) {
				if (playMP3.isComplete()) {
					System.out.println("next song playing");
					//ts.nextSong(p.getPartyName());
					tc.songEnded(p.getPartyName());
					break;
				}
			}
			System.out.println("ended while loop");
			//playMP3.
		} catch (JavaLayerException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	}
	public void endSong(){
		if(playMP3 != null){
			playMP3.close();
		}
	}
	
//	public static void main(String[] args){
//		MusicPlayerTest m = new MusicPlayerTest();
//	}
}








//
//import java.io.File;
//
//import javax.sound.sampled.AudioInputStream;
//import javax.sound.sampled.AudioSystem;
//import javax.sound.sampled.Clip;
//
//public class MusicPlayerTest {
//
//	public static void main(String[] args){
//		//playSound();
//	}
//
//
////	public static synchronized void playSound(final String url) {
////        new Thread(new Runnable() {
////          public void run() {
////            try {
////              Clip clip = AudioSystem.getClip();
////              AudioInputStream inputStream = AudioSystem.getAudioInputStream(ChatClient.class.getResourceAsStream("/resources/" + url));
////              clip.open(inputStream);
////              clip.start();
////            } catch (Exception e) {
////              System.err.println(e.getMessage());
////            }
////          }
////        }).start();
////      }
//
//
//
//
//
//	public static void playSound() {
//		while(true){
//		    try {
//		        AudioInputStream audioInputStream = AudioSystem.getAudioInputStream(new File("pig.wav").getAbsoluteFile());
//		        Clip clip = AudioSystem.getClip();
//		        clip.open(audioInputStream);
//		        clip.start();
//		    } catch(Exception ex) {
//		        System.out.println("Error with playing sound.");
//		        ex.printStackTrace();
//		    }
//		}
//	}
//}
