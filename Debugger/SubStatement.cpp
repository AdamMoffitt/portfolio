// SubStatement.cpp:
#include "SubStatement.h"
using namespace std;

SubStatement::SubStatement(std::string variableName, string p) 
	: m_variableName( variableName )
{
	this->p = p;
}
SubStatement::~SubStatement()
{}

// The SubStatement version of execute() should make two changes to the
// state of the program:
//
//    * set the value of the appropriate variable
//    * increment the program counter
void SubStatement::execute(ProgramState * state, ostream &outf)
{
	map<string, int> myMap = state->getMap();

	//check if key exists
	if(!myMap[m_variableName]){
		state->insert(m_variableName, 0);
	}

		int newValue = 0;

		//check if p is a variable or an integer by calling isNumber function from ProgramState class
		if(state->isNumber(p)){
			int value = atoi(p.c_str());
			newValue = myMap[m_variableName] - value;
			//call overwriteValue function in ProgramState to insert new value at key
			state->overwriteValue(m_variableName, newValue);
		}

		//if p is not an integer, add values of two keys (if second key exists)
		else{
			if(myMap[p]){
				newValue = (myMap[m_variableName] - myMap[p]);
				//call overwriteValue function in ProgramState to insert new value at key
				state->overwriteValue(m_variableName, newValue);
			}
		}
	

	state->advanceProgramCounter();
}
