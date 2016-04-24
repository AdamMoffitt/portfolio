# Exam Scheduler

- **By**: Adam Moffitt
- **CSCI 104 Spring 2016**
- **April 16, 2016**

This program schedules exam time slots so that no 
student has two exams at the same time, using recursion 
and backtracking. The input file (whose name will be passed
in at the command line) will have three parameters on the
first line: how many exams there are, how many students there are,
and how many timeslots there are, separated by an arbitrary 
amount of whitespace. Each successive line will have the name
of a student (a string of lowercase letters), followed by the 
name of the classes that student is in (each one being an 
integer greater than 0). There will be an arbitrary amount
of whitespace between the student name and each class. 
I assume you always receive a correctly formatted input file.

The output is an assignment of classes to the integers
between 1 and the number of timeslots, one class per line:

If there is no solution for the requested number of timeslots, 
the program outputs No valid solution.
 
The program stores the final schedule in an AVL tree, and outputs 
the final schedule using an inorder traversal.

The Exam Scheduler file is examScheduler.cpp. Compile using
g++ -g -Wall examScheduler.cpp -o exam.

Test file included is testFile.txt
