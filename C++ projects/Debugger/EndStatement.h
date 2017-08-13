
#ifndef End_STATEMENT_INCLUDED
#define End_STATEMENT_INCLUDED

#include "Statement.h"
#include "ProgramState.h"

class EndStatement: public Statement
{
private:

public:
	EndStatement();
	virtual ~EndStatement();
	virtual void execute(ProgramState * state, std::ostream &outf);
};

#endif