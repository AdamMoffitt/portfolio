#include "values_window.h"

ValuesWindow::ValuesWindow(ProgramState* state){

	this->state = state;

	//VALUE WINDOW
	valuesWindow = new QWidget();
	valuesWindow->setWindowTitle("Current Values");
	valuesLayout = new QHBoxLayout;
	VbuttonsLayout = new QVBoxLayout;
	currentValuesListWidget = new QListWidget;
	valuesLayout->addWidget(currentValuesListWidget);
	valuesLayout->addLayout(VbuttonsLayout);

	//Combobox
	comboBoxLayout = new QHBoxLayout();
	QLabel* sortByLabel = new QLabel("Sort By:");
	comboBoxLayout->addWidget(sortByLabel);
	valuesWindowComboBox = new QComboBox();
	comboBoxLayout->addWidget(valuesWindowComboBox);
	valuesWindowComboBox->addItem("Name - Ascending");
	valuesWindowComboBox->addItem("Name - Descending");
	valuesWindowComboBox->addItem("Value - Increasing");
	valuesWindowComboBox->addItem("Value - Decreasing");
	VbuttonsLayout->addLayout(comboBoxLayout);

	//Update window
	updateButton = new QPushButton("Update");
	connect(updateButton, SIGNAL(clicked()), this, SLOT(updateValues()));
	VbuttonsLayout->addWidget(updateButton);

	//Hide button - values window
	hideButton = new QPushButton("Hide");
	connect(hideButton, SIGNAL(clicked()), this, SLOT(hideValuesWindow()));
	VbuttonsLayout->addWidget(hideButton);

	valuesWindow->setLayout(valuesLayout);
	this->displayFacileCodeFromMap();
	vector < pair <string, int> > mapVector;

	valuesWindow->show();
}

ValuesWindow::~ValuesWindow(){
	delete comboBoxLayout;
	delete valuesWindow;
	delete valuesLayout;
	delete VbuttonsLayout;
	delete currentValuesListWidget;
	delete hideButton;
	delete updateButton;
	delete valuesWindowComboBox;

	delete state;
}

void ValuesWindow::updateValues(){

	sort();

	displayFacileCodeFromVector();
}

void ValuesWindow::hideValuesWindow(){
	valuesWindow->hide();
}

void ValuesWindow::displayFacileCodeFromVector(){
	//show values from vector
	currentValuesListWidget->clear();
	string value;
	for(int i = 0; i < (int)mapVector.size(); ++i)   
		{
			stringstream ss;
			ss << mapVector[i].first;
			ss << "_";
			ss << mapVector[i].second;
			ss >> value; 
			currentValuesListWidget->addItem(QString::fromStdString(value));
		}
		valuesWindow->show();
}

void ValuesWindow::displayFacileCodeFromMap(){
	//Show values from State
	map<string, int> myMap = state->getMap();
	map<string, int>::iterator it;
	string value;
	for(it = myMap.begin( ); it != myMap.end( ); ++it)   
		{
			stringstream ss;
			ss << it->first;
			ss << "_";
			ss << it->second;
			ss >> value; 
			currentValuesListWidget->addItem(QString::fromStdString(value));
		}
	valuesWindow->show();
}

void ValuesWindow::sort(){
	mapVector.clear();
	map<string, int> myMap = state->getMap();
	map<string, int>::iterator it;
	for(it = myMap.begin( ); it != myMap.end( ); ++it)   
		{
			mapVector.push_back(make_pair(it->first, it->second));
		}

	int choice = (int)valuesWindowComboBox->currentIndex();

	NameSortAscComp comp1;
	NameSortDescComp comp2;
	ValueSortAscComp comp3;
	ValueSortDescComp comp4;
	if (choice == 0){

		mergeSort(mapVector, comp1);
	
	}
	else if (choice == 1){
		
		mergeSort(mapVector, comp2);

	}
	else if (choice == 2){
		
		mergeSort(mapVector, comp3);
		
	}
	else if (choice == 3){
		
		mergeSort(mapVector, comp4);
		
	}
	else{
		
		mergeSort(mapVector, comp1);
		
	}
}
