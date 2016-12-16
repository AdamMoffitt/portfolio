package game_logic;

import java.util.List;

public class GameFile{
	//total number of people that have rated this file
	private int numRatings;
	//total rating
	private int totalRating;
	//lines of the file
	private List<String> fileLines;
	private String filePath;
	private String fileName;

	public GameFile(List<String> fileLines, int numRatings, int totalRating, String filePath, String fileName) {
		this.numRatings = numRatings;
		this.fileName = fileName;
		this.totalRating = totalRating;
		this.fileLines = fileLines;
		this.filePath = filePath;
	}
	
	public String getFileName(){
		return fileName;
	}
	
	public int getNumberOfRatings(){
		return numRatings;
	}
	
	public int getTotalRating(){
		return totalRating;
	}
	//get avergae rating
	public int getAverageRating(){
		if (totalRating == -1) return -1;
		return (int) Math.round((double) totalRating / (double) numRatings);
	}
	
	public List<String> getFileLines(){
		return fileLines;
	}

	public String getFilePath(){
		return filePath;
	}
}
