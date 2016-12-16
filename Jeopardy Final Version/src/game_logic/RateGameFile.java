package game_logic;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;

public class RateGameFile {

	public void writeToFile(GameData gameData, int rating, int numRatings){
		GameFile gameFile = gameData.getGameFile();
		FileWriter fw = null;
		BufferedWriter bw = null;
		
		try {
			//getting file path from the game file object
			fw = new FileWriter(gameFile.getFilePath());
			bw = new BufferedWriter(fw);
			//writing out all the lines of the game file 
			for (String line : gameFile.getFileLines()){
				bw.write(line);
				bw.newLine();
			}
			//if the game has never been rated before
			if (gameFile.getNumberOfRatings() == -1){
				bw.write(Integer.toString(numRatings));
				bw.newLine();
				bw.write(Integer.toString(rating));
			}
			//game has been rated before
			else{
				bw.write(Integer.toString(gameFile.getNumberOfRatings()+numRatings));
				bw.newLine();
				bw.write(Integer.toString(gameFile.getTotalRating()+rating));
			}
			//flush the stream
			bw.flush();
		} 
		
		catch (IOException e) {}
		
		finally{
			try {
				if (bw != null) bw.close();
				if (fw != null) fw.close();
			} 
			
			catch (IOException e) {}
		}
	}

}
