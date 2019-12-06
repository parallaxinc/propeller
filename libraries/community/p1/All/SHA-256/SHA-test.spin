{{
////////////////////////////////////////////////////////////////////////////////////////////
//                  SHA-test.spin

// Example test file for SHA-256 implementation

// Author: Mark Tillotson
// Updated: 2012-02-03
// Designed For: P8X32A

// Shows how to call and use the SHA-256.spin object.

////////////////////////////////////////////////////////////////////////////////////////////
}}

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  propTX  = 30 'programming output
  propRX  = 31 'programming input
  baudrate = 115_200


  TESTSIZE = 5000
  TESTCOUNT = 205

OBJ
  Clock : "Clock"
  debug: "SerialMirror"  '//debug port
  fmt:   "Format"  '//Format object
  hash:  "SHA-256"

VAR
  BYTE buffer[180] 'buffer to assemble output strings


  byte  results[65]
  byte  bytes[TESTSIZE]

  long  i, j
  long  duration, millis, kBytes, byteCount

PUB Main
  Clock.init (5_000_000)
  Clock.setclock (XTAL1 + PLL16X) 'Set clock to really fast

  debug.start (propRX, propTX, 0, baudrate)
  sprinln (string("Starting..."),cnt)

  sprinln (string ("Start SHA, cog=%i"), hash.Start)

  ' test addByte
  hash.addByte ("a")
  hash.addByte ("b")
  hash.addByte ("c")
  hash.calcHashHex (@results)
  sprinln (string ("SHA-256 ('abc') = %s"), @results)

  ' double hash test
  hash.addByte ("a")
  hash.addByte ("b")
  hash.addByte ("c")
  hash.calcDoubleHashHex (@results)
  sprinln (string("SHA-256 (SHA-256 ('abc')) = %s"), @results)

  ' double hash test the boring way
  hash.addByte ("a")
  hash.addByte ("b")
  hash.addByte ("c")
  hash.calcHash (@results)
  hash.addByteVec (@results, 32)
  hash.calcHashHex (@results)
  sprinln (string("SHA-256 (SHA-256 ('abc')) = %s"), @results)

  ' test addByteVec
  hash.addByteVec (string ("abc"), 3)
  hash.calcHashHex (@results)
  sprinln (string ("SHA-256 ('abc') = %s"), @results)

  ' long string of spaces
  repeat i from 0 to TESTSIZE-1
    bytes[i] := " "

  duration := cnt
  repeat i from 0 to TESTCOUNT-1
    hash.addByteVec (@bytes, TESTSIZE-i) ' vary size of vector in call
  byteCount := hash.getByteCount   ' get byte count actually used
  hash.calcHashHex (@results)
  duration := cnt - duration

  sprinln (string ("doing %i space chars:"), byteCount)
  sprinln (string ("%s"), @results)
  millis := (duration+40000)/80000
  kBytes := (byteCount+512) >> 10
  sprin (string ("took %ims"), millis)
  sprinln (string (" - %i kB/s"), kBytes * 1000/millis)


  repeat i from 50 to 70
    sprin (string("doing %i spaces: "), i)
    hash.clearHash
    hash.addByteVec (@bytes, i)
    show_result_bin

  hash.Stop


  sprinln (string ("restart SHA, cog=%i"), hash.Start)
  hash.addByte ("a")
  hash.addByte ("b")
  hash.addByte ("c")
  hash.calcHashHex (@results)
  sprinln (string ("abc %s"), @results)
  hash.Stop




PRI show_result_bin
  hash.calcHash (@results)
  repeat j from 0 to 31
    sprin (string("%x"), (results[j] >> 4) & $F)
    sprin (string("%x"), results[j]  & $F)
    if (j & 3) == 3
      debug.tx (32)
  debug.tx(10)

PRI sprinln(fmtstr, fmtarg)
  fmt.sprintf (@buffer, fmtstr, fmtarg)
  debug.str (@buffer)
  debug.tx (10)

PRI sprin(fmtstr, fmtarg)
  fmt.sprintf (@buffer, fmtstr, fmtarg)
  debug.str (@buffer)



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
