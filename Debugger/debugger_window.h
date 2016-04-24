#ifndef DEBUGGER_WINDOW_H
#define DEBUGGER_WINDOW_H

#include "Statement.h"
#include "LetStatement.h"
#include "ProgramState.h"
#include "PrintStatement.h"
#include "PrintAllStatement.h"
#include "EndStatement.h"
#include "AddStatement.h"
#include "SubStatement.h"
#include "MultStatement.h"
#include "DivStatement.h"
#include "GOTOStatement.h"
#include "IFStatement.h"
#include "GOSUBStatement.h"
#include "ReturnStatement.h"
#include "stackint.h"
#include "values_window.h"
#include "error_window.h"
#include <QWidget>
#include <QVBoxLayout>
#include <QLabel>
#include <QLineEdit>
#include <QTextEdit>
#include <QPushButton>
#include <QListWidget>
#include <string>
#include <vector>
#include "stdlib.h"
#include <fstream>
#include <sstream>
#include <iostream>

using namespace std;


class DebuggerWindow : public QWidget
{
	Q_OBJECT
public:
	DebuggerWindow(istream& inf, ostream& outf);
	virtual ~DebuggerWindow();
	void Error(string message);
	void showDebuggerWindow();
	void parseProgram(istream& inf, vector<Statement *> & program, vector<string> &codeLines);
	Statement * parseLine(string line);
	void resetListWidget();

	
private slots:
	void quitGracefully();
	void cont();
	void brk();
	void step();
	void next();
	void inspect();

private:

	vector<Statement *> program;
	vector <bool> isGOSUBVector;
	ProgramState* state;
	int programCounter;
	vector <int> breakPoints;

	//Debugger Window
	QWidget* debuggerWindow;
	QVBoxLayout* debuggerLayout;

	QHBoxLayout* topHalfLayout;

	QListWidget* facileLineListWidget;
	QVBoxLayout* sideButtons;
	QPushButton* continueButton;
	QPushButton* breakButton;
	QPushButton* stepButton;
	QPushButton* nextButton;
	QPushButton* inspectButton;
	QPushButton* quitButton;
	
	int temp;
	//vector of lines that will correspond with the vector of statements
	std::vector<std::string> line;
};

#endif