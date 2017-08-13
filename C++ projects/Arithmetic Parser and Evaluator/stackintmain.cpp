#include "stackint.h"
#include "llistint.h"
#include <iostream>

using namespace std;

int main() 
{
	StackInt *stack = new StackInt;

	for(int i = 0; i<10; i++){
  		stack->push(i*5);
  		cout << stack->top() << endl;
	}

	stack->pop();
	stack->pop();
	stack->push(1);
	stack->push(10000);
	cout << "Top: " << stack->top() << endl;
	if(stack->empty())
		cout << "Stack is empty." << endl;
	else
		cout << "Stack is not empty." << endl;

	while(!stack->empty())
	{
		cout << stack->top() << endl;
		stack->pop();
	}
	cout << "stack is empty\n";
	stack->pop();

	delete stack;
	return 0;
}
