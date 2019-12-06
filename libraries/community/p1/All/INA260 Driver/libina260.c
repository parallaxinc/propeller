/**
 * @brief INA260 Adafruit power driver
 * @author Michael Burmeister
 * @date June 23, 2019
 * @version 1.0
 * 
*/
#include "ina260.h"
#include "simpletools.h"

#define CLK 1
#define DTA 0

int i;

int main()
{
  i = INA260_open(0, CLK, DTA);

  printi("MFG: %x\n", i);
  
  i = INA260_getVoltage();
  
  printi("Volts: %d\n", i);
  
  i = INA260_getCurrent();
  
  printi("Current: %d\n", i);
  
  i = INA260_getPower();
  
  printi("Power: %d\n", i);
  
  INA260_setConfig(7, 4, 4, 7, 0);
  
  i = INA260_getConfig();
  
  printi("Config: %x\n", i);
  
  while(1)
  {
    pause(250);
    i = INA260_getCurrent();
    printi("Current: %d\n", i);
  }  
}
