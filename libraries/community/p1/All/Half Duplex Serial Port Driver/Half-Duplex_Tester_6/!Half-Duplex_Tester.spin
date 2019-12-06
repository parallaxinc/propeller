{{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Half-Duplex Tester
//
// Author: Kwabena W. Agyeman
// Updated: 5/30/2011
// Designed For: P8X32A
// Version: 1.0
//
// Copyright (c) 2011 Kwabena W. Agyeman
// See end of file for terms of use.
//
// Update History:
//
// v1.0 - Original release - 5/30/2011.
//
// On startup this program launches a simple echo serial terminal where what is written in the serial terminal is echoed back
// out. The echo serial terminal will accept 512 characters before echoing them back. Please open a serial port terminal.
//
// Nyamekye,
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}}

CON

  _clkmode = xtal1 + pll16x ' The clkfreq is 96 MHz.
  _xinfreq = 6_000_000 ' Not demo board compatible.

  _baudRate = 19_200 ' Not standard.
  _newLine = 13 ' Carriage return (13) or line feed (10).

  _receiverPin = 31 ' The boot loader uses pin 31 as its receiver pin.
  _transmitterPin = 30 ' The boot loader uses pin 30 as its transmitter pin.

OBJ

  com: "Half-Duplex_COMEngine.spin"

PUB main | data[128]

  com.COMEngineStart(_receiverPin, _transmitterPin, _baudRate) ' Never fails.
  waitcnt((clkfreq * 3) + cnt)

  com.writeString(string(_newLine, _newLine, "Echo Terminal:", _newLine)) ' Echo terminal.
  repeat

    com.writeString(string(_newLine, ">_ "))
    result := com.readString(@data, 512)
    com.writeString(string("   "))
    com.writeString(result)

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