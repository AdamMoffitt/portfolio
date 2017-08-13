#include "kruskalishmaze.h"
#include "ufds.h"
#include <cstdlib>
#include <time.h>

KruskalishMaze::KruskalishMaze(int numRows, int numCols, int startX, int startY, int goalX, int goalY, bool simple)
: Maze(numRows, numCols, startX, startY, goalX, goalY),  _maze(numRows)
{
	for (int i=0; i < numRows; i++)
	{
		_maze[i].resize( numCols );
	}
    createMaze(simple);
}

bool KruskalishMaze::canTravel(Direction d, int row, int col) const
{
	return ! _maze[row][col].walls[d];
}


void KruskalishMaze::destroyWall(Direction d, int row, int col)
{
	_maze[row][col].walls[d] = false;
}


Direction randdir()
{
	switch( rand() % 4 )
	{
	case 0: return UP;
	case 1: return DOWN;
	case 2: return LEFT;
	default: return RIGHT;
	}
}




/*
 * Creates a Maze where any two squares have a unique path between them
   in a Kruskalish fashion.
 */
void KruskalishMaze::createMaze(bool simpleMaze)
{
	long seed = time(NULL);
	srand(seed);

	int rows = numRows();
	int cols = numCols();

	UnionFind uf(rows * cols);
	int numComponents = rows * cols;

	int row, col, otherrow, othercol, component1, component2;
	Direction dir, otherdir;
	while( numComponents > 1 )
	{
		row = otherrow = rand() % numRows();
		col = othercol = rand() % numCols();
		
		dir = randdir();
		
		switch(dir)
		{
		case UP: otherrow--; otherdir = DOWN; break;
		case DOWN: otherrow++; otherdir = UP; break;
		case LEFT: othercol--; otherdir = RIGHT; break;
		case RIGHT: othercol++; otherdir = LEFT; break;
		}
		component1 = row * numRows() + col;
		component2 = otherrow * numRows() + othercol;
		
		if( otherrow >= 0 && otherrow < numRows() 
		 && othercol >= 0 && othercol < numCols() 
		 && ! uf.same(component1, component2) )
		{
			destroyWall(dir, row, col);
			destroyWall(otherdir, otherrow, othercol);
			uf.merge(component1, component2);
			numComponents--;
		}
    }

    // The maze now has a unique solution.  That's a simple maze.
    // If we don't want a simple maze, let's destroy some interior walls.
    if( ! simpleMaze )
    {
        const int WALLS_TO_DESTROY = numRows() * numCols() / 10;
        for( int i=0; i < WALLS_TO_DESTROY; i++)
        {

            row = otherrow = rand() % numRows();
            col = othercol = rand() % numCols();

            dir = randdir();

            switch(dir)
            {
            case UP: otherrow--; otherdir = DOWN; break;
            case DOWN: otherrow++; otherdir = UP; break;
            case LEFT: othercol--; otherdir = RIGHT; break;
            case RIGHT: othercol++; otherdir = LEFT; break;
            }

            if( otherrow >= 0 && otherrow < numRows()
             && othercol >= 0 && othercol < numCols() )
            {
                destroyWall(dir, row, col);
                destroyWall(otherdir, otherrow, othercol);
            }
            else
                i--;

        }
    }
}
