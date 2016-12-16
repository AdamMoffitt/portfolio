package game_logic;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.Vector;

import other_gui.TeamGUIComponents;

public class FinalistsAndEliminatedTeams implements Serializable{

	//a list of the teams that qualified for final jeoapardy
	private Vector<TeamGUIComponents> finalists;
	private Set<Integer> finalistIndices;
	//a list of the teams who have been eliminated from the game (will not be in final jeopardy)
	private Vector<TeamGUIComponents> eliminatedTeams;
	private Set<Integer> eliminatedIndices;
	
	public FinalistsAndEliminatedTeams(List<TeamGUIComponents> teams) {
		this.finalists = new Vector<>();
		this.eliminatedTeams = new Vector<>();
		finalistIndices = new HashSet<>();
		eliminatedIndices = new HashSet<>();
		
		for (int i = 0; i<teams.size(); i++){
			
			TeamGUIComponents team = teams.get(i);
			//sort the team into the appropriate list: finalist, or loser
			if (team.getPoints() > 0) {
				finalists.add(team);
				finalistIndices.add(team.getTeamIndex());
			}
			
			else {
				eliminatedTeams.add(team);
				eliminatedIndices.add(team.getTeamIndex());
			}
		}
	}
	
	public List<TeamGUIComponents> getFinalists(){
		return finalists;
	}
	
	public List<TeamGUIComponents> getEliminatedTeams(){
		return eliminatedTeams;
	}

	public Set<Integer> getElimindatedTeamsIndices(){
		return eliminatedIndices;
	}
	//returns a list of the winning teams
	//note that the return type is and ArrayList<TeamData> NOT ArrayList<TeamGUIComponents>
	//this is because the WinnersGUI only needs to access the team name, it doesn't need the GUI information
	// yay abstraction!!
	public ArrayList<TeamData> getWinners(){
	
		ArrayList<TeamData> winners = new ArrayList<>();
		
		if (finalists.size() != 0){
			//sorts the finalists in order of their total score
			Collections.sort(finalists, TeamData.getComparator());
			//the team at the end of the list must have the highest score and is definitely a winner
			TeamData definiteWinner = finalists.get(finalists.size() - 1);
			long max = definiteWinner.getPoints();
			//if the max score is 0, we know that no one won the game
			if (max == 0) return winners;
			
			winners.add(definiteWinner);
			
			//check to see if there are other winners
			if (finalists.size() > 1){
				
				for (int i = finalists.size() -2; i > -1; i--){
			
					//if this team has the same score as the max, it must also be a winner
					if (finalists.get(i).getPoints() == max) winners.add(finalists.get(i));
				}	
			}
		}
		
		return winners;
	}

}
