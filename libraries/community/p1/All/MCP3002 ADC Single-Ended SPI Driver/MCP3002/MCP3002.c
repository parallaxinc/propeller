/* Measure Volts
* Use Serial Peripheral Interface to communicate with
  an MCP3002 to measure voltage across channels 0 and 1 to ground.
* References: "2.7V Dual Channel 10-Bit A/D Converter with SPI Serial Interface"
* 
* I make no guarantees with this software. It worked for me, that doesn't mean it will 
* work for you. Use at your own risk, double check your hardware, and post problems
* on the Parallax forums!
* 
* Written by Andrew Enright
*/
#include "MCP3002.h" // Include MCP3002.h, which includes simpletools.h
#include "simpletools.h"

//int MCP3002_init(int mosi, int miso, int clk, int csin, float vref)
//float MCP3002_getVolts(int ch);

volatile short bitsIn = 0b0000000000000000;
volatile int CS_ADC=-1, SCK=-1, MISO=-1, MOSI=-1; // DO = MOSI, DI = MISO
volatile float VREF = -99.99;

float MCP3002_getVolts(int ch, int mosi, int miso, int clk, int csin, float vref) {
    if (vref < 0) {
   print("Error! Float Vref = %f, should not be <= 0\n", vref);
  } else {
         CS_ADC = csin; 
         SCK = clk;
         MISO = miso; 
         MOSI = mosi; // DO = MOSI, DI = MISO 
         VREF = vref;
         high(CS_ADC);
        low(CS_ADC); // CS_ADC low selects chip
        //boot sequence: start, sgl/diff (1 for single-ended mode), odd/sign (channel in single-ended mode), msbf
        if (ch == 0){
          shift_out(MOSI, SCK, MSBFIRST, 4, 0b1101); // Send "read channel 0 single-ended"
        } else {
          shift_out(MOSI, SCK, MSBFIRST, 4, 0b1111); // Send "read channel 1 single-ended"
        } 
        bitsIn = shift_in(MISO,SCK,MSBPOST,10);
        float volts = bitsIn * VREF / 1024; // 1024: 2^10, it's a 10-bit ADC after all.
        high(CS_ADC);
        usleep(5);
        shift_out(MOSI, SCK, MSBFIRST, 1, 0b1);
        return volts;
    }
  return -99.99;  
} 


