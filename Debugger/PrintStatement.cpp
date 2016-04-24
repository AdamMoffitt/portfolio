// PrintStatement.cpp:
#include "PrintStatement.h"
#include <iostream>
using namespace std;

PrintStatement::PrintStatement(std::string variableName)
	: m_variableName( variableName )
{}
PrintStatement::~PrintStatement(){}

void PrintStatement::execute(ProgramState * state, std::ostream &outf)
{
	map<string, int> myMap = state->getMap();

	//check if key exists
	if(!myMap[m_variableName]){
		state->insert(m_variableName, 0);
	}
	
	if(myMap.empty()){
		outf << "Map is empty." << endl;
	}

	else{
		map<string, int>::iterator it;
		it = myMap.find(m_variableName);
		outf << it->second << endl;
	}

	state->advanceProgramCounter();
}

