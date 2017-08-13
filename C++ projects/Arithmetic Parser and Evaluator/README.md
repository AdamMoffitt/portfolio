# Arithmetic Parser

- **By**: Adam Moffitt
- **CSCI 104 Spring 2016**
- **DUE**: 2-16-2016

Included are: Custom built doubly Linked List data structure. Files are llistint.h and llistint.cpp. llisttest.cpp is the google test. Llisttest is a rule in my Makefile to compile all the needed code and my test program. You can compile my program by simply typing make. Run test with ./llisttest.cpp

Included: Custom build Stack data structure. Files are stackint.h stackint.cpp. Makefile has a rule stacktest that compiles the three stack files together (stackint.cpp, stackint.h, and stackintmain.cpp). stackint.cpp can be compiled alone however, as it #includes stackint.h. Compile with make, executable file is stored in bin. In bin, use ./stacktest to run.

Included: Arithmetic Parser File is problem5.txt. Can be compiled with all its dependencies by typing make problem5, as it is included in my makefile under rule problem5. Executable is stored in bin and must be run with an input file in the command line. In the bin, type ./prob5 problem5Test1.txt or ./prob5 problem5Test2.txt to run either of both test input files.
