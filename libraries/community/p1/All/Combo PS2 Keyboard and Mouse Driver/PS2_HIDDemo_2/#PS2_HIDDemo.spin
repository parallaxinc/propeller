{{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// PS2 HIDEngine Demo
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
// Run the program with the specified driver hardware.
//
// Nyamekye,
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}}

CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  _videoPinGroup = 2
  _keyboardLocks = 2

  _keyboardTypematicDelay = 2
  _keyboardTypematicRate = 3

  _mouseSampleRate = 3
  _mouseScaling = 1

  _keyboardClock = 27
  _keyboardData = 26
  _mouseClock = 25
  _mouseData = 24

OBJ

  tmp: "VGA64_TMPEngine.spin"
  tmpK: "VGA64_TMPEngine.spin"
  tmpM: "VGA64_TMPEngine.spin"
  hid: "PS2_HIDEngine.spin"
  str: "ASCII0_STREngine.spin"
  strK: "ASCII0_STREngine.spin"
  strM: "ASCII0_STREngine.spin"

VAR

  long keyboardPrinterStack[100]
  long mousePrinterStack[100]

PUB demo | x, y

  ifnot( tmp.TMPEngineStart(_videoPinGroup, hid.XPositionAddress, hid.YPositionAddress) and {
       } hid.HIDEngineStart(_keyboardClock, _keyboardData, _mouseClock, _mouseData, _keyboardLocks, 639, 479))
    reboot

  hid.keyboardConfiguration(_keyboardTypematicDelay, _keyboardTypematicRate)
  hid.mouseConfiguration(_mouseSampleRate, _mouseScaling)
  tmp.mouseCursorTile(tmp.displayCursor)
  tmp.mouseCursorColor(tmp#light_red)
  tmp.printCursorRate(5)
  tmp.printCursorColor(tmp#light_blue)
  cognew(keyboardPrinter, @keyboardPrinterStack)
  cognew(mousePrinter, @mousePrinterStack)

  repeat

    tmp.displayString(string("X: "), tmp#light_green, tmp#black, 0, 0)
    tmp.displayString(1 + str.integerToDecimal(hid.XPosition, 3), tmp#light_green, tmp#black, 0, 3)
    tmp.displayString(string("Y: "), tmp#light_green, tmp#black, 0, 7)
    tmp.displayString(1 + str.integerToDecimal(hid.YPosition, 3), tmp#light_green, tmp#black, 0, 10)
    tmp.displayString(string("Z: "), tmp#light_green, tmp#black, 0, 14)
    tmp.displayString(str.integerToDecimal(hid.ZPosition, 3), tmp#light_green, tmp#black, 0, 17)

    tmp.displayString(string("L: "), tmp#light_green, tmp#black, 0, 22)
    tmp.displayCharacter(("0" - hid.leftButton), tmp#light_green, tmp#black, 0, 25)
    tmp.displayString(string("R: "), tmp#light_green, tmp#black, 0, 27)
    tmp.displayCharacter(("0" - hid.rightButton), tmp#light_green, tmp#black, 0, 30)
    tmp.displayString(string("C: "), tmp#light_green, tmp#black, 0, 32)
    tmp.displayCharacter(("0" - hid.middleButton), tmp#light_green, tmp#black, 0, 35)

    if(hid.mouseReady)
      tmp.displayString(string(21, "M"),  tmp#light_green, tmp#black, 0, 37)

    else
      tmp.displayString(string(191, "M"),  tmp#light_green, tmp#black, 0, 37)

    if(hid.keyboardReady)
      tmp.displayString(string(21, "K"),  tmp#light_green, tmp#black, 6, 37)

    else
      tmp.displayString(string(191, "K"),  tmp#light_green, tmp#black, 6, 37)

    tmp.displayString(string("C:"), tmp#light_green, tmp#black, 6, 25)
    tmp.displayCharacter(("0" - hid.keyboardCapsLock), tmp#light_green, tmp#black, 6, 27)
    tmp.displayString(string("N:"), tmp#light_green, tmp#black, 6, 29)
    tmp.displayCharacter(("0" - hid.keyboardNumberLock), tmp#light_green, tmp#black, 6, 31)
    tmp.displayString(string("S:"), tmp#light_green, tmp#black, 6, 33)
    tmp.displayCharacter(("0" - hid.keyboardScrollLock), tmp#light_green, tmp#black, 6, 35)

    repeat y from 0 to 4 step 2
      repeat x from 0 to 39 step 1
        if((y == 4) and (x == 24))
          quit

        tmp.displayCharacter(15 + hid.keyboardButton(x + (20 * y)), tmp#light_green, tmp#black, y + 2, x)

PRI keyboardPrinter

  tmpK.printBoxColor(tmp#light_teal, tmp#black)
  tmpK.printBoxSize(8, 0, 29, 19)

  repeat
    result := hid.keyboardEvent
    if(hid.keyboardEventMakeOrBreak(result))

      if(hid.keyboardEventCharacter(result) == hid#Left_Arrow_Event)
        tmpK.printCharacter(tmp#cursor_left)

      elseif(hid.keyboardEventCharacter(result) == hid#Right_Arrow_Event)
        tmpK.printCharacter(tmp#cursor_right)

      elseif(hid.keyboardEventCharacter(result) == hid#Up_Arrow_Event)
        tmpK.printCharacter(tmp#cursor_up)

      elseif(hid.keyboardEventCharacter(result) == hid#Down_Arrow_Event)
        tmpK.printCharacter(tmp#cursor_down)

      elseif(hid.keyboardEventPrintable(result))
        tmpK.printCharacter(hid.keyboardEventCharacter(result))

PRI mousePrinter

  tmpM.printBoxColor(tmp#light_orange, tmp#black)
  tmpM.printBoxSize(8, 20, 29, 39)

  repeat
    result := hid.mouseEvent

    if(hid.mouseEventLeftPressed(result))
      tmpM.printString(string("L Pre @ X_"))
      tmpM.printString(1 + strM.integerToDecimal(hid.mouseEventXPosition(result), 3))
      tmpM.printString(string(" Y_"))
      tmpM.printString(1 + strM.integerToDecimal(hid.mouseEventYPosition(result), 3))
      tmpM.printString(string(tmp#carriage_return, tmp#line_feed))

    if(hid.mouseEventRightPressed(result))
      tmpM.printString(string("R Pre @ X_"))
      tmpM.printString(1 + strM.integerToDecimal(hid.mouseEventXPosition(result), 3))
      tmpM.printString(string(" Y_"))
      tmpM.printString(1 + strM.integerToDecimal(hid.mouseEventYPosition(result), 3))
      tmpM.printString(string(tmp#carriage_return, tmp#line_feed))

    if(hid.mouseEventMiddlePressed(result))
      tmpM.printString(string("M Pre @ X_"))
      tmpM.printString(1 + strM.integerToDecimal(hid.mouseEventXPosition(result), 3))
      tmpM.printString(string(" Y_"))
      tmpM.printString(1 + strM.integerToDecimal(hid.mouseEventYPosition(result), 3))
      tmpM.printString(string(tmp#carriage_return, tmp#line_feed))

    if(hid.mouseEventLeftReleased(result))
      tmpM.printString(string("L Rel @ X_"))
      tmpM.printString(1 + strM.integerToDecimal(hid.mouseEventXPosition(result), 3))
      tmpM.printString(string(" Y_"))
      tmpM.printString(1 + strM.integerToDecimal(hid.mouseEventYPosition(result), 3))
      tmpM.printString(string(tmp#carriage_return, tmp#line_feed))

    if(hid.mouseEventRightReleased(result))
      tmpM.printString(string("R Rel @ X_"))
      tmpM.printString(1 + strM.integerToDecimal(hid.mouseEventXPosition(result), 3))
      tmpM.printString(string(" Y_"))
      tmpM.printString(1 + strM.integerToDecimal(hid.mouseEventYPosition(result), 3))
      tmpM.printString(string(tmp#carriage_return, tmp#line_feed))

    if(hid.mouseEventMiddleReleased(result))
      tmpM.printString(string("M Rel @ X_"))
      tmpM.printString(1 + strM.integerToDecimal(hid.mouseEventXPosition(result), 3))
      tmpM.printString(string(" Y_"))
      tmpM.printString(1 + strM.integerToDecimal(hid.mouseEventYPosition(result), 3))
      tmpM.printString(string(tmp#carriage_return, tmp#line_feed))

    if(hid.mouseEventXMovement(result))
      tmpM.printString(string("Move to X_"))
      tmpM.printString(1 + strM.integerToDecimal(hid.mouseEventXPosition(result), 3))
      tmpM.printString(string(" Y_"))
      tmpM.printString(1 + strM.integerToDecimal(hid.mouseEventYPosition(result), 3))
      tmpM.printString(string(tmp#carriage_return, tmp#line_feed))

    if(hid.mouseEventYMovement(result))
      tmpM.printString(string("Move to X_"))
      tmpM.printString(1 + strM.integerToDecimal(hid.mouseEventXPosition(result), 3))
      tmpM.printString(string(" Y_"))
      tmpM.printString(1 + strM.integerToDecimal(hid.mouseEventYPosition(result), 3))
      tmpM.printString(string(tmp#carriage_return, tmp#line_feed))

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