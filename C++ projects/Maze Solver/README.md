# Maze Solver

- **By**: Adam Moffitt
- **CSCI 104 Spring 2016**
- **DATE**: 4/5/2016

This program displays a GUI window using Qt and, based on user selections, generates a maze. The user can then solve the maze using either Breadth First Search, Depth First Search Iterative, Depth First Search Recursive, or using one of 3 A* heuristics: 1. A* with heuristic estimate of 0 for all nodes in the maze, 2. A* with a heuristic estimate of the euclidean distance to the goal location, or 3. A* with a heuristic estimate of the "Manhattan distance" to the goal location. 

The bulk of the program is in mazesolver.cpp.

The program is compiled using qmake and then make. The executable is Maze. Run using ./Maze.


Folder also includes a custom built d-ary min heap that I built.
Heap is in file heap.h. Test file is in testHeap.cpp. Can be compiled with g++ -g -Wall testHeap.cpp and run with ./testHeap.

