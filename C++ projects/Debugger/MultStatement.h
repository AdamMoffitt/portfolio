#ifndef MULT_STATEMENT_INCLUDED
#define MULT_STATEMENT_INCLUDED

#include "Statement.h"
#include "ProgramState.h"
#include <iostream>
#include <map>
#include <string>
#include <cstdlib>

class MultStatement: public Statement
{
private:
	std::string m_variableName;
	int m_value;
	string p;


public:
	MultStatement(std::string variableName, string p);
	virtual ~MultStatement();
	virtual void execute(ProgramState * state, std::ostream &outf);
};

#endif