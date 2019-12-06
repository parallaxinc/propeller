/* Measure Volts
* Use Serial Peripheral Interface to communicate with
  an MCP3002 to measure voltage across channels 0 and 1 to ground.
* References: "2.7V Dual Channel 10-Bit A/D Converter with SPI Serial Interface"
* 
* I make no guarantees with this software.
* Use at your own risk, double check your hardware, and post problems
* on the Parallax forums! 
* 
* Written by Andrew Enright
*/
#include "MCP3002.h" // Include simpletools lib 
#include "simpletools.h"
int t_CS=26, t_clk=23, t_miso=24, t_mosi=25; // DO = MOSI, DI = MISO
float t_vref = 5.1;

int main() // Main function
{  
      while(1) // Main loop
      {
        putchar(CLS); //clear screen between updates
        float v0 = MCP3002_getVolts(0, t_mosi, t_miso, t_clk, t_CS, t_vref);
        float v1 = MCP3002_getVolts(1, t_mosi, t_miso, t_clk, t_CS, t_vref);
        print("%cCh0: %f V\nCh1: %f V\n", HOME,v0, v1);
        pause(500); // Wait 0.5 s before repeat
      }//end while    
} //end main
