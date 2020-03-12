#include <stdio.h>
#include <cstdlib>
#include <iostream>
#include <time.h>
#include <unistd.h>
#include <vector>
#include <map>
#include <random>
#include <string>
#include "Vector2D.h"
#include "Robot.h"
#include "Simulator.h"
#include "MDP.h"
#define SIZEX 10
#define SIZEY 10
//Program mode
enum ProgramMode {
    VALUE_ITERATION,
    QLEARNING
};
int main(int argc, char **argv)
{
    std::random_device rd; //random device
    std::mt19937 rng; //random number generator
    int episodes = 0; //episodes
    int steps = 0;  // the steps before found the target
    int waitCounter = 200; // amount to wait between steps (milliseconds)
    int numObstacles = 20; // number of hidden obstacles
    float alpha = 0.95; // transition probabilities
    float epsilon = 0.08; //epsilon for epsilon-greedy policy
    int numEpisodes = 500000; //number of episodes to run for Q-learning
    int numEvalEpisodes = 10; //number of evaluation episodes
    double gamma = 0.95; //discount factor for value iteration and q learning
    double valItErrorThreshold = 0.01; // value iteration error threshold
    double learningRate = 0.1; //learning rate for q learning
    ProgramMode mode = VALUE_ITERATION; //Mode of the program (see ProgramMode enum above)
    int sx = -1; int sy = -1;
    if (argc==3 && (sx=std::stoi(argv[1])) && (sy=std::stoi(argv[2]))) {printf("Project environment size = [%d,%d]\n", sx, sy);}
    else {sx = SIZEX; sy = SIZEY;}
    rng = std::mt19937(rd());
    Robot *r = new Robot(1); // create robot
    Simulator sim = Simulator(sx, sy, r, alpha, 1.0); //create simulator instance
    sim.createRandomObstacles(numObstacles);
    std::uniform_int_distribution<> randRowCol(0, sx - 1);
    Point2D target = Point2D(randRowCol(rng), randRowCol(rng));
    std::vector<Point2D> obLocations = sim.getObstacleLocations();
    //Find a target position that is not the same as the robot's position and not colliding with an obstacle
    while (std::find(obLocations.begin(), obLocations.end(), target) != obLocations.end() || target == r->getPosition()) {
        target = Point2D(randRowCol(rng), randRowCol(rng));
    }
    sim.setTarget(target.getX(), target.getY());
    //Create an MDP for this project
    MDP mdp = MDP(alpha, sx, sim);
    //Run value iteration the given error threshold and discount factor
    mdp.valueIteration(valItErrorThreshold, gamma);
    if (mode == VALUE_ITERATION) {
        std::cout<<"Perform Value Iteration: "<<std::endl;
        //Proceed straight to evaluation of policy, which is computed above with value iteration
        numEpisodes = numEvalEpisodes;
    } else {
        //Otherwise, we must active perform simulations for Q-learning
        std::cout<<"Performing Q-Learning"<<std::endl;
    }
    //Distributions to select random actions
    std::vector<RobotAction> validActs {MOVE_UP, MOVE_DOWN, MOVE_LEFT, MOVE_RIGHT};
    std::uniform_real_distribution<> real01(0.0, 1.0);
    std::uniform_int_distribution<> randActDist(0, validActs.size() - 1);
    //For each episode (an episode ends when the agent finds the target)
    for (int i=0; i<numEpisodes; i++) {
        steps = 0;
        //Reset the target and agent position.
        Point2D newPosition = Point2D(randRowCol(rng), randRowCol(rng));
        while (std::find(obLocations.begin(), obLocations.end(), newPosition) != obLocations.end() || newPosition == target) {
            newPosition = Point2D(randRowCol(rng), randRowCol(rng));
        }
        sim.moveRobotToPosition(newPosition);
        sim.setTarget(target.getX(), target.getY());
        if (mode == VALUE_ITERATION) {
            sim.display();
            std::cout<<std::endl<<std::endl;
        }
        //While agent has not found the target
        while (r->getPosition() != sim.getTarget()) {
            steps++;
            RobotAction a;
            std::string action = "";
            if (mode == VALUE_ITERATION) std::cout<<"Current Location: ("<<r->getX()<<","<<r->getY()<<")"<<std::endl;
            if (mode == VALUE_ITERATION) {
                //Select optimal action according to policy computed by value iteration
                a = mdp.getOptimalVIAction(r->getPosition());
            } else {
                //Follow epsilon-greedy strategy for Q-learning
                if (real01(rng) < epsilon) {
                    a = (RobotAction)randActDist(rng);
                } else {
                    a = mdp.getOptimalQLearningAction(r->getPosition());
                }
            }
            Point2D curr = r->getPosition();
            sim.step(a);
            Point2D next = r->getPosition();
            //Perform an online q-learning update
            if (mode == QLEARNING) mdp.QLearningUpdate(a, curr, next, gamma, learningRate);
            if (mode == VALUE_ITERATION) {
                //If evaluating value iteration, display results
                std::cout<<"Selected Action: ";
                if (a == MOVE_UP) {std::cout<<"UP"<<std::endl;}
                else if (a == MOVE_DOWN) {std::cout<<"DOWN"<<std::endl;}
                else if (a == MOVE_LEFT) {std::cout<<"LEFT"<<std::endl;}
                else {std::cout<<"RIGHT"<<std::endl;}
                sim.display();
                std::cout<<std::endl<<std::endl;
            }
            if (mode == VALUE_ITERATION) {usleep(waitCounter*1000);}
            //In case the agent cannot find the target (degenerate environment)
            if (steps > 500) break;
        }
        if (episodes % 1000 == 0 && mode == QLEARNING) std::cout<<"Episodes Completed:"<<episodes<<std::endl;
        if (mode == VALUE_ITERATION) std::cout<<"Found target in: "<<steps<<" steps"<<std::endl;
        episodes++;
    }
    std::cout<<std::endl<<std::endl;
    //Print optimal policy map for value iteration
    std::cout<<"Value Iteration Policy:"<<std::endl;
    mdp.printVIPolicy();
    std::cout<<std::endl<<std::endl;
    if (mode == QLEARNING) {
        //Once we have trained Q-learner, evaluate the policy it generates in the same way as for value iteration above
        std::cout<<"Q Learning Policy:"<<std::endl;
        mdp.printQPolicy();
        std::cout<<"Testing Q Learning Policy: "<<std::endl;
        for (int i=0; i<numEvalEpisodes; i++) {
        Point2D newPosition = Point2D(randRowCol(rng), randRowCol(rng));
        while (std::find(obLocations.begin(), obLocations.end(), newPosition) != obLocations.end() || newPosition == target) {
            newPosition = Point2D(randRowCol(rng), randRowCol(rng));
        }
        sim.moveRobotToPosition(newPosition);
        sim.setTarget(target.getX(), target.getY());
        sim.display();
        std::cout<<std::endl<<std::endl;
        steps = 0;
        while (r->getPosition() != sim.getTarget()) {
            steps++;
            RobotAction a = mdp.getOptimalQLearningAction(r->getPosition());
            sim.step(a);
            std::cout<<"Selected Action: ";
            if (a == MOVE_UP) {std::cout<<"UP"<<std::endl;}
            else if (a == MOVE_DOWN) {std::cout<<"DOWN"<<std::endl;}
            else if (a == MOVE_LEFT) {std::cout<<"LEFT"<<std::endl;}
            else {std::cout<<"RIGHT"<<std::endl;}
            sim.display();
            std::cout<<std::endl;
            std::cout<<std::endl;
            if (steps > 500) break;
            usleep(waitCounter*1000);
        }
        std::cout<<"Found target in: "<<steps<<" steps"<<std::endl;
        }
    }
    std::cout<<std::endl<<std::endl;
    delete r;
}



