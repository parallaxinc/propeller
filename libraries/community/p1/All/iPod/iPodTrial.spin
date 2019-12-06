''**********************************************************************************
''*This Demo turns on the iPod, plays for 10 seconds,                              *
''*  stops, and then turns the iPod off.  See iPod.spin documentation.             *
''**********************************************************************************

OBJ
  iPod : "iPod.spin"
CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  Tx = 0
  Rx = 1
  
PUB Trial  
  iPod.Initialize(Rx,Tx)                                'Always call this method first 

  repeat 2
    iPod.iPodOn                                         'Sometimes you need to send a command twice
  waitcnt(clkfreq + cnt)
  
  iPod.Play
  iPod.Release                                          'Always send a release command after any other command

  repeat 10
    waitcnt(clkfreq + cnt)

  iPod.Stop
  iPod.Release
  waitcnt(clkfreq + cnt)

  iPod.iPodOff
  iPod.Release  