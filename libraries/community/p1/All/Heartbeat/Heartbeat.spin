''This object should be used like this:

''VAR
''long  stack[5]

''OBJ
''heart :       "heartbeat"

''PUB start
''  cognew(Run_Heart, stack)

''PUB Run_Heart
''  heart.run(pin_number)

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  out   =       %1
  on    =       %1
  off   =       %0
 
PUB Run(led)
  dira[led] := out
  outa[led] := off
  repeat
    outa[led] := on
    waitcnt(clkfreq / 4 + cnt)
    outa[led] := off
    waitcnt(clkfreq / 6 + cnt)
    outa[led] := on
    waitcnt(clkfreq / 6 + cnt)
    outa[led] := off
    waitcnt(clkfreq + cnt)  