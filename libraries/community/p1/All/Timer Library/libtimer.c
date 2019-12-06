/**
 * @brief Timer delays
 * @author Michael Burmeister
 * @date November 14, 2017
 * @version 1.0
 * 
*/

#include "simpletools.h"
#include "timer.h"

unsigned long PCNT;
unsigned long P2CNT;


int main()
{
  int sec, sec2;
  
  int d1, d2;
  micros(&PCNT);
  millis(&P2CNT);
  
  sec = 0;
  sec2 = 0;
  d1 = 0;
  d2 = 0;
  
  while(1)
  {
    d1 += micros(&PCNT);
    d2 += millis(&P2CNT);
    
    if (d1 > 1000000)  // wait a second
    {
      d1 = d1 - 1000000;
      print("Timer: %d, %d\n", d1, sec++);
    }      
    
    if (d2 > 1000) // wait a second
    {
      d2 = d2 - 1000;
      print("Timer2: %d, %d\n", d2, sec2++);
    }      
  }  
}
