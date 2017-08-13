/**
 * bst.h
 *  Implements a(n unbalanced) BST storing Key,Value pairs
 */
#ifndef BST_H
#define BST_H
#include <iostream>
#include <exception>
 #include <stdexcept>
#include <cstdlib>
#include <utility>
 #include <sstream>
 using namespace std;

/* -----------------------------------------------------
 * Regular Binary Tree Nodes
 ------------------------------------------------------*/

template <class KeyType, class ValueType>
  class Node {
 public:
  Node (const KeyType & k, const ValueType & v, Node<KeyType, ValueType> *p)
    : _item(k, v)
   // the default is to create new nodes as leaves
    { _parent = p; _left = _right = NULL; }
  
  virtual ~Node()
  { }
  
  std::pair<const KeyType, ValueType> const & getItem () const
    { return _item; }
  
  std::pair<const KeyType, ValueType> & getItem ()
    { return _item; }
  
  const KeyType & getKey () const
  { return _item.first; }
  
  const ValueType & getValue () const
  { return _item.second; }
  
  /* the next three functions are virtual because for AVL-Trees,
     we'll want to use AVL nodes, and for those, the
     getParent, getLeft, and getRight functions should return 
     AVL nodes, not just ordinary nodes.
     That's an advantage of using getters/setters rather than a struct. */
  
  virtual Node<KeyType, ValueType> *getParent () const
    { return _parent; }
  
  virtual Node<KeyType, ValueType> *getLeft () const
    { return _left; }
  
  virtual Node<KeyType, ValueType> *getRight () const
    { return _right; }
  
  
  void setParent (Node<KeyType, ValueType> *p)
  { _parent = p; }
  
  void setLeft (Node<KeyType, ValueType> *l)
  { _left = l; }
  
  void setRight (Node<KeyType, ValueType> *r)
  { _right = r; }
  
  void setValue (const ValueType &v)
  { _item.second = v; }
  
 protected:
  std::pair<const KeyType, ValueType> _item;
  Node <KeyType, ValueType> *_left, *_right, *_parent;
};

/* -----------------------------------------------------
 * Regular Binary Search Tree
 ------------------------------------------------------*/

template <class KeyType, class ValueType>
class BinarySearchTree {
 protected:
  // Main data member of the class
  Node<KeyType, ValueType> *root;

 public:
  /**
   * Constructor
   */
  BinarySearchTree () { root = NULL; }

  /**
   * Destructor
   */
  ~BinarySearchTree () { deleteAll (root); }

  /**
   * Prints the entire tree structure in a nice format 
   *  
   * It will denote subtrees in [] brackets.
   *  This could be helpful if you want to debug your functions. 
   */  
  void print () const
  { 
    printRoot (root);
    std::cout << "\n";
  }
    
   Node<KeyType, ValueType> * myRoot(){
      return root;
   }

  void getRoot() const
    {
      std::cout << "Root: " << root->getKey() << std::endl;
    }
  /**
   * An In-Order iterator
   *  !!! You must implement this !!!
   */
  class iterator {
  public:
    /**
     * Initialize the internal members of the iterator
     */
    iterator(Node<KeyType,ValueType>* ptr){
      curr = ptr;
    }
    
    std::pair<const KeyType,ValueType>& operator*()
      { return curr->getItem();  }
    
    std::pair<const KeyType,ValueType>* operator->() 
      { return &(curr->getItem()); }
    
    /**
     * Checks if 'this' iterator's internals have the same value
     *  as 'rhs'
     */
    bool operator==(const iterator& rhs) const{
      return (curr == rhs.curr);

      /*if(this->getKey() == rhs->getKey() && this->getValue() == rhs->getValue()){
        return true;
      }
      else
        return false;*/
    }
    
    /**
     * Checks if 'this' iterator's internals have a different value
     *  as 'rhs'
     */
    bool operator!=(const iterator& rhs) const{
      return !(curr == rhs.curr);
      /*if(this->getKey() == rhs->getKey() && this->getValue() == rhs->getValue()){
        return false;
      }
      else
        return true;*/
}
    
    /**
     * Advances the iterator's location using an in-order sequencing
     */
    iterator& operator++(){
   
      if(curr->getRight()!=NULL){
        curr=curr->getRight();
        while(curr->getLeft()!=NULL){
          curr=curr->getLeft();
        }
      }
      else{
        while(curr->getParent()!=NULL&&curr->getParent()->getLeft() != curr){
          curr = curr->getParent();
        }
        curr = curr->getParent();
      }
      return *this;
    }
    
  protected:
    Node<KeyType, ValueType>* curr;
    //you are welcome to add any necessary variables and helper functions here.
  };
  

  /**
   * Returns an iterator to the "smallest" item in the tree
   */
  iterator begin(){
    //go to farthest left node #where left pointer == NULL
    Node<KeyType, ValueType>* a = root;
    while(a->getLeft() != NULL){
      a = a->getLeft();
    }
    iterator it(a);
    return it;
  }

  /**
   * Returns an iterator whose value means INVALID
   */
  iterator end(){
    iterator it(NULL);
    return it;
  } 


void insert (const std::pair<const KeyType, ValueType>& new_item){
  /* This one is yours to implement.
     It should insert the (key, value) pair to the tree, 
     making sure that it remains a valid AVL Tree.
     If the key is already in the tree, you should throw an exception. */

     KeyType key = new_item.first;
     ValueType value = new_item.second;
     Node<KeyType, ValueType> *p;


     if(this->root == NULL){
      this->root = new Node<KeyType, ValueType>(key, value, NULL);
      cout << "Root is now node: " << this->root->getKey() << endl;
      return;
     }

    else{
      
      p = this->root;
      //cout << "Insert node: " << key << " , " << value << endl;
      while(p != NULL){
        if (key < p->getKey()){
          if(p->getLeft() != NULL){
            p = p->getLeft();
          }
          else{
            Node<KeyType, ValueType> * new_node = new Node<KeyType, ValueType>(key,value, p);
            p->setLeft(new_node);
            break;
          }
        }
        else if ( key > p->getKey()){
         
          if(p->getRight() != NULL){
            p = p->getRight();
          
          }
          else{
            
            Node<KeyType, ValueType> * new_node = new Node<KeyType, ValueType>(key, value, p);     
            p->setRight(new_node);
            break;
          }
        }
        else if (key == p->getKey()){
          stringstream ss;
          ss << key;
          string number;
          ss >> number;
          string errorMessage = "Element ";
          errorMessage += number;
          errorMessage += " already exists.";
          throw logic_error(errorMessage);
        }
      }
    }
    //cout << "Root is now node: " << this->root->getKey() << endl;
    //this->print();
    //cout << endl;
  }


      /**
   * Helper function to find a node with given key, k and 
   * return a pointer to it or NULL if no item with that key
   * exists
   */
  Node<KeyType, ValueType>* internalFind(const KeyType& k) const 
  {
    Node<KeyType, ValueType> *curr = root;
    while (curr) {
      if (curr->getKey() == k) {
         return curr;
      } else if (k < curr->getKey()) {
          curr = curr->getLeft();
      } else {
          curr = curr->getRight();
      }
    }
    return NULL;
  }
  
  //GET SUCCESSOR
  Node<KeyType, ValueType>* getSuccessor(Node<KeyType, ValueType> *r){
      
      if(r == NULL){
        return NULL;
      }

     else if(r->getRight() != NULL){
        return smallestValue(r->getRight());
      }

      //if node has no right child, traverse up tree
      Node<KeyType, ValueType>  * a = r->getParent();
      Node<KeyType, ValueType>  * b = r;

      while (a!=NULL && b == a->getRight())
      {
            b = a;
            a = a->getParent();
      }
      //if a is left child of b
      return b;
    }

    Node<KeyType, ValueType>* smallestValue(Node<KeyType, ValueType> *r){
        Node<KeyType, ValueType>* curr = r;
        while(curr->getLeft()!=NULL){
          curr = curr->getLeft();
        }
        return curr;
    }

 protected:
  

  
  /**
   * Helper function to print the tree's contents
   */
  void printRoot (Node<KeyType, ValueType> *r) const
  {
    if (r != NULL)
      {
	std::cout << "[";
	printRoot (r->getLeft());
	std::cout << " (" << r->getKey() << ", " << r->getValue() << ") ";
	printRoot (r->getRight());
	std::cout << "]";
      }
  }
  
  /**
   * Helper function to delete all the items
   */
  void deleteAll (Node<KeyType, ValueType> *r)
  {
    if (r != NULL)
      {
        if(r->getLeft()!= NULL){
        	deleteAll (r->getLeft());
        }
        if(r->getRight()!=NULL){
        	deleteAll (r->getRight());
        }
        	delete r;
      }
  }

 
};

/* Feel free to add member function definitions here if you need */

#endif
