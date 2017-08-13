// EndStatement.cpp:
#include "EndStatement.h"

using namespace std;

EndStatement::EndStatement(
) {}
EndStatement::~EndStatement()
{}

// The EndStatement version of execute() should just return false?
void EndStatement::execute(ProgramState * state, ostream &outf)
{
	int newProgramCounter = -1;
	state->setProgramCounter(newProgramCounter);
}