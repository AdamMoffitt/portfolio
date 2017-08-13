// GOSUBStatement.cpp:

//A GOSUB is just like a GOTO, except that it allows 
//you to use the RETURN statement to return to where you jumped from.

#include "GOSUBStatement.h"
using namespace std;

GOSUBStatement::GOSUBStatement(int lineNum) 
{
	number = lineNum;
}

GOSUBStatement::~GOSUBStatement()
{}

// The GOSUBStatement version of execute() should call setProgramCounter function in Program State
void GOSUBStatement::execute(ProgramState * state, ostream &outf)
{
	if(number > state->getNumLines()){
		outf << "Illegal jump instruction" << endl;
		state->setProgramCounter(-101);
		return;
	}
	//use stack to keep track of GOSUB and return lines
	else{
		state->pushStack(state->getProgramCounter());
		state->setProgramCounter(number);
	}
}