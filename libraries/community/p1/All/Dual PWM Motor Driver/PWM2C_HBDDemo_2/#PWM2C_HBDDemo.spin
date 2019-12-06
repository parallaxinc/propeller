{{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// PWM2C H-Bridge Demo
//
// Author: Kwabena W. Agyeman
// Updated: 8/20/2010
// Designed For: P8X32A
// Version: 1.0
//
// Copyright (c) 2010 Kwabena W. Agyeman
// See end of file for terms of use.
//
// Update History:
//
// v1.0 - Original release - 8/20/2010.
//
// Run the program with the specified driver hardware.
//
// Nyamekye,
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}}

CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  _leftFW = 25
  _leftBW = 24
  _rightFW = 26
  _rightBW = 27

  _timeStepInMilliseconds = 20
  _updateFrequencyInHertz = 8_000

OBJ

  hbd: "PWM2C_HBDEngine.spin"

PUB demo | timeCounter, frequencyCounter

  ifnot(hbd.HBDEngineStart(_leftFW, _leftBW, _rightFW, _rightBW, _updateFrequencyInHertz))
    reboot

  timeCounter := ((clkfreq / 1_000) * _timeStepInMilliseconds)
  repeat

    repeat frequencyCounter from 0 to 1_000 step 1
      hbd.leftDuty(frequencyCounter)
      hbd.rightDuty(-frequencyCounter)

      waitcnt(timeCounter + cnt)

    repeat frequencyCounter from 1_000 to 0 step 10
      hbd.leftDuty(frequencyCounter)
      hbd.rightDuty(-frequencyCounter)

      waitcnt(timeCounter + cnt)

    repeat frequencyCounter from 0 to -1_000 step 1
      hbd.leftDuty(frequencyCounter)
      hbd.rightDuty(-frequencyCounter)

      waitcnt(timeCounter + cnt)

    repeat frequencyCounter from -1_000 to 0 step 10
      hbd.leftDuty(frequencyCounter)
      hbd.rightDuty(-frequencyCounter)

      waitcnt(timeCounter + cnt)

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