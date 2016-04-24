// ProgramState.h
//
// CS 104 / Spring 2016
//
// The ProgramState class encapsulates the state of an executing Facile
// program.  The state of a Facile program consists of three parts:
//
//    * The program counter, which specifies the line number of the
//      statement that will execute next.
//    * A map, as explained by the problem writeup.
//    * A stack of integers, which is used to hold return lines for GOSUB
//      statements.

#ifndef PROGRAM_STATE_INCLUDED
#define PROGRAM_STATE_INCLUDED


#include <map>
#include <iostream>
#include "stackint.h"

using namespace std;

class ProgramState
{

private:
	int m_ProgramCounter;
	int m_numLines;
	map<string, int> myMap;
	StackInt* stack;

public:
	ProgramState(int numLines);
	~ProgramState();

	// You'll need to add a variety of methods here.  Rather than trying to
	// think of what you'll need to add ahead of time, add them as you find
	// that you need them.

	void insert(string variableName, int value);
	bool isNumber(string p);
	void overwriteValue(string key, int newValue);
	void clearMap();
	int getProgramCounter();
	void setProgramCounter(int newProgramCounter);
	void advanceProgramCounter();
	map<string, int> getMap();
	int getNumLines();
	int getStackTop();
	void pushStack(int value);
	void popStack();
	bool isStackEmpty();
	
};

#endif