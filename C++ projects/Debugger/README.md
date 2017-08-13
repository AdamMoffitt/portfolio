# Debugger Window Facile Program Interpreter Project

- **By**: Adam Moffitt
- **CSCI 104 Spring 2016**
- **Date**: 3-24-2016

Debugger for Facile Interpreter program

 This Debugger serves as an GUI Interpreter for a very limited version of BASIC called Facile, which supports only twelve kinds of statements. There is a generic Statement class, which serves as the base class for all twelve Facile statements (that is, there is a class for each Facile statement, and it inherits from the generic Statement class).

The bulk of the program is run in debugger_window.cpp.

In my debugger window, the current line is highlighted in Yellow. When a breakpoint is set, the text of that line is set to Red. Whenever a line has been executed, the text becomes Green. This allows the user to clearly see where the program currently is, where it has been, and where the breakpoints are. 

To Compile and run: All files compile with command make. Executable is called Debugger. The load window asks for an input file: 3 simple test files are test3.txt, test4.txt, and test6.txt. All other test files are stored in folder titled test_input. There are 50 test files testing the different functionalities of the debugger window, with facile_test50.txt 50 being the most intense.


FACILE:

Because a Facile program should have no more than 1000 lines per the Facile program definition, an initial breakpoint is set at 1000. 

Debugger window calls my value window which can sort and display the values up to that point in the program using a custom made merge sort that uses comparator functors to sort the data based on the variable name or value, in either ascending or descending order. The main and debugger windows can both call an error window which displays the specific type of error incurred.

The program will read in a Facile program from an input stream, interpret that program, and output everything to an output stream. I pass in a file stream as input and cout as output, but the should work just as well if you pass in different streams to the interpretProgram function (such as redirecting output to a file).

A valid Facile program is a sequence of statements, one per line.

A variable in a Facile program consists of a string of upper-case letters. Each variable is capable of storing an integer value. They do not need to be declared: if a variable is referenced before a value is set, the variable should have a value of 0.

The value of a variable can be changed with a LET statement, and printed with a PRINT statement. The PRINT statement prints the value of a single variable on its own line.



Basic Statements of a Facile Program

LET *var* *int*  | Change the value of variable *var* to the integer *int*
--------------------------------------------------------------------------------------------------------
PRINT *var*      | Print the value of variable *var* to output
--------------------------------------------------------------------------------------------------------
PRINTALL         | Prints the value of all used variables to output, one per line.
--------------------------------------------------------------------------------------------------------
ADD *var* *p*    | Adds *p* to the value of the variable *var*, where *p* is an int or variable.
--------------------------------------------------------------------------------------------------------
SUB *var* *p*    | Subtracts *p* from  the value of the variable *var*, where *p* is an int or variable.
--------------------------------------------------------------------------------------------------------
MULT *var* *p*   | Multiplies the value of the variable *var* by the integer or variable *p*
--------------------------------------------------------------------------------------------------------
DIV *var* *p*    | Divides the value of the variable *var* by the integer or variable *p*
--------------------------------------------------------------------------------------------------------
GOTO *linenum*   | Jumps execution of the program to the line numbered *linenum*
--------------------------------------------------------------------------------------------------------
IF *var* *op*    | Compares the value of the variable *var* to the integer *int*
*int* THEN       | via the operator *op* (<, <=, >, >=, =, <>), and jumps
*linenum*        | execution of the program to line *linenum* if true.
--------------------------------------------------------------------------------------------------------
GOSUB *linenum*  | Temporarily jumps to line *linenum*, and jumps back after a RETURN
--------------------------------------------------------------------------------------------------------
RETURN           | Jumps execution of the program back to the most recently executed GOSUB.
--------------------------------------------------------------------------------------------------------
END              | Immediately terminates the program.
--------------------------------------------------------------------------------------------------------
.                | Placed at the end of the program, and behaves like an END statement.


