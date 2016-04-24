//This program creates a sample maze

#include "maze.h"
#include "ufds.h"
#include "kruskalishmaze.h"
#include <iostream>
using namespace std;

void outputMaze(const Maze * m);

int main()
{
	Maze * m = createMaze(10,10);

	outputMaze(m);	
}



void outputMaze(const Maze * m)
{
	const int SQUARE_SIZE = 4; // width and height of Maze squares for this.
	
	// output the top:
	int i,j, k;
	for(j=0; j < m->numCols(); j++)
	{
		cout << "+";
		for(k=0; k < SQUARE_SIZE; k++)
			cout << "-";
	}
	cout << "+" << endl;
	
	for(i=0; i < m->numRows(); i++)
	{
		cout << "|";
		for (j=0; j < m->numCols(); j++)
		{
			for(k=0; k < SQUARE_SIZE; k++)
				cout << " ";
			if( ! m->canTravel(RIGHT, i, j) )
				cout << "|";
			else
				cout << " ";
		}
				
		cout << endl;
		
		cout << "+";
		for (j=0; j < m->numCols(); j++)
		{
			if( m->canTravel(DOWN, i, j) )
			{
				for(k=0; k < SQUARE_SIZE; k++)
					cout << " ";
			}
			else
			{
				for(k=0; k < SQUARE_SIZE; k++)
					cout << "-";
			}
			cout << "+";
		}
		cout << endl;		
	}
}


