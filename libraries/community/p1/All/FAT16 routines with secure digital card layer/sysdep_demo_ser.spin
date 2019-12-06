{{
   fsrw Copyright 2009  Tomas Rokicki and Jonathan Dummer

   See end of file for terms of use.

   This object contains the system dependencies.  This
   includes stdin (maybe keyboard, maybe serial),
   stdout (may serial, maybe tvtext, maybe vga) and
   information on where the SD card is attached.  It
   defines rx (input), tx, dec, and str (output),
   sd_base and start methods.  It also defines clock
   speed.

   I use serial I/O and connect my SD card starting at
   pin 0 on a demo board.
}}
con
   _clkmode = xtal1 + pll16x
   _xinfreq = 5_000_000
   sd_DO = 0
   sd_CLK = 1
   sd_DI = 2
   sd_CS = 3
obj
   term : "FullDuplexSerial"   
{{
   This should start stdin and out, but *not* anything on the
   secure digital card.
}}
pub start
   term.start( 31, 30, 0, 115200 )
pub rx
   return term.rx
{{
   If you don't have an input device, this definition of rx will allow
   the test to run once, and only once.

var
   long testcounter
pub rx
   repeat while testcounter==1
   testcounter++
   return " "
}}
pub rxtime( t )
   return term.rxtime( t )
pub rxcheck
   return term.rxcheck
pub tx(a)
   return term.tx(a) ' this may be out in some objects
pub str(a)
   return term.str(a)
pub dec(a)
   return term.dec(a)
pub hex(a,d)
   return term.hex(a,d)
{{
'  Permission is hereby granted, free of charge, to any person obtaining
'  a copy of this software and associated documentation files
'  (the "Software"), to deal in the Software without restriction,
'  including without limitation the rights to use, copy, modify, merge,
'  publish, distribute, sublicense, and/or sell copies of the Software,
'  and to permit persons to whom the Software is furnished to do so,
'  subject to the following conditions:
'
'  The above copyright notice and this permission notice shall be included
'  in all copies or substantial portions of the Software.
'
'  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
'  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
'  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
'  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
'  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
'  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
'  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}}