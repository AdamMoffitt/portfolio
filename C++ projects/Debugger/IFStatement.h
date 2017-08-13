
/*An IF statement acts as a conditional GOTO statement. 
It performs a comparison, and jumps to the specified line number 
if the comparison is true.

An IF will always be followed by exactly five strings. The first is the 
name of the variable, the second is the operator, the third is an integer,
the fourth is the word THEN, and the fifth is the line number.

As with GOTO statements, the program terminates with the error 
message "Illegal jump instruction" if it tries to jump outside the 
boundaries of the program.*/

#ifndef IF_STATEMENT_INCLUDED
#define IF_STATEMENT_INCLUDED

#include "Statement.h"
#include "ProgramState.h"
#include <map>

class IFStatement: public Statement
{
private:
	string variable;
	string op;
	int value;
	int number;
public:
	IFStatement(string var, string op, int val, int lineNum);
	virtual ~IFStatement();
	virtual void execute(ProgramState * state, std::ostream &outf);
};

#endif
