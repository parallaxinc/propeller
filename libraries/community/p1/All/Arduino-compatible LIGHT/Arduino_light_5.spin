{{
      $Id: Arduino_light.spin 13 2011-12-08 03:04:35Z pedward $
   Object: Arduino_light
  Version: 1.0
   Author: Perry Harrington
Copyright: (c) 2011 Perry Harrington
=======================================================================

This object is a SPIN interface to emulate the Arduino SDK functions.

These methods are intended to make it easier for developers familiar
with Arduino to start using the Propeller.  I highly recommend that
you own the _Propeller Manual_ ISBN# 9781928982470 in hardcopy.  You
can download the PDF version from the Parallax website.

These functions are entirely written in SPIN, absent any ASM.  Where
it makes sense, functions are written long hand for readability,
however some of the operations use SPIN shorthand conventions because
they are more convenient than the standard C notation.

There are a lot of objects on OBEX (http://obex.parallax.com) which
implement many of the Arduino functions in a native manner, with higher
performance.  I highly recommend perusing the demos and objects included
in the Propeller Development Kit download.

Some objects I recommend reviewing:

FullDuplexSerial
Simple_Serial
Parallax Serial Terminal
Float32
SDCard Full Filesystem Driver (http://obex.parallax.com/objects/619/)
ADC
CTR
MCP3208
SPI_Spin -or- SPI_Asm
VGA -and- VGA_Text
TV -and- TV_Text -and- TV_Terminal

This is considered the _light_ version, which does not require a
supervisory COG.  The caveat to the _light_ version is that some
functions do not operate exactly like the Arduino.

Differences between this _light_ implementation and the Arduino:

millis() and micros() overflow every ~54 seconds because the system
counter runs at clock speed (usually 80Mhz) and is 32 bits

tone() does not have a duration option, so you must call noTone() to turn
off the output.  This function also accepts values larger than 65536.

digitalWrite() does not operate at 500Hz, it uses a hardware counter that
operates at the main clock frequency, which is usually 80Mhz.

pow() is integer only, it does not accept or return float types, see
the Float32A object

sqrt() is integer only, see Float32A

attachInterrupt(), detachInterrupt(), interrupts(), and noInterrupts()
are not implemented because the Propeller does not have interrupts.
Propeller programming convention is to use multiple COGs where you might
have used interrupts in a conventional mCu architecture.

sin(), cos(), and tan() take degrees and radius, instead of radians.  This
format does not require degree to radian conversion and subsequent radius
multiplication.  The result is a signed value with a range of +- radius.

analogRead() and analogReference() are not implemented, the Propeller does
not have embedded AtoD hardware, either an external ADC chip is needed or
you can use Sigma-Delta AtoD conversion.  The ADC SPIN object implements
sigma delta ADC conversion, the MCP3208 object interfaces to an
external ADC chip via SPI.

}}

CON

  INPUT = 0
  OUTPUT = 1
  HIGH = 1
  LOW = 0
  MSBFIRST = 1
  LSBFIRST = 0
  ctrNCO = %00100
  ctrDUTY = %00110
  dutyPeriod = $101_0101
  uS = 1_000_000
  mS = 1_000

  NOTE_B2  = 123
  NOTE_C3  = 131
  NOTE_CS3  = 139
  NOTE_D3  = 147
  NOTE_DS3  = 156
  NOTE_E3  = 165
  NOTE_F3  = 175
  NOTE_FS3  = 185
  NOTE_G3  = 196
  NOTE_GS3  = 208
  NOTE_A3  = 220
  NOTE_AS3  = 233
  NOTE_B3  = 247
  NOTE_C4  = 262
  NOTE_CS4  = 277
  NOTE_D4  = 294
  NOTE_DS4  = 311
  NOTE_E4  = 330
  NOTE_F4  = 349
  NOTE_FS4  = 370
  NOTE_G4  = 392
  NOTE_GS4  = 415
  NOTE_A4  = 440
  NOTE_AS4  = 466
  NOTE_B4  = 494
  NOTE_C5  = 523
  NOTE_CS5  = 554
  NOTE_D5  = 587
  NOTE_DS5  = 622
  NOTE_E5  = 659
  NOTE_F5  = 698
  NOTE_FS5  = 740
  NOTE_G5  = 784
  NOTE_GS5  = 831
  NOTE_A5  = 880
  NOTE_AS5  = 932
  NOTE_B5  = 988
  NOTE_C6  = 1047
  NOTE_CS6  = 1109
  NOTE_D6  = 1175
  NOTE_DS6  = 1245
  NOTE_E6  = 1319
  NOTE_F6  = 1397
  NOTE_FS6  = 1480
  NOTE_G6  = 1568
  NOTE_GS6  = 1661
  NOTE_A6  = 1760
  NOTE_AS6  = 1865
  NOTE_B6  = 1976
  NOTE_C7  = 2093
  NOTE_CS7  = 2217
  NOTE_D7  = 2349
  NOTE_DS7  = 2489
  NOTE_E7  = 2637
  NOTE_F7  = 2794
  NOTE_FS7  = 2960
  NOTE_G7  = 3136
  NOTE_GS7  = 3322
  NOTE_A7  = 3520
  NOTE_AS7  = 3729
  NOTE_B7  = 3951
  NOTE_C8  = 4186
  NOTE_CS8  = 4435
  NOTE_D8  = 4699
  NOTE_DS8  = 4978
  
VAR
  long randseed

PUB pinMode(pin, mode)
  DIRA[pin] := mode

PUB digitalWrite(pin, value)
  OUTA[pin] := value

PUB digitalRead(pin)
  return INA[pin]

PUB tone(pin,freq,dur)          'currently duration isn't supported
  ctra := 0
  frqa := fraction(freq,clkfreq,1)
  ctra := ctrNCO << 26 + pin

PRI fraction(a, b, shift) : f   'borrowed from CTR.spin

  if shift > 0                         'if shift, pre-shift a or b left
    a <<= shift                        'to maintain significant bits while
  if shift < 0                         'insuring proper result
    b <<= -shift

  repeat 32                            'perform long division of a/b
    f <<= 1
    if a => b
      a -= b
      f++
    a <<= 1

PUB notone(pin)
  frqa := 0

PUB pulseIn(pin,state,timeout)
  if timeout
    waitcnt(clkfreq / 1000 * timeout + cnt)
  else
    waitcnt(clkfreq + cnt)

  waitpeq(state,|<pin,0)
  result:=cnt
  waitpeq(!state,|<pin,0)
  result-=cnt

PUB analogWrite(pin,duty)
  ctra := 0
  frqa := dutyPeriod * duty
  ctra := ctrDUTY << 26 + pin

PUB shiftOut(pin,clkpin,order,val) | x
  repeat x from 0 to 7
      if order == MSBFIRST
        outa[pin] := val >> (7-x) & 1
      else
        outa[pin] := val >> x & 1

'      waitcnt(clkfreq + cnt)
      outa[clkpin]~~
'      waitcnt(clkfreq + cnt)
      outa[clkpin]~

PUB shiftIn(pin,clkpin,order) | x
  repeat x from 0 to 7
    if order == MSBFIRST
      result |= ina[pin] << (7-x)
    else
      result |= ina[pin] << x

    outa[clkpin]~~
    outa[clkpin]~

PUB lowByte(val)
  return val.byte

PUB highByte(val)
  return (val >> 8) & $FF

PUB bitRead(val, n)
  result := val
  result &= |< n
  result >>= n

PUB bitWrite(varptr, n, b)
  long[varptr] &= ! |< n
  long[varptr] |= b << n

PUB bitSet(varptr, n)
  bitWrite(varptr, n, 1)

PUB bitClear(varptr, n)
  bitWrite(varptr, n, 0)

PUB bit(n)
  return |< n

PUB _min(x,y)
  if x > y
    return y
  return x

PUB _max(x,y)
  if x > y
    return x
  return y

PUB _abs(x)
  return || x

PUB constrain(x,a,b)
  return x #> a <# b

PUB map(val,fromL,fromH,toL,toH)
  return (val - fromL) * (toH - toL) / (fromH - fromL) + toL

PUB pow(base, exp)
  result:=base
  repeat exp-1
    result*=base

PUB sqrt(x)
  return ^^x

PUB sin(degree, range) : s | c,z,angle
  angle := (degree*91)~>2  ' *22.75
  c := angle & $800
  z := angle & $1000
  if c
    angle := -angle
  angle |= $E000>>1
  angle <<= 1
  s := word[angle]
  if z
    s := -s
  return (s*range)~>16     ' return sin = -range..+range

PUB cos(degree,range)
  return sin(degree+90,range)

PUB tan(degree,range)
  result := sin(degree,range)
  result *= range
  result /= cos(degree,range)

PUB millis
  return (cnt / (clkfreq / mS))

PUB micros
  return (cnt / (clkfreq / uS))

PUB delay(time)
  waitcnt((time * (clkfreq / mS)) + cnt)

PUB delayMicroseconds(time)
  waitcnt((time * (clkfreq / uS)) + cnt)

PUB random(l,h)
  return ?randseed #> l <# h

PUB randomSeed(n)
  randseed := n

