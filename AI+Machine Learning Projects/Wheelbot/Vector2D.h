#ifndef Vector2D_h
#define Vector2D_h
/**
 * @class Point2D
 * @brief 2d point
 */
class Point2D
{
private:
    /**< x component */
    float x;
    /**< y component */
    float y;
public:
    /**
     * @brief constructor
     */
    Point2D() {}
    /**
     * @brief constructor
     * @param r x coordinate
     * @param s y coordinate
     */
    Point2D(float r, float s) {this->x = r; this->y=s;}
    /**
     * @brief set x
     * @param x x coordinate
     */
    void setX(float xC) {this->x = xC;}
    /**
     * @brief get x
     * @return x coordinate
     */
    int getX(){return this->x;}
    /**
     * @brief set y
     * @param y y coordinate
     */
    void setY(float yC) {this->y = yC;}
    /**
     * @brief get y
     * @return y coordinate
     */
    int getY(){return this->y;}
    /**
     * @brief comparison operator for
     */
    bool operator <(const Point2D& other) const
    {
        if (x < other.x) return true;
        else if (x > other.x) return false;
        else if (y < other.y) return true;
        else return false;
    }
    /**
     * @brief equality operator
     * @param other other object
     * @return this == other
     */
    bool operator==(const Point2D &other) const {return (this->x == other.x && this->y == other.y);}
    /**
     * @brief inequality operator
     * @param other other object
     * @return this != other
     */
    bool operator!=(const Point2D &other) const {return !(*this == other);}
};
#endif
