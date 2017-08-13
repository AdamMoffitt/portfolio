#include "stackint.h"
#include <iostream>
using namespace std;

StackInt::StackInt()
{
	
}

StackInt::~StackInt(){
	
}

/**
   * Returns true if the stack is empty, false otherwise
   */
  bool StackInt::empty() const{
  	return list.empty();
  }

  /**
   * Pushes a new value, val, onto the top of the stack
   */
  void StackInt::push(const int& val){
  	list.insert(list.size(), val);
  }

  /**
   * Returns the top value on the stack
   */
  int const &  StackInt::top() const{
  	int size = list.size();
  	return list.get(size-1);
  }

  /**
   * Removes the top element on the stack
   */
  void StackInt::pop(){
  	int size = list.size();
  	list.remove(size-1);
  }
