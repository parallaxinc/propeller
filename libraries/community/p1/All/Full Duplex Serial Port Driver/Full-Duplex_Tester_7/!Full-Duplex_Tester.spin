{{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Full-Duplex Tester
//
// Author: Kwabena W. Agyeman
// Updated: 6/9/2012
// Designed For: P8X32A
// Version: 1.2
//
// Copyright (c) 2012 Kwabena W. Agyeman
// See end of file for terms of use.
//
// Update History:
//
// v1.0 - Original release - 5/29/2011.
// v1.1 - Updated the two helper functions - 6/8/2011.
// v1.2 - Updated the testing loop. The default clkfreq is now 96 MHz instead of 80 MHz - 6/9/2011.
//
// On startup this program speed tests the SPIN interpreter's ability to push and pop data out of the serial port's FIFO
// buffers using the built-in rountines for the object. The serial port's baud rate limits the resulting speed test speeds.
// After speed testing the serial port code this program checks serial port loop back communication by pushing as much data
// as possibe out one serial port and in to another and vice versa at the same time. Random baud rate jitter is added to the
// loop back test to make sure full duplex functionality is operational. Finally the program launches a simple echo serial
// terminal where what is written in the serial terminal is echoed back out. The echo serial terminal will accept 512
// characters before echoing them back. Please open a serial port terminal to see the output of this program.
//
// Nyamekye,
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}}

CON

  _clkmode = xtal1 + pll16x ' The clkfreq is 96 MHz.
  _xinfreq = 6_000_000 ' Not demo board compatible.

  _baudRate = 250_000 ' Not standard. 115,200 BPS for 80 MHz operation...
  _newLine = 13 ' Carriage return (13) or line feed (10).

  _receiverPin = 31 ' The boot loader uses pin 31 as its receiver pin.
  _transmitterPin = 30 ' The boot loader uses pin 30 as its transmitter pin.

  _loopBackTestRX = 1 ' The serial loopback in circuit pin.
  _loopBackTestTX = 0 ' The serial loopback out circuit pin.

OBJ

  com0: "Full-Duplex_COMEngine.spin"
  com1: "Full-Duplex_COMEngine.spin"
  com2: "Full-Duplex_COMEngine.spin"

PUB main | buffer, counter, data[128]

  com0.COMEngineStart(_receiverPin, _transmitterPin, _baudRate) ' Never fails.
  com1.COMEngineStart(_loopBackTestRX, _loopBackTestTX, _baudRate) ' Never fails.
  com2.COMEngineStart(_loopBackTestTX, _loopBackTestRX, _baudRate) ' Never fails.

  waitcnt((clkfreq * 3) + cnt)

  com0.receiverFlush
  com1.receiverFlush
  com2.receiverFlush
  com0.writeString(string(_newLine, _newLine, "128 Byte Stride - Speed Test:", _newLine, _newLine))

  ' Start speed test.

  waitcnt(clkfreq + cnt)
  com0.writeString(string("writeByte - "))
  buffer := cnt
  repeat counter from constant(32_768 + 0) to constant(32_768 + 127) step 1
    com1.writeByte(byte[counter])

  printDecimal(multiplyDivide(128, (cnt - buffer)) >> 10)
  com0.writeString(string(" KBs", _newLine))

  waitcnt(clkfreq + cnt)
  com0.writeString(string("readByte - "))
  buffer := cnt
  repeat counter from constant(32_768 + 0) to constant(32_768 + 127) step 1
    if(com2.readByte <> byte[counter])
      com0.writeString(string("Failure", _newLine))
      repeat ' Forever...

  printDecimal(multiplyDivide(128, (cnt - buffer)) >> 10)
  com0.writeString(string(" KBs", _newLine))

  waitcnt(clkfreq + cnt)
  com0.writeString(string("writeShort - "))
  buffer := cnt
  repeat counter from constant(32_768 + 0) to constant(32_768 + 127) step 2
    com1.writeShort(word[counter])

  printDecimal(multiplyDivide(128, (cnt - buffer)) >> 10)
  com0.writeString(string(" KBs", _newLine))

  waitcnt(clkfreq + cnt)
  com0.writeString(string("readShort - "))
  buffer := cnt
  repeat counter from constant(32_768 + 0) to constant(32_768 + 127) step 2
    if(com2.readShort <> word[counter])
      com0.writeString(string("Failure", _newLine))
      repeat ' Forever...

  printDecimal(multiplyDivide(128, (cnt - buffer)) >> 10)
  com0.writeString(string(" KBs", _newLine))

  waitcnt(clkfreq + cnt)
  com0.writeString(string("writeLong - "))
  buffer := cnt
  repeat counter from constant(32_768 + 0) to constant(32_768 + 127) step 4
    com1.writeLong(long[counter])

  printDecimal(multiplyDivide(128, (cnt - buffer)) >> 10)
  com0.writeString(string(" KBs", _newLine))

  waitcnt(clkfreq + cnt)
  com0.writeString(string("readLong - "))
  buffer := cnt
  repeat counter from constant(32_768 + 0) to constant(32_768 + 127) step 4
    if(com2.readLong <> long[counter])
      com0.writeString(string("Failure", _newLine))
      repeat ' Forever...

  printDecimal(multiplyDivide(128, (cnt - buffer)) >> 10)
  com0.writeString(string(" KBs", _newLine))

  waitcnt(clkfreq + cnt)
  com0.writeString(string("writeData - "))
  buffer := cnt
  com1.writeData(32_768, 128)

  printDecimal(multiplyDivide(128, (cnt - buffer)) >> 10)
  com0.writeString(string(" KBs", _newLine))

  waitcnt(clkfreq + cnt)
  com0.writeString(string("readData - "))
  buffer := cnt
  com2.readData(32_768, 128)

  printDecimal(multiplyDivide(128, (cnt - buffer)) >> 10)
  com0.writeString(string(" KBs", _newLine))

  ' End speed test.

  com0.writeString(string(_newLine, "Loopback Test:", _newLine, _newLine))
  repeat 64

    com0.writeByte(".")
    com1.writeData(32_768, 255)
    waitcnt(((clkfreq / _baudRate) * (((||(cnt?)) // 10) + 1)) + cnt) ' Creates random jitter.
    com2.writeData(32_768, 255)

    repeat counter from constant(32_768 + 0) to constant(32_768 + 254)
      buffer := byte[counter]
      if((com1.readByte <> buffer) or (com2.readByte <> buffer))
        com0.writeString(string(" - Pass Failed!", _newLine))

  ' Echo terminal.

  com0.writeString(string(_newLine, _newLine, "Echo Terminal:", _newLine))
  repeat

    com0.writeString(string(_newLine, ">_ "))
    result := com0.readString(@data, 512)
    com0.writeString(string("   "))
    com0.writeString(result)

PRI printDecimal(integer) | temp[3] ' Writes a decimal string.

  if(integer < 0) ' Print sign.
    com0.writeByte("-")

  longfill(@temp, 0, 3)

  repeat result from 10 to 1 ' Convert number.
    temp.byte[result] := ((||(integer // 10)) + "0")
    integer /= 10

  result := @temp ' Skip past leading zeros.
  repeat ' Format saves two bytes.
  while(byte[++result] == "0")
  result += (not(byte[result]))

  com0.writeString(result~) ' Print number.

PRI multiplyDivide(dividen, divisor) | productHigh, productLow

  productHigh := (clkfreq ** dividen)
  productLow := (clkfreq * dividen)

  if((productHigh ^ negx) < (divisor ^ negx)) ' Return 0 on overflow.
    repeat 32 ' Preform ((clkfreq * dividen) / divisor) ... all unsigned.

      dividen := (productHigh < 0) ' Carry bit.
      productHigh := ((productHigh << 1) + (productLow >> 31))
      productLow <<= 1
      result <<= 1

      if(((productHigh ^ negx) => (divisor ^ negx)) or dividen) ' Unsigned "=>".
        productHigh -= divisor
        result += 1

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