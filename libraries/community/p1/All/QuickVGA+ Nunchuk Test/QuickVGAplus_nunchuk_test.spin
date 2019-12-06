'' =================================================================================================
''
''   File....... QuickVGAplus_nunchuk_test.spin
''   Purpose.... Updates jm_nunchuk_test_v3 to work with
''               QuickVGA+ board's nunchuk pinout, and
''               uses onboard VGA display in place of serial
''               terminal.
''
''               Also displays additional information about the
''               nunchuk's state.
''
''   Author..... Mark Graybill (aka saundby)
''               based on jm_nunchuk_test_v3
''               and uses jm_nunchuk_ez_v3 by
''               Jon "JonnyMac" McPhalen (aka Jon Williams)
''               jon@jonmcphalen.term
''               Copyright (c) 2011 Jon McPhalen
''               -- see below for terms of use
''   E-mail..... saundby@saundby.com
''   Started.... 06 MAR 2011
''   Updated.... 19 JUN 2012
''
'' =================================================================================================

'Null Values
' null (unactivated or midrange) values for joystick are about 120-130.
' null values for the accelerometers are about 500 ("flat" for that axis.)


con

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000                                          ' use 5MHz crystal
' _xinfreq = 6_250_000                                          ' use 6.25MHz crystal

  CLK_FREQ = ((_clkmode - xtal1) >> 6) * _xinfreq
  MS_001   = CLK_FREQ / 1_000
  US_001   = CLK_FREQ / 1_000_000


con

  RX1 = 31
  TX1 = 30
  SDA = 25           ' nunchuk controller pins used on GadgetGangster QuickVGA+
  SCL = 24

VAR
  ' Some tracking values to see what the controller is up to.
  byte MaxJX, MinJX, MaxJY, MinJY   'Joystick min and max values.
  word MaxAX, MinAX, MaxAY, MinAY, MaxAZ, MinAZ   'Accel min and max values.
  
obj

  wii  : "jm_nunchuk_ez_v3"                             ' polls Wii nunchuk
  term : "VGA_Text"                                     ' for VGA terminal output


pub main | idx, t

  wii.init(SCL, SDA)                                    ' setup Wii on EE pins
  term.start(16)                                        ' start VGA terminal , pin 16
  pause(1)

  term.out($00)
  term.str(string("Nunchuk Demo", $0D, "-- manual scan", $0D, "-- id: "))

  repeat idx from 0 to 5
    term.hex(byte[wii.idpntr][idx], 2)
    term.out(" ")
  
  ' Set initial values for mins and maxes.
  MaxJX := 130
  MinJX := 120
  MaxJY := 130
  MinJY := 120
  MaxAX := MinAX := 500
  MaxAY := MinAY := 500
  MaxAZ := MinAZ := 500
  
  t := cnt
  repeat
    wii.scan                                                    ' scan Wii nunchuk
    term.str(string($0B, $03, $0A, $01))                      ' position for report 
    term.out($0D)

    ' Read and display values/info for Joystick X direction.
    if wii.joyx > MaxJX   ' See if we have a new max value.
      MaxJX := wii.joyx
    if wii.joyx < MinJX   ' See if we have a new min value.
      MinJX := wii.joyx
    term.str(string("Joy X:"))
    term.dec(wii.joyx)
    term.str(string("  Min:"))
    term.dec(MinJX)
    term.str(string("  Max:"))
    term.dec(MaxJX)
    if MaxJX-wii.joyx<20 AND MaxJX>130  ' If we're near max, show right arrow.
      term.out($03)
    elseif wii.joyx-MinJX<20 AND MinJX<120  ' If we're near min, show left arrow.
      term.out($02)
    else                       ' Otherwise show nothing.
      term.out($20)
    term.str(string("   ",$0D))
    
    'Read and display values for Joystick Y direction.
    if wii.joyy > MaxJY   ' See if we have a new max value.
      MaxJY := wii.joyy
    if wii.joyy < MinJY   ' See if we have a new min value.
      MinJY := wii.joyy
    term.str(string("Joy Y:"))
    term.dec(wii.joyy)
    term.str(string("  Min:"))
    term.dec(MinJY)
    term.str(string("  Max:"))
    term.dec(MaxJY)
    if MaxJY-wii.joyy<20 AND MaxJY>130   ' If we're near max, show up arrow.
      term.out($04)
    elseif wii.joyy-MinJY<20 AND MinJY<120  ' If we're near min, show left arrow.
      term.out($05)
    else                       ' Otherwise show nothing.
      term.out($20)
    term.str(string("   ",$0D))


    'Read and display values for X Axis Accelerometer
    if wii.accx > MaxAX   ' See if we have a new max value.
      MaxAX := wii.accx
    if wii.accx < MinAX   ' See if we have a new min value.
      MinAX := wii.accx
    term.str(string("Acc X:"))
    term.dec(wii.accx)
    term.str(string(" Min:"))
    term.dec(MinAX)
    term.str(string(" Max:"))
    term.dec(MaxAX)
    if wii.accx < 450       ' If we're near tipped left, show left slant.
      term.out($2F)
    elseif wii.accx > 550   ' If we're tipped right, show right slant.
      term.out($5C)
    else                    ' Otherwise show flat bar.
      term.out($2D)
    term.str(string($20,"  ",$0D))

    'Read and display values for Y Axis Accelerometer
    if wii.accy > MaxAY   ' See if we have a new max value.
      MaxAY := wii.accy
    if wii.accy < MinAY   ' See if we have a new min value.
      MinAY := wii.accy
    term.str(string("Acc Y:"))
    term.dec(wii.accy)
    term.str(string(" Min:"))
    term.dec(MinAY)
    term.str(string(" Max:"))
    term.dec(MaxAY)
    if wii.accy < 450       ' If we're near tipped back, show up arrow.
      term.out($A0)
    elseif wii.accy > 550   ' If we're tipped forward, show down arrow.
      term.out($A2)
    else                    ' Otherwise show flat bar.
      term.out($2D)
    term.str(string($20,"  ",$0D))

    'Read and display values for Z Axis Accelerometer
    if wii.accz > MaxAZ   ' See if we have a new max value.
      MaxAZ := wii.accz
    if wii.accz < MinAZ   ' See if we have a new min value.
      MinAZ := wii.accz
    term.str(string("Acc Z:"))
    term.dec(wii.accz)
    term.str(string(" Min:"))
    term.dec(MinAZ)
    term.str(string(" Max:"))
    term.dec(MaxAZ)
    if wii.accz < 450       ' If we're inverted (negative gees), show 'v'.
      term.out($76)
    elseif wii.accz > 550   ' If we're upright (positive gees), show caret.
      term.out($5E)
    else                    ' Otherwise show flat bar.
      term.out($2D)
    term.str(string($20,"  ",$0D))

    term.str(string("Btns.... "))
    term.out(wii.btnz + "0")
    term.out(wii.btnc + "0")
    if wii.btnz AND wii.btnc
      term.str(string(" Both buttons "))
    elseif wii.btnz
      term.str(string(" Small button"))
    elseif wii.btnc
      term.str(string(" Large button"))
    else
      term.str(string("             "))
      
    term.out($01) ' Home display
    
    waitcnt(t += constant(100 * MS_001)) 

 
pub pause(ms) | t

'' Delay program ms milliseconds

  t := cnt - 1088                                            ' sync with system counter
  repeat (ms #> 0)                                           ' delay must be > 0
    waitcnt(t += MS_001)

       
dat

{{

  Terms of Use: MIT License

  Permission is hereby granted, free of charge, to any person obtaining a copy of this
  software and associated documentation files (the "Software"), to deal in the Software
  without restriction, including without limitation the rights to use, copy, modify,
  merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to the following
  conditions:

  The above copyright notice and this permission notice shall be included in all copies
  or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
  PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
  OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

}}