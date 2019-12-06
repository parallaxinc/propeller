{{
Pulse width modulated LED driver
24-channels, 8 bits per channel
Intended for use with 8 RBG LED modules
Runs as an I²C slave

Version 1.1  2014-03-30
Copyright (c) 2014 Alexander Hajnal
See end of file for terms of use

Driver uses successive approximation to provide
256 brightness levels for each channel

────────────────────────────────────────────────────────────────────────────────

Sample circuit using common-anode RBG modules:

                                              ┌──┳─┳─┳─┐
                                              │ ┌┴─┴─┴─┴┐
                                               │      •│
      2x ULN2803A:                              │23LC256│
 ┌────────────────┐                             │       │
 │  10kΩ  ┌─────┐ │        Propeller            └┬─┬─┬─┬┘
 ┣──┤     ├─┘         ┌─────┐              │ │  └──────┳──── 3.3V
     R0 ─┤     ├───────────┤•    ├─ Serial Rx   │ │          │
      B0 ─┤     ├───────────┤     ├─ Serial Tx   │ │  10kΩ    │    10kΩ
      G0 ─┤     ├───────────┤     ├──────────────┻─┼────┻─────┐
      R1 ─┤     ├───────────┤     ├────────────────┘         330Ω         │
      B1 ─┤     ├───────────┤     ├───────────────────────┳─────────┻──── I²C SDA    ┐
      G1 ─┤     ├───────────┤     ├─────────────────────┳─┼────────────── I²C SCL    ├─ To I²C master
      R2 ─┤     ├───────────┤     ├─              ┌───┘ │  330Ω            ┌─ I²C Ground ┘
      B2 ─┤    •├───────────┤     ├─              ┣─────┘                  
          └─────┘   Ground ─┤     ├─ 3.3V           2x 3.3V Zener diode
 ┌────────────────┐ Ground ─┤     ├───┐5MHz
 │  10kΩ  ┌─────┐ │  Reset ─┤     ├────┘crystal  ULN2803A:
 ┣──┤     ├─┘   3.3V ─┤     ├─ Ground      ┌─────┐
     G2 ─┤     ├───────────┤     ├──────────────┤•    ├─ G7
      R3 ─┤     ├───────────┤     ├──────────────┤     ├─ B7
      B3 ─┤     ├───────────┤     ├──────────────┤     ├─ R7
      G3 ─┤     ├───────────┤     ├──────────────┤     ├─ G6
      R4 ─┤     ├───────────┤     ├──────────────┤     ├─ B6
      B4 ─┤     ├───────────┤     ├──────────────┤     ├─ R6
      G4 ─┤     ├───────────┤     ├──────────────┤     ├─ G5
      R5 ─┤    •├───────────┤     ├──────────────┤     ├─ B5
          └─────┘           └─────┘            ┌─┤     ├┐
                                               │ └─────┘ 10kΩ │
                                               └──────────────┫
                                                              
          12V
           │             Propeller I²C     LED
 Common 0 ─╋─ Common 4   Ground    Ground  Ground         3.3V
 Common 1 ─╋─ Common 5     │         │       │     0.1µF   │
 Common 2 ─╋─ Common 6     └─────────╋───────┻────────────┘
 Common 3 ─┻─ Common 7               
                                   System
                                   ground

Ground lines for Propeller, I²C, and LEDs should all be tied together

Propeller and I²C run at 3.3V
LEDs can run at any voltage that the ULN2803A's can handle (12V in this example)

Note that you may need to use multiple 12V power supplies depending on how much
current the LEDs need.  For example you might tie Common 0..3 to one supply's
12V rail and Common 4..7 to a second supply's 12V rail (both supplies' ground
rails need to be tied to the system ground).

The circuit was tested using Ikea Dioder lights which run at 12V and have
resistors built-in.  If you're using discrete LEDs you will probably want to add
a current-limiting resistor in series with each LED.  The lights that I have
draw about 504mA at 12V when all 24 channels are on (plus 24mA for the Propeller
and the rest of the circuitry).  The Ikea power supplies can only supply 430mA
each so using a split supply (1x 12V power supply for every 4 light strips) is
recommended.

Cabling for Ikea Dioder RBG lights:

 Common (12V)
 Red
XXXXXX Blue
 Green

────────────────────────────────────────────────────────────────────────────────

Release notes and errata:

• I am not an electrical engineer.
  Use this circuit at your own risk!

• Do NOT connect the 12V rail to any of the Propeller's pins.
  If you do so you will immediately and permanently destroy the Propeller chip.
  The only connections should be through the ULN2803A's.

• You can use different Darlington arrays in place of the ULN2803As as long as
  they meet the electrical specifications for both the LEDs and the Propeller.

• The I²C interface consists of 24 read/write 8-bit registers at (by default for
  this demo) I²C address $42.  To set an RBG channel's brightness simply write a
  value between 0 (fully off) and 255 (fully on) to the appropriate register
  using standard I²C read and write commands.  The registers are as follows:

  0 ── Channel 0 red
  1 ── Channel 0 blue
  2 ── Channel 0 green
  ...
  21 ─ Channel 7 red
  22 ─ Channel 7 blue
  23 ─ Channel 7 green

• I²C driver probably won't work with a clock above 400kHz

• The Propeller may fail to boot if data is being written by an external master
  to the I²C bus on pins 28 and 29 at boot time.  To avoid this it is probably
  best to have separate I²C buses for the EEPROM and for external control.
  (The example circuit shown above uses separate I²C buses)

• See "raspberry_pi_i2c_pwm.pl" for a demo of controlling this system from a
  Raspberry Pi's I²C pins.

• See "PWM demo.spin" for a standalone demo.

• See "24-channel PWM.spin" for additional notes

────────────────────────────────────────────────────────────────────────────────

Release history:

2014-03-28  v1.0  • Initial release

2014-03-30  v1.1  • Various bug fixes and other updates to low-level driver
                    ("24-channel PWM.spin")
                  • Documentation clean-up and corrections
}}

CON
_clkmode = xtal1 + pll16x
_xinfreq = 5_000_000

' I²C settings
SDA_pin     = 27
SCL_pin     = 26
Bitrate     = 400_000
I2C_address = $42

OBJ
i2c : "I2C slave v1.0a"
pwm : "24-channel PWM"

PUB main | i, i2c_register_base
  ' Start the I²C slave in a new cog with an I²C device address of $42
  i2c.start(SCL_pin,SDA_pin,I2C_address)

  ' Clear the I²C registers
  repeat i from 0 to 31
    i2c.put(i, 0)

  ' Get the base address of the I²C registers
  i2c_register_base := i2c.address

  ' Start LED driver in new cog
  ' It will poll the I²C buffer for 8 channels of RBG values (in first 24 bytes of I²C buffer)
  pwm.start(i2c_register_base)

  ' Shut down current cog
  cogstop(0)

DAT
{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}
