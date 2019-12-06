{{
////////////////////////////////////////////////////////////////////////////////////////////
//                  ILI9341-test.spin
// Test the ILI9341-spi.spin driver

// Author: Mark Tillotson
// Updated: 2013-11-16
// Designed For: P8X32A
// Version: 1.0

// Tested eBay 2.2" 320x240 TFT module using ILI9341 SPI driver.
// for instance: 
//    http://www.ebay.co.uk/itm/1PC-22-Inch-SPI-TFT-LCD-Serial-Port-Module-Display-ILI9341-5V33V-New-/380708838265

// Update History:

// v1.0 - Initial version 2013-11-16

////////////////////////////////////////////////////////////////////////////////////////////
}}

CON
  _CLKMODE = XTAL1 + PLL16X
  _XINFREQ = 5_000_000

  propTX  = 30 'programming output
  propRX  = 31 'programming input
  baudrate = 115_200

  nRESET= 22
  RS    = 23
  nCS   = 24
  MOSI  = 25
  SCLK  = 27
  MISO  = 26

OBJ
  disp  : "ILI9341-spi"

VAR
  BYTE buffer[100] 'buffer to assemble output strings

PUB Main | i, j, k

  disp.Start (nRESET, nCS, RS, MOSI, SCLK)

  repeat
    {
    disp.SetColours ($0, $F800)
    disp.ClearScreen
    repeat 10
      repeat j from 0 to 240-32 step 32
        k := INA & $3FFFFF
        repeat i from 0 to 22-1
          disp.DrawChar (i*14, j, ((k>>i)&1)+"0")
    }
    disp.SetColours ($0, $0F800)
    disp.ClearScreen
    repeat i from 0 to 115 step 3
      disp.SetColours ($0000+i*$0842, $001F)
      disp.DrawRect (40+i, i, 279-i, 239-i)
    waitcnt (cnt + clkfreq/2)
    repeat i from 0 to 63
      disp.SetColours (j+56*(i>>1), $001F)
      disp.DrawRect (i*3, 17+i*2, i*3+100, 50+i*2)
    waitcnt (cnt + clkfreq/2)
    disp.SetColours ($F81F, $E)
    disp.ClearScreen
    disp.DrawString (0, 0, @stringy)
    disp.DrawStringSmall (0, 100, @stringy)
    repeat i from 0 to 319 step 5
      disp.SetColours ($F000+$12*i, $E)
      disp.DrawLine (i, 0, 319-i, 239)
    waitcnt (cnt + clkfreq/2)
    disp.SetColours ($FFFF, $0)
    repeat i from 0 to 239 step 5
      disp.DrawDot (270, i)
    repeat i from 0 to 239
      disp.DrawCharSmall ((i & 15)*10, (i >> 4)* 16, i)
    waitcnt (cnt + clkfreq/2)
    disp.SetColours ($0, $FFFF)
    repeat i from 0 to 63
      disp.DrawChar (170+(i & 7)*18, (i >> 3)* 32, i+$20)
    waitcnt (cnt + clkfreq/2)
    disp.SetColours ($FFE0, $0010)
    repeat i from 0 to 63
      disp.DrawChar (170+(i & 7)*18, (i >> 3)* 32, i+$40)
    waitcnt (cnt + clkfreq/2)
    disp.SetColours ($F800, $07F0)
    repeat i from 0 to 14
      disp.DrawStringSmall (0, i<<4, @stringy2)
    waitcnt (cnt + clkfreq)

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
