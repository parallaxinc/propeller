{{
////////////////////////////////////////////////////////////////////////////////////////////
//                  invert_pwm_1cog_6pin_test.spin

// Example test file for invert_pwm_1cog_6pin.spin

// Author: Mark Tillotson
// Updated: 2014-08-05
// Designed For: P8X32A

////////////////////////////////////////////////////////////////////////////////////////////
}}


CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  DEADTIME = 4
  MAX_DELTA = pwm#HALF_PERIOD - DEADTIME

  UPINH = 16    ' pin numbers
  UPINL = 17
  VPINH = 18
  VPINL = 19
  WPINH = 20
  WPINL = 21

VAR

  long  uval		' need three continguous longs to control PWM channels
  long  vval            ' longs used as no sign-extension is needed, these are zero-centred
  long  wval		' signed values to make 3-phase drive easy.


OBJ
  pwm : "invert_pwm_1cog_6pin"


PUB Main | phase, starttime

  uval := pwm#OFFSET
  vval := pwm#OFFSET
  wval := pwm#OFFSET
  starttime := CNT + clkfreq

  pwm.start (starttime, UPINL, UPINH, VPINL, VPINH, WPINL, WPINH, DEADTIME, @uval)

  waitcnt (starttime+clkfreq)

  ' simple 3-phase sinusoidal drive, drive from +/- MAX_DELTA
  repeat
    uval := pwm#OFFSET + ((sine (phase)           / 340) #> -MAX_DELTA <# MAX_DELTA)
    vval := pwm#OFFSET + ((sine (phase+$55555555) / 340) #> -MAX_DELTA <# MAX_DELTA)
    wval := pwm#OFFSET + ((sine (phase+$AAAAAAAB) / 340) #> -MAX_DELTA <# MAX_DELTA)
    phase += $1333333

    waitcnt (CNT + clkfreq / 100)

  ' Note that the cog is sampling u/v/wval every  pwm#DELAYCOUNT cycles
  ' currently 1720 cycles which gives full waveform period of 3440 cycles
  ' ie 23.255kHz in a 80MHz system.


PRI  sine (i)  ' input 0 -- $FFFFFFFF represents 0 to 2pi
  i |= 1
  if i < 0
    return -sine(-i)
  if i => $40000000
    return sine ($80000000-i)
  return word [$E000][(i>>19) & $7FF]  ' output is 17.15 fixed point


{{
////////////////////////////////////////////////////////////////////////////////////////////
//                                TERMS OF USE: MIT License
////////////////////////////////////////////////////////////////////////////////////////////
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the "Software"), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify, merge,
// publish, distribute, sublicense, and/or sell copies of the Software, and to permit
// persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
// PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
// FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
////////////////////////////////////////////////////////////////////////////////////////////
}}
