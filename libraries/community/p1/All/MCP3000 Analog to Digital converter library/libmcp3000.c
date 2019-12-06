/**
 * @brief Read MCP3000 Analog to digital
 * @author Michael Burmeister
 * @date February 16, 2016
 * @version 1.1
 * 
*/

#include "simpletools.h"
#include "mcp3000.h"


#define CS 5
#define CLK 4
#define DOUT 3
#define DIN 2
#define REFV 5

int main()
{
  int i, j;
  
  mcp3000_open(CS, CLK, DOUT, DIN);
  
  while (1)
  {
    i = mcp3202_read(0);
    j = mcp3202_volts(REFV, 0);
    printi("Port 0: %d, (%d)mv", i, j);
    i = mcp3202_read(1);
    j = mcp3202_volts(REFV, 1);
    printi(" Port 1: %d, (%d)mv\n", i, j);  
    pause(1000);
  }  
}
