{{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// VGA64 6 Bits Per Pixel Demo
//
// Author: Kwabena W. Agyeman
// Updated: 11/18/2010
// Designed For: P8X32A
// Version: 1.0
//
// Copyright (c) 2010 Kwabena W. Agyeman
// See end of file for terms of use.
//
// Update History:
//
// v1.0 - Original release - 11/18/2010.
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
  _switchRate = 5

OBJ

  pix: "VGA64_PIXEngine.spin"

PUB demo

  ifnot(pix.PIXEngineStart(_pinGroup))
    reboot

  repeat

    repeat until(pix.displayRate(_switchRate) == true)

      pix.displayWait(2)
      pix.plotBox( pix.displayColor( ((||(cnt?)) // 4), ((||(cnt?)) // 4), ((||(cnt?)) // 4)), {
                 } ((||(cnt?)) // 160), ((||(cnt?)) // 120), ((||(cnt?)) // 160), ((||(cnt?)) // 120))

    repeat while(pix.displayRate(_switchRate) == true)
      pix.plotPixel( pix.displayColor( ((||(cnt?)) // 4), ((||(cnt?)) // 4), ((||(cnt?)) // 4)), {
                   } ((||(cnt?)) // 160), ((||(cnt?)) // 120))

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