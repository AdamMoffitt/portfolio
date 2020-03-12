#ifndef Robot_h
#define Robot_h
#include <stdio.h>
#include <vector>
#include "Vector2D.h"
class Simulator;
/**
 * @enum RobotAction
 * @brief enumeration of robot actions
 */
enum RobotAction {
    MOVE_UP = 0,
    MOVE_DOWN,
    MOVE_LEFT,
    MOVE_RIGHT,
    STOP
};
/**
 * @class Robot
 * @brief representation of robot on 2d grid
 */
class Robot
{
private:
    /**< x coordinate of robot */
    int X;
    /**< y coordinate of robot */
    int Y;
    /**< ID number */
    int ID;
public:
    /**
     * @brief constructor
     * @param IDNum id number
     */
    Robot(){}
    /**
     * @brief constructor
     * @param IDNum id number
     */
    Robot(int IDNum) {this->ID = IDNum;}
    
    /**
     * @brief constructor
     * @param IDNum id number
     * @param x x coordinate of robot position
     * @param y y coordinate of robot position
     * @param vx x component of robot vector
     * @param vy y component of  robot vector
     */
    Robot(int IDNum, int x, int y) {ID = IDNum; X = x; Y = y;}
    /**
     * @brief move robot position
     * @param x x coord of robot position
     * @param y y coord of robot position
     */
    void movePosition(int x, int y) {this->X = x;this->Y = y;}
    /**
     * @brief set robot id 
     * @param IDNum id number of robot
     */
    void setID(int IDNum) {this->ID = IDNum;}
    /**
     * @brief get robot id
     * @return id of robot
     */
    int getID() {return this->ID;}
    /**
     * @brief set x coordinate
     * @param x x coordinate
     */
    void setX(int x) {this->X = x;}
    /**
     * @brief get x coordinate
     * @return x coordinate
     */
    int getX() {return this->X;}
    /**
     * @brief set y coordinate
     * @param y y coordinate
     */
    void setY(int y) {this->Y = y;}
    /**
     * @brief get y coordinate
     * @return y coordinate
     */
    int getY() {return this->Y;}
    /**
     * @brief get robot position
     * @return robot position
     */
    Point2D getPosition() {return Point2D(this->X,this->Y);}
};
#endif
