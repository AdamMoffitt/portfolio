#include "debugger_window.h"

DebuggerWindow::DebuggerWindow(istream& inf, ostream& outf){

	//DEBUGGER WINDOW
	debuggerWindow = new QWidget();
	debuggerWindow->setWindowTitle("Debugger");


	debuggerLayout = new QVBoxLayout();

	topHalfLayout = new QHBoxLayout();
	debuggerLayout->addLayout(topHalfLayout);

	// List of all lines of code
	facileLineListWidget = new QListWidget();
	//connect(facileLineListWidget, SIGNAL(currentRowChanged(int)),this,SLOT(displayFacileCode(ProgramState*&)));
	topHalfLayout->addWidget(facileLineListWidget);

	//Side buttons to debug code
	sideButtons = new QVBoxLayout();
	topHalfLayout->addLayout(sideButtons);

	topHalfLayout->addStretch();

	this->continueButton = new QPushButton("Continue");
	connect(this->continueButton, SIGNAL(clicked()), this, SLOT(cont()));
	sideButtons->addWidget(continueButton);

	breakButton = new QPushButton("Breakpoint");
	connect(breakButton, SIGNAL(clicked()), this, SLOT(brk()));
	sideButtons->addWidget(breakButton);

	stepButton = new QPushButton("Step");
	connect(stepButton, SIGNAL(clicked()), this, SLOT(step()));
	sideButtons->addWidget(stepButton);

	nextButton = new QPushButton("Next");
	connect(nextButton, SIGNAL(clicked()), this, SLOT(next()));
	sideButtons->addWidget(nextButton);

	inspectButton = new QPushButton("Inspect");
	connect(inspectButton, SIGNAL(clicked()), this, SLOT(inspect()));
	sideButtons->addWidget(inspectButton);

	quitButton = new QPushButton("Quit");
	connect(quitButton, SIGNAL(clicked()), this, SLOT(quitGracefully()));
	debuggerLayout->addWidget(quitButton);

	debuggerWindow->setLayout(debuggerLayout);

	//SET UP LIST WIDGET

	//To get line info - Parse Program
	vector<string> facileCodeLines;

	parseProgram(inf, program, facileCodeLines);

	//Initialize ProgramState
	unsigned int numLines = program.size();

	state = new ProgramState(numLines);

	programCounter = state->getProgramCounter();

	int lineNumber = 1;
	// Create a new list item with the line of code name
	for(int i = 0;i < (int)facileCodeLines.size();i++){

		string input;
		stringstream ss;
		ss << lineNumber;
		ss << ". ";
		ss >> input;
		input += facileCodeLines[i];
		facileLineListWidget->addItem(QString::fromStdString(input));
		lineNumber++;
	}
	facileLineListWidget->item(0)->setBackground(Qt::yellow);

	breakPoints.push_back(1000);
	//******************outfile = outf;

	debuggerWindow->show();

}

DebuggerWindow::~DebuggerWindow(){
	for(int i = 0; i < (int)program.size();i++){
		delete program[i];
	}

	delete state;
	delete debuggerLayout;
	delete topHalfLayout;
	delete facileLineListWidget;
	delete sideButtons;
	delete continueButton;
	delete breakButton;
	delete stepButton;
	delete nextButton;
	delete inspectButton;
	delete quitButton;
}
void DebuggerWindow::resetListWidget(){
		state->clearMap();
		programCounter = 1;
		state->setProgramCounter(1);
		while(programCounter > 0 && programCounter <= (int)program.size()){
			facileLineListWidget->item(programCounter-1)->setBackground(Qt::white);
			if(facileLineListWidget->item(programCounter-1)->foreground()==Qt::green){
				facileLineListWidget->item(programCounter-1)->setForeground(Qt::black);
			}
			++programCounter;
		}
		programCounter = 1;
		facileLineListWidget->item(programCounter-1)->setBackground(Qt::yellow);
}

void DebuggerWindow::cont(){

	//If program reached end, start over
	if(programCounter == -1){
		resetListWidget();
	}

	while(programCounter > 0 && programCounter <= (int)program.size()){
		//stop if line is breakpoint
		for(int i = 0; i < (int)breakPoints.size(); i++){
			if(programCounter == (int)breakPoints[i]){
				return;
			}
		}
		
		for (int i = 0; i < facileLineListWidget->count(); i++){
			facileLineListWidget->item(i)->setBackground(Qt::white);
		}

		//HIGHLIGHT current line
		facileLineListWidget->item(programCounter-1)->setBackground(Qt::yellow);
		if(facileLineListWidget->item(programCounter-1)->foreground()!=Qt::red){
			facileLineListWidget->item(programCounter-1)->setForeground(Qt::green);
		}
		program[programCounter]->execute(state, cout);
		temp = programCounter;
		programCounter = state->getProgramCounter();

		if(programCounter == -100){
			string line;
			stringstream ss;
			ss << temp;
			ss >> line;
			string error = "Line: ";
			error += line;
			error += " Cannot divide by Zero";
			Error(error);
			resetListWidget();
			return;
		}
		else if(programCounter == -101){
			string line;
			stringstream ss;
			ss << temp;
			ss >> line;
			string error = "Line: ";
			error += line;
			error += " Illegal Jump Instruction";
			Error(error);
			resetListWidget();
			return;
		}
	}
}

void DebuggerWindow::brk(){
	
	bool hasBreakPoint = false;
	int breakPointAt = -1;
	int inBreakArray = -1;
	for(int i = 0; i < (int)breakPoints.size(); i++){
		if(facileLineListWidget->currentRow()+1 == (int)breakPoints[i]){
			breakPointAt = facileLineListWidget->currentRow()+1;
			inBreakArray = i;
			hasBreakPoint = true;
			break;
		}
	}

	if(hasBreakPoint){
		
		breakPoints.erase(breakPoints.begin()+(inBreakArray));
		facileLineListWidget->item(breakPointAt-1)->setForeground(Qt::black);
		
	}

	else{
		int breakPoint = facileLineListWidget->currentRow();
		breakPoints.push_back(breakPoint+1);
		facileLineListWidget->item(breakPoint)->setForeground(Qt::red);
	}

}

void DebuggerWindow::step(){

	//IF PROGRAM HIT END OR RETURN
	if(programCounter == -100){
			string line;
			stringstream ss;
			ss << temp;
			ss >> line;
			string error = "Line: ";
			error += line;
			error += " Cannot divide by Zero";
			Error(error);
			resetListWidget();
			return;
		}
	else if(programCounter == -101){
			string line;
			stringstream ss;
			ss << temp;
			ss >> line;
			string error = "Line: ";
			error += line;
			error += " Illegal Jump Instruction";
			Error(error);
			resetListWidget();
			return;
	}
	if(programCounter == -1){
		state->clearMap();
		programCounter = 1;
		state->setProgramCounter(1);
		int temp = programCounter;
		programCounter = 1;
		while(programCounter > 0 && programCounter <= (int)program.size()){
			facileLineListWidget->item(programCounter-1)->setBackground(Qt::white);
			if(facileLineListWidget->item(programCounter-1)->foreground()==Qt::green){
				facileLineListWidget->item(programCounter-1)->setForeground(Qt::black);
			}
			++programCounter;
		}
		programCounter = temp;
	}

	if(programCounter > 0 && programCounter <= (int)program.size()){
		for (int i = 0; i < facileLineListWidget->count(); i++){
			facileLineListWidget->item(i)->setBackground(Qt::white);
		}
		facileLineListWidget->item(programCounter-1)->setBackground(Qt::yellow);
		if(facileLineListWidget->item(programCounter-1)->foreground()!=Qt::red){
			facileLineListWidget->item(programCounter-1)->setForeground(Qt::green);
		}
		program[programCounter]->execute(state, cout);
		temp = programCounter;
		programCounter = state->getProgramCounter();
		if(programCounter == -100){
			string line;
			stringstream ss;
			ss << temp;
			ss >> line;
			string error = "Line: ";
			error += line;
			error += " Cannot divide by Zero";
			Error(error);
			resetListWidget();
			return;
		}
	else if(programCounter == -101){
			string line;
			stringstream ss;
			ss << temp;
			ss >> line;
			string error = "Line: ";
			error += line;
			error += " Illegal Jump Instruction";
			Error(error);
			resetListWidget();
			return;
	}
	if(programCounter == -1){
		state->clearMap();
		programCounter = 1;
		state->setProgramCounter(1);
		int temp = programCounter;
		programCounter = 1;
		while(programCounter > 0 && programCounter <= (int)program.size()){
			facileLineListWidget->item(programCounter-1)->setBackground(Qt::white);
			if(facileLineListWidget->item(programCounter-1)->foreground()==Qt::green){
				facileLineListWidget->item(programCounter-1)->setForeground(Qt::black);
			}
			++programCounter;
		}
		programCounter = temp;
	}
	}
}

void DebuggerWindow::next(){
	int GOSUBline = programCounter;
	if(programCounter < 0){
		step();
	}
	if(isGOSUBVector[programCounter-1]==true){
		while(programCounter > 0 && programCounter <= (int)program.size()){
			//stop if line is breakpoint
			for(int i = 0; i < (int)breakPoints.size(); i++){
				
				if(programCounter == (int)breakPoints[i]){
					
					return;
				}
			}
			
			for (int i = 0; i < facileLineListWidget->count(); i++){
			facileLineListWidget->item(i)->setBackground(Qt::white);
		}

			//HIGHLIGHT current line
			facileLineListWidget->item(programCounter-1)->setBackground(Qt::yellow);
			if(facileLineListWidget->item(programCounter-1)->foreground()!=Qt::red){
				facileLineListWidget->item(programCounter-1)->setForeground(Qt::green);
			}
			program[programCounter]->execute(state, cout);
			temp = programCounter;
			programCounter = state->getProgramCounter();
			if(programCounter == -100){
				string line;
				stringstream ss;
				ss << temp;
				ss >> line;
				string error = "Line: ";
				error += line;
				error += " Cannot Divide by Zero";
				Error(error);
				resetListWidget();
				return;
			}
			else if(programCounter == -101){
				string line;
				stringstream ss;
				ss << temp;
				ss >> line;
				string error = "Line: ";
				error += line;
				error += " Illegal Jump Instruction";
				Error(error);
				resetListWidget();
				return;
			}
			else if(programCounter-1 == GOSUBline){
				return;
			}
		}
	}
	else{
		step();
	}
}

void DebuggerWindow::inspect(){
	ValuesWindow* valuesWindow = new ValuesWindow(state);
	valuesWindow->hide();
}

void DebuggerWindow::showDebuggerWindow(){
	this->show();
}

void DebuggerWindow::Error(string message){
	string errormessage = message;
	ErrorWindow* errorWindow = new ErrorWindow(errormessage);
	errorWindow->hide();
	//errorType = new QLabel(QString::fromStdString(message));
	//errorTopLayout->addWidget(errorType);

}

void DebuggerWindow::quitGracefully(){
	
	exit(0);
}


void DebuggerWindow::parseProgram(istream &inf, vector<Statement *> & program, vector<string> &codeLines)
{

	program.push_back(NULL);

	string line;
	int i = 0;
	while( !inf.eof() && i < 1000)
	{
		getline(inf, line);
		codeLines.push_back(line);
		if(inf.eof()){
			break;
		}
		program.push_back( parseLine( line ) );
	
		++i;
	}
}


Statement * DebuggerWindow::parseLine(string line)
{

	Statement * statement;	
	stringstream ss;
	string type;
	string var;
	int val;
	string p;

	ss << line;
	ss >> type;
	
	if ( type == "LET" )
	{
		
		ss >> var;
		ss >> val;
		// Note:  Because the project spec states that we can assume the file
		//	  contains a syntactically legal Facile program, we know that
		//	  any line that begins with "LET" will be followed by a space
		//	  and then a variable and then an integer value.
		statement = new LetStatement(var, val);
		isGOSUBVector.push_back(false);
	}
	else if( type == "END" || type == ".." || type == ".") {	
		statement = new EndStatement();
		isGOSUBVector.push_back(false);
	}
	else if( type == "PRINT"){
	
		ss >> var;
		statement = new PrintStatement(var);
		isGOSUBVector.push_back(false);
	}
	else if( type == "PRINTALL"){
		
		statement = new PrintAllStatement();
		isGOSUBVector.push_back(false);
	}
	else if ( type == "ADD"){

		ss >> var;
		ss >> p;
		statement = new AddStatement(var, p);
		isGOSUBVector.push_back(false);
	}
	else if ( type == "SUB"){
		
		ss >> var;
		ss >> p;
		statement = new SubStatement(var, p);
		isGOSUBVector.push_back(false);
	}
	else if ( type == "MULT"){
		
		ss >> var;
		ss >> p;
		statement = new MultStatement(var, p);
		isGOSUBVector.push_back(false);
	}
	else if ( type == "DIV"){
	
		ss >> var;
		ss >> p;
		statement = new DivStatement(var, p);
		isGOSUBVector.push_back(false);
	}
	else if (type == "GOTO"){

		ss >> val;
		statement = new GOTOStatement(val);
		isGOSUBVector.push_back(false);
	}
	else if (type == "IF"){
		string op;
		string gobbleThen;
		int lineNum;
		ss >> var;
		ss >> op;
		ss >> val;
		ss >> gobbleThen;
		ss >> lineNum;
		statement = new IFStatement(var, op, val, lineNum);
		isGOSUBVector.push_back(false);
	}
	else if(type == "GOSUB"){
		int lineNum;
		ss >> lineNum;
		statement = new GOSUBStatement(lineNum);
		isGOSUBVector.push_back(true);;
	}
	else if(type == "RETURN"){
		statement = new ReturnStatement();
		isGOSUBVector.push_back(false);
	}
	else{
		cout << "Unrecognized statement\n";
		return NULL;
	}
		
	return statement;
}