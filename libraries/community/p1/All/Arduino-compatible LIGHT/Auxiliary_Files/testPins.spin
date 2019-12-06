{{
      $Id: test[Pins].spin 9 2011-11-30 06:05:39Z pedward $
   Author: Perry Harrington
Copyright: (c) 2011 Perry Harrington
=======================================================================

Test template

}}
CON

_clkmode = xtal1 + pll16x
_xinfreq = 5_000_000

OBJ

Pins: "Arduino_light"
pst: "Parallax Serial Terminal"

PUB main |x
'  pst.start(115_200)

  repeat x from 16 to 23
    Pins.pinMode(x,Pins#OUTPUT)

  Pins.shiftOut(16,17,Pins#MSBFIRST,$AA)
  waitcnt(clkfreq + cnt)
  Pins.shiftOut(16,17,Pins#LSBFIRST,$55)

  Pins.tone(16,500,0)
  waitcnt(clkfreq + cnt)
  Pins.notone(16)

  repeat
    repeat 2
      repeat x from 16 to 23
        Pins.digitalWrite(x,!Pins.digitalRead(x))
        waitcnt(5_000_000 + cnt)
    repeat x from 128 to 255
      Pins.analogWrite((x&%111)+16,x)
      waitcnt(2_500_000 + cnt)
    repeat x from 255 to 128
      Pins.analogWrite((x&%111)+16,x)
      waitcnt(2_500_000 + cnt)
    repeat 2
      repeat x from 23 to 16
        Pins.digitalWrite(x,!Pins.digitalRead(x))
        waitcnt(5_000_000 + cnt)

