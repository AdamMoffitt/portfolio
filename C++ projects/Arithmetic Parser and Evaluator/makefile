BIN_DIR = bin
CXX = g++
CPPFLAGS = -g -Wall
GTEST_LL = -I /usr/local/opt/gtest/include/ -l gtest -l gtest_main -pthread


all: $(BIN_DIR)/.dirstamp llisttest stacktest problem5

llisttest: llisttest.cpp $(BIN_DIR)/llistint.o  
	$(CXX) $(CPPFLAGS) $^ $(GTEST_LL) -o $@

stacktest: stackintmain.cpp $(BIN_DIR)/stackint.o 
	$(CXX) $(CPPFLAGS) stackintmain.cpp $(BIN_DIR)/stackint.o $(BIN_DIR)/llistint.o -o $(BIN_DIR)/stacktest

problem5: problem5.cpp $(BIN_DIR)/stackint.o 
	$(CXX) $(CPPFLAGS) problem5.cpp $(BIN_DIR)/stackint.o $(BIN_DIR)/llistint.o -o $(BIN_DIR)/prob5
	
$(BIN_DIR)/stackint.o: stackint.cpp $(BIN_DIR)/llistint.o 
	$(CXX) $(CPPFLAGS) -c stackint.cpp $(BIN_DIR)/llistint.o -o $(BIN_DIR)/stackint.o

$(BIN_DIR)/llistint.o: llistint.cpp 
	$(CXX) $(CPPFLAGS) -c llistint.cpp -o $(BIN_DIR)/llistint.o

$(BIN_DIR)/.dirstamp: 
	mkdir -p $(BIN_DIR) 
	touch $@


.PHONY: clean

clean:
	rm -rf $(BIN_DIR)

