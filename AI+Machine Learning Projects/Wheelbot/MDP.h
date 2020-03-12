#ifndef MDP_hpp
#define MDP_hpp

#include <stdio.h>
#include <map>
#include "Vector2D.h"
#include "Simulator.h"
#include "Robot.h"
#include <vector>
#include <float.h>
class MDP {
private:
    Simulator simulator; //copy of the simulator
    double alpha; //transition probability parameter
    int gridDimension; //dimension of grid
    int N; //number of grid cells
    std::vector<RobotAction> actions; //actions the robot can take
    std::map<Point2D, RobotAction> policy; //policy for value iteration
    std::map<Point2D, std::map<RobotAction, double>> Q; //q value function
public:
    /**
     * @brief constructor
     * @param alpha transition probability parameter
     * @param dim dimension of grid
     * @param sim simulator pointer
     */
    MDP(double a, int dim, Simulator &sim);
    /**
     * @brief set simulator pointer
     * @param sim simulator
     */
    void setSimulator(Simulator& sim) {this->simulator = sim;}
    /**
     * @brief get simulator pointer
     * @return simulator instance
     */
    Simulator& getSimulator() {return this->simulator;}
    /**
     * @brief set value of alpha
     * @param a alpha
     */
    void setAlpha(double a) {this->alpha = a;}
    /**
     * @brief get alpha value
     * @return alpha value
     */
    double getAlpha() {return this->alpha;}
    /**
     * @brief set dimension of grid
     * @param dim dimension of grid
     */
    void setN(int dim) {this->N = dim;}
    /**
     * @brief get environment dimension
     * @return environment dimension
     */
    int getN() {return this->N;}
    /**
     * @brief get policy
     * @return policy computed by value iteration
     */
    std::map<Point2D, RobotAction> getPolicy() {return this->policy;}
    /**
     * @brief get q function
     * @return q function
     */
    std::map<Point2D, std::map<RobotAction, double>> getQFunction() {return this->Q;}
    /**
     * @bvrief perform q learning update
     * @param a action
     * @param current current state
     * @param next next state
     * @param gamma disccount factor
     * @param learningRate learning rate
     */
    void QLearningUpdate(RobotAction a, Point2D current, Point2D next, double gamma, double learningRate);
    /**
     * @brief get reward for transition
     * @param a action
     * @param current currrent state
     * @param next next state
     */
    double getRewardForTransition(RobotAction a, Point2D current, Point2D next);
    /**
     * @brief get probability of transition
     * @param a robot action
     * @param current current state
     * @param next next state
     * @return probability of transitioning from current astate to next state under action a
     */
    double getProbabilityOfTransition(RobotAction a, Point2D current, Point2D next);
    /**
     * @brief get transition probability distribution
     * @param a action
     * @param curr current state
     * @return distribution (calculuated) over next state P(N| curr, a)
     */
    std::vector<double> getTransitionDistribution(RobotAction a, Point2D curr);
    /**
     * @brief value iteration
     * @param valItThreshold error threshold
     * @param discountFactor discount factor
     */
    void valueIteration(double valItThreshold, double discountFactor);

    bool checkBelowThreshold(std::map<Point2D, double> previous, std::map<Point2D, double> current, double threshold);

    /**
     * @brief print value iteration policy
     */
    void printVIPolicy();
    /**
     * @brief print q learning policy
     */
    void printQPolicy();
    /**
     * @brief get optimal value iteration action
     * @param state state
     * @return optimal value iteration action
     */
    RobotAction getOptimalVIAction(Point2D state);
    /**
     * @brief get optimal q learning action
     * @param state state
     * @return optimal q learning action
     */
    RobotAction getOptimalQLearningAction(Point2D state);    
};
#endif
