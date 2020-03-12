cmake_minimum_required(VERSION 3.6)
project(Project3Student)

set(CMAKE_CXX_STANDARD 11)

set(SOURCE_FILES
        main.cpp
        MDP.h
        MDP.cpp
	Simulator.cpp
        Robot.h
        Simulator.h
        Vector2D.h)

add_executable(Simulator360 ${SOURCE_FILES})
