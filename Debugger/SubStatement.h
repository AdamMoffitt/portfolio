#ifndef SUB_STATEMENT_INCLUDED
#define SUB_STATEMENT_INCLUDED

#include "Statement.h"
#include "ProgramState.h"
#include <iostream>
#include <map>
#include <string>
#include <cstdlib>

class SubStatement: public Statement
{
private:
	std::string m_variableName;
	int m_value;
	string p;


public:
	SubStatement(std::string variableName, string p);
	virtual ~SubStatement();
	virtual void execute(ProgramState * state, std::ostream &outf);

};

#endif