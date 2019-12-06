# Arduino-compatible LIGHT

![propeller_glasses_small.png](propeller_glasses_small.png)

By: Perry Harrington

Language: Spin

Created: Nov 29, 2011

Modified: May 2, 2013

This is a basic \_light\_ implementation of the Arduino SDK for the Propeller and does not require a dedicated COG. It is intended for newbies to get acquainted with the Propeller. There are many useful SDK functions implemented, things like PWM, tones, shiftIn/shiftOut, bit setting routines and math routines. This object is intended as an easy way for Arduinites to explore the Propeller, it is not intended as a substitute for the many great SPIN/PASM objects that implement much of these functions in a more robust and thorough manner.

**UPDATES:**

12/07/2011: added note constants to CON section, see note\_player.spin example added sound file player example snd\_player.spin

12/05/2011: fixed compile failure in random() declaration

The following functions are implemented:

Pins

*   pinMode()
*   digitalWrite()
*   digitalRead()

Time

*   millis()
*   micros()
*   delay()
*   delayMicroseconds()

Math

*   \_min()
*   \_max()
*   \_abs()
*   constrain()
*   map()
*   pow()
*   sqrt()
*   sin()
*   cos()
*   tan()

Bits and Bytes

*   lowByte()
*   highByte()
*   bitRead()
*   bitWrite()
*   bitSet()
*   bitClear()
*   bit()

Advanced I/O

*   tone()
*   noTone()
*   shiftIn()
*   shiftOut()
*   pulseIn()

Analog I/O

*   analogWrite()

Random Numbers

*   randomSeed()
*   random()

Differences between this \_light\_ implementation and the Arduino:

millis() and micros() overflow every ~54 seconds because the system

counter runs at clock speed (usually 80Mhz) and is 32 bits

tone() does not have a duration option, so you must call noTone() to turn

off the output. This function also accepts frequencies larger than 65536.

digitalWrite() does not operate at 500Hz, it uses a hardware counter that

operates at the main clock frequency, which is usually 80Mhz.

pow() and sqrt() are integer only, for floating point functions see the Float32, Float32, and FloatFull objects.

attachInterrupt(), detachInterrupt(), interrupts(), and noInterrupts()

are not implemented because the Propeller does not have interrupts.

Propeller programming convention is to use multiple COGs where you might

have used interrupts in a conventional mCu architecture.

sin(), cos(), and tan() take degrees and radius, instead of radians. This format does not require degree to radian conversion and subsequent radius multiplication. The result is a signed value with a range of +- radius.

analogRead() and analogReference() are not implemented, the Propeller does not have embedded ADC hardware, either an external ADC chip is needed or you can use Sigma-Delta ADC with the ADC SPIN object included in the Propeller Development Kit, or the MCP3208 object which interfaces to an external ADC chip via SPI.
