//TODO
#include <iostream>
#include "math.h"
#include <vector>
using namespace std;

	template <class T, class Comparator>
	void mergeSort (vector<T>& myVector, Comparator comp);

	template <class T, class Comparator>
	void SortFunc(vector<T>& myVector, int l, int r, Comparator comp);

	template <class T, class Comparator>
	void MergeFunc(vector<T>& myVector, int l, int r, int m, Comparator comp);


	template <class T, class Comparator>
	void mergeSort (vector<T>& myVector, Comparator comp){
		int l = 0;
		int r = myVector.size()-1;
		SortFunc(myVector, l, r, comp);
	}

	template <class T, class Comparator>
	void SortFunc(vector<T>& myVector, int l, int r, Comparator comp){
		if(l<r) {
			int m = floor((l+r)/2);
			SortFunc(myVector,l,m, comp);
			SortFunc(myVector,m+1,r, comp);
			MergeFunc(myVector,l,r,m, comp);
		}
	}

	template <class T, class Comparator>
	void MergeFunc(vector<T>& myVector, int l, int r, int m, Comparator comp) {
		int i = l;
		int j = m+1;
		int k=0;
		vector <T> temp = myVector;
		while (i<=m || j <= r) {
			if (i <= m && (j > r || comp(myVector[i],myVector[j]))) {
				temp[k] = myVector[i];
				i++;
				k++;
			}	
			else {
				temp[k] = myVector[j];
				j++;
				k++;
			}
		}
		for(k=0; k < r + 1 - l; k++){
			myVector[k+l] = temp[k];
		}
	}


struct ValueSortAscComp {
    bool operator()(const std::pair<std::string,int> lhs, const std::pair<std::string,int> rhs) 
    { 
    	return lhs.second < rhs.second;
    }
  };

struct ValueSortDescComp {
    bool operator()(const std::pair<std::string,int> lhs, const std::pair<std::string,int> rhs) 
    { 
    	return rhs.second < lhs.second;
    }
  };

  struct NameSortAscComp {
    bool operator()(const std::pair<std::string,int> lhs, const std::pair<std::string,int> rhs) 
    {  
    	return lhs.first < rhs.first;
    }
  };

  struct NameSortDescComp {
    bool operator()(const std::pair<std::string,int> lhs, const std::pair<std::string,int> rhs) 
    { 
    	return rhs.first < lhs.first;
    }
  };