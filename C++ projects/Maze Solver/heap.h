//This program is a custom built templated d-ary MinHeap class. Includes
//add, peek, remove, bubbleUp and bubbleDown functions. Allows user input
//of d, where for a d-ary MinHeap, each node will have d children. 

#include <iostream>
#include <vector>
#include <exception>
#include <stdexcept>

using namespace std;

template <typename T>
  class MinHeap {
     public:
       MinHeap (int d);
       /* Constructor that builds a d-ary Min Heap
          This should work for any d >= 2,
          but doesn't have to do anything for smaller d.*/

       ~MinHeap ();

       void add (T item, int priority);
         /* adds the item to the heap, with the given priority. */

       const T & peek () const;
         /* returns the element with smallest priority. */

       void remove ();
         /* removes the element with smallest priority. */

       bool isEmpty ();
         /* returns true iff there are no elements on the heap. */

   private:
      // whatever you need to naturally store things.
      // You may also add helper functions here.
      vector< pair <int, T> > myVector;
      void bubbleUp(int child);
      void bubbleDown(int parent);
      int treeDegree;
  };

//The left child of node in index i is: 2*i+1
//The right child of node in index i is: 2*i+2
//The parent of the node in index i is: (int)((i-1)/2)
//The root of the tree is in index 0, its left child is in index 1 and its right child is in index 2 and so on.

template <typename T>
MinHeap<T>::MinHeap (int d){
  treeDegree = d;
  if(d < 2){
    cout << "Invalid tree" << endl;
    return;
  }
}
       /* Constructor that builds a d-ary Min Heap
          This should work for any d >= 2,
          but doesn't have to do anything for smaller d.*/

template <typename T>
MinHeap<T>::~MinHeap (){

}

template <typename T>
void MinHeap<T>::add (T item, int priority){
  myVector.push_back(std::make_pair(priority, item));
  bubbleUp(myVector.size()-1);
}
/* adds the item to the heap, with the given priority. */

template <typename T>
const T & MinHeap<T>::peek () const{
  return myVector[0].second;

}
/* returns the element with smallest priority. */

template <typename T>
void MinHeap<T>::remove (){
 if(myVector.empty()){
  throw exception(logic_error("Invalid: Remove from empty min heap"));
 }
  myVector[0] = myVector[myVector.size()-1];
  myVector.erase(myVector.end());
  bubbleDown(0);

}
/* removes the element with smallest priority. */

template <typename T>
bool MinHeap<T>::isEmpty (){
  return (myVector.empty());
}
/* returns true iff there are no elements on the heap. */

template <typename T>
void MinHeap<T>::bubbleUp(int child){
    int parent = (int)((child-1)/treeDegree);
    if(child == 0)
      return;
    if(child > 0 && myVector[child].first < myVector[parent].first){
      pair<int, T> temp = myVector[parent];
      myVector[parent] = myVector[child];
      myVector[child] = temp;
    }
    bubbleUp(parent);
}

template <typename T>
void MinHeap<T>::bubbleDown(int parent){
  int child = treeDegree*parent+1;


  if (child >= myVector.size()){
    return; //is a leaf
  }

    for (int j = 0; j <= treeDegree; j++){

      //Check children nodes and put smallest node as first child
      for(int k = 1; k <= treeDegree; k++){
          if(child < myVector.size() && child+k<myVector.size() && myVector[child+k].first < myVector[child].first){
            pair<int, T> temp = myVector[child];
            myVector[child] = myVector[child+k];
            myVector[child+k] = temp;
          }
      }

        //swap child with parent if smaller than parent
        if(myVector[(child)].first < myVector[parent].first){
          pair<int, T> temp = myVector[parent];
          myVector[parent] = myVector[(child)];
          myVector[(child)] = temp;
        }

        if(child+j < myVector.size()){
          bubbleDown(child+j);
        }
    }
}