'
'   Copyright 2008   Radical Eye Software
'
'   See end of file for terms of use.
'
CON
        _clkmode        = xtal1 + pll16x
        _xinfreq        = 5_000_000
obj
   term: "tv_text"
   sdfat: "fsrw"
var
   byte tbuf[20]
   byte bigbuf[8192]
pub go | x
   x := \start
   term.str(string("Returned from start", 13))
   term.dec(x)
   term.out(13)
pub start | r, sta, bytes
   term.start(12)
   term.str(string("Mounting.", 13))        
   sdfat.mount(0)
   term.str(string("Mounted.", 13))
   term.str(string("Dir: ", 13))
   sdfat.opendir
   repeat while 0 == sdfat.nextfile(@tbuf)
      term.str(@tbuf)
      term.out(13)
   term.str(string("That's the dir", 13))
   term.out(13)
   sta := cnt
   r := sdfat.popen(string("speed.txt"), "w")
   repeat 256
      sdfat.pwrite(@bigbuf, 8192)
   sdfat.pclose
   r := cnt - sta
   term.str(string("Writing 2M took "))
   term.dec(r)
   term.out(13)
   sta := cnt
   r := sdfat.popen(string("speed.txt"), "r")
   repeat 256
      sdfat.pread(@bigbuf, 8192)
   sdfat.pclose
   r := cnt - sta
   term.str(string("Reading 2M took "))
   term.dec(r)
   term.out(13)
   term.str(string("That's, all, folks! 3", 13))
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