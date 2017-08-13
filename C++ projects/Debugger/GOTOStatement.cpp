// GOTOStatement.cpp:
#include "GOTOStatement.h"
using namespace std;

GOTOStatement::GOTOStatement(int lineNum) 
{
	number = lineNum;
}
GOTOStatement::~GOTOStatement()
{}

// The GOTOStatement version of execute() should call setProgramCounter function in Program State
void GOTOStatement::execute(ProgramState * state, ostream &outf)
{
	//check if line number is in range
	if(number > state->getNumLines()){
		outf << "Illegal jump instruction" << endl;
		state->setProgramCounter(-101);
		return;
	}
	//change program counter to GOTO line
	else
		state->setProgramCounter(number);

}