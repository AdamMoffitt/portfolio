#ifndef MAIN_WINDOW_H
#define MAIN_WINDOW_H

#include "debugger_window.h"
#include "error_window.h"
#include <QWidget>
#include <QVBoxLayout>
#include <QDesktopWidget>
#include <QLabel>
#include <QLineEdit>
#include <QTextEdit>
#include <QPushButton>
#include <QListWidget>
#include <QComboBox>
#include <string>
#include <vector>
#include <fstream>
#include <sstream>
#include <iostream>
#include "stdlib.h"
using namespace std;

class MainWindow : public QWidget
{
	Q_OBJECT
public:
	MainWindow();
	virtual ~MainWindow();
	void Error(string message);

private slots:
	void quitGracefully();
	
	//loadwindow
	void loadFile();

private:

	// // UI Load Window
	// Layouts
	QVBoxLayout* overallLayout;
	QHBoxLayout* lineLayout;
	QHBoxLayout* buttonLayout;

	//quit button
	QPushButton* quitButton;

	//load button
	QPushButton* loadButton;

	//filename input
	QLabel* inputLabel;
	QLineEdit* inputFilename;

	//vector of lines that will correspond with the vector of statements
	std::vector<std::string> line;

	DebuggerWindow* debuggerWindow;
	ErrorWindow* errorWindow;
};


#endif