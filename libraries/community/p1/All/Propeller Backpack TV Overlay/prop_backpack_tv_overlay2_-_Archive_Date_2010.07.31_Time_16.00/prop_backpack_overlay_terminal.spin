'' Demo program Copyright (c) 2010 Philip C. Pilgrim
'' See end of file for terms of use.

CON

  _clkmode      = xtal1 + pll8x
  _xinfreq      = 10_000_000

  BUF_SIZE      = 16384

OBJ

  pr : "prop_backpack_tv_overlay2"
  io : "basic_sio"

VAR

  byte  buffer[BUF_SIZE]

PUB start | i

  pr.start(@buffer, BUF_SIZE)
  io.start
  repeat
    if (pr.out(io.in) == pr#MARK)
      waitcnt(cnt + clkfreq / 100)
      io.out(pr#MARK)

''-----------[ TERMS OF USE ]---------------------------------------------------
''
'' Permission is hereby granted, free of charge, to any person obtaining a copy of
'' this software and associated documentation files (the "Software"), to deal in
'' the Software without restriction, including without limitation the rights to use,
'' copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
'' Software, and to permit persons to whom the Software is furnished to do so,
'' subject to the following conditions: 
''
'' The above copyright notice and this permission notice shall be included in all
'' copies or substantial portions of the Software. 
''
'' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
'' INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
'' PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
'' HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
'' OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
'' SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.              