#include "error_window.h"

ErrorWindow::ErrorWindow(string message){
	
//ERROR MESSAGE - dont show at first
	errorLayout = new QVBoxLayout();
	errorTopLayout = new QVBoxLayout();
	errorLayout->addLayout(errorTopLayout);
	errorWindow = new QWidget();
	errorWindow->setGeometry(20,20,20, 20);
	//error message
	errorMessage = new QLabel("Error!");
	errorTopLayout->addWidget(errorMessage);

	//Error Font
	QFont errorFont;
      errorFont.setBold(true);
      errorFont.setPointSize(30);
      errorMessage->setFont(errorFont);

      //okay button
	okayButton = new QPushButton("Okay");
	connect(okayButton, SIGNAL(clicked()), this, SLOT(hideError()));
	errorLayout->addWidget(okayButton);
	errorWindow->setLayout(errorLayout);

	errorType = new QLabel(QString::fromStdString(message));
	errorTopLayout->addWidget(errorType);

	errorWindow->show();

}

ErrorWindow::~ErrorWindow(){
	delete errorWindow;
	delete errorLayout;
	delete errorTopLayout;
	delete errorType;
	delete errorMessage;
	delete okayButton;
}


void ErrorWindow::hideError(){
	errorTopLayout->removeWidget(errorType);
	errorWindow->hide();
}
