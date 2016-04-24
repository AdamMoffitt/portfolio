#ifndef LLISTINT_H
#define LLISTINT_H

class LListInt {
 public:
  struct Item {
    int val;
    Item *prev;
    Item *next;
  } item;

  /**
   * Default constructor
   */
  LListInt();
 /**
   * Copy constructor (deep copy)
   */
  LListInt(const LListInt& other);

  /**
   * Assignment Operator (deep copy)
   */
  LListInt& operator=(const LListInt& other);

  /**
   * Concatenation Operator (other should be appended to the end of this)
   */
  LListInt operator+(const LListInt& other) const;

  /**
   * Access Operator
   */
  int const & operator[](int position) const;

  /**
   * Destructor
   */
  ~LListInt();

  /**
   * Returns the current number of items in the list 
   */
  int size() const;

  /**
   * Returns true if the list is empty, false otherwise
   */
  bool empty() const;

  /**
   * Inserts val so it appears at index, pos
   */
  void insert(int pos, const int& val);

  /**
   * Removes the value at index, pos
   */
  void remove(int pos);

  /**
   * Overwrites the old value at index, pos, with val
   */
  void set(int pos, const int& val);

  /**
   * Returns the value at index, pos
   */
  int& get(int pos);

  /**
   * Returns the value at index, pos
   */
  int const & get(int pos) const;

  /**
   * Deletes all items in the list
   */
  void clear();

 private:
  /** 
   * Returns a pointer to the item at index, pos
   *  and NULL for an invalid position
   */
  Item* getNodeAt(int pos) const;

  /**
   * Data members
   */
  Item* head_;
  Item* tail_;
  int size_;
};

#endif