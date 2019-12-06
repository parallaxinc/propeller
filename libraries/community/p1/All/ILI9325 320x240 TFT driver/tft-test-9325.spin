{{
////////////////////////////////////////////////////////////////////////////////////////////
//                  tft-test-9325.spin
// Test the ILI9325.spin driver

// Author: Mark Tillotson
// Updated: 2012-09-17
// Designed For: P8X32A
// Version: 1.1

// Tested on cheap eBay 2.4" TFT ILI5325 module with touchscreen:
// http://www.ebay.co.uk/itm/2-4-TFT-LCD-Module-Display-Touch-Panel-PCB-adapter-akt-/180868037704?pt=UK_BOI_Electrical_Components_Supplies_ET&hash=item2a1c933c48

// Update History:

// v1.1 - Added XPT2046 touch screen chip support via a cobbled-together SPI driver of mine (not ideal I know)
        - added touch screen drawing to demo loop
        - see http://www.youtube.com/watch?v=zTDWFc4P4io
        - 2012-09-17
// v1.0 - Initial version 2012-09-14

////////////////////////////////////////////////////////////////////////////////////////////
}}

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

{
  propTX  = 30 'programming output
  propRX  = 31 'programming input
  baudrate = 115_200
}
  nWR = 8
  nRD = 9
  nCS = 10
  RS  = 11
  nRES = 12
  backLight = 13

  VIDGP = 2

  DELAY = 50_000_000

  SCLK_TOUCH = 7
  MISO_TOUCH = 6
  MOSI_TOUCH = 5
  CS_TOUCH =   4

OBJ
{
  debug:  "SerialMirror"		'//debug port
  fmt:    "Format"			'//Format object
}
  disp: "ILI9325"
  touch: "touchSPI"

VAR
  BYTE buffer[100] 'buffer to assemble output strings


PUB Main | i, j, k, temp, randy, lock, xx, yy, pres
{
  debug.start (propRX, propTX, 0, baudrate)
  fmt.sprintf (@buffer, string("ts = %i ."),cnt)
  debug.str (@buffer)
  debug.tx (10)
}
  lock := locknew
  touch.Start (SCLK_TOUCH, MISO_TOUCH, MOSI_TOUCH, CS_TOUCH, 100, lock)
  disp.Start (nRES, nCS, RS, nWR, nRD, backLight, VIDGP)
  repeat
    disp.SetColours ($0, $F800)
    disp.ClearScreen
    waitcnt (cnt+40_000_000)
    repeat j from $ffff to 0 step $2000
      repeat i from 0 to 115 step 3
        disp.SetColours ($0000+i*$840, $001F)
        disp.DrawRect (i, i, 319-i, 239-i)
      waitcnt (cnt + DELAY)

      disp.SetColours ($F800, $0841)
     ' disp.ClearScreen
      repeat i from 0 to $FFF
        waitcnt (cnt + 100_000)
        pres := touchPres
        xx := ((touchX * 380) >> 12) - 40
        yy := ((touchY * 270) >> 12) - 15

        if touchPres <> 0 and pres <> 0
          disp.SetColours ($FFFF-(pres-50), 0)
 	  disp.DrawRect (xx, yy, xx+4, yy+4)

      disp.SetColours ($F800, $0841)
      waitcnt (cnt + DELAY)

      randy := 1
      repeat i from 0 to $1FFF
        temp := randy ^ (randy << 2) ^ (randy << 6) ^ (randy << 7)
        randy := (randy << 1) | (temp >> 31)
        temp := randy ^ (randy << 2) ^ (randy << 6) ^ (randy << 7)
        randy := (randy << 1) | (temp >> 31)
        disp.drawLine (00 + (randy & $FF), 00 + ((randy >> 8) & $7F), 64 + ((randy >> 16) & $FF), 112 + ((randy >> 24) & $7F))
        disp.SetColours ($000F+(i>>6)*$861, $001F)
        'disp.SetColours (word [0][i & $FFF], $001F)

      waitcnt (cnt + DELAY)


      repeat i from 0 to 63
        disp.SetColours (j+56*(i>>1), $001F)
        disp.DrawRect (i*3, 17+i*2, i*3+100, 50+i*2)
      waitcnt (cnt + DELAY)

      disp.SetColours ($F81F, $E)
      disp.ClearScreen
      disp.DrawString (0, 0, @stringy)
      disp.DrawStringSmall (0, 100, @stringy)
      repeat i from 0 to 319 step 5
        disp.SetColours ($F000+$12*i, $E)
        disp.DrawLine (i, 0, 319-i, 239)
      waitcnt (cnt + DELAY)

      disp.SetColours ($FFFF, $0)
      repeat i from 0 to 239 step 5
        disp.DrawDot (270, i)
      repeat i from 0 to 239
        disp.DrawCharSmall ((i & 15)*10, (i >> 4)* 16, i)
      waitcnt (cnt + DELAY)

      disp.SetColours ($F800, $0000)
      disp.ClearScreen
      i := 0
      repeat k from 0 to $FFF
        disp.DrawCharSmall ((i & 31)*10, (i >> 5)* 16, byte[$8000][k])
        i ++
        if i => 480
          i := 0
          disp.ClearScreen
          waitcnt (cnt + 8_000_000)
      waitcnt (cnt + DELAY)

      disp.SetColours ($0, $FFFF)
      repeat i from 0 to 63
        disp.DrawChar (170+(i & 7)*18, (i >> 3)* 32, i+$20)
      waitcnt (cnt + DELAY)

      disp.SetColours ($FFE0, $0010)
      repeat i from 0 to 63
        disp.DrawChar (170+(i & 7)*18, (i >> 3)* 32, i+$40)
      waitcnt (cnt + DELAY)

      disp.SetColours ($FFE0, $001F)
      disp.ClearScreen
      i := 0
      repeat k from 0 to $FFE
        disp.DrawChar ((i & 15)*20, (i >> 4)* 32, byte[$8000][k])
        i ++
        if i => 128
          disp.SetColours ($FFE0+k, 0) '!($FFE0+k))
          disp.ClearScreen
          i := 0
          waitcnt (cnt + 8_000_000)
      waitcnt (cnt + DELAY)

      disp.SetColours ($F800, $07F0)
      repeat i from 0 to 14
        disp.DrawStringSmall (0, i<<4, @stringy2)
      waitcnt (cnt + DELAY)


PUB  touchX 
  return (touch.readWordReg ($90) >> 3) & $FFF

PUB  touchY
  return $FFF - ((touch.readWordReg ($D0) >> 3) & $FFF)

PUB  touchPres | z1, z2, x, pres
  z1 := (touch.readWordReg ($B0) >> 3) & $FFF
  z2 := (touch.readWordReg ($C0) >> 3) & $FFF
  x  := (touch.readWordReg ($D0) >> 3) & $FFF
  {
  fmt.sprintf (@buffer, string("z1=%x, "), z1)
  debug.str (@buffer)
  fmt.sprintf (@buffer, string("z2=%x, "), z2)
  debug.str (@buffer)
  }
  pres :=  100 * x * (z2 - z1) / ($1000 * z1)
  {
  fmt.sprintf (@buffer, string("pres=%x"), pres)
  debug.str (@buffer)
  debug.tx (10)
}
  return  pres


PRI  countbits (x, width)
  if x == 0
    return 0
  if x == 1
    return 1
  return countbits (x >> width, width >> 1) + countbits (x & ((1 << width) - 1), width >> 1)


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
