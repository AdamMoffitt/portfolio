#ifndef STACKINT_H
#define STACKINT_H
#include "llistint.h"

class StackInt {
 public:

  //Constructor
  StackInt();

  //Destructor
  ~StackInt();

  /**
   * Returns true if the stack is empty, false otherwise
   */
  bool empty() const;

  /**
   * Pushes a new value, val, onto the top of the stack
   */
  void push(const int& val);

  /**
   * Returns the top value on the stack
   */
  int const &  top() const;

  /**
   * Removes the top element on the stack
   */
  void pop();

 private:
  /** 
   * Single data member of the Stack.
   * We use composition to implement this Stack 
   */
  LListInt list;
};
#endif