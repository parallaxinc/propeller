{{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// I2C ROMEngine Demo
//
// Author: Kwabena W. Agyeman
// Updated: 7/27/2010
// Designed For: P8X32A
// Version: 1.0
//
// Copyright (c) 2010 Kwabena W. Agyeman
// See end of file for terms of use.
//
// Update History:
//
// v1.0 - Original release - 7/27/2010.
//
// Type "help" into the serial terminal and press enter after connecting to display the command list.
//
// Nyamekye,
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}}

CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  _baudRateSpeed = 250_000
  _newLineCharacter = 13
  _clearScreenCharacter = 16
  _homeCursorCharacter = 1

  _receiverPin = 31
  _transmitterPin = 30
  _clockDataPin = 29
  _clockClockPin = 28

OBJ

  rom: "I2C_ROMEngine.spin"
  com: "RS232_COMEngine.spin"
  str: "ASCII0_STREngine.spin"

PUB shell

  ifnot( rom.ROMEngineStart(_clockDataPin, _clockClockPin, -1) and {
       } com.COMEngineStart(_receiverPin, _transmitterPin, _baudRateSpeed))
    reboot

  repeat

    result := shellLine(string(">_ "))
    com.transmitString(string("Running command: "))
    com.transmitString(result)
    com.transmitByte(_newLineCharacter)

    result := \shellCommands(result)
    com.transmitString(result)
    com.transmitByte(_newLineCharacter)

PRI shellCommands(stringPointer)

  stringPointer := str.tokenizeString(stringPointer)

  programClear(stringPointer)
  programEcho(stringPointer)

  programReboot(stringPointer)
  programHelp(stringPointer)

  programGetByte(stringPointer)
  programGetWord(stringPointer)
  programGetLong(stringPointer)

  programSetByte(stringPointer)
  programSetWord(stringPointer)
  programSetLong(stringPointer)

  programHexDump(stringPointer)
  programHexTest(stringPointer)

  abort string("Command Not Found! Try ", com#quotation_marks, "Help", com#quotation_marks, _newLineCharacter)

PRI shellLine(prompt)

  com.transmitString(prompt)

  repeat
    result := com.receivedByte
    str.buildString(result)
  while((result <> com#carriage_return) and (result <> com#line_feed) and (result <> com#null))

  return str.trimString(str.builtString(true))

PRI shellDecision(prompt, characterToFind, otherCharacterToFind)

  com.transmitString(prompt)

  repeat

    prompt := com.receivedByte
    result or= ((prompt == characterToFind) or (prompt == otherCharacterToFind))

    if(prompt == com#backspace)
      return false

  while((prompt <> com#carriage_return) and (prompt <> com#line_feed) and (prompt <> com#null))

PRI programClear(stringPointer)

  ifnot(str.stringCompareCI(string("clear"), stringPointer))
    waitcnt((clkfreq >> 1) + cnt)
    com.transmitString(string(_clearScreenCharacter, _homeCursorCharacter))
    abort false

PRI programEcho(stringPointer)

  ifnot(str.stringCompareCI(string("echo"), stringPointer))
    com.transmitString(str.trimString(stringPointer += 5))
    com.transmitByte(_newLineCharacter)
    abort false

PRI programReboot(stringPointer)

  ifnot(str.stringCompareCI(string("reboot"), stringPointer))
    com.transmitString(string("Restarting "))

    repeat 3
      waitcnt((clkfreq >> 1) + cnt)
      com.transmitString(string(". "))

    waitcnt((clkfreq >> 1) + cnt)
    reboot

PRI programHelp(stringPointer)

  ifnot(str.stringCompareCI(string("help"), stringPointer))
    com.transmitString(@shellProgramHelpStrings)
    abort false

DAT shellProgramHelpStrings

  byte _newLineCharacter
  byte "Command Listing"
  byte _newLineCharacter, _newLineCharacter

  byte "<clear>                     - Clear the screen."
  byte _newLineCharacter
  byte "<echo> <string>             - Echo the string argument."
  byte _newLineCharacter
  byte "<reboot>                    - Reboot the propeller chip."
  byte _newLineCharacter
  byte "<help>                      - Show the command listing."
  byte _newLineCharacter
  byte "<getb> <index>              - Get a byte."
  byte _newLineCharacter
  byte "<getw> <index>              - Get a word."
  byte _newLineCharacter
  byte "<getl> <index>              - Get a long."
  byte _newLineCharacter
  byte "<setb> <index> <value>      - Set a byte."
  byte _newLineCharacter
  byte "<setw> <index> <value>      - Set a word."
  byte _newLineCharacter
  byte "<setl> <index> <value>      - Set a long."
  byte _newLineCharacter
  byte "<hexdump> <address> <count> - Display any parts of the memory."
  byte _newLineCharacter
  byte "<hextest>                   - Speed test the reading code."
  byte _newLineCharacter, 0

PRI programGetByte(stringPointer)

  ifnot(str.stringCompareCI(string("getb"), stringPointer))
    com.transmitString(string("0x"))
    com.transmitString(str.integerToHexadecimal(rom.readByte(str.decimalToInteger(str.tokenizeString(0))), 2))
    com.transmitByte(_newLineCharacter)
    abort false

PRI programGetWord(stringPointer)

  ifnot(str.stringCompareCI(string("getw"), stringPointer))
    com.transmitString(string("0x"))
    com.transmitString(str.integerToHexadecimal(rom.readWord(str.decimalToInteger(str.tokenizeString(0))), 4))
    com.transmitByte(_newLineCharacter)
    abort false

PRI programGetLong(stringPointer)

  ifnot(str.stringCompareCI(string("getl"), stringPointer))
    com.transmitString(string("0x"))
    com.transmitString(str.integerToHexadecimal(rom.readLong(str.decimalToInteger(str.tokenizeString(0))), 8))
    com.transmitByte(_newLineCharacter)
    abort false

PRI programSetByte(stringPointer)

  ifnot(str.stringCompareCI(string("setb"), stringPointer))
    if(rom.writeByte(str.decimalToInteger(str.tokenizeString(0)), str.decimalToInteger(str.tokenizeString(0))))
      com.transmitString(string("Success", _newLineCharacter))
    else
      com.transmitString(string("Failure", _newLineCharacter))
    abort false

PRI programSetWord(stringPointer)

  ifnot(str.stringCompareCI(string("setw"), stringPointer))
    if(rom.writeWord(str.decimalToInteger(str.tokenizeString(0)), str.decimalToInteger(str.tokenizeString(0))))
      com.transmitString(string("Success", _newLineCharacter))
    else
      com.transmitString(string("Failure", _newLineCharacter))
    abort false

PRI programSetLong(stringPointer)

  ifnot(str.stringCompareCI(string("setl"), stringPointer))
    if(rom.writeLong(str.decimalToInteger(str.tokenizeString(0)), str.decimalToInteger(str.tokenizeString(0))))
      com.transmitString(string("Success", _newLineCharacter))
    else
      com.transmitString(string("Failure", _newLineCharacter))
    abort false

PRI programHexDump(stringPointer)

  ifnot(str.stringCompareCI(string("hexdump"), stringPointer))

    stringPointer := str.decimalToInteger(str.tokenizeString(0))

    repeat str.decimalToInteger(str.tokenizeString(0))

      com.transmitString(string("0x"))
      com.transmitString(str.integerToHexadecimal(rom.readByte(stringPointer + result++), 2))
      com.transmitByte(com#horizontal_tab)

    com.transmitByte(_newLineCharacter)

    abort false

PRI programHexTest(stringPointer) | startTime, stopTime, array[4_096]

  ifnot(str.stringCompareCI(string("hextest"), stringPointer))

    startTime := cnt
    rom.readPage(0, @array, constant(4_096 * 4))
    stopTime := cnt

    com.transmitString(string("Transfer speed clocked at "))
    com.transmitString(1 + str.integerToDecimal(multiplyDivide(constant(4_096 * 4), (||(stopTime - startTime))), 4))
    com.transmitString(string(" BPS.", _newLineCharacter))

    abort false

PRI multiplyDivide(dividen, divisor) | productHigh, productLow

  productHigh := clkfreq ** dividen
  productLow := clkfreq * dividen

  if(productHigh => divisor)
    return posx

  repeat 32

    dividen := (productHigh < 0)
    productHigh := ((productHigh << 1) + (productLow >> 31))
    productLow <<= 1
    result <<= 1

    if((productHigh => divisor) or dividen)
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