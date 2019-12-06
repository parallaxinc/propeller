/**
 * @file timer.c
 * @brief Timer delays
 * @author Michael Burmeister
 * @date November 14, 2017
 * @version 1.0
 *
*/
#include "simpletools.h"
#include "timer.h"

int micros(unsigned long *D)
{
  long t;
  
  t = CNT + 280 - *D;
  *D = CNT;
  if (t < 0)
    t = UINT32_MAX + t;

  *D = *D - t % us;
  t = t/us;
  return t;
}

int millis(unsigned long *D)
{
  long t;
  
  t = CNT + 280 - *D;
  *D = CNT;
  if (t < 0)
    t = UINT32_MAX + t;

  *D = *D - t % ms;
  t = t/ms;
  return t;
}
