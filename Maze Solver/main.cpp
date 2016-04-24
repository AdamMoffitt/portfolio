#include "mazedisplay.h"
#include "maze.h"
#include <QApplication>
#include <iostream>

using namespace std;

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    MazeDisplay w(&app, createMaze(20, 20, true));

    return app.exec();
}
