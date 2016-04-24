#include "maze.h"
#include "mazedisplay.h"
#include "mazesolver.h"
#include "visitedtracker.h"
#include <chrono>
#include <string>
#include <sstream>
#include <QCheckBox>
#include <QHBoxLayout>
#include <QObject>
#include <QThread>
#include <QWidget>
#include <QPushButton>
#include <QLabel>
#include <QPicture>
#include <QPainter>
#include <vector>
#include <exception> 
#include <typeinfo>
#include <iostream>

// To add more choices to maze sizes, add their names
// to this array.
// You will also need to modify MazeDisplay::generateMaze
const std::string mazeSizeChoices [] = {"small", "medium", "large", "huge"};

const std::string mazeSolverChoices [] = {"BFS", "DFS-Recursive", "DFS-Iterative",
                                          "A*1", "A*2", "A*3"};


const char * MAZE_NOT_SOLVED_TEXT = "Maze not yet solved.";

void MazeDisplay::generateMaze()
{
    // To adjust the meaning of small etc maze sizes,
    // change the functions in here.

    boxAccessCount->setText( MAZE_NOT_SOLVED_TEXT );
    timeTakenLabel->setText( MAZE_NOT_SOLVED_TEXT );
    if( maze != NULL )
        delete maze;
    if( mazeChoices->currentText().toStdString() == "small")
        maze = createMaze(10, 10, simpleChoiceBox->isChecked());
    else if ( mazeChoices->currentText().toStdString() == "medium")
        maze = createMaze(20, 20, simpleChoiceBox->isChecked());
    else if ( mazeChoices->currentText().toStdString() == "large")
        maze = createMaze(50, 50, simpleChoiceBox->isChecked());
    else if ( mazeChoices->currentText().toStdString() == "huge")
        maze = createMaze(75, 75, simpleChoiceBox->isChecked());
    solver->setMaze(maze);
    drawMaze();
}

void MazeDisplay::drawMaze()
{
    // draws the maze but not the solution
    QPainter p(&pi);
    p.setRenderHint(QPainter::Antialiasing);
    drawMaze(p);
    p.end();
    mazeCanvas->setPicture(pi);
}

void MazeDisplay::solveMaze()
{
    auto start = std::chrono::system_clock::now();
    try{
    if( solverChoices->currentText().toStdString() == "BFS")
    {
        solver->solveByBFS();
    }
    else if( solverChoices->currentText().toStdString() == "DFS-Recursive")
    {
        solver->solveByDFSRecursive();
    }
    else if( solverChoices->currentText().toStdString() == "DFS-Iterative")
    {
        solver->solveByDFSIterative();
    }
    else if( solverChoices->currentText().toStdString() == "A*1")
    {
        solver->solveByAStar(1);
    }
    else if( solverChoices->currentText().toStdString() == "A*2")
    {
        solver->solveByAStar(2);
    }
    else if( solverChoices->currentText().toStdString() == "A*3")
    {
        solver->solveByAStar(3);
    }
    }catch (std::exception& e)
      {
        std::cerr << "exception caught: " << e.what() << '\n';
      }

    auto stop = std::chrono::system_clock::now();
    std::chrono::duration<double> timeElapsed = stop - start;
    std::ostringstream message;
    message << timeElapsed.count() << " seconds taken.\n";
    timeTakenLabel->setText( message.str().c_str() );
}


void MazeDisplay::reportSolution(const std::vector<Direction> & path, const VisitedTracker & vt, int numExplored, int pathSize)
{
    QPainter p(&pi);
    p.setRenderHint(QPainter::Antialiasing);
    drawMaze(p, vt);
    drawSolutionPath(p, path);
    std::ostringstream message;
    message << "Maze solved:\n" << vt.numVisited() << " accessed.\n" << numExplored << " explored.\n" << pathSize << " steps taken.";
    boxAccessCount->setText( message.str().c_str() );
    p.end();
    mazeCanvas->setPicture(pi);
}

void MazeDisplay::drawSolutionPath(QPainter & p, const std::vector<Direction> & solution)
{
    p.setPen(QPen(Qt::red, 2, Qt::SolidLine , Qt::RoundCap));
    int row, col;
    row = maze->getStartRow();
    col = maze->getStartCol();
    for(auto foo = solution.begin(); foo!= solution.end(); foo++)
    {
        drawWalkPiece(p, row, col, *foo);
        switch(*foo)
        {
        case UP:  row--; break;
        case DOWN: row++; break;
        case LEFT: col--; break;
        case RIGHT: col++; break;
        }
    }
}


MazeDisplay::MazeDisplay(QApplication *app, Maze * m)
    : maze(m)
{
    this->app = app;
    solver = new MazeSolver( maze, this );
    v1 = new QVBoxLayout;
    h1 = new QHBoxLayout;
    window = new QWidget;

    boxAccessCount = new QLabel( MAZE_NOT_SOLVED_TEXT );
    timeTakenLabel = new QLabel( MAZE_NOT_SOLVED_TEXT );

    generateMazeButton = new QPushButton("Generate Maze");
    solveMazeButton = new QPushButton("Solve Maze");

    mazeChoices = new QComboBox;


    for (const std::string & s : mazeSizeChoices )
        mazeChoices->addItem(s.c_str());
    mazeChoices->setCurrentIndex(1);

    solverChoices = new QComboBox;
    simpleChoiceBox = new QCheckBox("Simple");

    for (const std::string & s : mazeSolverChoices )
        solverChoices->addItem(s.c_str());

    v1->addWidget(mazeChoices);
    v1->addWidget(generateMazeButton);
    v1->addWidget(simpleChoiceBox);
    v1->addWidget(solverChoices);

    v1->addWidget(solveMazeButton);
    v1->addWidget(boxAccessCount);
    v1->addWidget(timeTakenLabel);


    QObject::connect(solveMazeButton, SIGNAL(clicked()), this, SLOT(solveMaze()));
    QObject::connect(generateMazeButton, SIGNAL(clicked()), this, SLOT(generateMaze()));

    mazeCanvas  = new QLabel;
    drawMaze();


    h1->addLayout(v1);
    h1->addWidget(mazeCanvas);
    window->setLayout(h1);
    window->setWindowTitle("A-MAZE-ing Homework Six");
    window->show();
}


MazeDisplay::~MazeDisplay()
{
    delete maze;
    delete generateMazeButton;
    delete simpleChoiceBox;
    delete solverChoices;
    delete solveMazeButton;
    delete boxAccessCount;
    delete timeTakenLabel;
    delete v1;
    delete h1;
    delete window;
}

void MazeDisplay::drawMaze(QPainter & p)
{
    // A blank maze is essentially a maze with nothing visited.
    VisitedTracker vt(maze->numRows(), maze->numCols());
    drawMaze(p, vt);
}

void MazeDisplay::drawMaze(QPainter & p, const VisitedTracker & vt)
{
    p.setPen(QPen(Qt::black, 2, Qt::SolidLine , Qt::RoundCap));

    for (int r=0; r < maze->numRows(); r++)
    {
        for (int c= 0; c < maze->numCols(); c++)
        {
            drawBox(p, r, c, vt.isVisited(r,c));
        }
    }
}

void MazeDisplay::drawSurroundingBox(QPainter & p)
{
    // draws the surrounding box.
    // This is actually unnecessary if we set the maze
    // to always be untravel-out-able.

    p.drawLine(0,0, 0, MAZE_HEIGHT);
    p.drawLine(0,0, MAZE_WIDTH, 0);
    p.drawLine(0,MAZE_HEIGHT, MAZE_WIDTH, MAZE_HEIGHT);
    p.drawLine(MAZE_WIDTH,0, MAZE_WIDTH, MAZE_HEIGHT);

}

void MazeDisplay::drawBox(QPainter & p, int r, int c, bool fillBackground)
{
    int boxHeight = MAZE_HEIGHT / maze->numRows();
    int boxWidth = MAZE_WIDTH / maze->numCols();

    int topLeftX = boxWidth * c;
    int topLeftY = boxHeight * r;

    if( fillBackground )
    {
        p.fillRect(topLeftX, topLeftY, boxWidth, boxHeight, Qt::green);
    }


    // Actually, I don't need Up and Down, and also Left and Right
    // unless we either change it to allow one-way moves.
    // (although we will need to add the bottom and right most walls of the exterior)

    if ( ! maze->canTravel(UP, r, c))
    {
        p.drawLine(topLeftX, topLeftY, topLeftX + boxWidth, topLeftY);
    }
    if ( ! maze->canTravel(DOWN, r, c))
    {
        p.drawLine(topLeftX, topLeftY + boxHeight, topLeftX + boxWidth, topLeftY + boxHeight);
    }
    if( ! maze->canTravel(LEFT, r, c))
    {
        p.drawLine(topLeftX, topLeftY, topLeftX, topLeftY + boxHeight);
    }
    if( ! maze->canTravel(RIGHT, r, c))
    {
        p.drawLine(topLeftX + boxWidth, topLeftY, topLeftX + boxWidth, topLeftY + boxHeight);
    }
}

void MazeDisplay::drawWalkPiece(QPainter & p, int fromRow, int fromCol, Direction d)
{
    int boxHeight = MAZE_HEIGHT / maze->numRows();
    int boxWidth = MAZE_WIDTH / maze->numCols();

    int x1 = fromCol * boxWidth + .5 * boxWidth;
    int y1 = fromRow * boxHeight + .5 * boxHeight;

    int x2 = x1;
    int y2 = y1;

    switch(d)
    {
    case UP: y2 = y2 - boxHeight; break;
    case DOWN: y2 = y2 + boxHeight; break;
    case LEFT: x2 = x2 - boxWidth; break;
    case RIGHT: x2 = x2 + boxWidth; break;
    }

    p.drawLine(x1, y1, x2, y2);
}
