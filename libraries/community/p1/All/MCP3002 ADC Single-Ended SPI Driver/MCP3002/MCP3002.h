/* MCP3002.h 
* Use Serial Peripheral Interface to communicate with
* an MCP3002 to measure voltage across channels 0 and 1 to ground.
* References: "2.7V Dual Channel 10-Bit A/D Converter with SPI Serial Interface"
* 
* I make no guarantees with this software. It worked for me, that doesn't mean it will 
* work for you. Use at your own risk, double check your hardware, and post problems
* on the Parallax forums!
* 
* Written by Andrew Enright
*/
#include "simpletools.h"

/* Function MCP3002_getVolts gets a measurement from the ADC.
* PARAMETERS:
* ch      = Channel, either 0 or 1 (anything but a zero will return measures from channel 1)
* mosi    = Master Out, Slave In
* miso    = Master In, Slave Out
* clk     = bus clock
* cs_adc  = ADC Chip Select, active low (leave high when not in use)
* vref    = reference voltage, 2.7-5.5V. Recommend measuring with voltmeter for best results.
* 
*  RETURN: Returns a floating-point value which is the voltage on the MCP3002, which should be
*  somewhere between GND and VREF.
*         Returns -1.0 if MOSI, MISO, CLK, CS, or VREF are -1 (happens when not initialized).  
*/
float MCP3002_getVolts(int ch, int mosi, int miso, int clk, int cs_adc, float vref);