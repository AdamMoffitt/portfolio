#include "MDP.h"
/**
 * @brief constructor
 * @param alpha transition probability parameter
 * @param dim dimension of grid
 * @param sim simulator pointer
 */
MDP::MDP(double a, int dim, Simulator &sim) {
    this->alpha = a;
    this->N = dim*dim;
    this->simulator = sim;
    this->gridDimension = dim;
    std::vector<Point2D> locs = simulator.getObstacleLocations();
    actions.push_back(MOVE_UP);
    actions.push_back(MOVE_DOWN);
    actions.push_back(MOVE_LEFT);
    actions.push_back(MOVE_RIGHT);
    //Initialize Q-values
    for (int i=0; i<gridDimension; i++) {
        for (int j=0; j<gridDimension; j++) {
            for (auto a: actions) {
                if (std::find(locs.begin(), locs.end(), Point2D(i, j)) != locs.end()) {
                    Q[Point2D(i, j)][a] = -10.0;
                } else if (Point2D(i, j) == simulator.getTarget()) {
                    Q[Point2D(i, j)][a] = 100.0;
                } else {
                    Q[Point2D(i, j)][a] = 0.0;
                }
                
            }
        }
    }
}
/**
 * @brief get reward for transition
 * @param a action
 * @param current currrent state
 * @param next next state
 */
double MDP::getRewardForTransition(RobotAction a, Point2D current, Point2D next) {
    if (next == simulator.getTarget()) return 100;
    else if (next == current) return -10;
    else return -0.04;
    
}
/**
 * @brief get probability of transition
 * @param a robot action
 * @param current current state
 * @param next next state
 * @return probability of transitioning from current astate to next state under action a
 */
double MDP::getProbabilityOfTransition(RobotAction a, Point2D current, Point2D next) {
    if (fabs(current.getX() - next.getX()) > 1 || fabs(current.getY() - next.getY()) > 1 ||
        (fabs(current.getX() - next.getX()) == 1 && fabs(current.getY() - next.getY()) == 1)) {
        return 0.0;
    } else {
        std::vector<Point2D> walls = simulator.getObstacleLocations(current);
        //Order: up, down, left, right
        std::vector<bool> blockedDirections(4, false);
        for (auto w: walls) {
            if (w.getX() == current.getX() - 1 && w.getY() == current.getY()) {
                blockedDirections[0] = true;
            } else if (w.getX() == current.getX() + 1 && w.getY() == current.getY()) {
                blockedDirections[1] = true;
            } else if (w.getX() == current.getX() && w.getY() == current.getY() - 1) {
                blockedDirections[2] = true;
            } else if (w.getX() == current.getX() && w.getY() == current.getY() + 1) {
                blockedDirections[3] = true;
            }
        }
        if (current.getX() == 0) blockedDirections[0] = true;
        if (current.getX() == simulator.getHeight() - 1) blockedDirections[1] = true;
        if (current.getY() == 0) blockedDirections[2] = true;
        if (current.getY() == simulator.getWidth() - 1) blockedDirections[3] = true;
        double tOtherProb = (1.0 - alpha)/3.0;
        int numBlocked = 0;
        for (auto b: blockedDirections) {if (b) numBlocked++;}
        if (a == MOVE_UP) {
            //Intended direction is not blocked
            if (!blockedDirections[0]) {
                if (current.getX() - 1 == next.getX()) {
                    return alpha;
                } else if (current == next){
                    return fmax(0.0, (numBlocked)*tOtherProb);
                } else if (current.getX() + 1 == next.getX() && !blockedDirections[1]) {
                    return tOtherProb;
                } else if (current.getY() - 1 == next.getY() && !blockedDirections[2]) {
                    return tOtherProb;
                } else if (current.getY() + 1 ==  next.getY() && !blockedDirections[3]) {
                    return tOtherProb;
                }
                //Intended direction blocked
            } else {
                if (current == next) {
                    return alpha + (numBlocked - 1)*tOtherProb;
                } else if (current.getX() + 1 == next.getX() && !blockedDirections[1]) {
                    return tOtherProb;
                } else if (current.getY() - 1 == next.getY() && !blockedDirections[2]) {
                    return tOtherProb;
                } else if (current.getY() + 1 ==  next.getY() && !blockedDirections[3]) {
                    return tOtherProb;
                }
            }
        } else if (a == MOVE_DOWN) {
            //Intended direction is not blocked
            if (!blockedDirections[1]) {
                if (current.getX() + 1 == next.getX()) {
                    return alpha;
                } else if (current == next){
                    return fmax(0.0, (numBlocked)*tOtherProb);
                } else if (current.getX() - 1 == next.getX() && !blockedDirections[0]) {
                    return tOtherProb;
                } else if (current.getY() - 1 == next.getY() && !blockedDirections[2]) {
                    return tOtherProb;
                } else if (current.getY() + 1 ==  next.getY() && !blockedDirections[3]) {
                    return tOtherProb;
                }
                //Intended direction blocked
            } else {
                if (current == next) {
                    return alpha + (numBlocked - 1)*tOtherProb;
                } else if (current.getX() - 1 == next.getX() && !blockedDirections[0]) {
                    return tOtherProb;
                } else if (current.getY() - 1 == next.getY() && !blockedDirections[2]) {
                    return tOtherProb;
                } else if (current.getY() + 1 ==  next.getY() && !blockedDirections[3]) {
                    return tOtherProb;
                }
            }
        } else if (a == MOVE_LEFT) {
            //Intended direction is not blocked
            if (!blockedDirections[2]) {
                if (current.getY() - 1 == next.getY()) {
                    return alpha;
                } else if (current == next){
                    return fmax(0.0, (numBlocked)*tOtherProb);
                } else if (current.getX() + 1 == next.getX() && !blockedDirections[1]) {
                    return tOtherProb;
                } else if (current.getX() - 1 == next.getX() && !blockedDirections[0]) {
                    return tOtherProb;
                } else if (current.getY() + 1 ==  next.getY() && !blockedDirections[3]) {
                    return tOtherProb;
                }
                //Intended direction blocked
            } else {
                if (current == next) {
                    return alpha + (numBlocked - 1)*tOtherProb;
                } else if (current.getX() + 1 == next.getX() && !blockedDirections[1]) {
                    return tOtherProb;
                } else if (current.getX() - 1 == next.getX() && !blockedDirections[0]) {
                    return tOtherProb;
                } else if (current.getY() + 1 ==  next.getY() && !blockedDirections[3]) {
                    return tOtherProb;
                }
            }
        } else {
            //Intended direction is not blocked
            if (!blockedDirections[3]) {
                if (current.getY() + 1 == next.getY()) {
                    return alpha;
                } else if (current == next) {
                    return fmax(0.0, (numBlocked)*tOtherProb);
                } else if (current.getX() + 1 == next.getX() && !blockedDirections[1]) {
                    return tOtherProb;
                } else if (current.getX() - 1 == next.getX() && !blockedDirections[0]) {
                    return tOtherProb;
                } else if (current.getY() - 1 ==  next.getY() && !blockedDirections[2]) {
                    return tOtherProb;
                }
                //Intended direction blocked
            } else {
                if (current == next) {
                    return alpha + (numBlocked - 1)*tOtherProb;
                } else if (current.getX() + 1 == next.getX() && !blockedDirections[1]) {
                    return tOtherProb;
                } else if (current.getX() - 1 == next.getX() && !blockedDirections[0]) {
                    return tOtherProb;
                } else if (current.getY() - 1 ==  next.getY() && !blockedDirections[2]) {
                    return tOtherProb;
                }
            }
        }
    }
    return 0.0;
}
/**
 * @brief get transition probability distribution
 * @param a action
 * @param curr current state
 * @return distribution (calculuated) over next state P(N| curr, a)
 */
std::vector<double> MDP::getTransitionDistribution(RobotAction a, Point2D curr) {
    std::vector<double> dist(this->N);
    for (int i=0; i<this->N; i++) {
        int r = i/simulator.getWidth();
        int c = i%simulator.getWidth();
        dist[i] = getProbabilityOfTransition(a, curr, Point2D(r, c));
    }
    return dist;
}
/**
 * @brief value iteration
 * @param valItThreshold error threshold
 * @param discountFactor discount factor
 */
void MDP::valueIteration(double valItThreshold, double gamma) {

    std::map<Point2D, double> previous;
    std::vector<Point2D> states;
    for (int i=0; i<this->gridDimension; i++) {
        for (int j=0; j<this->gridDimension; j++) {
            states.push_back(Point2D(i, j));
            previous[Point2D(i, j)] = 1;
            // compute Vk[s] = max (for each action) of 
                        // sum of for each state (getProbability of Transition * (getRewardForTransition() + gamma * Vk-1[s]

        }
    }

    bool done = false;
    std::map<Point2D, double> current;
    int iterations = 0;
    while (!done) {
        for (int i=0; i<this->gridDimension; i++) {
            for (int j=0; j<this->gridDimension; j++) { 
                double actionValues[4];
                for (auto action: actions) {
                    int sum = 0;
                    for (int a=0; a<this->gridDimension; a++) {
                        for (int b=0; b<this->gridDimension; b++) { 
                            Point2D currentState = Point2D(i, j);
                            Point2D nextState = Point2D(a,b);
                            double prob = getProbabilityOfTransition(action, currentState, nextState);
                            double reward = getRewardForTransition(action, currentState, nextState);
                            double gammaThing = gamma * previous[nextState];
                            double total = prob * (reward + gammaThing);
                            sum += total;
                        }
                    }
                    actionValues[action] = sum;
                }
                current[Point2D(i, j)] = *std::max_element(actionValues,actionValues+4);
            }
        }        
        done = checkBelowThreshold(previous, current, valItThreshold);
        previous = current;
        iterations++;
    }

    double actionValues[4];
    for (int i=0; i<this->gridDimension; i++) {
            for (int j=0; j<this->gridDimension; j++) {
                for (auto action: actions) {
                    int sum = 0;
                    for (int a=0; a<this->gridDimension; a++) {
                        for (int b=0; b<this->gridDimension; b++) { 
                            Point2D currentState = Point2D(i, j);
                            Point2D nextState = Point2D(a,b);
                            double prob = getProbabilityOfTransition(action, currentState, nextState);
                            double reward = getRewardForTransition(action, currentState, nextState);
                            double gammaThing = gamma * current[nextState];
                            double total = prob * (reward + gammaThing);
                            sum += total;
                        }
                    }
                    actionValues[action] = sum;
                }
                
                int doAction = std::distance(actionValues, std::max_element(actionValues,actionValues+4));
                policy[Point2D(i, j)] = RobotAction(doAction);
            }
        }
}

bool MDP::checkBelowThreshold(std::map<Point2D, double> previous, std::map<Point2D, double> current, double threshold) {
    for (int i=0; i<this->gridDimension; i++) {
            for (int j=0; j<this->gridDimension; j++) { 
                Point2D currentPoint = Point2D(i, j);
                if (std::abs(current[currentPoint] - previous[currentPoint]) > threshold) {
                    return false;
                }
            }
        }
        return true;
}

/**
 * @bvrief perform q learning update
 * @param a action
 * @param current current state
 * @param next next state
 * @param gamma disccount factor
 * @param learningRate learning rate
 */
void MDP::QLearningUpdate(RobotAction a, Point2D current, Point2D next, double gamma, double learningRate) {
    ///TODO: Compute Q-learning update
    double reward = getRewardForTransition(a, current, next);
    double options[4];
    options[0] = Q[next][RobotAction(0)];
    options[1] = Q[next][RobotAction(1)];
    options[2] = Q[next][RobotAction(2)];
    options[3] = Q[next][RobotAction(3)];
    double max =(*std::max_element(options, options+4));
    double gammaThing = gamma * max;
    Q[current][a] = ((1-learningRate) * Q[current][a]) + (learningRate * (reward + gammaThing));
}
/**
 * @brief print value iteration policy
 */
void MDP::printVIPolicy() {
    std::vector<Point2D> locs = simulator.getObstacleLocations();
    for (int x=0; x<this->gridDimension; x++) {
        for (int y=0; y<this->gridDimension; y++) {
            if (std::find(locs.begin(), locs.end(), Point2D(x, y)) != locs.end()) {
                printf("# ");
                continue;
            } else if (Point2D(x, y) == simulator.getTarget()) {
                printf("$ ");
                continue;
            }
            if (policy[Point2D(x, y)] == MOVE_UP) {
                printf("↑ ");
            } else if (policy[Point2D(x, y)] == MOVE_DOWN) {
                printf("↓ ");
            } else if (policy[Point2D(x, y)] == MOVE_LEFT) {
                printf("← ");
            } else {
                printf("→ ");
            }
        }
        printf("\n");
    }
}
/**
 * @brief print q learning policy
 */
void MDP::printQPolicy() {
    std::vector<Point2D> locs = simulator.getObstacleLocations();
    for (int x=0; x<this->gridDimension; x++) {
        for (int y=0; y<this->gridDimension; y++) {
            RobotAction maxAction = getOptimalQLearningAction(Point2D(x, y));
            if (std::find(locs.begin(), locs.end(), Point2D(x, y)) != locs.end()) {
                printf("# ");
                continue;
            } else if (Point2D(x, y) == simulator.getTarget()) {
                printf("$ ");
                continue;
            }
            if (maxAction == MOVE_UP) {
                printf("↑ ");
            } else if (maxAction == MOVE_DOWN) {
                printf("↓ ");
            } else if (maxAction == MOVE_LEFT) {
                printf("← ");
            } else {
                printf("→ ");
            }
        }
        printf("\n");
    }
}
/**
 * @brief get optimal value iteration action
 * @param state state
 * @return optimal value iteration action
 */
RobotAction MDP::getOptimalVIAction(Point2D state) {
    return policy[state];
}
/**
 * @brief get optimal q learning action
 * @param state state
 * @return optimal q learning action
 */
RobotAction MDP::getOptimalQLearningAction(Point2D state) {
    ///TODO: Replace with optimal action from Q learning policy
     double options[4];
    options[0] = Q[state][RobotAction(0)];
    options[1] = Q[state][RobotAction(1)];
    options[2] = Q[state][RobotAction(2)];
    options[3] = Q[state][RobotAction(3)];
    // std::cout << "max: " << *std::max_element(options, options+4) << std::endl;
    int doAction = std::distance(options, std::max_element(options, options+4));

    return RobotAction(doAction);
}
