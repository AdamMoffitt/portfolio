#-------------------------------------------------
#
# Project created by QtCreator 2016-03-09T20:34:00
#
#-------------------------------------------------

QT       += core gui
QMAKE_CXXFLAGS += -std=c++11 -g

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = Maze
TEMPLATE = app

CONFIG += c++11

SOURCES += main.cpp\
        mazedisplay.cpp \
    kruskalishmaze.cpp \
    maze.cpp \
    ufds.cpp \
    mazesolver.cpp \
    visitedtracker.cpp

HEADERS  += mazedisplay.h \
    kruskalishmaze.h \
    maze.h \
    ufds.h \
    mazesolver.h \
    visitedtracker.h

FORMS    += mazedisplay.ui
