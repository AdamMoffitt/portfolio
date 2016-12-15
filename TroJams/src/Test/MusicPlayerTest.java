package Test;

import java.io.FileInputStream;

import javazoom.jl.decoder.JavaLayerException;
import javazoom.jl.player.Player;

public class MusicPlayerTest extends Thread{

	
	// retrieve text from search, check if vector contains that song
	// call method with that song name
	Player playMP3;
	public MusicPlayerTest(String filepath){
	    try{
		    //FileInputStream fis = new FileInputStream("music/sunset_lover.mp3");
	    	FileInputStream fis = new FileInputStream(filepath);
		    playMP3 = new Player(fis);
		    this.start();
		    //playMP3.play();
		    //playMP3.
		    Thread.sleep(5000);
		    System.out.println("done sleeping");
		    
		    playMP3.close();
//		    while (!playMP3.isComplete()) {
//		    	
//		    }
		    System.out.println("finished");
//		    FileInputStream fis2 = new FileInputStream("music/closer.mp3");
//		    Player playMP3_2 = new Player(fis2);
//		    playMP3_2.play();
		    
	    }catch(Exception e){
	    	System.out.println(e);
	    }
	}
	
	public void run(){
		try {
			playMP3.play();
			//playMP3.
		} catch (JavaLayerException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public void close(){
		playMP3.close();
	}
	
	public static void main(String[] args){
		MusicPlayerTest m = new MusicPlayerTest("music/closer.mp3");
	}
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
