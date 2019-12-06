{{
      $Id: test[Bits].spin 9 2011-11-30 06:05:39Z pedward $
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
Bits: "Arduino_light"

PUB main | a,x,b
  pst.start(115200)             'debug output

  a := $AA55

  pst.Str(String(pst#NL, "A:"))
  pst.Hex(a,4)
  a := Bits.lowByte(a)
  pst.Str(String(pst#NL, "lowByte:"))
  pst.Hex(a,4)

  a := $AA55
  a := Bits.highByte(a)
  pst.Str(String(pst#NL, "highByte:"))
  pst.Hex(a,4)

  a := $AA55
  pst.Str(String(pst#NL, "bitRead:"))
  repeat x from 0 to 15
    pst.Dec(Bits.bitRead(a,x))

  a := $FFFF
  repeat x from 0 to 15
    Bits.bitWrite(@a,x,0)
    pst.Str(String(pst#NL, "bitWrite0("))
    pst.Hex(x,1)
    pst.Str(String("):"))
    pst.Hex(a,4)

  a := $0000
  repeat x from 0 to 15
    Bits.bitWrite(@a,x,1)
    pst.Str(String(pst#NL, "bitWrite1("))
    pst.Hex(x,1)
    pst.Str(String("):"))
    pst.Hex(a,4)

  a := $0000
  repeat x from 0 to 15
    Bits.bitSet(@a,x)
    pst.Str(String(pst#NL, "bitSet:"))
    pst.Hex(a,4)

  a := $FFFF
  repeat x from 0 to 15
    Bits.bitClear(@a,x)
    pst.Str(String(pst#NL, "bitClear:"))
    pst.Hex(a,4)

  repeat x from 0 to 31
    pst.Str(String(pst#NL, "bit(x):"))
    pst.Hex(Bits.bit(x),8)

