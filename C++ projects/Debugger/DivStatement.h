#ifndef DIV_STATEMENT_INCLUDED
#define DIV_STATEMENT_INCLUDED

#include "Statement.h"
#include "ProgramState.h"
#include <iostream>
#include <map>
#include <string>
#include <cstdlib>

class DivStatement: public Statement
{
private:
	std::string m_variableName;
	int m_value;
	string p;


public:
	DivStatement(std::string variableName, string p);
	
	virtual void execute(ProgramState * state, std::ostream &outf);
	virtual ~DivStatement();
};

#endif