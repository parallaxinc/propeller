{{
////////////////////////////////////////////////////////////////////////////////////////////
//                  encoder-test.spin

// Example test file for quadrature encoder library "encoder"

// Author: Mark Tillotson
// Updated: 2014-03-20
// Designed For: P8X32A

////////////////////////////////////////////////////////////////////////////////////////////
}}

CON
  _clkmode = XTAL1 + PLL16X
  _xinfreq = 5_000_000
  propTX  = 30
  propRX  = 31
  baudrate = 115_200

  APIN = 16    ' pins to use for outputting test signal
  BPIN = 17  

OBJ
  debug: "SerialMirror"  ' debug port
  fmt: "Format"          ' Format object

  enc :  "encoder"       ' The encoder library being tested/demonstrated

VAR
  byte sbuf [100]        ' buffer to assemble output strings for Format

  byte pins [enc#NCHANS * 2]          ' pin number byte vector



PUB Main | i, channel, counteraddr, erroraddr
  ' default to inactive channel
  repeat i from 0 to enc#NCHANS * 2 - 1
    pins [i] := $FF


  debug.start (propRX, propTX, 0, baudrate)

  ' channel 0 uses pins P0/P8, channel 1 pins P1/P9, etc
  repeat channel from 0 to enc#NCHANS-1
    pins [channel*2]   := channel
    pins [channel*2+1] := channel+8


  dira [APIN]~~        ' Use test pins to generate AB quadrature signal to connect back to the inputs
  dira [BPIN]~~

  enc.Start (@pins)
  counteraddr := enc.getCounters
  erroraddr := enc.getErrorCounters

  repeat
      waitcnt (CNT + clkfreq/2)

      fmt.sprintf (@sbuf, string ("counts: "), 0)
      debug.str (@sbuf)
      fmt.sprintf (@sbuf, string ("%i, "), long [counteraddr][0])  ' direct access
      debug.str (@sbuf)
      fmt.sprintf (@sbuf, string ("%i, "), enc.count (1))  ' method access
      debug.str (@sbuf)
      fmt.sprintf (@sbuf, string ("%i, "), enc.count (2))
      debug.str (@sbuf)
      fmt.sprintf (@sbuf, string ("%i    "), enc.count (3))
      debug.str (@sbuf)
      fmt.sprintf (@sbuf, string ("errors: "), 0)
      debug.str (@sbuf)
      fmt.sprintf (@sbuf, string ("%i, "), long [erroraddr] [0])  ' direct access
      debug.str (@sbuf)
      fmt.sprintf (@sbuf, string ("%i, "), enc.errorCount (1))   ' method access
      debug.str (@sbuf)
      fmt.sprintf (@sbuf, string ("%i, "), enc.errorCount (2))
      debug.str (@sbuf)
      fmt.sprintf (@sbuf, string ("%i"), enc.errorCount (3))
      debug.str (@sbuf)
      debug.tx (10)

      repeat 10000   ' test AB signal
        outa [APIN]~~
        outa [BPIN]~~
        outa [APIN]~
        outa [BPIN]~    ' loop sends 10000 pulses, ie 40000 counts.

 
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
