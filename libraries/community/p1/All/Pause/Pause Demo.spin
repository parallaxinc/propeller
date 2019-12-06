CON
  _clkmode      = xtal1 + pll16x
  _xinfreq      = 5_000_000
  led           = 0                        
VAR
  
OBJ
  pause :       "pause"
PUB Start                                
  pause.start
  repeat
    outa[led] := %1
    pause.pause(100)
    outa[led] := %0
    pause.pause(500)