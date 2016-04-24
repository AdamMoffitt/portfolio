#include "llistint.h"
#include <iostream>
#include <cstdlib>
#include <stdexcept>
using namespace std;

LListInt::LListInt()
{
  head_ = NULL;
  tail_ = NULL;
  size_ = 0;
}

LListInt::~LListInt()
{
  clear();
}

 /**
   * Copy constructor (deep copy)
   */
  LListInt::LListInt(const LListInt& other)
  {

    head_ = NULL;
    tail_ = NULL;
    size_ = 0;

    for(int j = 0; j < other.size_; j++)
    {
       this->insert(j, other.get(j));
    }
  }

 /**
   * Assignment Operator (deep copy)
   */
  LListInt& LListInt::operator=(const LListInt& other){
    
        this->clear();
        head_ = NULL;
        tail_ = NULL;
        size_ = 0;
 
    for(int j = 0; j < other.size(); j++){
         this->insert(j, other.get(j));
      }

      return *this;
  }

  /**
   * Concatenation Operator (other should be appended to the end of this)
   */
  LListInt LListInt::operator+(const LListInt& other) const
  {
    LListInt copy(*this);

  for(int j = 0; j < other.size(); j++){
         copy.insert(copy.size(), other.get(j));
      }
    return copy;
  }

/**
   * Access Operator
   */
  int const & LListInt::operator[](int position) const{
    return this->get(position);
  }


bool LListInt::empty() const
{
  return size_ == 0;
}

int LListInt::size() const
{
  return size_;
}

/**
 * Insert function checks if location is valid, if linked list is empty creates first item, 
 * if list exists creates item at desired location and changes pointers to include new item,
 * if location is a beginning of list, creates new beginning and points previous head to new 
 * first item, and if location is at end of list adds new item to end of list and changes tail 
 * pointer. ALSO all valid inserts increment size_ by 1.
 */
void LListInt::insert(int loc, const int& val)
{
  
  //If the desired location is greater than the size_ of the list, output error 
  if((loc>size_)||(loc<0)){
    return;
  }
  
  //if linked list does not yet exist, make beginning of linked list
  else if(size_== 0){
      Item* first = new Item;
        first->val = val;
        first->prev = NULL;
        first->next = NULL;
        head_ = first;
        tail_ = first;  
        first->prev = tail_;
        size_++;
  }

  /*if loc = 0 and list exists, insert at start of existing linked list
   * -set new Item to point at current head
   * -set current head prev to point at new Item
   * -change head pointer to point at new item
   */
  else if (loc==0){
      Item* newItem = new Item;
      newItem->val = val;
      newItem->next = head_;
      head_->prev = newItem;
      head_ = newItem;
      size_++;
    }

  /*If desired location equals size_, add to end of list.
   * -set current last item to point to new item
   * -change tail to point to last item
   * -make newItem point to NULL
   */
  else if(loc==size_){
     Item* newItem = new Item;
     newItem->val = val;
     Item* temp = tail_;
     temp->next = newItem;
     newItem->prev = temp;
     newItem->next = NULL;
     tail_ = newItem;
     size_++;
    }

  /**Make new item, traverse list to node before desired location, and 
  *  -change pointers to include newItem
  *  -change previous item to point to new item
  *  -change new item to point prev to previous item
  *  -change new item to point next to next
  *  -change next item to point prev at newItem
  */
  else {
      
        Item* counter = getNodeAt(loc); //returns item before location of insert
        Item* newItem = new Item;
        newItem->val = val;
        newItem->prev = counter;
        newItem->next = counter->next;
        counter->next->prev = newItem;
        counter->next = newItem;
        size_++;
      }
  }
  


/**
 * Remove function checks if location is valid, if there is only one item in list, calls clear(),
 * if removing last item from the list, changes the tail pointer to new last item and sets last item
 * next pointer to NULL, and if removing first item from list moves head pointer to new first item and
 * sets new first item previous pointer to NULL
 * ALSO all valid removes decrement size_ by 1.
 */
void LListInt::remove(int loc)
{

  //If the desired location is greater than the size_ of the list, output error
  if(loc>=size_||loc<0){
    return;
  }

  //If only one item in list call clear()
  else if(size_==1){
    clear();
  }

  else{
      //If removing last item from list, move tail pointer to new last item
      if(loc==size_-1){
      Item* counter = getNodeAt(loc);
      tail_ = counter;
      counter->next->prev = NULL;
      delete counter->next;
      counter->next = NULL;
      size_--;
    } 

    //If removing first item from list, move head pointer to new first item
    else if(loc==0){
      head_= head_->next;
      delete head_->prev;
      head_->prev = NULL;
      size_--;
    }

    //remove item in middle of list. reset pointers of elements around item and delete item
    else{
    Item* counter = getNodeAt(loc+1);
    Item* temp = counter;
    counter->prev->next = temp->next;
    counter->next->prev= temp->prev;
    delete counter;
    size_--;
    }
  }
}

void LListInt::set(int loc, const int& val)
{
  Item *temp = getNodeAt(loc);
  temp->next->val = val;
}

int& LListInt::get(int loc)
{
  if(loc < 0 || loc >= size_){
    throw std::invalid_argument("bad location");
  }
  Item *temp = getNodeAt(loc+1);
  return temp->val;
}

int const & LListInt::get(int loc) const
{
  if(loc < 0 || loc >= size_){
    throw std::invalid_argument("bad location");
  }
  Item *temp = getNodeAt(loc+1);
  return temp->val;
}

void LListInt::clear()
{
  while(head_ != NULL){
    Item *temp = head_->next;
    delete head_;
    head_ = temp;
  }
  tail_ = NULL;
  size_ = 0;
}


/**
 * returns the node before the node the desired node by using a temp counter to trace through
 * list to loc-1 and return pointer to that item.
 */
LListInt::Item* LListInt::getNodeAt(int loc) const
{

    Item* counter = head_;
      int temp = 0;
      if(loc == 0 ){
        return head_;
      }
      else{
        while(temp!=loc-1){
        
          if(counter->next!=NULL){
          counter = counter->next;
          temp++;
          }
        }
      }
     
    return counter;
  
}

