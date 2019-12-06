{{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// PWM2C Signal Engine
//
// Author: Kwabena W. Agyeman
// Updated: 10/28/2010
// Designed For: P8X32A
// Version: 1.1
//
// Copyright (c) 2010 Kwabena W. Agyeman
// See end of file for terms of use.
//
// Update History:
//
// v1.0 - Original release - 2/28/2010.
// v1.1 - Added support for variable pin assignments - 10/28/2010.
//
// For each included copy of this object only one spin interpreter should access it at a time.
//
// Nyamekye,
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Servo Circuit:
//
//                 5V
//                 |
//                 --- Servo 5V Power
//
// Left Servo Pin  --- Servo Pulse Width Pin
//
//                 --- Servo Ground
//                 |
//                GND
//
//                 5V
//                 |
//                 --- Servo 5V Power
//
// Right Servo Pin --- Servo Pulse Width Pin
//
//                 --- Servo Ground
//                 |
//                GND
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}}

VAR

  long leftLength, rightLength, stack[7]
  byte cogNumber, leftPinNumber, rightPinNumber, timeoutPeriod

PUB leftPulseLength '' 3 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Returns the servo channel's pulse length in microseconds.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  return leftLength

PUB rightPulseLength '' 3 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Returns the servo channel's pulse length in microseconds.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  return rightLength

PUB SIGEngineStart(leftServoPin, rightServoPin, timeout) '' 9 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Starts up the SIG driver running on a cog.
'' //
'' // Returns true on success and false on failure.
'' //
'' // LeftServoPin - Pin for left channel servo pulse width input. Between (0 - 31).
'' // RightServoPin - Pin for right channel servo pulse width input. Between (0 - 31).
'' // Timeout - The timeout period before zeroing the channel pulse lengths in centiseconds. Between 0 and 100. (Try 10).
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  SIGEngineStop
  if(chipver == 1)
    leftPinNumber := ((leftServoPin <# 31) #> 0)
    rightPinNumber := ((rightServoPin <# 31) #> 0)
    timeoutPeriod := ((timeout <# 100) #> 0)
    cogNumber := cognew(SIGDriver, @stack)
    result or= ++cogNumber

PUB SIGEngineStop '' 3 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Shuts down the SIG driver running on a cog.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  if(cogNumber)
    cogstop(-1 + cogNumber~)

PRI SIGDriver : leftTimeout | rightTimeout ' 7 Stack Longs

  ctra := constant(%0_1000 << 26) + leftPinNumber
  ctrb := constant(%0_1000 << 26) + rightPinNumber

  frqa := frqb := 1
  leftTimeout := rightTimeout := cnt

  repeat

    if(phsa < 0)
      leftLength := 0
      phsa := 0

    ifnot(ina[leftPinNumber] or not(phsa))

      leftLength := ((||(phsa~)) / (clkfreq / 1_000_000))
      leftTimeout := cnt

    if((cnt - leftTimeout) > ((clkfreq / 100) * timeoutPeriod))
      leftLength := 0

    if(phsb < 0)
      rightLength := 0
      phsb := 0

    ifnot(ina[rightPinNumber] or not(phsb))

      rightLength := ((||(phsb~)) / (clkfreq / 1_000_000))
      rightTimeout := cnt

    if((cnt - rightTimeout) > ((clkfreq / 100) * timeoutPeriod))
      rightLength := 0

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