// PrintStatement.cpp:
#include "PrintAllStatement.h"

using namespace std;

PrintAllStatement::PrintAllStatement()
{}
PrintAllStatement::~PrintAllStatement()
{}

//Prints all variables stored in Program State map and their corresponding values
void PrintAllStatement::execute(ProgramState * state, std::ostream &outf)
{
	map<string, int> myMap = state->getMap();
	
	if(myMap.empty()){
		outf << "Map is empty." << endl;
	}

	else{
		map<string, int>::iterator it;
		for(it = myMap.begin( ); it != myMap.end( ); ++it)   
		{
   				 outf << it->first << " " << it->second << std::endl;
		}
	}

	state->advanceProgramCounter();
}

