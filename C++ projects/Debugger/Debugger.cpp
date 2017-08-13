//Debugger.cpp
#include <QApplication>
#include <QStyle>
#include <QDesktopWidget>
#include <vector>
#include <string>
#include <sstream> 
#include <fstream>
#include <cstdlib>
#include <iostream>
#include "main_window.h"

using namespace std;


int main(int argc, char* argv[])
{
	QApplication app(argc, argv);

	MainWindow mainWindow;
	
	mainWindow.setGeometry(
    QStyle::alignedRect(
	        Qt::LeftToRight,
	        Qt::AlignCenter,
	        mainWindow.size()/4,
	        app.desktop()->availableGeometry()
    	)
    );

	//QApplication::setStyle(new QWindowsStyle);

	mainWindow.show();

	return app.exec();
}

