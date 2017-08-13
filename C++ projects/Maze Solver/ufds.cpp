#include "ufds.h"

const int NO_PARENT = -1;
// since each parent would be [0, numElements-1] otherwise.
// Keeping this constant is really an error state, something
// the UnionFind constructor will fix.

Element::Element()
:parent(NO_PARENT), count(1)
{}


UnionFind::~UnionFind()
{
	delete [] _elements;
}

UnionFind::UnionFind(int numElements)
: _numElements(numElements)
{
	_elements = new Element[_numElements];
	for(int i=0; i < _numElements; i++)
	{
		_elements[i].parent = i;
	}
}

int UnionFind::find(int elem) const
{
	if ( _elements[elem].parent != elem )
		_elements[elem].parent = find( _elements[elem].parent );
	return _elements[elem].parent;
}

void UnionFind::merge(int one, int two)
{
	int x = find(one);
	int y = find(two);
	if( _elements[x].count > _elements[y].count )
	{
		_elements[y].parent = x;
		_elements[y].count += _elements[x].count;
	}
	else
	{
		_elements[x].parent = y;
		_elements[x].count += _elements[y].count;
	}
}
	
bool UnionFind::same(int one, int two) const
{
	return find(one) == find(two);
}
