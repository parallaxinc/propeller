/**
 * @file timer.h
 * @brief Timer delays
 * @author Michael Burmeister
 * @date November 14, 2017
 * @version 1.0
 * @details The first time you call the function
 *  with a variable it starts the timer.<br> The next
 *  time you call the function it will return the
 *  amount of time passed since the last time it was called.
*/

/**
 * @brief milliseconds pasted
 * @param X pass a reference to an unsigned long variable
 * @return milliseconds past
 */

int millis(unsigned long *X);

/**
 * @brief microsecond past
 * @param X pass a reference to an unsigned long variable
 * return microseconds past
 */

int micros(unsigned long *X);

