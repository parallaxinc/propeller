{{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// PROPELLER TB6612FNG - TEST
//
//
// Author: Stefan Wendler
// Updated: 2013-12-11
// Designed For: P8X32A
// Version: 1.0
//
// Copyright (c) 2013 Stefan Wendler
// See end of file for terms of use.
//
// Update History:
//
// v1.0 - Initial release       - 2013-12-11
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Circuit Diagram:
//
// PIN AO1       --- AO1,  Motor A out 1
// PIN AO2       --- AO2,  Motor A out 2
// PIN PWMA      --- PWMA, Motor A PWM (for speed control)
// PIN BO1       --- BO1,  Motor B out 1
// PIN BO2       --- BO2,  Motor B out 2
// PIN PWMB      --- PWMB, Motor B PWM (for speed control)
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Brief Description:
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}}

CON

  '' Clock settings
  '' _clkmode = rcfast                                  ' Internal clock at 12MHz

  _CLKMODE = XTAL1 + PLL16X                             ' External clock at 80MHz
  _XINFREQ = 5_000_000

  '' First motor (A) on the TB5512FNG
  MOT_AO1       = 2                                     ' TB6612FNG AO1  pin
  MOT_AO2       = 3                                     ' TB6612FNG AO2  pin
  MOT_PWMA      = 6                                     ' TB6612FNG PWMA pin

  '' Second motor (B) on the TB5512FNG
  MOT_BO1       = 4                                     ' TB6612FNG BO1  pin
  MOT_BO2       = 5                                     ' TB6612FNG BO2  pin
  MOT_PWMB      = 7                                     ' TB6612FNG PWMB pin

OBJ

  mc    : "tb6612fng"

VAR

  '' none

PUB main | i

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Main routine. Init motor driver, operate the motor
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  '' set LEDs to output
  repeat i from 16 to 23
    dira[i] := 1

  repeat

    '' turn off all LEDs
    repeat i from 16 to 23
      outa[i] := 0

    '' Setup motor driver
    mc.init(MOT_AO1, MOT_AO2, MOT_PWMA, MOT_BO1, MOT_BO2, MOT_PWMB)

    '' drive both motors counter clock wise (CCW)
    outa[16] := 1 '' enable led to indicate processig of the test
    mc.operateSync(mc#CMD_CCW)
    delay

    '' drive both motors clock wise (CW)
    outa[17] := 1 '' enable led to indicate processig of the test
    mc.operateSync(mc#CMD_CW)
    delay

    '' drive motors A counter clock wise (CCW), B clock wise (CW)
    outa[18] := 1 '' enable led to indicate processig of the test
    mc.operateAsync(mc#CMD_CCW, mc#CMD_CW)
    delay

    '' drive motors A clock wise (CW), B counter clock wise (CCW)
    outa[19] := 1 '' enable led to indicate processig of the test
    mc.operateAsync(mc#CMD_CW, mc#CMD_CCW)
    delay

    '' stop both motors
    mc.operateSync(mc#CMD_STOP)

    '' drive motor A CCW
    outa[20] := 1 '' enable led to indicate processig of the test
    mc.operate(mc#MOT_A, mc#CMD_CCW)
    delay

    '' drive motor A CW
    outa[21] := 1 '' enable led to indicate processig of the test
    mc.operate(mc#MOT_A, mc#CMD_CW)
    delay

    '' stop motor A
    mc.operate(mc#MOT_A, mc#CMD_STOP)

    '' drive motor B CCW
    outa[22] := 1 '' enable led to indicate processig of the test
    mc.operate(mc#MOT_B, mc#CMD_CCW)
    delay

    '' drive motor B CW
    outa[23] := 1 '' enable led to indicate processig of the test
    mc.operate(mc#MOT_B, mc#CMD_CW)
    delay

    '' stop motor B
    mc.operate(mc#MOT_B, mc#CMD_STOP)

    '' set speed of both motors to 10%
    mc.setSpeedSync(10)

    '' drive both moters CW
    outa[16] := 0 '' enable led to indicate processig of the test
    mc.operateSync(mc#CMD_CW)
    delay

    '' setSpeed of motor A to 30%
    outa[17] := 0 '' enable led to indicate processig of the test
    mc.setSpeed(mc#MOT_A, 30)
    delay

    '' setSpeed of motor A to 10% and B to 30%
    outa[18] := 0 '' enable led to indicate processig of the test
    mc.setSpeedAsync(10, 30)
    delay

    '' stop both motors
    mc.operateSync(mc#CMD_STOP)

PRI delay

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Wait a little
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  waitcnt(clkfreq * 5 + cnt)

DAT

{{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                  TERMS OF USE: MIT License
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
// Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}}
