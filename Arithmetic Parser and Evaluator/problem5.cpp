/*

Program: Simple Arithmetic Parser and Evaluator

Author: Adam Moffitt

Date: 02/16/2016

This program will read simple arithmetic expressions from a file, 
and evaluate and show the output of the given arithmetic expressions.

Simple arithmetic expressions consist of integers, the operators 
PLUS (+), MULTIPLY (*), SHIFTLEFT (<), and SHIFTRIGHT (>), 
along with parentheses to specify a desired order of operations. 
The SHIFTLEFT operator indicates you should double the integer 
immediately following the operator. The SHIFTRIGHT operator indicates you 
should divide the integer by 2 (rounding down).

Simple Arithmetic Expressions are defined formally as follows:

Any string of digits is a simple arithmetic expression, namely a positive integer.
If Y1, Y2, ..., Yk are simple arithmetic expressions then the 
following are simple arithmetic expressions:
<Y1
>Y1
(Y1+Y2+Y3+...+Yk)
(Y1*Y2*Y3*...*Yk)

This format rules out the expression 12+23, since it is missing
the parentheses. It also rules out (12+34*123) which would have to 
instead be written (12+(34*123)), so never have to worry about precedence. 
Whitespace may occur in arbitrary places in arithmetic expressions, 
but never in the middle of an integer. Each expression will be on a single line.


This program takes the filename in which the formulas are stored as an input parameter. 
For each expression, the program outputs to cout, one per line, one of 
the options:
	-Malformed if the formula was malformed (did not meet the definition of a formula) 
		and then continue to the next expression.
	-An integer equal to the evaluation of the expression, if the expression 
		was well-formed.*/

#include "stackint.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <cstdlib>

using namespace std;



//This functions checks to make sure all characters in a line are valid characters and looks for any easily spottable 
//malformations and returns false if it finds a malformation
bool checkValidChar(const string& input){
	int counterParenth = 0;
	int counterMultiply = 0;
	int counterPlus = 0;
	int counterInt = 0;
	int totalParenth = 0;

	
	for(unsigned int i = 0; i < input.size(); i++){
		//check if each character is valid
		if((input[i]  >= 48 && input[i] <= 57) || (input[i] >= 40 && input[i] < 44) || input[i] == 60 || input[i] == 62 || input[i] == 32){
			if(input[i] == 40){
				counterParenth++;
				totalParenth++;
				counterMultiply = 0;
				counterPlus = 0;
			}
			//checks for too many + or *
			else if(input[i] == 41){
				if(counterPlus>=counterInt || counterMultiply>=counterInt){
					cerr << "Malformed" << endl;
					return false;
				}
				counterParenth--;
				counterMultiply = 0;
				counterPlus = 0;
			}

			//in case of operators but no parenthesis
			if((counterMultiply>0 && totalParenth == 0)|| (counterPlus>0&&totalParenth==0)){
				//cout << "Malformed" << endl;
				return false;
			}
			//if multiply, increment multiply
			else if(counterParenth > 0 && input[i] == 42){
				counterMultiply++;
			}
			//if plus, increment plus
			else if(counterParenth > 0 && input[i] == 43){
				counterPlus++;
			}

			
			if(i > 0){
				//if integer, increment countInt
				if(!(input[i-1]>=48 && input[i-1]<=57) && (input[i] >= 48 && input[i]<= 57)){
					counterInt++;
				}
				//check for shift immediately after integer
				if((input[i-1]>=48 && input[i-1]<=57) && (input[i]==60 || input[i]==62)){
					cerr << "Malformed" << endl;
					return false;
				}
			}
			else if(i==0 && (input[i]>=48 && input[i]<=57)){
				counterInt++;
			}

			//check for two integers without operators between them
			if((input[i] >= 48 && input[i]<= 57) && input[i+1]==32){
				bool isOperator = false;
				int j = i+1;
				while(!(input[j] >= 48 && input[j]<= 57)){
					if((input[j]>=40&&input[j]<=43))
						isOperator = true;
					j++;
				}
				if(!isOperator){
					cerr << "Malformed" << endl;
					return false;
				}
			}

			//check for plus and multiply in same parenthesis
			if(counterParenth > 0 && counterMultiply > 0 && counterPlus > 0){
				cerr << "Malformed" << endl;
				return false;
			}
			continue;
		}
		else{
			cerr << "Malformed" << endl;
			return false;
		}
	} 
	//checks for cases like 1+1 with no parenthesis
	if(counterInt > 1 && totalParenth==0){
		cerr << "Malformed" << endl;
		return false;
	}

	//checks for too many + or * signs 
	if ((counterMultiply != 0 && counterPlus != 0) && ((counterMultiply+counterPlus)!=(counterInt-1))){
		cerr << "Malformed" << endl;
		return false;
	}


	if(counterParenth!=0){
		cerr << "Malformed" << endl;
		return false;
	}
	else
		return true;
}

//This function takes in two values and a negative number indicating a special character and performs the 
//desired operation and then returns the result
int calc(int first, int math, int second){

	int value = 0;
	if(math == -3){
		value = first + second;
	}
	else if(math == -4){
		value = first * second;
	}
	else if(math == -5){
		value = first * 2;
	}
	else if(math == -6){
		value = first / 2;
	}
	return value;
}

//This function takes in one value and a special operator (either the shift left or shift right) and performs the calculation
//and returns the value of the calculation
int calc(int first, int math){

	int value=0;
	if(math == -5){
		value = first * 2;
	}
	else if(math == -6){
		value = first / 2;
	}
	return value;
}

/*
 *This function checks to see if an integer has multiple shift operators before it, and if so, performs the shift
 *operations on the integer and then pushes the calculated result
 */
void checkShifts(StackInt* stack, int &result, int &size){
	
	int number = stack->top();
	stack->pop();
	size--;
	
	if(stack->top() == -5 || stack->top() == -6){
		while((stack->top() == -5 || stack->top() == -6) && size!=0){
			if(stack->top() == -5){
		
				number = number*2;
		
				stack->pop();
				size--;
				if(size == 0){
					result = number;
					return;
				}
			}
			else if(stack->top()==-6){
			
				number = number/2;
				
				stack->pop();
				size--;
				if(size == 0){
					result = number;
					return;
				}
			}
		}
		
		stack->push(number);
		
		size++;
	}
	else {
		stack->push(number);
	
		size++;
	}
}

void popLockAndDrop(StackInt* stack, int &result, int &size, int &reachedOpen){
	
	//check for shiftleft or shiftright operators that will mess with normal order of operations
	if(stack->top()>=0){
		checkShifts(stack, result, size);
	}
	int first = stack->top();

	stack->pop();
	size--;

	
	//check if at end of stack
	if((stack->top() == -1 && size == 1) || size == 0){
		
		result = first;
		if(size!=0){
			stack->pop();
			size--;
		}
		return;
	}
	//if open parenthesis, pop open parenthesis and go back to see if more to push on input line
	else if(stack->top() == -1){
		stack->pop();
		stack->push(first);
		reachedOpen = 1;
		return;
	}

	int math = stack->top();
	//cout << "math is " << math << endl;
	stack->pop();
	size--;

	//check for shiftleft or shiftright operators that will mess with normal order of operations
	if(stack->top()>=0){
		checkShifts(stack, result, size);
	}

	int second = stack->top();

	//if first is int, math is operator, and second is number, call calc with 3 parameters
	if((math<0) && (second>=0)) {
		result = calc(first, math, second);
		stack->pop();
		size--;
		stack->push(result);
		size++;

	} 
	else if(math<0 && second<0){
		stack->push(math);
		size++;
		stack->push(first);
		size++;
		if(stack->top()>=0){
			checkShifts(stack, result, size);
		}	
	}
}


int main(int argc, char* argv[]){
	
	int result = 0;
	int size = 0;
  	if(argc < 2){
   	 	cerr << "Please provide an input file." << endl;
    	return 1;
 	 }

  	ifstream input(argv[1]);

	if(!input.is_open()){
		cerr << "File not found.\n";
	}
	//to read in input with stringstream
	string curr;

	//declare constant variables to substitute for special charactersa to push into stack
	const int OPEN_PAREN = -1;
	//const int CLOSE_PAREN = -2;
	const int PLUS = -3;
	const int MULTIPLY = -4;
	const int SHIFTLEFT = -5;
	const int SHIFTRIGHT = -6;


	//create a new stack
	StackInt* stack = new StackInt();

	while(getline(input, curr))
	{
		if(!curr.empty()){
			if (!checkValidChar(curr))
				continue;
			else {

				stringstream ss;
				ss << curr;
				char a;
				ss >> a;

				//check if input char is appropriate to start line
				if(stack->empty() && (a != 40 && a != 60 && a != 62 && !(a >= 48 && a <= 57))){
						cerr << "Malformed" << endl;
				}
				else{
					ss.putback(a);

					while(ss >> a){
						if(curr.size() == 1){
							if(curr[0] >= 48 && curr[0]<= 57){
								result = curr[0];
								continue;
							}
						}
						
						if(a == '<'){
							stack->push(SHIFTLEFT);
							
							size++;
						}
						else if (a == '>'){
							stack->push(SHIFTRIGHT);
							
							size++;
						}
						else if (a == '('){
							stack->push(OPEN_PAREN);
							
							size++;
						}
						else if (a == '+'){
							stack->push(PLUS);
							
							size++;
						}
						else if (a == '*'){
							stack->push(MULTIPLY);
							
							size++;
						}
						else if (a >= 48 && a<= 57){
							ss.putback(a);
							int number;
							ss >> number;
							//cout << "Number: " << number << endl;
							stack->push(number);
							size++;
							//cout << "push integer" << endl;
						}
						else if(a == 41){
							
							//check to see if item before close parenthesis is an integer as it should be
							if(stack->top() < 0){
								cerr << "Malformed" << endl;
								continue;
							}
							else{
								int reachedOpen = 0;
								while(!stack->empty() && reachedOpen == 0){
									reachedOpen = 0;
									if(stack->top() == -1){
										
										stack->pop();
										size--;
										
									}

									if(stack->top() >= 0 && size > 1){
										popLockAndDrop(stack, result, size, reachedOpen);
									}

									//cout << "Result is currently: " << result << endl;

									if(size == 1 && result == stack->top()){
										stack->pop();
										size--;
										continue;
									}
								}
							}
						}
					}
					if(curr.size() == 1 && curr[0] >= 48 && curr[0]<= 57){
							cerr << curr[0] << endl;
							continue;
					}
					else if(!stack->empty() && stack->top()>0){
						checkShifts(stack, result, size);
						cerr << result << endl;
					}
					else if(!stack->empty() && stack->top()<0){
						cerr << "Malformed" << endl;
					}
					else {
						cerr << result << endl;
						while(!stack->empty()){
							stack->pop();
						}
					}
				continue;	
				}
			}
		}
	}
delete stack;
return 0;
}
