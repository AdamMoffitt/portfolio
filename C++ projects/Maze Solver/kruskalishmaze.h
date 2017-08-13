#ifndef __KRUSKALISH_MAZE_H
#define __KRUSKALISH_MAZE_H

#include <vector>
#include "maze.h"


/*
 * A Maze is a 2D vector of MazeSquare objects.
 * By default, each square has four walls surrounding it.
 * It's an oversight in this design that the way this is written
   could be used to have one-way movements in the maze.
 */
struct MazeSquare{
	bool walls[4];
	MazeSquare(){ walls[UP] = walls[DOWN] = walls[LEFT] = walls[RIGHT] = true; }
};


class KruskalishMaze : public Maze
{
public:
    KruskalishMaze(int numRows, int numCols, int startX, int startY, int goalX, int goalY, bool simple);

    virtual bool canTravel(Direction d, int row, int col) const;

private:
	std::vector<std::vector<MazeSquare>> _maze;	
    void createMaze(bool simpleMaze);
	void destroyWall(Direction d, int row, int col); 

};

#endif
