// ReturnStatement.cpp:
#include "ReturnStatement.h"
using namespace std;

ReturnStatement::ReturnStatement() 
{}
ReturnStatement::~ReturnStatement(){}

// The ReturnStatement version of execute() should call setProgramCounter function in Program State
void ReturnStatement::execute(ProgramState * state, ostream &outf)
{
		if(state->isStackEmpty()){
			int newProgramCounter = -1;
			state->setProgramCounter(newProgramCounter);
		}

		else if(state->getStackTop() == -10000){
			state->advanceProgramCounter();
			return;
		}
		else{
			state->setProgramCounter(state->getStackTop()+1);
			state->popStack();
		}
}


