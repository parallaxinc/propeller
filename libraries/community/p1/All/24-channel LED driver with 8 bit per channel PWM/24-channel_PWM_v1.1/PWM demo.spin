{{
Pulse width modulated LED driver
24-channels, 8 bits per channel
Intended for use with 8 RBG LED modules

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
      B0 ─┤     ├───────────┤     ├─ Serial Tx   │ │  10kΩ    │
      G0 ─┤     ├───────────┤     ├──────────────┻─┼────┘
      R1 ─┤     ├───────────┤     ├────────────────┘
      B1 ─┤     ├───────────┤     ├─
      G1 ─┤     ├───────────┤     ├─
      R2 ─┤     ├───────────┤     ├─
      B2 ─┤    •├───────────┤     ├─
          └─────┘   Ground ─┤     ├─ 3.3V
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
           │             Propeller  LED
 Common 0 ─╋─ Common 4   Ground     Ground         3.3V
 Common 1 ─╋─ Common 5     │          │     0.1µF   │
 Common 2 ─╋─ Common 6     └──────────╋────────────┘
 Common 3 ─┻─ Common 7                
                                    System
                                    ground

Ground lines for Propeller and LEDs should all be tied together

Propeller runs at 3.3V
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

• See "I2C PWM.spin" for a demo showing control over I²C.

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

OBJ
pwm : "24-channel PWM"

VAR
byte rbg[24]

PUB main | i, a, a_offset, r, b, g
  ' Clear RBG buffer
  repeat i from 0 to 23
    rbg[i] := 0

  ' Start LED driver in new cog
  ' It will poll the I²C buffer for 8 channels of RBG values (in first 24 bytes of I²C buffer)
  pwm.start(@rbg)

  ' Generate a shifting rainbow effect on the LEDs
  repeat
    repeat a from 0 to (256+256+255)
      a_offset := 0
      i := 0
      repeat while i =< 23
        a_offset += 64
        r := ( a + a_offset) // (256 * 3)
        b := ( a + a_offset + 256 ) // (256 * 3)
        g := ( a + a_offset + 512 ) // (256 * 3)

        if ( (r<0) or (r > 511) )
          r := 0
        else
          r := 255 - ( || (r - 256) )
          if r < 0
            r := 0

        if ( (b<0) or (b > 511) )
          b := 0
        else
          b := 255 - ( || (b - 256) )
          if b < 0
            b := 0

        if ( (g<0) or (g > 511) )
          g := 0
        else
          g := 255 - ( || (g - 256) )
          if g < 0
            g := 0

        rbg[i++] := r
        rbg[i++] := b
        rbg[i++] := g

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
