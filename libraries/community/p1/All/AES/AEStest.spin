{{
////////////////////////////////////////////////////////////////////////////////////////////
//                  AEStest.spin

// Example test file for AES implementation, 128/192/256 bit keys, ECB mode and CBC mode.

// Author: Mark Tillotson
// Updated: 2012-01-27
// Designed For: P8X32A

// Has various tests for producing results files for the Known Answer Tests for the
// Advanced Encryption Standard.  Specifically ECB varying key and ECB varying plaintext
// for 128, 192 and 256 bit keys.
//    Also Monte Carlo test for 128 key size only.

// For official Known Answer Test files see ( http://csrc.nist.gov/groups/STM/cavp/ )

// Shows how to call and use the AES.spin object.

////////////////////////////////////////////////////////////////////////////////////////////
}}

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  propTX  = 30 'programming output
  propRX  = 31 'programming input
  baudrate = 115_200


OBJ
  Clock : "Clock"        
  debug: "SerialMirror"   ' Used for outputing results
  fmt: "Format"           ' Used for outputing results

  aes: "AES"              ' The AES object under test

VAR
  byte buffer[180] 'buffer to assemble output strings
  long bpos

  long nn
  long ii
  long jj

  long plaintext [4*4]
  long ciphertext [4*4]
  byte thekey [32]
  long initvec [4]
  long check [4]
  long before
  long after

PUB Main
  Clock.init (5_000_000)          ' 5MHz crystal
  Clock.setclock (XTAL1 + PLL16X) ' Set clock to standard 80MHz clock speed

  debug.start (propRX, propTX, 0, baudrate) 
  sprinln (string("Starting..."),0) ' announce started up

  repeat nn from 0 to 31
    thekey[nn] := $00
  repeat nn from 0 to 15
    plaintext[nn] := $00
    ciphertext[nn] := $22
  repeat nn from 0 to 3
    initvec[nn] := 0
    check[nn] := $33
  thekey [0] := $80

  before := cnt
  aes.Start
  after := cnt
  sprinln (string ("aes.Start took %ius"), (after-before)/80)

  before := cnt
  aes.SetKey (128, @thekey)
  after := cnt
  sprinln (string ("aes.SetKey took %ius"), (after-before)/80)
  prinarr (@thekey, 8, string ("key    = "))

  before := cnt
  aes.CBCEncrypt (@plaintext, @ciphertext, 4, @initvec)
  after := cnt
  sprinln (string ("aes.CBCEncrypt took %ius"), (after-before)/80)
  prinarr (@initvec, 4, string("IV     = "))
  prinarr (@plaintext, 16, string("plain  = "))
  prinarr (@ciphertext, 16, string("cipher = "))

  repeat nn from 0 to 3
    initvec[nn] := 0
  repeat nn from 0 to 15
    plaintext[nn] := $AA

  before := cnt
  aes.CBCDecrypt (@ciphertext, @plaintext, 4, @initvec)
  after := cnt
  sprinln (string ("aes.CBCDecrypt took %ius"), (after-before)/80)
  prinarr (@initvec, 4, string("IV     = "))
  prinarr (@ciphertext, 16, string("cipher = "))
  prinarr (@plaintext, 16, string("plain  = "))


  before := cnt
  aes.ECBEncrypt (@plaintext, @ciphertext)
  after := cnt
  sprinln (string ("aes.ECBEncrypt took %ius"), (after-before)/80)
  prinarr (@plaintext, 4, string("plain  = "))
  prinarr (@ciphertext, 4, string("cipher = "))

  before := cnt
  aes.ECBDecrypt (@ciphertext, @check)
  after := cnt
  sprinln (string ("aes.ECBDecrypt took %ius"), (after-before)/80)
  prinarr (@ciphertext, 4, string("cipher = "))
  prinarr (@check, 4, string("check  = "))

  ' run all the tests, voluminous output
  VaryKey(128)
  VaryKey(192)
  VaryKey(256)
  VaryPlain(128)
  VaryPlain(192)
  VaryPlain(256)
  MonteCarlo(128)  ' this one takes about 33 seconds, note.

  sprinln (string("Done"),cnt)
  repeat


PRI MonteCarlo(bits)
  aes.ScrubState
  debug.tx(10)
  sprin (string("Monte Carlo %i"), bits)
  sprinln (string(" bits"), 0)
  debug.tx(10)
  CopyBlock (@plaintext, @monteplain)
  CopyBlock (@thekey, @montekey)
  repeat ii from 0 to 99
    sprinln (string("COUNT = %i"), ii)
    prinarr (@thekey, bits>>5, string("KEY = "))
    prinarr (@plaintext, 4, string("PLAINTEXT = "))
    aes.ScrubState
    aes.SetKey (bits, @thekey)
    repeat jj from 0 to 999
      aes.ECBEncrypt (@plaintext, @ciphertext)
      CopyBlock (@plaintext, @ciphertext)

    prinarr (@ciphertext, 4, string("CIPHERTEXT = "))
    debug.tx(10)
    if bits == 128
      XorBlock (@thekey, @ciphertext)

PRI CopyBlock(toa, froma)
  repeat nn from 0 to 3
    long[toa][nn] := long[froma][nn]


PRI XorBlock(toa, froma)
  repeat nn from 0 to 3
    long[toa][nn] := long[toa][nn] ^ long[froma][nn]


PRI VaryPlain(bits)
  sprin (string ("ECB Varying Plaintext %i"), bits)
  sprinln (string(" bits"), 0)
  repeat nn from 0 to 31
    thekey[nn] := 0
  aes.SetKey (bits, @thekey)
  repeat ii from 1 to 128
    debug.tx (10)
    setbits (@plaintext, 128, ii)
    sprinln (string ("COUNT = %i"), ii-1)
    prinarr (@thekey, bits>>5, string("KEY = "))
    aes.ECBEncrypt (@plaintext, @ciphertext)
    prinarr (@plaintext, 4, string("PLAINTEXT = "))
    prinarr (@ciphertext, 4, string("CIPHERTEXT = "))
  debug.tx (10)
  debug.tx (10)

PRI VaryKey(bits)
  sprin (string ("ECB Varying Key %i"), bits)
  sprinln (string(" bits"), 0)
  repeat nn from 0 to 3
    plaintext[nn] := 0

  repeat ii from 1 to bits
    debug.tx (10)
    setbits (@thekey, bits, ii)
    aes.SetKey (bits, @thekey)
    sprinln (string ("COUNT = %i"), ii-1)
    prinarr (@thekey, bits>>5, string("KEY = "))
    aes.ECBEncrypt (@plaintext, @ciphertext)
    prinarr (@plaintext, 4, string("PLAINTEXT = "))
    prinarr (@ciphertext, 4, string("CIPHERTEXT = "))
  debug.tx (10)
  debug.tx (10)



PRI setbits(arr, maxbits, bits) | jjj
  repeat nn from 0 to (maxbits-1)>>3
    byte [arr][nn] := 0
  jjj := bits >> 3
  repeat nn from 0 to jjj-1
    byte[arr][nn] := $FF
  byte [arr][jjj] := $FF << (1+((128+7-bits) & 7))



PRI sprin(fmtstr, fmtarg)
  fmt.sprintf (@buffer, fmtstr, fmtarg)
  debug.str (@buffer)

PRI sprinln(fmtstr, fmtarg)
  fmt.sprintf (@buffer, fmtstr, fmtarg)
  debug.str (@buffer)
  debug.tx (10)

PRI prin(fmtstr)
  fmt.sprintf (@buffer, fmtstr, 0)
  debug.str (@buffer)

PRI prinarr (arr, size, name) | kk
  debug.str (name)
  repeat kk from 0 to size-1
    prinw (long[arr][kk])
  debug.tx (10)


PRI prinw (val) | kk
  bpos := 0
  repeat kk from 0 to 3
    prinb (val & $FF)
    val := val >> 8
  buffer[bpos] := 0
  debug.str (@buffer)

PRI prinb (val)
  buffer [bpos++] := hex [(val >> 4) & $F]
  buffer [bpos++] := hex [val & $F]

DAT

hex           byte $30
              byte $31
              byte $32
              byte $33
              byte $34
              byte $35
              byte $36
              byte $37
              byte $38
              byte $39
              byte $61
              byte $62
              byte $63
              byte $64
              byte $65
              byte $66

monteplain    byte $b9, $14, $5a, $76, $8b, $7d, $c4, $89, $a0, $96, $b5, $46, $f4, $3b, $23, $1f

montekey      byte $13, $9a, $35, $42, $2f, $1d, $61, $de, $3c, $91, $78, $7f, $e0, $50, $7a, $fd


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
