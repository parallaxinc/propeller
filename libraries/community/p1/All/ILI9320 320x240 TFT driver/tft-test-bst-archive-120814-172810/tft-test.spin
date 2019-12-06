{{
////////////////////////////////////////////////////////////////////////////////////////////
//                  tft-test.spin
// Test the ILI9320.spin driver

// Author: Mark Tillotson
// Updated: 2012-08-14
// Designed For: P8X32A
// Version: 1.0

// Tested on TechToys 2.4 TFT Colour LCD Module TY240-240320-B0 (rev 1B)
//    http://www.techtoys.com.hk/Displays/TY240240320/TY240240320.htm
// Purchased from SKPang:
//    http://www.skpang.co.uk/catalog/24-tft-colour-lcd-module-p-267.html

// Update History:

// v1.0 - Initial version 2012-08-14

////////////////////////////////////////////////////////////////////////////////////////////
}}

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000


  nWR = 8
  nRD = 9
  nCS = 10
  RS  = 11
  nRES = 12
  backLight = 13

  VIDGP = 2

OBJ

  disp: "ILI9320"



PUB Main | i, j

  disp.Start (nRES, nCS, RS, nWR, nRD, backLight, VIDGP)
  repeat
    disp.SetColours ($0, $F800)
    disp.ClearScreen
    waitcnt (cnt+100_000_000)
    repeat j from $ffff to 0 step $2000
      repeat i from 0 to 115 step 1
        disp.SetColours ($0000+i*$840, $001F)
        disp.DrawRect (i, i, 319-i, 239-i)
      waitcnt (cnt + 40_000_000)
      repeat i from 0 to 63
        disp.SetColours (j+56*(i>>1), $001F)
        disp.DrawRect (i*3, 17+i*2, i*3+100, 50+i*2)
      waitcnt (cnt + 40_000_000)
      disp.SetColours ($F81F, $E)
      disp.ClearScreen
      disp.DrawString (0, 0, @stringy)
      disp.DrawStringSmall (0, 100, @stringy)
      repeat i from 0 to 319 step 5
        disp.SetColours ($F000+$12*i, $E)
        disp.DrawLine (i, 0, 320-i, 239)
      waitcnt (cnt + 80_000_000)
      disp.SetColours ($FFFF, $0)
      repeat i from 0 to 239 step 5
        disp.DrawDot (270, i)
      repeat i from 0 to 239
        disp.DrawCharSmall ((i & 15)*10, (i >> 4)* 16, i)
      waitcnt (cnt + 80_000_000)
      disp.SetColours ($0, $FFFF)
      repeat i from 0 to 63
        disp.DrawChar (170+(i & 7)*18, (i >> 3)* 32, i+$20)
      waitcnt (cnt + 80_000_000)
      disp.SetColours ($FFE0, $0010)
      repeat i from 0 to 63
        disp.DrawChar (170+(i & 7)*18, (i >> 3)* 32, i+$40)
      waitcnt (cnt + 80_000_000)
      disp.SetColours ($F800, $07F0)
      repeat i from 0 to 14
        disp.DrawStringSmall (0, i<<4, @stringy2)
      waitcnt (cnt + 80_000_000)

DAT
stringy       byte  "Test string",0
stringy2      byte  "The quick brown fox jumps over the lazy ",0

{{
////////////////////////////////////////////////////////////////////////////////////////////
//                                TERMS OF USE: MIT License
////////////////////////////////////////////////////////////////////////////////////////////
// Permission is hereby granted, free of charge, to any person obtaining a copy of this 
// software and associated documentation files (the "Software"), to deal in the Software 
// without restriction, including without limitation the rights to use, copy, modify, merge,
// publish, distribute, sublicense, and/or sell copies of the Software, and to permit 
// persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
// PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
// FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
// DEALINGS IN THE SOFTWARE.
////////////////////////////////////////////////////////////////////////////////////////////
}}
