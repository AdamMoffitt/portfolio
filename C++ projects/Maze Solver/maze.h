#ifndef __MAZE_H
#define __MAZE_H

#include <cstdint>
#include <vector>

// strongly typed enums can't be autoconverted to ints, which I want for MazeSquare
enum Direction {UP=0, DOWN=1, LEFT=2, RIGHT=3};

class Maze
{

public:
	int numRows() const;
	int numCols() const;

    int getStartRow() const;
    int getStartCol() const;

    int getGoalRow() const;
    int getGoalCol() const;
		
	virtual bool canTravel(Direction d, int row, int col) const = 0;

    virtual ~Maze(){}

protected:
    // creates a Maze with the given dimensions and start/end coordinates.
    // Note that this is protected:  you cannot call it.  Call the
    // createMaze function, provided below.
    Maze(int numRows, int numCols, int startRow, int startCol, int goalRow, int goalCol);


private:
    int _rows, _cols, _startRow, _startCol, _goalRow, _goalCol;

};


/*
 * Call this, not a constructor, if you want a Maze to work with.
 */
Maze * createMaze(int numRows, int numCols, bool simpleMaze);


#endif
