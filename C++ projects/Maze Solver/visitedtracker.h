//This interface is to track which spaces have been visited 
//when exploring a maze. 
#ifndef VISITEDTRACKER_H
#define VISITEDTRACKER_H

#include <vector>

class VisitedTracker
{
public:
    VisitedTracker(int rows, int cols);

    bool isVisited(int r, int c) const;
    void setVisited(int r, int c, bool val = true);
    int numVisited() const;


private:
    int squareNumber(int r, int c) const;


    int numRows, numCols;
    std::vector<bool> visited;
};

#endif // VISITEDTRACKER_H
