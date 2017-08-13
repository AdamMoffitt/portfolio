#include "llistint.h"
#include "gtest/gtest.h"

class LListTest : public testing::Test {
protected:
	// You can remove any or all of the following functions if its body is empty.

	LListTest() {
		// You can do set-up work for each test here.
		LListInt list;
		list.insert(0,1);
		list.insert(1,2);
		list.insert(2,3);
		list.insert(3,4);
	}

	virtual ~LListTest() {
		// You can do clean-up work that doesn't throw exceptions here.		
	}

	// If the constructor and destructor are not enough for setting up
	// and cleaning up each test, you can define the following methods:
	virtual void SetUp() {
		// Code here will be called immediately after the constructor (right
		// before each test).
	}

	virtual void TearDown() {
		// Code here will be called immediately after each test (right
		// before the destructor).
	}

	// Objects declared here can be used by all tests in the test case.
	LListInt list;
};

//Check concotenation operator overload and copy constructor
TEST(LListTest, Concotenation)
{
	LListInt list1;
	LListInt list2;
	LListInt list3;

	for(int i=0;i<10;i++){
		list1.insert(0,i);
	}
	for(int i =0; i < 5; i++){
		list2.insert(0, i*5);
	}

	list3 = (list1 + list2);

	EXPECT_EQ(list3.size(), (list1.size()+list2.size()));
	EXPECT_EQ(list3.get(14), 0);
}

//check Assignment operator and copy constructor
TEST(LListTest, Assignment)
{
	LListInt listA;
	LListInt listB;

	for(int i=0;i<10;i++){
		listA.insert(0,i+2);
	}
	for(int i =0; i < 5; i++){
		listB.insert(0, i*5);
	}

	listA = listB;

	for(int i = 0; i < listB.size(); i++){
		EXPECT_EQ(listA.get(i), listB.get(i));
	}
}


//Check access operator
TEST(LListTest, Access) {
	LListInt list;
	list.insert(0,1);
	list.insert(1,2);
	list.insert(2,3);
	list.insert(3,4);
	for(int i=0;i<4;i++){
		EXPECT_EQ(list[i], i+1);
	}
}