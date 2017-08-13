#ifndef __UNION_FIND_DATA_STRUCTURE
#define __UNION_FIND_DATA_STRUCTURE

#include<vector>

class Element
{
public:
	Element();
	int parent, count;
};

class UnionFind
{
public:
	explicit UnionFind(int numElements);
	~UnionFind();
	
	bool same(int one, int two) const;
	void merge(int one, int two); 
	
private:
	int find(int elem) const;

	int _numElements;
	volatile Element * _elements;
};


#endif

