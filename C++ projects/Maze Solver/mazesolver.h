#ifndef MAZESOLVER_H
#define MAZESOLVER_H
#include "visitedtracker.h"
#include "maze.h"
#include <QMessageBox>
#include <queue>
#include <stack>
#include <vector>
#include <exception>



/*
 * I didn't want the students to have to deal
 * with function pointers, so I'm making the
 * MazeSolver an object with various solve
 * methods.
 *
 * I won't be offended if anyone wants to refactor
 * this to make specific functions for them to call.
 */


class MazeDisplay;

class Maze;

class MazeSolver
{
public:
    MazeSolver(Maze * m, MazeDisplay * md);

    void solveByBFS();

    void solveByDFSIterative();

    void solveByDFSRecursive();

    void recursion(int r,int c, VisitedTracker &vt, std::vector<Direction> &parent, int &numExplored);

    void solveByAStar(int Choice);

    int AStarHeuristic(int choice, int r, int c, std::vector<int> cost);

    void setMaze(Maze* m);


private:

    int squareNumber(int r, int c) const;
    int getManhattanDistance(int r, int c);
    int getEuclideanDistance(int r, int c);
    Maze * maze;
    MazeDisplay * display;
};

#endif // MAZESOLVER_H
