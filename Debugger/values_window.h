#ifndef VALUES_WINDOW_H
#define VALUES_WINDOW_H

#include "m_sort.h"
#include <QWidget>
#include <QVBoxLayout>
#include <QLabel>
#include <QLineEdit>
#include <QTextEdit>
#include <QPushButton>
#include <QListWidget>
#include <QComboBox>
#include <string>
#include <vector>
#include "stdlib.h"
#include <sstream>
#include "ProgramState.h"
#include <iostream>
using namespace std;

class ValuesWindow : public QWidget
{
	Q_OBJECT
public:
	ValuesWindow(ProgramState* state);
	virtual ~ValuesWindow();
	void displayFacileCodeFromMap();
	void displayFacileCodeFromVector();
	void sort();

private slots:
	void hideValuesWindow();

	void updateValues();

private:

	vector < pair <string, int> > mapVector;

	//Value Window
	QHBoxLayout* comboBoxLayout;
	QWidget* valuesWindow;
	QHBoxLayout* valuesLayout;
	QVBoxLayout* VbuttonsLayout;
	QListWidget* currentValuesListWidget;
	QPushButton* hideButton;
	QPushButton* updateButton;
	QComboBox* valuesWindowComboBox;

	ProgramState* state;

};

#endif