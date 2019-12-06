'' Demo for MCP4922 Driver
CON
   _clkmode = xtal1 + pll16x
   _xinfreq = 5_000_000

OBJ
   DAC : "MCP4922" 

PUB Main
  DAC.Init(0, 1, 2) 'CS, SCK, SDI respectively 
  DAC.Set(0, 2048) 'Set Channel A to half-range (2.5V with 5V reference)

  repeat