/**
 * @brief Laser Ping Driver to determine distance
 * @author Michael Burmeister
 * @date March 30, 2019
 * @version 1.0
 * 
*/

#include "simpletools.h"
#include "laserping.h"


#define LASER 16
#define PING 0

int i;

int main()
{

  laserping_start('X', LASER);
  
  while(1)
  {
    i = laserping_distance();
    printi("Distance: %d\n", i);
    pause(500);
  }  
}

