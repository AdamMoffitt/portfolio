#include <iostream>
#include "heap.h"
using namespace std;

int main(){
	MinHeap<int> minHeap(9);
	int myInt = 0;

	for (int i = 0; i < 100; i++){
		myInt = i;
		minHeap.add(myInt, i);
	}

	while(!minHeap.isEmpty()){
		cout << minHeap.peek() << endl;
		minHeap.remove();
		
	}
	
	return 0;
}