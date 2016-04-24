#ifndef MAZEDISPLAY_H
#define MAZEDISPLAY_H

#include <QMainWindow>
#include "maze.h"
#include "mazesolver.h"
#include "visitedtracker.h"
#include <QCheckBox>
#include <QHBoxLayout>
#include <QVBoxLayout>
#include <QWidget>
#include <QPushButton>
#include <QLabel>
#include <QComboBox>
#include <QPicture>


class MazeDisplay : public QWidget {
Q_OBJECT

public:
    MazeDisplay(QApplication *app, Maze * m);
    ~MazeDisplay();

    void reportSolution(const std::vector<Direction> & path, const VisitedTracker & vt, int numExplored, int pathSize);


public slots:
    void solveMaze();
    void generateMaze();

private:

    QPicture pi; // not a pointer.
    QCheckBox * simpleChoiceBox;

    QApplication *app;
    Maze * maze;
    MazeSolver * solver;

    QPushButton * generateMazeButton;
    QPushButton * solveMazeButton;
    QLabel * mazeCanvas;
    QLabel * boxAccessCount; // for displaying how many nodes were explored
    QLabel * timeTakenLabel;

    QComboBox * solverChoices;
    QComboBox * mazeChoices;

    QWidget *window;
    QHBoxLayout *h1;
    QVBoxLayout *v1;

    void drawMaze();
    void drawMaze(QPainter & p);
    void drawMaze(QPainter & p, const VisitedTracker & vt);

    void drawSolutionPath(QPainter & p, const std::vector<Direction> & solution);

    // drawSurroundingBox() might actually be unnecessary.
    void drawSurroundingBox(QPainter & p);
    void drawBox(QPainter & p, int r, int c, bool fillBackground);

    // It would have been nice if I had found a better name for this function.
    // It draws a walk from the given box to the one in that direction.
    // If that isn't a valid walk, :shrug:
    void drawWalkPiece(QPainter & p, int fromRow, int fromCol, Direction d);

    // I'm not sure these belong here.
    // In fact, constants for these might be a bad idea overall.
    const int MAZE_HEIGHT = 400;
    const int MAZE_WIDTH = 400;
};


#endif // MAZEDISPLAY_H
