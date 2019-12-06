' This program allows the Propeller to communicate with the CMUCAM2 via a MAX232 converter chip.
' Coded by Bryan Kobe May, 2007


CON

  _clkmode      = xtal1 + pll16x                        ' use crystal x 16
  _xinfreq      = 5_000_000                             ' external xtal is 5 MHz

  CR            = 13
  FF            = 12
  LF            = 10
  Space         = " "

  
OBJ

  debug : "pc_debug"


PUB main
  
  debug.startx(14, 13, 9_600)             ' start terminal @ 9600 BAUD
  debug.str(string("RS", CR))       ' send reset to camera tx pin
  waitcnt(8_000_000 + cnt)              'wait for 100 ms
  debug.str(string("PM", CR))       'set camera to poll mode
  waitcnt(8_000_000 + cnt)
  repeat
    waitcnt(40_000_000 + cnt)
    debug.str(string("L0 0", CR))     'turn off green LED
    repeat until (debug.in == ":")
    waitcnt(40_000_000 + cnt)
    debug.str(string("L0 1", CR))     'turn on green LED
    repeat until (debug.in == ":")

  
  