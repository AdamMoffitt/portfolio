//This interface is to track which spaces have been visited 
//when exploring a maze. 

#include "visitedtracker.h"
#include <assert.h>

VisitedTracker::VisitedTracker(int rows, int cols)
    : numRows(rows), numCols(cols), visited( rows * cols )

{
    for(int i=0; i < rows * cols; i++)
        visited[i] = false;
}

bool VisitedTracker::isVisited(int r, int c) const
{
    assert(r >=0 && r < numRows && c >= 0 && c < numCols) ;
    return visited[squareNumber(r,c)];
}

void VisitedTracker::setVisited(int r, int c, bool val)
{
    assert(r >=0 && r < numRows && c >= 0 && c < numCols) ;
    visited[squareNumber(r,c)] = val;
}

int VisitedTracker::numVisited() const
{
    int count = 0;
    for (const bool & b : visited)
        if(b)
            count++;
    return count;
}


int VisitedTracker::squareNumber(int r, int c) const
{
    return numCols * r + c;
}
