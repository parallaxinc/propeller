{{
////////////////////////////////////////////////////////////////////////////////////////////
//                  inverter_pwm_test.spin

// Example test file for inverter_pwm.spin

// Author: Mark Tillotson
// Updated: 2014-08-03
// Designed For: P8X32A

////////////////////////////////////////////////////////////////////////////////////////////
}}


CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  PERIOD = 2500           ' 16kHz since two PWM periods = one waveform period (phase-correct PWM)
  MAX_DELTA = PERIOD/2-30 ' need to limit the values to a bit less than half-period to avoid lock-up

  UPINH = 16
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
  pwm : "inverter_pwm"

PUB Main | phase, starttime

  starttime := CNT + clkfreq	' synchronization point for the 3 cogs

  'pwm.start3 (starttime, PERIOD/2, UPINH, VPINH, WPINH, @uval)   ' 3-pin only version

  pwm.start6 (starttime, PERIOD/2, UPINL, UPINH, VPINL, VPINH, WPINL, WPINH, @uval, false)

  waitcnt (starttime) 

  ' simple 3-phase sinusoidal drive, drive from +/- 2^10
  repeat
    uval := (sine (phase) ~> 6) #> -MAX_DELTA <# MAX_DELTA
    vval := (sine (phase+$55555555) ~> 6) #> -MAX_DELTA <# MAX_DELTA
    wval := (sine (phase+$AAAAAAAB) ~> 6) #> -MAX_DELTA <# MAX_DELTA
    phase += $333333

    waitcnt (CNT + clkfreq / 1000)


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
