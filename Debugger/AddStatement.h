#ifndef ADD_STATEMENT_INCLUDED
#define ADD_STATEMENT_INCLUDED

#include "Statement.h"
#include "ProgramState.h"
#include <iostream>
#include <map>
#include <string>
#include <cstdlib>

class AddStatement: public Statement
{
private:
	std::string m_variableName;
	int m_value;
	string p;


public:
	AddStatement(std::string variableName, string p);
	virtual ~AddStatement();
	
	virtual void execute(ProgramState * state, std::ostream &outf);
};

#endif