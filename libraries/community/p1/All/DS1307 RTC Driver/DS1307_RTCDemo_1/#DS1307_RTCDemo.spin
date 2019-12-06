{{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// DS1307 RTCEngine Demo
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

  rtc: "DS1307_RTCEngine.spin"
  com: "RS232_COMEngine.spin"
  str: "ASCII0_STREngine.spin"

PUB shell

  ifnot( rtc.rtcEngineStart(_clockDataPin, _clockClockPin, -1) and {
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

  programDate(stringPointer)
  programTime(stringPointer)

  programRamSet(stringPointer)
  programRamGet(stringPointer)

  programSQW(stringPointer)
  programOUT(stringPointer)

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
    rtc.pauseForMilliseconds(500)
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
      rtc.pauseForMilliseconds(500)
      com.transmitString(string(". "))

    rtc.pauseForMilliseconds(500)
    reboot

PRI programHelp(stringPointer)

  ifnot(str.stringCompareCI(string("help"), stringPointer))
    com.transmitString(@shellProgramHelpStrings)
    abort false

DAT shellProgramHelpStrings

  byte _newLineCharacter
  byte "Command Listing"
  byte _newLineCharacter, _newLineCharacter

  byte "<clear>                        - Clear the screen."
  byte _newLineCharacter
  byte "<echo> <string>                - Echo the string argument."
  byte _newLineCharacter
  byte "<reboot>                       - Reboot the propeller chip."
  byte _newLineCharacter
  byte "<help>                         - Show the command listing."
  byte _newLineCharacter
  byte "<date>                         - Display the current date and time."
  byte _newLineCharacter
  byte "<time>                         - Change the current date and time."
  byte _newLineCharacter
  byte "<set> <byteNumber> <byteValue> - Set the value of a BSRAM byte on the RTClock."
  byte _newLineCharacter
  byte "<get> <byteNumber>             - Get the value of a BSRAM byte on the RTClock."
  byte _newLineCharacter
  byte "<sqw> <frequencyNumber>        - Set the frequecny of the SWQ / OUT pin. (0=1Hz, 1=4096Hz, 2=8192Hz, 3=32768Hz)."
  byte _newLineCharacter
  byte "<out> <digitalState>           - Set the state of the SWQ / OUT pin. (0=low, 1=high)."
  byte _newLineCharacter, 0

PRI programDate(stringPointer)

  ifnot(str.stringCompareCI(string("date"), stringPointer))

    ifnot(rtc.readTime)
      abort string("Operation Failed", _newLineCharacter)

    com.transmitString(lookup(rtc.clockDay: string("Sunday"), {
                                          } string("Monday"), {
                                          } string("Tuesday"),  {
                                          } string("Wednesday"), {
                                          } string("Thursday"), {
                                          } string("Friday"), {
                                          } string("Saturday")))
    com.transmitString(string(", "))
    com.transmitString(lookup(rtc.clockMonth: string("January"), {
                                            } string("Feburary"), {
                                            } string("March"), {
                                            } string("April"), {
                                            } string("May"), {
                                            } string("June"), {
                                            } string("July"),  {
                                            } string("August"), {
                                            } string("September"), {
                                            } string("October"), {
                                            } string("November"), {
                                            } string("December")))

    com.transmitByte(" ")
    com.transmitString(1 + str.integerToDecimal(rtc.clockDate, 2))
    com.transmitString(string(", "))
    com.transmitString(1 + str.integerToDecimal(rtc.clockYear, 4))
    com.transmitByte(" ")
    com.transmitString(1 + str.integerToDecimal(rtc.clockMeridiemHour, 2))
    com.transmitByte(":")
    com.transmitString(1 + str.integerToDecimal(rtc.clockMinute, 2))
    com.transmitByte(":")
    com.transmitString(1 + str.integerToDecimal(rtc.clockSecond, 2))
    com.transmitByte(" ")

    if(rtc.clockMeridiemTime)
      com.transmitString(string("PM", _newLineCharacter))
    else
      com.transmitString(string("AM", _newLineCharacter))

    abort false

PRI programTime(stringPointer) | time[6]

  ifnot(str.stringCompareCI(string("time"), stringPointer))
    com.transmitString(string("Please enter the exact time,", _newLineCharacter))

    time := str.decimalToInteger(shellLine(string("Year (2000 - 2127): ")))
    time[1] := str.decimalToInteger(shellLine(string("Month (1 - 12): ")))
    time[2] := str.decimalToInteger(shellLine(string("Date (1 - 31): ")))
    time[3] := str.decimalToInteger(shellLine(string("Day (1 - 7): ")))
    time[4] := str.decimalToInteger(shellLine(string("Hours (0 - 23): ")))
    time[5] := str.decimalToInteger(shellLine(string("Minutes (0 - 59): ")))
    ifnot(rtc.writeTime(str.decimalToInteger(shellLine(string("Seconds (0 - 59): "))), {
                       } time[5], {
                       } time[4], {
                       } time[3], {
                       } time[2], {
                       } time[1], {
                       } time))
      abort string("Operation Failed", _newLineCharacter)

    com.transmitByte(_newLineCharacter)
    programDate(string("date"))
    com.transmitString(string(_newLineCharacter, "Operation Successful", _newLineCharacter))
    abort false

PRI programRamSet(stringPointer)

  ifnot(str.stringCompareCI(string("set"), stringPointer))
    result := rtc.writeSRAM(str.decimalToInteger(str.tokenizeString(0)), str.decimalToInteger(str.tokenizeString(0)))

    stringPointer := string("Failure!", _newLineCharacter)
    if(result)
      stringPointer := string("Success!", _newLineCharacter)

    com.transmitString(stringPointer)
    abort false

PRI programRamGet(stringPointer)

  ifnot(str.stringCompareCI(string("get"), stringPointer))
    com.transmitString(1 + str.integerToDecimal(rtc.readSRAM(str.decimalToInteger(str.tokenizeString(0))), 3))
    com.transmitByte(_newLineCharacter)
    abort false

PRI programSQW(stringPointer)

  ifnot(str.stringCompareCI(string("sqw"), stringPointer))
    result := rtc.clockSquareWaveOut(str.decimalToInteger(str.tokenizeString(0)) & 1, 1)

    stringPointer := string("Failure!", _newLineCharacter)
    if(result)
      stringPointer := string("Success!", _newLineCharacter)

    com.transmitString(stringPointer)
    abort false

PRI programOUT(stringPointer)

  ifnot(str.stringCompareCI(string("out"), stringPointer))
    result := rtc.clockSquareWaveOut(0, ((str.decimalToInteger(str.tokenizeString(0)) & 1) << 1))

    stringPointer := string("Failure!", _newLineCharacter)
    if(result)
      stringPointer := string("Success!", _newLineCharacter)

    com.transmitString(stringPointer)
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