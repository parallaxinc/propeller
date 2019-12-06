{{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// VGA64 Bitmap Demo
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
  _linePoints = 4

  _horizontalResolution = 160
  _verticalResolution = 120

VAR

  word XPoints[_linePoints], YPoints[_linePoints], XPointsDir[_linePoints], YPointsDir[_linePoints]
  long displayBuffer[((_horizontalResolution * _verticalResolution) / 32) * 2]

OBJ

  bmp: "VGA64_BMPEngine.spin"

PUB demo | randomSeed, displayPointer, currentDisplay, extraCounter

  ifnot(bmp.BMPEngineStart(_pinGroup, 1, _horizontalResolution, _verticalResolution, @displayBuffer))
    reboot

  bmp.displayColor(0, bmp#black)
  bmp.displayColor(1, bmp#blue)

  randomSeed := cnt
  repeat result from 0 to constant(_linePoints - 1) step 1

    XPoints[result] := ((||(randomSeed?)) // _horizontalResolution)
    YPoints[result] := ((||(randomSeed?)) // _verticalResolution)

    XPointsDir[result] or= ((randomSeed?) & 1)
    YPointsDir[result] or= ((randomSeed?) & 1)

  displayPointer := constant((_horizontalResolution * _verticalResolution) / 32)
  repeat

    bmp.displayWait(1)
    bmp.displayPointer(@displayBuffer[displayPointer & currentDisplay])
    not currentDisplay
    bmp.displayClear(0, @displayBuffer[displayPointer & currentDisplay])

    repeat result from 0 to constant(_linePoints - 1) step 1

      repeat extraCounter from result to constant(_linePoints - 1) step 1

        line( XPoints[result], {
            } YPoints[result], {
            } XPoints[extraCounter // _linePoints], {
            } YPoints[extraCounter // _linePoints], {
            } 1, @displayBuffer[displayPointer & currentDisplay])

    repeat result from 0 to constant(_linePoints - 1) step 1

      XPointsDir[result] ^= ((XPoints[result] =< 0) ^ (XPoints[result] => constant(_horizontalResolution - 1)))
      XPoints[result] += ((XPointsDir[result]) | 1)

      YPointsDir[result] ^= ((YPoints[result] =< 0) ^ (YPoints[result] => constant(_verticalResolution - 1)))
      YPoints[result] += ((YPointsDir[result]) | 1)

PRI line(x0, y0, x1, y1, lineColor, displayBase) | deltaX, deltaY, x, y, loopError, loopStep

  result := ((||(y1 - y0)) > (||(x1 - x0)))

  if(result)
    swap(@x0, @y0)
    swap(@x1, @y1)

  if(x0 > x1)
    swap(@x0, @x1)
    swap(@y0, @y1)

  deltaX := (x1 - x0)
  deltaY := (||(y1 - y0))
  loopError := (deltax >> 1)
  loopStep := ((y0 => y1) | 1)

  y := y0
  repeat x from x0 to x1 step 1

    if(result)
      bmp.plotPixel(lineColor, y, x, displayBase)
    else
      bmp.plotPixel(lineColor, x, y, displayBase)

    loopError -= deltaY
    if(loopError < 0)
      y += loopStep
      loopError += deltaX

PRI swap(x, y)

  result := long[x]
  long[x] := long[y]
  long[y] := result

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