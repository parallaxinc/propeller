{{
      $Id: test[Time].spin 9 2011-11-30 06:05:39Z pedward $
   Author: Perry Harrington
Copyright: (c) 2011 Perry Harrington
=======================================================================

Test template

}}
CON

_clkmode = xtal1 + pll16x
_xinfreq = 5_000_000

OBJ

pst:    "Parallax Serial Terminal"
Time:   "Arduino_light"

PUB main | a
  pst.start(115_200)             'debug output

  repeat
    pst.Str(String(pst#NL,pst#NL,pst#NL, "Milliseconds:"))
    pst.Dec(Time.millis)
    a:=Time.millis
    Time.delay(1_000)
    a:=Time.millis - a
    pst.Str(String(pst#NL, "Elapsed Milliseconds:"))
    pst.Dec(a)
    pst.Str(String(pst#NL, "Microseconds:"))
    pst.Dec(Time.micros)
    a:=Time.micros
    Time.delayMicroseconds(500_000)
    a:=Time.micros - a
    pst.Str(String(pst#NL, "Elapsed Microseconds:"))
    pst.Dec(a)

