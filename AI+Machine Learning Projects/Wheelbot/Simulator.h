#ifndef Simulator_h
#define Simulator_h
#include <stdio.h>
#include <math.h>
#include <vector>
#include <cstdlib>
#include <iostream>
#include <random>
#include "Robot.h"
#if defined(_WIN32) || defined(_WIN64)
#include <windows.h>
#include <stdlib.h>
#endif
#define EMPTY       0
#define OCCUPIED    1
#define TARGET      2
#define OBSTACLE    3
#define DEAD        4
#define MAX_X       200
#define MAX_Y       200
//#define MAKE_HIDDEN_OBSTACLES_KNOWN
/**
 * @class Simulator
 * @brief simulator object
 */
class Simulator
{
private:
    bool showHiddenObstacles;
    /**< random device */
    static std::random_device rd;
    /**< random number generator */
    static std::mt19937 rng;
    /**< target X */
    int TX;
    /**< target Y */
    int TY;
    /**< locations of obstacles */
    std::vector<Point2D> obstacleLocations;
    /**< robot to pointer */
    Robot *robot;
    /**< x size of environment (width) */
    int SX;
    /**< y size of environment (height) */
    int SY;
    /**< grid area */
    int AREA[MAX_X][MAX_Y];
    /**< transition probabilities */
    double alpha;
    /**< observation probabilities */
    double epsilon;
public:
    /**
     * @brief get the obstacle locations at a certain point
     * @return obstacle locations
     */
    std::vector<Point2D> getObstacleLocations(Point2D p) {
        Point2D p1 = Point2D(p.getX() + 1, p.getY());
        Point2D p2 = Point2D(p.getX() - 1, p.getY());
        Point2D p3 = Point2D(p.getX(), p.getY() + 1);
        Point2D p4 = Point2D(p.getX(), p.getY() - 1);
        std::vector<Point2D> pointsToCheck;
        pointsToCheck.push_back(p1); pointsToCheck.push_back(p2);
        pointsToCheck.push_back(p3); pointsToCheck.push_back(p4);
        std::vector<Point2D> obs;
        for (int i=0; i<pointsToCheck.size(); i++) {
            if (pointsToCheck[i].getX() >= 0 && pointsToCheck[i].getY() >= 0 &&
                pointsToCheck[i].getX() < this->SX && pointsToCheck[i].getY() < this->SY &&
                AREA[(int)pointsToCheck[i].getX()][(int)pointsToCheck[i].getY()] == OBSTACLE) {
                    obs.push_back(Point2D(pointsToCheck[i].getX(), pointsToCheck[i].getY()));
                }
        }
        return obs;
    }
    /**
     * @brief simulator constructor
     */
    Simulator() {}
    /**
     * @brief constructor
     * @param sx size of environment (x)
     * @param sy size of environment (y)
     * @param r robot
     */
    Simulator(int sx, int sy, Robot* r, double alpha=0.7, double epsilon=0.7) {
        SX = sx>MAX_X ? MAX_X : sx;
        SY = sy>MAX_Y ? MAX_Y : sy;
        this->clean();
        this->robot = r;
        this->alpha = alpha;
        this->epsilon = epsilon;
        rng = std::mt19937(rd());
        std::uniform_int_distribution<> widthDist(0, SX - 1);
        std::uniform_int_distribution<> heightDist(0, SY - 1);
        TX = widthDist(rng);
        TY = heightDist(rng);
        int ix = widthDist(rng);
        int iy = heightDist(rng);
        this->robot->movePosition(ix, iy);
        AREA[this->robot->getX()][this->robot->getY()] = OCCUPIED;
        AREA[TX][TY] = EMPTY;
        showHiddenObstacles = true;
    }
    /**
     * @brief move robot to the given position in the grid
     * @param p position to which to move robot
     */
    void moveRobotToPosition(Point2D p) {
        AREA[this->robot->getX()][this->robot->getY()] = EMPTY;
        AREA[p.getX()][p.getY()] = OCCUPIED;
        this->robot->movePosition(p.getX(), p.getY());
    }
    /**
     * @brief get height of environment
     * @return height of environment
     */
	int getHeight() { return SX; }
    /**
     * @brief get width of environment
     * @return width of environment
     */
	int getWidth() { return SY; }
    /**
     * @brief get the locations of the obstacles
     * @return obstacle locations
     */
    std::vector<Point2D> getObstacleLocations() {return obstacleLocations;}
    /**
     * @brief create uniformly random obstacles in the environment
     * @param num number of obstacles to create
     */
    void createRandomObstacles(int num) {
        std::uniform_int_distribution<> widthDist(0, SX - 1);
        std::uniform_int_distribution<> heightDist(0, SY - 1);
        for (int i=0; i<num; i++) {
            int ox = widthDist(rng);
            int oy = heightDist(rng);
            while ((ox == TX && oy == TY) || (ox == robot->getX() && oy == robot->getY())) {
                ox = widthDist(rng);
                oy = heightDist(rng);
            }
            AREA[ox][oy] = OBSTACLE;
            obstacleLocations.push_back(Point2D(ox, oy));
        }
    }
    /**
     * @brief get wall sensor reading
     * @return sensor readings of each of the robot's four wall sensors (assumed independent)
     */
    int getCurrentNumWalls() {
        std::vector<Point2D> locs = getObstacleLocations(this->robot->getPosition());
        std::uniform_real_distribution<> real01(0, 1);
        if (real01(rng) < this->epsilon) {return locs.size();}
        else {
            std::vector<int> validNums {0, 1, 2, 3, 4};
            validNums.erase(std::find(validNums.begin(), validNums.end(), locs.size()));
            std::uniform_int_distribution<> randValidN(0, validNums.size() - 1);
            return validNums[randValidN(rng)];
        }
    }
    /**
     * @brief clear the environment
     */
    void clean() {
        for (int x=0; x<SX; x++) {
            for (int y=0; y<SY; y++) {
                AREA[x][y] = EMPTY;
            }
        }
    }
    /**
     * @brief display the environment on the terminal
     */
    void display() {
        for (int x=0; x<SX; x++) {
            for (int y=0; y<SY; y++) {
                if (AREA[x][y]==EMPTY) printf(". ");
                else if (AREA[x][y]==TARGET) printf("$ ");
                else if (AREA[x][y] == DEAD) printf("X ");
                else if (AREA[x][y] == OBSTACLE) printf("# ");
                else printf("O ");
            }
            printf("\n");
        }
    }
    /**
     * @brief get the target
     * @return target position
     */
    Point2D getTarget() {return Point2D(TX,TY);}
    /**
     * @brief set target
     * @param tx target x coordinate
     * @param ty target y coordinate
     */
    void setTarget(int tx, int ty) {
        TX = tx;
        TY = ty;
        AREA[tx][ty] = TARGET;
    }
    /**
     * @brief get distance to target
     * @return distance to target
     */
    int getTargetDistance() {
        int X1 = TX - robot->getX();
        int Y1 = TY - robot->getY();
        return sqrt(X1*X1 + Y1*Y1);
    }
    /**
     * @brief has robot found target?
     * @return true if yes, false otherwise
     */
    bool robotFoundTarget() {return (robot->getX()==TX && robot->getY()==TY);}
    /**
     * @brief get the robot
     * @return pointer to robot
     */
    Robot* getRobot() {return this->robot;}
    /**
     * @brief is the environment occupied at (x,y)
     * @param x x coordinate of position
     * @param y y coordinate of position
     * @return true if occupied, false otherwise
     */
    bool isOccupied(int x, int y) {return (AREA[x][y]==OCCUPIED);}
    /**
     * @brief is there an obstacle at (x,y)
     * @param x x coordinate of position
     * @param y y coordinate of position
     * @return true if in collision, false otherwise
     */
    bool isInCollision(int x, int y) {return AREA[x][y]==OBSTACLE;}
    /**
     * @brief take a step in the simulation
     * @param a action
     * @param transitionProb transition probability (probability of "correct" transition)
     * @return true if we can move again, false otherwise (we are dead)
     */
    bool step(RobotAction a)
    {
        int newX = this->robot->getX(); int newY = this->robot->getY();
        std::uniform_real_distribution<> real01(0.0, 1.0);
        bool randomize = false;
        float tError = 1.0 - this->alpha;
        if (real01(rng) < tError) {randomize = true;}
        if (!randomize) {
            if (a == MOVE_DOWN) newX += 1;
            else if (a == MOVE_UP) newX -= 1;
            else if (a == MOVE_LEFT) newY -= 1;
            else if (a == MOVE_RIGHT) newY += 1;
        } else {
            if (a == MOVE_DOWN) {
                std::uniform_int_distribution<> randAct(0, 2);
                int rAct = randAct(rng);
                if (rAct == 0) {
                    newX -= 1;
                } else if (rAct == 1) {
                    newY -= 1;
                } else {
                    newY += 1;
                }
            }
            else if (a == MOVE_UP) {
                std::uniform_int_distribution<> randAct(0, 2);
                int rAct = randAct(rng);
                if (rAct == 0) {
                    newX += 1;
                } else if (rAct == 1) {
                    newY -= 1;
                } else {
                    newY += 1;
                }
            }
            else if (a == MOVE_LEFT) {
                std::uniform_int_distribution<> randAct(0, 2);
                int rAct = randAct(rng);
                if (rAct == 0) {
                    newX -= 1;
                } else if (rAct == 1) {
                    newX += 1;
                } else {
                    newY += 1;
                }
            }
            else if (a == MOVE_RIGHT) {
                std::uniform_int_distribution<> randAct(0, 2);
                int rAct = randAct(rng);
                if (rAct == 0) {
                    newX -= 1;
                } else if (rAct == 1) {
                    newY -= 1;
                } else {
                    newX += 1;
                }
            }
        }
        bool didMove = true;
        if (this->isOccupied(newX, newY) || newX>=this->SX || newY>=this->SY || newX<0 || newY<0 || AREA[newX][newY] == OBSTACLE) {didMove = false;}
        if (didMove) {
            AREA[this->robot->getX()][this->robot->getY()] = EMPTY;
            this->robot->movePosition(newX, newY);
            if (!isInCollision(newX, newY)) {
                AREA[newX][newY] = OCCUPIED;
            } else {
                AREA[this->robot->getX()][this->robot->getY()] = DEAD;
                return false;
            }
        }
        return true;
    }
};
#endif
