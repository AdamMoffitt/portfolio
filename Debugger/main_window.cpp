#include "main_window.h"

MainWindow::MainWindow()
{
	// overall layout
	overallLayout = new QVBoxLayout();
	
	//line layout
	lineLayout = new QHBoxLayout();
	overallLayout->addLayout(lineLayout);

	//get Input Filename
	inputLabel = new QLabel("Enter Facile program file name: ");
	lineLayout->addWidget(inputLabel);

	inputFilename = new QLineEdit();
	lineLayout->addWidget(inputFilename);

	lineLayout->addStretch();

	//buttonLayout

	buttonLayout = new QHBoxLayout();
	overallLayout->addLayout(buttonLayout);

	quitButton = new QPushButton("Quit");
	connect(quitButton, SIGNAL(clicked()), this, SLOT(quitGracefully()));
	buttonLayout->addWidget(quitButton);

	loadButton = new QPushButton("Load");
	connect(loadButton, SIGNAL(clicked()), this, SLOT(loadFile()));
	connect(inputFilename, SIGNAL(returnPressed()), this, SLOT(loadFile()));
	buttonLayout->addWidget(loadButton);

	//set overall layout
	setLayout(overallLayout);

}

MainWindow::~MainWindow(){
	//TODO
	delete quitButton;
	delete loadButton;
	delete buttonLayout;
	delete inputLabel;
	delete lineLayout;
	delete overallLayout;
	delete inputFilename;
	
}

void MainWindow::Error(string message){

	ErrorWindow* errorWindow = new ErrorWindow(message);
	errorWindow->hide();

	//TODO Okay button in error doesnt work.
}



void MainWindow::quitGracefully(){
	exit(0);
}

void MainWindow::loadFile(){
	

	string filename = inputFilename->text().toStdString();
	if(filename.empty())
	{
		Error("No Input");
		return;
	}
	
    ifstream infile(filename.c_str());
    if (!infile)
    {
    		Error("File Doesn't Exist");
    		return;
    }

    else{
    	this->hide();
    	DebuggerWindow* debuggerWindow = new DebuggerWindow(infile, cout);
    	debuggerWindow->hide();
    }
}

