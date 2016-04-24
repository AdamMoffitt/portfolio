#ifndef ERROR_WINDOW_H
#define ERROR_WINDOW_H

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
#include <iostream>
using namespace std;


class ErrorWindow : public QWidget
{
	Q_OBJECT

public:
	ErrorWindow(string);
	virtual ~ErrorWindow();
	
private slots:
	void hideError();

private:
	//Error Window
	QWidget* errorWindow;
	QVBoxLayout* errorLayout;
	QVBoxLayout* errorTopLayout;
	QLabel* errorType;
	
	//QWidget errorWindow;
	QLabel* errorMessage;
	QPushButton* okayButton;

};
#endif