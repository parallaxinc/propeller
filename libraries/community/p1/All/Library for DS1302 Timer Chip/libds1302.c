/**
 * @brief Clock Calender device
 * @author Michael Burmeister
 * @date January 14, 2017
 * @version 1.0
 * 
*/

#include "simpletools.h"
#include "ds1302.h"

#define MISO 1
#define MOSI 2
#define SCLK 3
#define CS   4

int m, s, d, mn, hr, yr, dw;


int main()
{

  DS1302_open(MISO, CS, SCLK, MOSI);
    
  pause(1000);
  
  m = DS1302_getWriteProtect();
  if (m)
    print("Write Protect On\n");
  else
    print("Write Protect Off\n");
    
  
  if (1)
  {
    DS1302_clearWriteProtect();
    DS1302_setYear(18);
    DS1302_setMonth(1);
    DS1302_setDay(18);
    DS1302_setHour(11);
    DS1302_setMinute(00);
    DS1302_setSecond(00);
  }
  
  while(1)
  {
    m = DS1302_getMinutes();
    s = DS1302_getSeconds();
    d = DS1302_getDay();
    hr = DS1302_getHours();
    mn = DS1302_getMonth();
    dw = DS1302_getWeekDay();
    yr = 2000 + DS1302_getYear();
    
    print("Date: %d/%d/%d, %d:%d:%d\n", mn, d, yr, hr, m, s);
    
    pause(1000);
  }  
}
