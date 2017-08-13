// ProgramState.cpp
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

#include "stackint.h"
#include "ProgramState.h"
#include <iostream>
#include <map>
#include <string>

using namespace std;


	ProgramState::ProgramState(int numLines){
		m_ProgramCounter = 1;
		m_numLines = numLines;
		stack = new StackInt();
	}

	ProgramState::~ProgramState(){
		delete stack;
	}

	// You'll need to add a variety of methods here.  Rather than trying to
	// think of what you'll need to add ahead of time, add them as you find
	// that you need them.

	void ProgramState::insert(string variableName, int value){
		myMap[variableName] = value;
	}

	//input new value for existing key
	void ProgramState::overwriteValue(string key, int newValue){
			myMap[key] = newValue;
	}

	//clear map
	void ProgramState::clearMap(){
		myMap.clear();
	}

	//check to see if an input is int or variable
	bool ProgramState::isNumber(string p){
		for(unsigned int i = 0; i < p.size(); i++){
			if(!((p[i] >= 48 && p[i]<= 57) || p[i]==45)){
				return false;
			}
		}
		return true;
	}

	//Accessor method to get map
	map<string, int> ProgramState::getMap(){
		return myMap;
	}


	//Accessor method to get program counter
	int ProgramState::getProgramCounter(){
		return m_ProgramCounter;
	}

	//Mutator method to change program counter
	void ProgramState::setProgramCounter(int newProgramCounter){
		m_ProgramCounter = newProgramCounter;
	}

	//Add one to program counter (advance to next line)
	void ProgramState::advanceProgramCounter(){
		m_ProgramCounter++;
	}

	//Accessor to get max number of lines
	int ProgramState::getNumLines(){
		return m_numLines;
	}

	//Accessor to get value on top of stack
	int ProgramState::getStackTop(){
		return stack->top();
	}

	//check if stack is empty
	bool ProgramState::isStackEmpty(){
		return stack->empty();
	}

	//Pop stack
	void ProgramState::popStack(){
		stack->pop();
	}

	//Push current program counter onto stack
	void ProgramState::pushStack(int value){
		stack->push(value);
	}	




