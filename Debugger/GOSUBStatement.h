//A GOSUB is just like a GOTO, except that it allows 
//you to use the RETURN statement to return to where you jumped from.

#ifndef GOSUB_STATEMENT_INCLUDED
#define GOSUB_STATEMENT_INCLUDED

#include "Statement.h"
#include "ProgramState.h"

class GOSUBStatement: public Statement
{
private:
	int number;

public:
	GOSUBStatement(int lineNum);
	
	virtual void execute(ProgramState * state, std::ostream &outf);
	virtual ~GOSUBStatement();
};

#endif