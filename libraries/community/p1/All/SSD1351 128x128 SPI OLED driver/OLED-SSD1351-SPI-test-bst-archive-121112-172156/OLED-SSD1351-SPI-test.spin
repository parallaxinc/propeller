{{
////////////////////////////////////////////////////////////////////////////////////////////
//                  OLED-SSD1351-SPI-test.spin
// Test the SSD1351.spin SPI driver

// Author: Mark Tillotson
// Updated: 2012-11-12
// Designed For: P8X32A
// Version: 1.0

// Update History:

// v1.0 - Initial version 2012-11-12

////////////////////////////////////////////////////////////////////////////////////////////
}}

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  nCS   = 10
  DC    = 11
  nRES  = 12
  power = 13
  SCLK  = 16
  MOSI  = 17

  DELAY = 40_000_000

OBJ

  disp: "SSD1351-SPI"



PUB Main | i, j, bright


  disp.Start (nRES, nCS, DC, SCLK, MOSI, power)
  repeat
    bright := 10
    disp.SetColours ($AAAA, $5555)
    'disp.ClearScreen
    repeat 'j from $ffff to 0 step $2000
      disp.Brightness (bright)

      disp.SetColours ($F800, $0)
      disp.DrawRect (0, 0, 127, 127)
      waitcnt (cnt + DELAY)
      disp.SetColours ($07E0, $0)
      disp.DrawRect (10, 10, 117, 117)
      waitcnt (cnt + DELAY)
      disp.SetColours ($001F, $0)
      disp.DrawRect (20, 20, 107, 107)
      waitcnt (cnt + DELAY)
      disp.SetColours ($FFFF, $0)
      disp.DrawRect (30, 30, 97, 97)
      waitcnt (cnt + DELAY)
      disp.SetColours ($8410, $0)
      disp.DrawRect (40, 40, 87, 87)
      waitcnt (cnt + DELAY)
      disp.SetColours ($0000, $0)
      disp.DrawRect (50, 50, 77, 77)
      waitcnt (cnt + DELAY)

      bright += 14
      if bright > 100
        bright := 100
      repeat i from 0 to 63 step 1
        disp.SetColours ($F000+i*$840, $001F)
        disp.DrawRect (i, i, 127-i, 127-i)

      waitcnt (cnt + 8_000_000)

      repeat i from 0 to 40
        disp.SetColours (j+56*(i>>1), $001F)
        disp.DrawRect (i*2, 17+i*2, i*2+40, 30+i*2)
      waitcnt (cnt + DELAY)

      disp.SetColours ($F81F, $E)
      disp.ClearScreen
      waitcnt (cnt + DELAY)

      disp.DrawString (0, 0, @stringy)
      disp.DrawStringSmall (0, 30, @stringy)

      repeat i from 0 to 127 step 5
        disp.SetColours ($F000+$12*i, $E)
        disp.DrawLine (i, 0, 127-i, 127)
      waitcnt (cnt + DELAY)

      disp.SetColours ($FFFF, $0)
      repeat i from 0 to 127 step 5
        disp.DrawDot (100, i)

      repeat i from 0 to 63
        disp.DrawCharSmall ((i & 7)*10, (i >> 3)* 16, i+32)
      waitcnt (cnt + DELAY)
      disp.SetColours ($0, $FFFF)
      repeat i from 0 to 31
        disp.DrawChar (170+(i & 7)*18, (i >> 3)* 32, i+$20)
      waitcnt (cnt + DELAY)
      disp.SetColours ($FFE0, $0010)
      repeat i from 0 to 31
        disp.DrawChar (170+(i & 7)*18, (i >> 3)* 32, i+$40)
      waitcnt (cnt + DELAY)
      disp.SetColours ($F800, $07F0)
      repeat i from 0 to 7
        disp.DrawStringSmall (0, i*16, @stringy2)
      waitcnt (cnt + DELAY)
      repeat i from 7 to 100 step 7
        disp.Brightness (i)
        waitcnt (cnt + 2500000)
      repeat i from 100 to 0 step 7
        disp.Brightness (i)
        waitcnt (cnt + 2500000)
      repeat i from 7 to 100 step 7
        disp.Brightness (i)
        waitcnt (cnt + 2500000)
      repeat i from 100 to 0 step 7
        disp.Brightness (i)
        waitcnt (cnt + 2500000)



DAT
stringy       byte  "Test",0
stringy2      byte  "Quick brown fox",0

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
