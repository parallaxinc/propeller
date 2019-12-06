/**
 * @file laserping.h
 * @brief Laser Ping Driver to determine distance
 * @author Michael Burmeister
 * @date March 30, 2019
 * @version 1.0
 * 
*/

/**
 * @brief start ping sensor
 * @param mode default or S = serial
 * @param pin used
 */
void laserping_start(char mode, char pin);

/**
 * @brief get distance measured
 * @return distance in millimeters
 */
int laserping_distance(void);

/**
 * @brief stop laser ping sensor
 */
void laserping_stop(void);
