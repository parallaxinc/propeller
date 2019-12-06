{{
      $Id: test[Math].spin 9 2011-11-30 06:05:39Z pedward $
   Author: Perry Harrington
Copyright: (c) 2011 Perry Harrington
=======================================================================

Test template

}}
CON

_clkmode = xtal1 + pll16x
_xinfreq = 5_000_000

OBJ

pst: "Parallax Serial Terminal"
Math: "Arduino_light"

PUB main |a,b
  pst.start(115200)             'debug output

  a:=3
  b:=6

  pst.Str(String(pst#NL, "A:"))
  pst.Dec(a)
  pst.Str(String(pst#NL, "B:"))
  pst.Dec(b)

  pst.Str(String(pst#NL, "_min(a,b):"))
  pst.Dec(Math._min(a,b))

  pst.Str(String(pst#NL, "_max(a,b):"))
  pst.Dec(Math._max(a,b))

  pst.Str(String(pst#NL, "_abs(-5):"))
  pst.Dec(Math._abs(-5))

  pst.Str(String(pst#NL, "constrain(2,a,b):"))
  pst.Dec(Math.constrain(2,a,b))

  pst.Str(String(pst#NL, "constrain(7,a,b):"))
  pst.Dec(Math.constrain(7,a,b))

  pst.Str(String(pst#NL, "pow(3,4):"))
  pst.Dec(Math.pow(3,4))

  pst.Str(String(pst#NL, "pow(5,5):"))
  pst.Dec(Math.pow(5,5))

  pst.Str(String(pst#NL, "pow(2,16):"))
  pst.Dec(Math.pow(2,16))

  pst.Str(String(pst#NL, "sqrt(49):"))
  pst.Dec(Math.sqrt(49))

  pst.Str(String(pst#NL, "sqrt(2):"))
  pst.Dec(Math.sqrt(2))

  pst.Str(String(pst#NL, "sqrt(16):"))
  pst.Dec(Math.sqrt(16))

  pst.Str(String(pst#NL, "map(43,1,50,50,1):"))
  pst.Dec(Math.map(43,1,50,50,1))

  pst.Str(String(pst#NL, "map(32, 1, 50, 50, -100):"))
  pst.Dec(Math.map(32, 1, 50, 50, -100))

  pst.Str(String(pst#NL, "sin(60,100):"))
  pst.Dec(Math.sin(60,100))

  pst.Str(String(pst#NL, "cos(60,100):"))
  pst.Dec(Math.cos(60,100))

  pst.Str(String(pst#NL, "tan(60,100):"))
  pst.Dec(Math.tan(60,100))

