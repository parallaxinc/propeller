{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│               Alex Pirvulescu     Controller-less T6A39/T6A40 240x64 LCD driver test                                         │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                    TERMS OF USE: Parallax Object Exchange License                                            │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}
CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

CON
  SAMPLE_HEIGHT = 4
  DISP_HEIGHT = 64
  DISP_WIDTH = 200

OBJ
  lcd : "lcd_graphic"
  lcdt : "LCD"


VAR
  long x, y, s
  long stack[30]
  long cnts,cnte


PUB main | c, z
  cognew(main2, @stack)
  lcd.start(1)

  repeat
    repeat x from 0 to 239
      lcd.char(x // 128)
    waitcnt(clkfreq * 5  + cnt)
    repeat x from 0 to 32 step 2
      !outa[1]
      !outa[2]
      lcd.drawline(x, x, 239 - x, x, 2)
      lcd.drawline(239 - x, x, 239 - x, 63 - x, 2)
      lcd.drawline(239 - x, 63 - x, x, 63 - x, 2)
      lcd.drawline(x, 63 - x, x, x, 2)
    waitcnt(clkfreq * 2 + cnt)
    lcd.clear(0)

PUB main2 | c
    lcdt.init(0)
    repeat
      lcdt.goto(0,0)
      lcdt.dec(c++)

