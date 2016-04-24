/*

Exam Scheduler Using AVL Tree
**By: Adam Moffitt**
**Date: 04/15/2016**

This program schedules exam time slots so that no 
student has two exams at the same time, using recursion 
and backtracking. The input file (whose name will be passed
in at the command line) will have three parameters on the
first line: how many exams there are, how many students there are,
and how many timeslots there are, separated by an arbitrary 
amount of whitespace. Each successive line will have the name
of a student (a string of lowercase letters), followed by the 
name of the classes that student is in (each one being an 
integer greater than 0). There will be an arbitrary amount
of whitespace between the student name and each class. 
I assume you always receive a correctly formatted input file.

The output is an assignment of classes to the integers
between 1 and the number of timeslots, one class per line:

If there is no solution for the requested number of timeslots, 
the program outputs No valid solution.
 
The program stores the final schedule in an AVL tree, and outputs 
the final schedule using an inorder traversal.
*/

#include <iostream>
#include <exception>
#include <cstdlib>
#include <vector>
#include <fstream>
#include <sstream>
#include <map>
#include "avlbst.h"

using namespace std;

bool isValid(map<int,vector<string> >::iterator const it1, map<int,vector<string> >::iterator const it2, map<int, vector<string> > map1, map<int, vector<string> > map2, AVLTree<int, int> *tree3);
bool fillTimeSlots(map<int,vector<string> >::iterator it1, map<int,vector<string> >::iterator it2, AVLTree <int , int> *tree3, map<int, vector<string> > &map1, map<int, vector<string> > &map2);


int main(int argc, char* argv[]){

  	if(argc < 2){
   	 	cerr << "Please provide an input file." << endl;
    	return 1;
 	 }

  	ifstream inf(argv[1]);

	if(!inf.is_open()){
		cerr << "File not found.\n";
	}

	//to read in input with stringstream
	string curr;

	int numberExams;
	int numberStudents;
	int timeSlots;

	getline(inf, curr);
	stringstream ss;

	ss << curr;

	ss >> numberExams;
	
	ss >> numberStudents;
	
	ss >> timeSlots;



	//class->students in that class
	map  <int, vector<string> > map1;

	//timeslot->students in that timeslot
	map  <int, vector<string> > map2;
	//insert timeslots map 
		
		for(int i = 0; i < timeSlots; i++){
			int temp = i;
			vector <string> emptyVector;
			pair<int, vector<string> > item2 = make_pair(temp, emptyVector);
			map2.insert(item2);
		}
	//class->timeslot
	AVLTree  <int, int> *tree3 = new AVLTree<int, int>();

	while(!inf.eof())
	{
		stringstream ss;
		getline(inf, curr);
		if(!curr.empty()){
			string name;
			ss << curr;
			ss >> name;
			int classIndex;
			while(ss >> classIndex){				
				//if class doesn't exist in tree yet
				if(map1.find(classIndex)==map1.end()){
					vector<string> temp;
					temp.push_back(name);
					pair<int, vector<string> > item3 = make_pair(classIndex, temp);
					map1.insert(item3);
				}
				//if class in tree
				else{
					vector<string> temp = map1.find(classIndex)->second;
					temp.push_back(name);
					 std::map<int,vector<string> >::iterator it;
					 it = map1.find(classIndex);
					  if (it != map1.end())
					    map1.erase (it);
					pair<int, vector<string> > item4 = make_pair(classIndex, temp);
					map1.insert(item4);
				}
			}
		}
	}

	std::map<int,vector<string> >::iterator it1 = map1.begin();
	std::map<int,vector<string> >::iterator it2 = map2.begin();

	if(!fillTimeSlots(it1, it2, tree3, map1, map2)){
		cout << "No valid solution" << endl;
	}
	else{
		for(BinarySearchTree<int,int>::iterator it = tree3->begin(); it != tree3->end(); ++it){
			cout << "Class: " << it->first << " " << "Timeslot: " << it->second+1 << endl;
		}
	}

	return 0;
}


bool isValid(map<int,vector<string> >::iterator const it1, map<int,vector<string> >::iterator const it2, map<int, vector<string> > map1, map<int, vector<string> > map2, AVLTree<int, int> *tree3){
	
	
	
	vector<string> studentsTimeSlot = it2->second;
	vector<string> studentsClass = it1->second;

	for(unsigned int i = 0; i < studentsTimeSlot.size(); ++i){
		for(unsigned int j = 0; j < studentsClass.size(); ++j){
			
			if(studentsClass[j].compare(studentsTimeSlot[i]) == 0){
				return false;
			}
		}
	}

	return true;
}

//pass in timeslot node and class node
bool fillTimeSlots(map<int,vector<string> >::iterator it1, map<int,vector<string> >::iterator it2, AVLTree <int , int> *tree3, map<int, vector<string> > &map1, map<int, vector<string> > &map2){

	if(it1 == map1.end()){
		return true;
	}

	while(it2!=map2.end()){
		
		if(isValid(it1, it2, map1, map2, tree3)){
			
			vector<string> studentsTimeSlot = it2->second;
			vector<string> studentsClass = it1->second;
			
			//assign
			int classIndex = it1->first;
			int timeSlotIndex = it2->first;
			vector<string> temp = studentsTimeSlot;
			//combine vectors of strings
			for(vector<string>::iterator myIt = studentsClass.begin(); myIt != studentsClass.end();++myIt){
				temp.push_back(*myIt);
			}
			std::map<int,vector<string> >::iterator it3;
			it3 = map2.find(timeSlotIndex);
			if (it3 != map2.end())
				map2.erase (it3);
			pair<int, vector<string> > item5 = make_pair(timeSlotIndex, temp);
			map2.insert(item5);

			//insert to AVLTree
			pair<int, int > item6 = make_pair(it1->first, timeSlotIndex);
			try{
				tree3->insert(item6);
			}catch(std::exception& e){
			  std::cerr << "exception caught: " << e.what() << '\n';	
			}

			//recursion
			if(fillTimeSlots(++it1, map2.begin(), tree3, map1, map2) == true){
				return true;
			}

			//if not true, remove 1. students added to timeslot vector from class vector
			// and 2. node from AVL tree
			it2 = map2.find(timeSlotIndex);
			if (it2 != map2.end())
				map2.erase (it2);
			pair<int, vector<string> > item1 = make_pair(timeSlotIndex, studentsTimeSlot);
			map2.insert(item1);
			it2 = map2.find(timeSlotIndex);
			try{	
				tree3->remove(classIndex);
				--it1;
				++it2;
				//cout << it1->first << " " << it2->first << endl;
			}catch(std::exception& e){
				std::cerr << "exception caught: " << e.what() << '\n';
			}
		}
		else{
			++it2;
		}
	}
	return false;
}
