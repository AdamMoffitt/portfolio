
#ifndef GOTO_STATEMENT_INCLUDED
#define GOTO_STATEMENT_INCLUDED

#include "Statement.h"
#include "ProgramState.h"

class GOTOStatement: public Statement
{
private:
	int number;
public:
	GOTOStatement(int lineNum);
	virtual ~GOTOStatement();

	virtual void execute(ProgramState * state, std::ostream &outf);
};

#endif
