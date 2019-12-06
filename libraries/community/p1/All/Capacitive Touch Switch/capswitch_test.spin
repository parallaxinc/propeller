{{

Capacitive sensing test
lights up an LED on the demo board when the switch is activated

}}



CON

  _clkmode = xtal1+pll16x
  _clkfreq = 80_000_000

  switch_pin = 2
  threshold = $04
OBJ
  switch:       "capswitch"
  pc    :       "PC_Text"

VAR
  long  avg           ' for debugging and threshold adjustment
  long  current       ' for debugging and threshold adjustment

PUB start
  switch.start(switch_pin, @avg, @current, threshold)
  pc.start(pc#TXPIN)
  pc.out($00)
  dira[16]~~
  outa[16]~~
  waitcnt(clkfreq/2 + cnt)
  outa[16]~
  repeat
    waitcnt(clkfreq/50 + cnt)
    pc.out($01)
    pc.str(STRING(" AVG:"))
    pc.hex(avg,8)
    pc.out($0D)
    pc.str(STRING("CURR:"))
    pc.hex(current,8)
    if switch.state
      outa[16]~~
    else
      outa[16]~