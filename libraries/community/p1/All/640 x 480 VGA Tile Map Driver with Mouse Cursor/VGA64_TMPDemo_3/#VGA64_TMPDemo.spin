{{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// VGA64 Tilemap Demo
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

  _pinGroup = 2
  _startUpWait = 5

OBJ

  tmp: "VGA64_TMPEngine.spin"

VAR

  word XPos, YPos, XDir, YDir

PUB demo

  ifnot(tmp.TMPEngineStart(_pinGroup, @XPos, @YPos))
    reboot

  waitcnt((clkfreq * _startUpWait) + cnt)
  repeat

    tmp.display2DBox(tmp#white, 0, 0, 29, 39)
    tmp.displayString(string("Tile Map Driver Demo"), tmp#black, tmp#white, 14, 10)
    waitcnt((clkfreq * 5) + cnt)

    tmp.scrollString(string("By: Kwabena W. Agyeman"), 2, tmp#black, tmp#white, 14, 0, 39)
    waitcnt(clkfreq + cnt)

    repeat 600
      tmp.display2DBox(cnt?, ((||(cnt?)) // 30), ((||(cnt?)) // 40), ((||(cnt?)) // 30), ((||(cnt?)) // 40))
      tmp.display2DFrame(cnt?, ((||(cnt?)) // 30), ((||(cnt?)) // 40), ((||(cnt?)) // 30), ((||(cnt?)) // 40))

    tmp.display2DBox(tmp#white, 0, 0, 29, 39)
    tmp.displayString(string("Those were 2D Boxes!"), tmp#black, tmp#white, 14, 10)
    waitcnt((clkfreq * 5) + cnt)

    tmp.scrollString(string("Now for 3D Boxes"), 2, tmp#black, tmp#white, 14, 0, 39)
    waitcnt(clkfreq + cnt)

    repeat 600
      tmp.display3DBox(cnt?, cnt?, cnt?, ((||(cnt?)) // 30), ((||(cnt?)) // 40), ((||(cnt?)) // 30), ((||(cnt?)) // 40))
      tmp.display3DFrame(cnt?, cnt?, cnt?,  ((||(cnt?)) // 30), ((||(cnt?)) // 40), ((||(cnt?)) // 30), ((||(cnt?)) // 40))

    tmp.display2DBox(tmp#white, 0, 0, 29, 39)
    tmp.displayString(string("Text boxes now..."), tmp#black, tmp#white, 14, 11)
    waitcnt((clkfreq * 5) + cnt)

    repeat 600
      tmp.display2DTextBox(string("Hello World!"), cnt?, cnt?, ((||(cnt?)) // 30), ((||(cnt?)) // 40))
      tmp.display3DTextBox(string("Hello World!"), cnt?, cnt?, cnt?, cnt?, ((||(cnt?)) // 30), ((||(cnt?)) // 40))

    waitcnt(clkfreq + cnt)
    repeat 15
      tmp.scrollUp(1, cnt?, 0, 0, 14, 39)
      tmp.scrollDown(1, cnt?, 15, 0, 29, 39)
    waitcnt((clkfreq * 5) + cnt)

    tmp.display2DBox(tmp#white, 0, 0, 29, 39)
    tmp.displayString(string("That was arbitrary screen scrolling"), tmp#black, tmp#white, 14, 3)
    waitcnt((clkfreq * 5) + cnt)

    tmp.scrollString(string("Wait, I forgot something...             wait a sec..."), 2, tmp#black, tmp#white, 14, 0, 39)
    waitcnt(clkfreq + cnt)

    tmp.printBoxColor(tmp#black, tmp#white)
    tmp.printBoxSize(0, 0, 29, 39)
    tmp.printCursorColor(cnt?)
    tmp.printCursorRate(5)

    tmp.printString(string("Built in arbitrary size text box.", 13, 10, "That's what I was looking for!"))
    waitcnt((clkfreq * 2) + cnt)
    tmp.printString(string(13, 10, "And one more thing..."))
    waitcnt((clkfreq * 2) + cnt)
    tmp.printString(string(13, 10, "A pixel locked mouse cursor!"))

    XPos := ((||cnt?) // 640)
    YPos := ((||cnt?) // 480)
    tmp.mouseCursorColor(cnt?)
    tmp.mouseCursorTile(tmp.displayCursor)

    repeat 1_200
      waitcnt((clkfreq / 60) + cnt)

      XDir ^= ((XPos =< 0) ^ (XPos => 639))
      XPos += (XDir | 1)

      YDir ^= ((YPos =< 0) ^ (YPos => 479))
      YPos += (YDir | 1)

    tmp.mouseCursorTile(0)
    tmp.printCursorRate(0)

    tmp.display2DBox(tmp#white, 0, 0, 29, 39)
    tmp.displayString(string(7, " That is all folks! ", 6), tmp#black, tmp#white, 14, 9)
    waitcnt((clkfreq * 5) + cnt)

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