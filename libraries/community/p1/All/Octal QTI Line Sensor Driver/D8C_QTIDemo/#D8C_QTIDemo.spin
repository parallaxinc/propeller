{{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// D8C Charge Transfer Infrared Engine Demo
//
// Author: Kwabena W. Agyeman
// Updated: 9/6/2010
// Designed For: P8X32A
// Version: 1.0
//
// Copyright (c) 2010 Kwabena W. Agyeman
// See end of file for terms of use.
//
// Update History:
//
// v1.0 - Original release - 9/6/2010.
//
// Connect to a serial terminal.
//
// Nyamekye,
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}}

CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  _pinGroup = 0
  _baudRateSpeed = 250_000

  _receiverPin = 31
  _transmitterPin = 30

  _clearToEndOfLineCharacter = 11
  _newLineCharacter = 13

  _clearLinesBelowCharacter = 12
  _homeCursorCharacter = 1

OBJ

  qti: "D8C_QTIEngine.spin"
  com: "RS232_COMEngine.spin"
  str: "ASCII0_STREngine.spin"

PUB demo

  ifnot( qti.QTIEngineStart(_pinGroup) and {
       } com.COMEngineStart(_receiverPin, _transmitterPin, _baudRateSpeed))
    reboot

  repeat

    com.transmitString(string(_clearToEndOfLineCharacter, _homeCursorCharacter, "Raw QTI States:"))

    repeat result from 0 to 7

      com.transmitByte(" ")
      com.transmitString(1 + str.integerToDecimal(result, 1))
      com.transmitString(string(": "))
      com.transmitString(1 + str.integerToDecimal(qti.readSensorRaw(result), 5))

    com.transmitString(string(_clearToEndOfLineCharacter, _newLineCharacter, "Resized QTI States:"))

    repeat result from 0 to 7

      com.transmitByte(" ")
      com.transmitString(1 + str.integerToDecimal(result, 1))
      com.transmitString(string(": "))
      com.transmitString(1 + str.integerToDecimal(qti.readSensorScaled(result), 3))

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