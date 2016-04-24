#include "maze.h"
#include "kruskalishmaze.h"

Maze::Maze(int numRows, int numCols, int startRow, int startCol, int goalRow, int goalCol)
: _rows(numRows), _cols(numCols), _startRow(startRow), _startCol(startCol),
  _goalRow(goalRow), _goalCol(goalCol)
{}

int Maze::numRows() const
{
	return _rows;
}

int Maze::numCols() const
{
	return _cols;
}

int Maze::getGoalRow() const
{
    return _goalRow;
}

int Maze::getGoalCol() const
{
    return _goalCol;
}


int Maze::getStartRow() const
{
    return _startRow;
}

int Maze::getStartCol() const
{
    return _startCol;
}


Maze * createMaze(int numRows, int numCols, bool simpleMaze)
{
    return new KruskalishMaze(numRows, numCols, 0, 0, numRows-1, numCols-1, simpleMaze);
}
