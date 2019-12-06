{{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// PWM1C PIDEngine Demo
//
// Author: Kwabena W. Agyeman
// Updated: 10/15/2010
// Designed For: P8X32A
// Version: 1.0
//
// Copyright (c) 2010 Kwabena W. Agyeman
// See end of file for terms of use.
//
// Update History:
//
// v1.0 - Original release - 10/15/2010.
//
// Type "help" into the serial terminal and press enter after connecting to display the command list.
//
// Nyamekye,
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}}

CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  _homeCursorCharacter = 1
  _newLineCharacter = 13
  _clearToEndOfLineCharacter = 11
  _clearScreenCharacter = 16

  _baudRate = 250_000

  _PGain = 15
  _IGain = 14
  _Dgain = 15

  _encoderRightInput = 22
  _encoderLeftInput = 23
  _motorLeftOutput = 26
  _motorRightOutput = 27

  _transmitterPin = 30
  _receiverPin = 31

OBJ

  pid: "PWM1C_PIDEngine.spin"
  com: "RS232_COMEngine.spin"
  str: "ASCII0_STREngine.spin"

PUB shell

  ifnot( pid.PIDEngineStart(_motorLeftOutput, _motorRightOutput, _encoderLeftInput, _encoderRightInput, _PGain, _IGain, _DGain) and {
       } com.COMEngineStart(_receiverPin, _transmitterPin, _baudRate))
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

  programPosition(stringPointer)
  programSpeed(stringPointer)

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
    com.transmitString(string("Rebooting "))

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

  byte "<clear>               - Clear the screen."
  byte _newLineCharacter
  byte "<echo> <string>       - Echo the string argument."
  byte _newLineCharacter
  byte "<reboot>              - Reboot the propeller chip."
  byte _newLineCharacter
  byte "<help>                - Show the command listing."
  byte _newLineCharacter
  byte "<position>            - Show the encoder absolute position and speed."
  byte _newLineCharacter
  byte "<speed> <targetSpeed> - Drive the encoder at the target speed."
  byte _newLineCharacter, 0

PRI programPosition(stringPointer)

  ifnot(str.stringCompareCI(string("position"), stringPointer))

    waitcnt((clkfreq >> 1) + cnt)
    com.transmitString(string( _clearScreenCharacter, _homeCursorCharacter, "Press Enter To Quit", {
                             } _clearToEndOfLineCharacter, _newLineCharacter, {
                             } _clearToEndOfLineCharacter))

    result := cnt
    repeat

      com.transmitString(string(_homeCursorCharacter, _newLineCharacter, "Position: "))
      com.transmitString(str.integerToDecimal(pid.quadraturePosition(false), 10))

      if((cnt - result) > clkfreq)
        com.transmitString(string(_newLineCharacter, "Speed: "))
        com.transmitString(str.integerToDecimal(pid.quadraturePosition(true), 10))
        result := cnt

      if(com.receivedNumber)
        result := com.receivedByte
        if((result == com#carriage_return) or (result == com#line_feed) or (result <> com#null))
          quit

    com.transmitString(string(_clearScreenCharacter, _homeCursorCharacter))
    abort false

PRI programSpeed(stringPointer)

  ifnot(str.stringCompareCI(string("speed"), stringPointer))
    pid.quadratureSpeed(str.decimalToInteger(str.tokenizeString(0)))
    abort false

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