{{

┌──────────────────────────────────────────┐
│ Temperature Demo                         │
│ Author: Greg LaPolla                     │               
│ Email: glapolla@gmail.com                │               
│ Copyright (c) 2020 Greg LaPolla          │               
│ See end of file for terms of use.        │                
└──────────────────────────────────────────┘

}}
CON

  _clkmode        = xtal1 + pll16x                            ' set clock mode
  _xinfreq        = 5_000_000                                 ' set external crystal freq

  propTX          = 30                                        ' programming output
  propRX          = 31                                        ' programming input
  baudrate        = 115_200                                   ' Serial Display Baud Rate
  chipselect     =  22
  clock          =  23
  mosi           =  20
  miso           =  21

VAR
  
OBJ
  ADS1118 : "ADS1118"
    debug : "FullDuplexSerial"   

PUB Main | uV

  debug.start(propRX, propTX, 0, baudrate)
  ADS1118.Start(chipselect,clock,mosi,miso)
  ADS1118.Configure(ADS1118#RATE128SPS,ADS1118#SINGLE_SHOT,ADS1118#READY)
  waitcnt(clkfreq/10+Cnt)
  
  repeat
    debug.tx(16)
    debug.tx(1)
    debug.str(string("top of the ADS1118 demo"))
    debug.tx(10)
    uV := ADS1118.ReadExplicit(ADS1118#DIFF_0_1, ADS1118#FSR_256)
    debug.str(string("The Thermocoiple reading is : "))
    debug.dec(uV)
    debug.tx(10)
    uV:= ADS1118.ReadTemp
    debug.str(string("The Cold Junction reading is : "))
    debug.dec(uV)
    
    waitcnt(clkfreq+cnt)