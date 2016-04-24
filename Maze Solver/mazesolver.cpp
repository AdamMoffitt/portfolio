/*This program displays a GUI window using Qt and, based on user selections, 
generates a maze. The user can then solve the maze using either 
Depth First Search Iterative, Depth First Search Recursive, 
Breadth First Search Iterative, or Breadth First Search Recursive, 
or using one of 3 A* heuristics: 
1. A* with heuristic estimate of 0 for all nodes in the maze, 
2. A* with a heuristic estimate of the euclidean distance to the goal location, 
3. A* with a heuristic estimate of the "Manhattan distance" to the goal location. 

The program also outputs the number of steps taken to find the solution, 
and marks in green all of the nodes explored. Also outputs the amount
of time taken. Can be used to compare the effectiveness and runtime of the 
different search algorithms.*/

#include "mazesolver.h"
#include "mazedisplay.h"
#include "heap.h"
#include <cmath>
#include <iostream>
using namespace std;

MazeSolver::MazeSolver(Maze * m, MazeDisplay * md)
    : maze(m), display(md)
{}

void MazeSolver::solveByDFSRecursive()
{
    
    int numSquares = maze->numRows() * maze->numCols();
    VisitedTracker vt(maze->numRows(), maze->numCols());
    std::vector<Direction> parent( numSquares ); // what was my immediate prior direction to get here?
    int numExplored = 0;
    vt.setVisited(maze->getStartRow(), maze->getStartCol());
    numExplored++;
    recursion(maze->getStartRow(), maze->getStartCol(), vt, parent, numExplored);
}

void MazeSolver::recursion(int r,int c, VisitedTracker &vt, std::vector<Direction> &parent, int &numExplored){
        
    if( r == maze->getGoalRow() && c == maze->getGoalCol() )
    {
            std::vector<Direction> path;
            std::stack<Direction> st;

            while( r != maze->getStartRow() || c != maze->getStartCol())
            {
                st.push( parent[ squareNumber(r,c) ]);
                switch( st.top() )
                {
                case UP: r++; break; // yes, r++.  I went up to get here...
                case DOWN: r--; break;
                case LEFT: c++; break;
                case RIGHT: c--; break;
                }
            }
            while ( ! st.empty() )
            {
                path.push_back(st.top());
                st.pop();
            }
            display->reportSolution(path, vt, numExplored, path.size());
            return;
    } 
    if ( maze->canTravel(UP, r, c) && ! vt.isVisited(r-1,c))
        {
            parent[squareNumber(r-1, c)] = UP;
            vt.setVisited(r-1,c);
            numExplored++;
            recursion(r-1,c, vt, parent, numExplored);
        }
        // Note:  this is NOT "if" ...
    if ( maze->canTravel(DOWN, r, c) && ! vt.isVisited(r+1,c) )
        {
            parent[squareNumber(r+1, c)] = DOWN;
            vt.setVisited(r+1, c);
            numExplored++;
            recursion(r+1,c, vt, parent, numExplored);
        }
    if ( maze->canTravel(LEFT, r, c) && ! vt.isVisited(r,c-1) )
        {
            parent[squareNumber(r, c-1)] = LEFT;
            vt.setVisited(r, c-1);
            numExplored++;
            recursion(r,c-1, vt, parent, numExplored);
        }
    if ( maze->canTravel(RIGHT, r, c) && ! vt.isVisited(r, c+1) )
        {
            parent[squareNumber(r, c+1)] = RIGHT;
            vt.setVisited(r, c+1);
            numExplored++;
            recursion(r,c+1, vt, parent, numExplored);
        }
}

void MazeSolver::solveByAStar(int choice)
{
    int r, c;
    int numSquares = maze->numRows() * maze->numCols();
    VisitedTracker vt(maze->numRows(), maze->numCols());

    std::vector<int> pathSoFar(numSquares);
    for(int i = 0; i < (int)pathSoFar.size(); i ++){
        pathSoFar[i] = 0;
    }

    std::vector<Direction> parent( numSquares ); // what was my immediate prior direction to get here?
    int numExplored = 0;
    vt.setVisited(maze->getStartRow(), maze->getStartCol());
    MinHeap <pair<int,int>> myHeap(2);
    //check remove exception
    //myHeap.remove();
    int heuristic = AStarHeuristic(choice, maze->getStartRow(), maze->getStartCol(), pathSoFar);
    myHeap.add(pair<int,int>(maze->getStartRow(), maze->getStartCol()), heuristic);

    while( ! myHeap.isEmpty() )
    {
        std::pair<int, int> v = myHeap.peek();
        myHeap.remove();
        numExplored++;

        r = v.first;
        c = v.second;

         //stop when goal is reached
        if( r == maze->getGoalRow() && c == maze->getGoalCol() )
        {
            std::vector<Direction> path;
            std::stack<Direction> st;

            while( r != maze->getStartRow() || c != maze->getStartCol())
            {
                st.push( parent[ squareNumber(r,c) ]);
                switch( st.top() )
                {
                case UP: r++; break; // yes, r++.  I went up to get here...
                case DOWN: r--; break;
                case LEFT: c++; break;
                case RIGHT: c--; break;
                }
            }
            while ( ! st.empty() )
            {
                path.push_back(st.top());
                st.pop();
            }
            display->reportSolution(path, vt, numExplored, path.size());
            return;
        }

        if ( maze->canTravel(UP, r, c))
        {
            if(! vt.isVisited(r-1,c) || pathSoFar[squareNumber(r,c)]+1 < pathSoFar[squareNumber(r-1,c)]){
                parent[squareNumber(r-1, c)] = UP;
                vt.setVisited(r-1,c);
                pathSoFar[squareNumber(r-1,c)] = pathSoFar[squareNumber(r,c)]+1;
                int heuristic = AStarHeuristic(choice, r-1, c, pathSoFar);
                myHeap.add(std::pair<int,int>(r-1, c), heuristic);
            }
        }
        // Note:  this is NOT "else if" ...
        if ( maze->canTravel(DOWN, r, c) )
        {
            if(! vt.isVisited(r+1,c) || pathSoFar[squareNumber(r,c)]+1 < pathSoFar[squareNumber(r+1,c)]){
            parent[squareNumber(r+1, c)] = DOWN;
            vt.setVisited(r+1, c);
            pathSoFar[squareNumber(r+1,c)] = pathSoFar[squareNumber(r,c)]+1;
            int heuristic = AStarHeuristic(choice, r-1, c, pathSoFar);
            myHeap.add(std::pair<int,int>(r+1, c), heuristic);
            }
        }
        if ( maze->canTravel(LEFT, r, c) )
        {
            if(! vt.isVisited(r,c-1) || pathSoFar[squareNumber(r,c)]+1 < pathSoFar[squareNumber(r,c-1)]){
                parent[squareNumber(r, c-1)] = LEFT;
                vt.setVisited(r, c-1);
                pathSoFar[squareNumber(r,c-1)] = pathSoFar[squareNumber(r,c)]+1;
                int heuristic = AStarHeuristic(choice, r-1, c, pathSoFar);
                myHeap.add(std::pair<int,int>(r, c-1), heuristic);
            }
        }
        if ( maze->canTravel(RIGHT, r, c))
        {
            if(! vt.isVisited(r,c+1) || pathSoFar[squareNumber(r,c)]+1 < pathSoFar[squareNumber(r,c+1)]){
                parent[squareNumber(r, c+1)] = RIGHT;
                vt.setVisited(r, c+1);
                pathSoFar[squareNumber(r,c+1)] = pathSoFar[squareNumber(r,c)]+1;
                int heuristic = AStarHeuristic(choice, r-1, c, pathSoFar);
                myHeap.add(std::pair<int,int>(r, c+1), heuristic);
            }
        }
    }
}

int MazeSolver::AStarHeuristic(int choice, int r, int c, vector <int> pathSoFar){
    
    //    if choice is 1, solve by A* using heuristic of "return 0"
    //    else if choice is 2, solve by A* using heuristic of Manhattan Distance
    //    else if choice is 3, solve by A* using heuristic of Euclidean Distance

    if(choice == 1){
        int distance = 0;
        int travelled = pathSoFar[squareNumber(r,c)];
        return distance+travelled;
    }

    else if(choice == 2){
        int distance = getManhattanDistance(r,c);
        int travelled = pathSoFar[squareNumber(r,c)];
        return distance+travelled;
    }

    else if(choice == 3){
        int distance = getEuclideanDistance(r,c);
        int travelled = pathSoFar[squareNumber(r,c)];
        return distance+travelled;
    }
    else{
        throw exception(invalid_argument("Invalid Heuristic choice"));
        return 0;
    }
}

int MazeSolver::getManhattanDistance(int r, int c){
    int distance;
    int x = maze->getGoalRow() - r;
    int y = maze->getGoalCol() - c;
    distance = x+y;
    return distance;
}

int MazeSolver::getEuclideanDistance(int r, int c){
    int distance;
    int x = maze->getGoalRow() - r;
    int y = maze->getGoalCol() - c;
    distance = sqrt(pow(x,2)+pow(y,2));
    return distance;
}




void MazeSolver::solveByDFSIterative()
{
    int r, c;
    int numSquares = maze->numRows() * maze->numCols();
    VisitedTracker vt(maze->numRows(), maze->numCols());

    std::vector<Direction> parent( numSquares ); // what was my immediate prior direction to get here?
    int numExplored = 0;
    vt.setVisited(maze->getStartRow(), maze->getStartCol());
    std::stack<std::pair<int, int>> q;
    q.push(std::pair<int,int>(maze->getStartRow(), maze->getStartCol()));

    while( ! q.empty() )
    {
        std::pair<int, int> v = q.top();
        q.pop();
        numExplored++;

        r = v.first;
        c = v.second;

         //stop when goal is reached
        if( r == maze->getGoalRow() && c == maze->getGoalCol() )
        {
            std::vector<Direction> path;
            std::stack<Direction> st;

            while( r != maze->getStartRow() || c != maze->getStartCol())
            {
                st.push( parent[ squareNumber(r,c) ]);
                switch( st.top() )
                {
                case UP: r++; break; // yes, r++.  I went up to get here...
                case DOWN: r--; break;
                case LEFT: c++; break;
                case RIGHT: c--; break;
                }
            }
            while ( ! st.empty() )
            {
                path.push_back(st.top());
                st.pop();
            }
            display->reportSolution(path, vt, numExplored, path.size());
            return;
        }

        if ( maze->canTravel(UP, r, c) && ! vt.isVisited(r-1,c))
        {
            parent[squareNumber(r-1, c)] = UP;
            vt.setVisited(r-1,c);
            q.push(std::pair<int,int>(r-1, c));
        }
        // Note:  this is NOT "else if" ...
        if ( maze->canTravel(DOWN, r, c) && ! vt.isVisited(r+1,c) )
        {
            parent[squareNumber(r+1, c)] = DOWN;
            vt.setVisited(r+1, c);
            q.push(std::pair<int,int>(r+1, c));
        }
        if ( maze->canTravel(LEFT, r, c) && ! vt.isVisited(r,c-1) )
        {
            parent[squareNumber(r, c-1)] = LEFT;
            vt.setVisited(r, c-1);
            q.push(std::pair<int,int>(r, c-1));
        }
        if ( maze->canTravel(RIGHT, r, c) && ! vt.isVisited(r, c+1) )
        {
            parent[squareNumber(r, c+1)] = RIGHT;
            vt.setVisited(r, c+1);
            q.push(std::pair<int,int>(r, c+1));
        }
    }
}

void MazeSolver::solveByBFS()
{
    /*  Here, we have vertices with two numbers,
       row and col, in the range:
       [0, maze->numRows()-1], [0, maze->numCols() -1 ]
       to assign each a unique number [0, maze->numRows() * maze->numCols() -1]
       we will say that maze square (r,c) is really number
       r * maze->numCols() + c
    */
    int r, c;
    int numSquares = maze->numRows() * maze->numCols();
    VisitedTracker vt(maze->numRows(), maze->numCols());

    std::vector<Direction> parent( numSquares ); // what was my immediate prior direction to get here?
    int numExplored = 0;
    vt.setVisited(maze->getStartRow(), maze->getStartCol());
    std::queue<std::pair<int, int>> q;
    q.push(std::pair<int,int>(maze->getStartRow(), maze->getStartCol()));

    while( ! q.empty() )
    {
        std::pair<int, int> v = q.front();
        q.pop();
        numExplored++;

        r = v.first;
        c = v.second;

        //stop when goal is reached
        if( r == maze->getGoalRow() && c == maze->getGoalCol() )
        {
            std::vector<Direction> path;
            std::stack<Direction> st;

            while( r != maze->getStartRow() || c != maze->getStartCol())
            {
                st.push( parent[ squareNumber(r,c) ]);
                switch( st.top() )
                {
                case UP: r++; break; // yes, r++.  I went up to get here...
                case DOWN: r--; break;
                case LEFT: c++; break;
                case RIGHT: c--; break;
                }
            }
            while ( ! st.empty() )
            {
                path.push_back(st.top());
                st.pop();
            }
            display->reportSolution(path, vt, numExplored, path.size());
            return;
        }

        if ( maze->canTravel(UP, r, c) && ! vt.isVisited(r-1,c))
        {
            parent[squareNumber(r-1, c)] = UP;
            vt.setVisited(r-1,c);
            q.push(std::pair<int,int>(r-1, c));
        }
        // Note:  this is NOT "else if" ...
        if ( maze->canTravel(DOWN, r, c) && ! vt.isVisited(r+1,c) )
        {
            parent[squareNumber(r+1, c)] = DOWN;
            vt.setVisited(r+1, c);
            q.push(std::pair<int,int>(r+1, c));
        }
        if ( maze->canTravel(LEFT, r, c) && ! vt.isVisited(r,c-1) )
        {
            parent[squareNumber(r, c-1)] = LEFT;
            vt.setVisited(r, c-1);
            q.push(std::pair<int,int>(r, c-1));
        }
        if ( maze->canTravel(RIGHT, r, c) && ! vt.isVisited(r, c+1) )
        {
            parent[squareNumber(r, c+1)] = RIGHT;
            vt.setVisited(r, c+1);
            q.push(std::pair<int,int>(r, c+1));
        }
    }
}


int MazeSolver::squareNumber(int r, int c) const
{
    return maze->numCols() * r + c;
}



void MazeSolver::setMaze(Maze* m) {
 maze = m; 
}