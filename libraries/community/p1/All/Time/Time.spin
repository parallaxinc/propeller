{{ time.spin, v1.0
   Copyright (c) 2010 Austin Bowen
   *See end of file for terms of use*
}}

PUB S (DATA)
  REPEAT DATA
    WAITCNT(CLKFREQ+CNT)

PUB M (DATA)
  REPEAT DATA
    S(60)

PUB H (DATA)
  REPEAT DATA
    M(60)

PUB D (DATA)
  REPEAT DATA
    H(24)

PUB W (DATA)
  REPEAT DATA
    D(7)

PUB MO (DATA)
  REPEAT DATA
    D(30)

PUB Y (DATA)
  REPEAT DATA
    D(365)


DAT
{{Permission is hereby granted, free of charge, to any person obtaining a copy of this software
  and associated documentation files (the "Software"), to deal in the Software without restriction,
  including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
  and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
  subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
  PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
  FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}}
