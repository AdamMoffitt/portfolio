/*
 * avlbst.h
 *
 * Date        Author    Notes
 * =====================================================
 * 2014-04-14  Kempe     Initial version
 * 2015-04-06  Redekopp  Updated formatting and removed
 *                         KeyExistsException
 * 2016-03-31  Cote      Modify for AVL Trees
 */
#ifndef AVLBST_H
#define AVLBST_H

#include <iostream>
#include <exception>
#include <stdexcept>
#include <cstdlib>
#include <sstream>
#include "bst.h"

 using namespace std;

template <class KeyType, class ValueType>
class AVLNode : public Node<KeyType, ValueType>
{
public:
  AVLNode (KeyType k, ValueType v, AVLNode<KeyType, ValueType> *p)
    : Node<KeyType, ValueType> (k, v, p)
    { height = 0; }
  
  virtual ~AVLNode () {}
  
  int getHeight () const
    {return height; }
  
  void setHeight (int h)
    { height = h; }
  
  virtual AVLNode<KeyType, ValueType> *getParent () const
    { return (AVLNode<KeyType,ValueType>*) this->_parent; }
  
  virtual AVLNode<KeyType, ValueType> *getLeft () const
    { return (AVLNode<KeyType,ValueType>*) this->_left; }
  
  virtual AVLNode<KeyType, ValueType> *getRight () const
    { return (AVLNode<KeyType,ValueType>*) this->_right; }
  
 protected:
  int height;
  int rightHeight;
  int leftHeight;
};

/* -----------------------------------------------------
 * AVL Search Tree
 ------------------------------------------------------*/

template <class KeyType, class ValueType>
class AVLTree : public BinarySearchTree<KeyType, ValueType>
{
public:
  void insert (const std::pair<const KeyType, ValueType>& new_item){
  /* This one is yours to implement.
     It should insert the (key, value) pair to the tree, 
     making sure that it remains a valid AVL Tree.
     If the key is already in the tree, you should throw an exception. */

     KeyType key = new_item.first;
     ValueType value = new_item.second;
     AVLNode<KeyType, ValueType> *p;


     if(this->root == NULL){
      this->root = new AVLNode<KeyType, ValueType>(key, value, NULL);
      return;
     }

    else{
      
      p = static_cast<AVLNode<KeyType,ValueType>*>(this->root);
      //cout << "Insert node: " << key << " , " << value << endl;
      while(p != NULL){
        if (key < p->getKey()){
          if(p->getLeft() != NULL){
            p = p->getLeft();
          }
          else{
            AVLNode<KeyType, ValueType> * new_node = new AVLNode<KeyType, ValueType>(key,value, p);
            p->setLeft(new_node);
            updateHeight(p);
            checkBalance(new_node);
            updateHeight(p);
            break;
          }
        }
        else if ( key > p->getKey()){
         
          if(p->getRight() != NULL){
            p = p->getRight();
          
          }
          else{
            
            AVLNode<KeyType, ValueType> * new_node = new AVLNode<KeyType, ValueType>(key, value, p);
            
            p->setRight(new_node);
            updateHeight(p);
            checkBalance(new_node);
            updateHeight(p);
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
    //printHeights(static_cast<AVLNode<KeyType,ValueType>*>(this->root));
  }

  AVLNode<KeyType, ValueType>* getSuccessorAVL(AVLNode<KeyType, ValueType>* node){
    AVLNode<KeyType, ValueType>* successor = static_cast<AVLNode<KeyType,ValueType>*>(this->getSuccessor(node));
    return successor;
  }


  //set height of a node to biggest of children +1
  void updateHeight(AVLNode<KeyType, ValueType>* node){
    if(node->getLeft() == NULL && node->getRight() == NULL){
          node->setHeight(0);
        }
    else if(node->getLeft() == NULL){
      node->setHeight(node->getRight()->getHeight()+1);
    }
    else if(node->getRight() == NULL){
      node->setHeight(node->getLeft()->getHeight()+1);
    }
    else{
      if(node->getLeft()->getHeight() > node->getRight()->getHeight()){
        node->setHeight(node->getLeft()->getHeight()+1);
      }
      else if(node->getLeft()->getHeight() < node->getRight()->getHeight()){
        node->setHeight(node->getRight()->getHeight()+1);
      }
      else if (node->getLeft()->getHeight() == node->getRight()->getHeight()){
        node->setHeight(node->getLeft()->getHeight());
      }
    }
    if(node->getParent()!=NULL)
      updateHeight(node->getParent());
  }

  bool hasChildren(AVLNode<KeyType, ValueType>* node){
   
    if(node->getLeft() != NULL || node->getRight() != NULL){
      return true;
    }
    else
      return false;
  }


  void remove (const KeyType &toRemove){
 /* Implement this as well.  It should remove the (key, value) pair from
   * the tree which corresponds to the input parameter.
   * If the key is not in the tree, you should throw an exception.
   */
   //cout << "REMOVE " << toRemove << endl;
   if(this->internalFind(toRemove) == NULL){
          string errorMessage = "Element ";
          stringstream ss;
          ss << toRemove;
          string number;
          ss >> number;
          errorMessage += number;
          errorMessage += " doesn't exist.";
          throw logic_error(errorMessage);
          return;
   }

    AVLNode<KeyType, ValueType>* a = static_cast<AVLNode<KeyType,ValueType>*>(this->internalFind(toRemove));

    //if no children
    if(a->getRight() == NULL && a->getLeft() == NULL){


      AVLNode<KeyType, ValueType>* parent = a->getParent();

      //if has no parent
      if(parent == NULL){
        delete a;
        this->root = NULL;
      }
      else if(a == parent->getLeft()){
        parent->setLeft(NULL);
        delete a; 
      }
      else if (a == parent->getRight()){
        parent->setRight(NULL);
        delete a;
      }
    }

    //if has one right child
    else if((a->getRight() != NULL && a->getLeft() == NULL)){

      AVLNode<KeyType, ValueType>* parent = a->getParent();
      //if has no parent
      if(parent==NULL){
        a->getRight()->setParent(parent);
        this->root = a->getRight();
        delete a;
      }
      //if is a left child
      else if(a == parent->getLeft()){
        parent->setLeft(a->getRight());
        a->getRight()->setParent(parent);
        delete a; 
        updateHeight(parent->getLeft());
        checkBalance(parent->getLeft());
      }
      //if is a right child
      else if (a == parent->getRight()){
        parent->setRight(a->getRight());
        a->getRight()->setParent(parent);
        delete a;
        updateHeight(parent->getRight());
        checkBalance(parent->getRight());
      }
    }

    //if has one left child
    else if((a->getRight() == NULL && a->getLeft() != NULL)){
     
      AVLNode<KeyType, ValueType>* parent = a->getParent();
      //if has no parent
      if(parent==NULL){
        a->getLeft()->setParent(parent);
        this->root = a->getLeft();
        delete a;
      }
      //if is a left child
      else if(a == parent->getLeft()){
        parent->setLeft(a->getLeft());
        a->getLeft()->setParent(parent);
        delete a; 
        updateHeight(parent->getLeft());
        checkBalance(parent->getLeft());
      }
      //if is a right child
      else if (a == parent->getRight()){
        parent->setRight(a->getLeft()); 
        a->getLeft()->setParent(parent); 
        delete a; 
        updateHeight(parent->getRight()); 
        checkBalance(parent->getRight());
      }
    }

    //if has 2 children
    else if (a->getRight() != NULL && a->getLeft() != NULL){
    
     AVLNode<KeyType, ValueType>* parent = a->getParent();
     AVLNode<KeyType, ValueType>* successor = static_cast<AVLNode<KeyType,ValueType>*>(this->getSuccessor(a));
    
     //if parent is NULL
     if(parent == NULL){
     
        this->root = successor;
     }
      //if is a left child
      else  if(a == parent->getLeft()){
        parent->setLeft(successor);
      }
      //if is a right child
      else if (a == parent->getRight()){
        parent->setRight(successor);      
      }

      successor->setLeft(a->getLeft());
      if(a->getLeft() != NULL){
        a->getLeft()->setParent(successor);
      }
      successor->getParent()->setLeft(successor->getRight());
      successor->setParent(parent);
      if(successor != a->getRight()){
        successor->setRight(a->getRight());
      }
      delete a; 
      updateHeight(successor);
      checkBalance(successor);
    }
  }

  void checkBalance(AVLNode<KeyType, ValueType>* node){
     
     if(node != NULL){
   }
      AVLNode<KeyType, ValueType>* z;
      AVLNode<KeyType, ValueType>* y;
      AVLNode<KeyType, ValueType>* parent;

    if(node == NULL){
      return;
    }

    else if(node != NULL){

      

      //both children are null = balanced
      if(node->getLeft() == NULL && node->getRight()==NULL){ 
      }

      //if left is shorter
      //check if left is null
      else if(node->getLeft() == NULL){

        //check if right is 2 or more
        if(node->getRight()->getHeight() > 0){
          z = node;
          y =  node->getRight();
          parent = z->getParent();

        //if left child of y shorter - RR
          //if left child of y is null, right child must be greater
          if(y->getLeft() == NULL){
            rr(z, y, parent);
          }

          //if right child of y shorter - RL
          //if right child of y is null, left child must be greater
          else if(y->getRight() == NULL){
            rl(z, y, parent);
          }

          //compare right and left children of y - if left child shorter rr
          else if(y->getLeft()->getHeight() < y->getRight()->getHeight()){
            rr(z,y,parent);
          }
      
          //if right child of y shorter - RL
          else if(y->getLeft()->getHeight() > y->getRight()->getHeight()){
            rl(z,y,parent);
          }
        }
      }

      //if right is shorter
      //check if right is null
      else if(node->getRight() == NULL){
      
        //check if left is 2 or more
        if(node->getLeft()->getHeight() > 0){
          z = node;
          y =  node->getLeft();
          parent = z->getParent();

          //if left child of y shorter - LR
          //if left child of y is null, right child must be greater
          if(y->getLeft() == NULL){
            lr(z,y,parent);
          }
          //if right child of y shorter - RL
          //if right child of y is null, left child must be greater
          else if(y->getRight() == NULL){
            ll(z,y,parent);
          }

          //compare right and left children of y
          //if left is shorter - LR
          else if(y->getLeft()->getHeight() < y->getRight()->getHeight()){
            lr(z,y,parent);
          }

          //if right child of y shorter - LL
          else if(y->getLeft()->getHeight() > y->getRight()->getHeight()){
            ll(z, y, parent);
          }
        }
      }

      //check if left is shorter and not null
      else if(node->getLeft()->getHeight() + 1 < node->getRight()->getHeight()){
          z = node;
          y =  node->getRight();
          parent = z->getParent();

        //if left child of y shorter - RR
          //if left child of y is null, right child must be greater
          if(y->getLeft() == NULL){
                rr(z, y, parent);
          }

          //if right child of y shorter - RL
          //if right child of y is null, left child must be greater
          else if(y->getRight() == NULL){
                rl(z, y, parent);
            }

          //compare right and left children of y - if left child shorter rr
          else if(y->getLeft()->getHeight() < y->getRight()->getHeight()){
            rr(z,y,parent);
          }
      
          //if right child of y shorter - RL
          else if(y->getLeft()->getHeight() > y->getRight()->getHeight()){
            rl(z,y,parent);
          }
      }

        //if right is shorter and not null
      else if(node->getLeft()->getHeight() - 1 > node->getRight()->getHeight()){
          z = node;
          y =  node->getLeft();
          parent = z->getParent();

          //if left child of y shorter - LR
          //if left child of y is null, right child must be greater
          if(y->getLeft() == NULL){
            lr(z,y,parent);
          }
          //if right child of y shorter - RL
          //if right child of y is null, left child must be greater
          else if(y->getRight() == NULL){
            ll(z,y,parent);
          }

          //compare right and left children of y
          //if left is shorter - LR
          else if(y->getLeft()->getHeight() < y->getRight()->getHeight()){
            lr(z,y,parent);
          }

          //if right child of y shorter - LL
          else if(y->getLeft()->getHeight() > y->getRight()->getHeight()){
            ll(z, y, parent);
          }
      }
    }
    if(node->getParent() == NULL){
      this->root = node;
    }
    checkBalance(node->getParent());
  }


void rr(AVLNode<KeyType,ValueType>*z, AVLNode<KeyType,ValueType>* y, AVLNode<KeyType,ValueType>* parent){
    //cout << "RR" << endl;
    AVLNode<KeyType, ValueType>* T1;

    //if z has no parents
    if(z->getParent()==NULL){

      T1 = y->getLeft();
      z->setParent(y);
      z->setRight(T1);
      if(T1!=NULL){
        T1->setParent(z);
      }
      y->setLeft(z);
      y->setParent(parent);
      this->root = y;
    }

    //if z is left child
    else if(z == parent->getLeft()){

      T1 = y->getLeft();
      z->setParent(y);
      z->setRight(T1);
      if(T1!=NULL){
        T1->setParent(z);
      }
      y->setLeft(z);
      parent->setLeft(y);
      y->setParent(parent);
    }
    //if z is a right child
    else if (z == parent->getRight()){

      T1 = y->getLeft();
      z->setParent(y);
      z->setRight(T1);
      if(T1!=NULL){
        T1->setParent(z);
      }
      y->setLeft(z);
      parent->setRight(y);
      y->setParent(parent);
    }
    z->setHeight(z->getHeight()-2);
    updateHeight(y);
}

void rl(AVLNode<KeyType,ValueType>*z, AVLNode<KeyType,ValueType>* y, AVLNode<KeyType,ValueType>* parent){
  //cout << "RL" << endl;
  AVLNode<KeyType, ValueType>* T1;
  AVLNode<KeyType, ValueType>* T2;
  AVLNode<KeyType, ValueType>* T3;
  AVLNode<KeyType, ValueType>* x;

  //if z has no parents
  if(z->getParent() == NULL){
    x = y->getLeft();
    T1 = x->getLeft();
    T2 = x->getRight();
    T3 = y->getRight();
    z->setRight(T1);
    if(T1!=NULL){
        T1->setParent(z);
      }
    z->setParent(x);
    x->setLeft(z);
    x->setRight(y);
    y->setParent(x);
    y->setLeft(T2);
    if(T2!=NULL){
        T2->setParent(y);
      }
    y->setRight(T3);
    if(T3!=NULL){
        T3->setParent(y);
      }
    x->setParent(parent);
    this->root = x;
  }

  //if z is left child
  else if(z == parent->getLeft()){
    x = y->getLeft();
    T1 = x->getLeft();
    T2 = x->getRight();
    T3 = y->getRight();
    z->setRight(T1);
    if(T1!=NULL){
        T1->setParent(z);
      }
    z->setParent(x);
    x->setLeft(z);
    x->setRight(y);
    y->setParent(x);
    y->setLeft(T2);
    if(T2!=NULL){
        T2->setParent(y);
      }
    y->setRight(T3);
    if(T3!=NULL){
        T3->setParent(y);
      }
    parent->setLeft(x);
    x->setParent(parent);
  }
  //if z is a right child
  else if (z == parent->getRight()){
    x = y->getLeft();
    T1 = x->getLeft();
    T2 = x->getRight();
    T3 = y->getRight();
    z->setRight(T1);
    if(T1!=NULL){
        T1->setParent(z);
      }
    z->setParent(x);
    x->setLeft(z);
    x->setRight(y);
    y->setParent(x);
    y->setLeft(T2);
    if(T2!=NULL){
        T2->setParent(y);
      }
    y->setRight(T3);
    if(T3!=NULL){
        T3->setParent(y);
      }
    parent->setRight(x);
    x->setParent(parent);
  }
  x->setHeight(x->getHeight()+1);
  y->setHeight(y->getHeight()-1);
  z->setHeight(z->getHeight()-2);
  updateHeight(x);

}

void ll(AVLNode<KeyType,ValueType>*z, AVLNode<KeyType,ValueType>* y, AVLNode<KeyType,ValueType>* parent){
  //cout << "LL" << endl;
  AVLNode<KeyType, ValueType>* T2;
  AVLNode<KeyType, ValueType>* x;

  //if z has no parents
  if(z->getParent() == NULL){
    x = y->getLeft();
    T2 = y->getRight();
    z->setLeft(T2);
    if(T2!=NULL){
        T2->setParent(z);
    }
    z->setParent(y);
    y->setRight(z);
    x->setParent(y);
    y->setLeft(x);
    y->setParent(parent);
    this->root = y;
  }

  //if z is left child
  else if(z == parent->getLeft()){
    x = y->getLeft();
    T2 = y->getRight();
    z->setLeft(T2);
    if(T2!=NULL){
        T2->setParent(z);
      }
    z->setParent(y);
    y->setRight(z);
    x->setParent(y);
    y->setLeft(x);
    parent->setLeft(y);
    y->setParent(parent);
  }

  //if z is right child
  else if(z == parent->getRight()){
    x = y->getLeft();
    T2 = y->getRight();
    z->setLeft(T2);
    if(T2!=NULL){
        T2->setParent(z);
    }
    z->setParent(y);
    y->setRight(z);
    x->setParent(y);
    y->setLeft(x);
    parent->setRight(y);
    y->setParent(parent);
  }
  z->setHeight(z->getHeight()-2);
  updateHeight(y);
}

void lr(AVLNode<KeyType,ValueType>*z, AVLNode<KeyType,ValueType>* y, AVLNode<KeyType,ValueType>* parent){
  //cout << "LR" << endl;
  AVLNode<KeyType, ValueType>* T1;
  AVLNode<KeyType, ValueType>* T2;
  AVLNode<KeyType, ValueType>* T3;
  AVLNode<KeyType, ValueType>* x;

  //if z has no parent
  if(z->getParent()==NULL){
    x = y->getRight();
    T1 = x->getLeft();
    T2 = x->getRight();
    T3 = z->getRight();
    y->setRight(T1);
    if(T1!=NULL){
      T1->setParent(y);
    }
    y->setParent(x);
    x->setLeft(y);
    z->setParent(x);
    x->setRight(z);
    z->setLeft(T2);
    if(T2!=NULL){
      T2->setParent(z);
    }
    z->setRight(T3);
    if(T3!=NULL){
      T3->setParent(z);
    }
    x->setParent(parent);
    this->root = x;
  }

  //if z is left child
  else if(z == parent->getLeft()){
      x = y->getRight();
      T1 = x->getLeft();
      T2 = x->getRight();
      T3 = z->getRight();
      y->setRight(T1);
      if(T1!=NULL){
        T1->setParent(y);
      }
      y->setParent(x);
      x->setLeft(y);
      z->setParent(x);
      x->setRight(z);
      z->setLeft(T2);
      if(T2!=NULL){
        T2->setParent(z);
      }
      z->setRight(T3);
      if(T3!=NULL){
        T3->setParent(z);
      }
      parent->setLeft(x);
      x->setParent(parent);
    }

  //if z is right child
  else if(z == parent->getRight()){
      x = y->getRight();
      T1 = x->getLeft();
      T2 = x->getRight();
      T3 = z->getRight();
      y->setRight(T1);
      if(T1!=NULL){
        T1->setParent(y);
      }
      y->setParent(x);
      x->setLeft(y);
      z->setParent(x);
      x->setRight(z);
      z->setLeft(T2);
      if(T2!=NULL){
        T2->setParent(z);
      }
      z->setRight(T3);
      if(T3!=NULL){
        T3->setParent(z);
      }
      parent->setRight(x);
      x->setParent(parent);
  }
    z->setHeight(z->getHeight()-2);
    x->setHeight(x->getHeight()+1);
    y->setHeight(y->getHeight()-1);
    updateHeight(x);
}

void printHeights (AVLNode<KeyType, ValueType> *r) const
  {
    if (r != NULL)
      {
  std::cout << "[";
  printHeights (r->getLeft());
  std::cout << " (" << r->getKey() << ", " << r->getHeight() << ") ";
  printHeights(r->getRight());
  std::cout << "]";
      }
  }
};

#endif
