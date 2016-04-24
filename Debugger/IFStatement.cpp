// IFStatement.cpp:

/*An IF statement acts as a conditional GOTO statement. 
It performs a comparison, and jumps to the specified line number 
if the comparison is true.

An IF will always be followed by exactly five strings. The first is the 
name of the variable, the second is the operator, the third is an integer,
the fourth is the word THEN, and the fifth is the line number.

As with GOTO statements, the program terminates with the error 
message "Illegal jump instruction" if it tries to jump outside the 
boundaries of the program.*/

#include "IFStatement.h"
#include <iostream>

using namespace std;

IFStatement::IFStatement(string var, string op, int val, int lineNum) 
{
	variable = var;
	this->op = op;
	value = val;
	number = lineNum;
}
IFStatement::~IFStatement()
{}


// The IFStatement version of execute() should call setProgramCounter function in Program State
void IFStatement::execute(ProgramState * state, ostream &outf)
{
	map<string, int> myMap = state->getMap();
		
	if(op == "<"){
		if(myMap[variable] < value){
			if(number > state->getNumLines()){
				outf << "Illegal jump instruction" << endl;
				state->setProgramCounter(-101);
				return;
			}
			else
				state->setProgramCounter(number);
		}
		else{
			state->advanceProgramCounter();
		}
	}
	else if (op == ">"){		
		if(myMap[variable] > value){
			if(number > state->getNumLines()){
				outf << "Illegal jump instruction" << endl;
				state->setProgramCounter(-101);
				return;
			}
			else
				state->setProgramCounter(number);
		}
		else{
			state->advanceProgramCounter();
		}
	}
	else if (op == ">="){
		if(myMap[variable] >= value){
			if(number > state->getNumLines()){
				outf << "Illegal jump instruction" << endl;
				state->setProgramCounter(-101);
				return;
			}
			else
				state->setProgramCounter(number);
		}
		else{
			state->advanceProgramCounter();
		}
	}
	else if (op == "<="){
		if(myMap[variable] <= value){
			if(number > state->getNumLines()){
				outf << "Illegal jump instruction" << endl;
				state->setProgramCounter(-101);
				return;
			}
			else
				state->setProgramCounter(number);
		}
		else{
			state->advanceProgramCounter();
		}
	}
	else if ( op == "="){
		if(myMap[variable] == value){
			if(number > state->getNumLines()){
				outf << "Illegal jump instruction" << endl;
				state->setProgramCounter(-101);
				return;
			}
		else
			state->setProgramCounter(number);
		}
		else{
			state->advanceProgramCounter();
		}
	}
	else if ( op == "<>"){
		if(myMap[variable] != value){
			if(number > state->getNumLines()){
				outf << "Illegal jump instruction" << endl;
				state->setProgramCounter(-101);
				return;
			}
			else
				state->setProgramCounter(number);
		}
		else{
			state->advanceProgramCounter();
		}
	}
	else{
		state->advanceProgramCounter();
		return;
	}
}