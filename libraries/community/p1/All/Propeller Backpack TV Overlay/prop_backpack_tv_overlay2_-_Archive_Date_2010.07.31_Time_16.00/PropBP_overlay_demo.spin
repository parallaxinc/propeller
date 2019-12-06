'' Demo program Copyright (c) 2010 Philip C. Pilgrim
'' See end of file for terms of use.

CON

  _clkmode      = xtal1 + pll8x
  _xinfreq      = 10_000_000

  BUF_SIZE      = 4096
  TPT           = 0             'Change this to 1 for video sources that do not work well with
                                'opaque overlays.
  TPTor0        = ((TPT == 0) | TPT) & _0

  'Commands recognized by "out" method.

  CLS           = $00           '( ) Clear the current window, and home cursor.
  HOME          = $01           '( ) Move cursor to home position.
  CRSRXY        = $02           '(col,row) Move cursor to col and row.
  CRSRLF        = $03           '( ) Move cursor to the left.
  CRSRRT        = $04           '( ) Move cursor to the right.
  CRSRUP        = $05           '( ) Move cursor up.
  CRSRDN        = $06           '( ) Move cursor down.
  SHODSP        = $07           '(dispno) Show display number dispno.
  BKSP          = $08           '( ) Erase prior character and move cursor left.
  TAB           = $09           '( ) Move cursor right to next column divisible by 8.
  LF            = $0A           '( ) Linefeed. Scroll up if on bottom line.
  CLREOL        = $0B           '( ) Clear to the end of the current line.
  CLRDN         = $0C           '( ) Clear from cursor position to the end of the window.
  CR            = $0D           '( )Carriage return. Scroll up if necessary.
  CRSRX         = $0E           '(col) Move cursor to column col.
  CRSRY         = $0F           '(row) Move cursor to row.
  DEFWIN        = $10           '(winno,cols,rows) Define a new window winno sized cols x rows. Make it the current window.
  USEWIN        = $11           '(winno) Change the current window to winno.
  CHGCLR        = $12           '(mask,transparent,fgnd,bkgd) Change current window color to mask, transparent, fgnd, and bkgd.
  SCROLL        = $13           '(offset) Set X (one-line) or Y (multi-line) scroll offset (0 - 15) for current window.
  SMSCRL        = $14           '(rate) Set smooth scrolling rate in current window to rate ms/scan line.
  WDWRAP        = $15           '(yn) Set word wrapping for current window: on (yn<>0) or off (yn==0).
  BLINK         = $16           '(yn) Set blinking for current window: on (yn<>0) or off (yn==0).
  CPYWIN        = $17           '(winno) Copy the text from winno to current window.
  APNDSP        = $18           '(disp,winno,x,y) Append window winno to display disp at location (x,y).
  MOVWIN        = $19           '(slot,x,y) Move window in slot to (x,y).
  SHOWIN        = $1A           '(slot,yn) Show window in slot: yes (yn<>0) or no (yn==0).
  CHGWIN        = $1B           '(slot,winno) Change window in slot to winno.
  PRESET        = $1C           '(dispno,presetno) Create display dispno using preset presetno.
  SETTIM        = $1D           '(yr,mo,day,hr,min,sec) Set the current time.
  MARK          = $1E           '( )Return MARK to acknowledge reaching this point.
  ESC           = $1F           '(char) Escape next character char (i.e. print as-is).

  CLRWIN        = $FF           '( )Same as CLS where strings do not permit 0.
  NONE          = $FF           'Same as 0 when used as an argument.
  ZERO          = $FF           'Same as 0 when used as an argument.
  _0            = $FF           'Same as 0 when used as an argument.
  NO            = $FF           'Same as 0 when used as an argument.
  YES           = $01           'Canonical non-zero value used for binary choices.

  DBL           = $80           'OR with height and width arguments to get double-sized characters.
  SHO           = $40           'OR with window number to set visibility on.

  'Preset names.

  BIGWIN        = $01           '40 x 13 regular window.
  CREDITS       = $02           'Vertically overscanned window with smooth scrolling.
  MARQUEE       = $03           'Single row at bottom with smooth scrolling.
  HILO          = $04           'Single rows top and bottom.
  HILO2         = $05           'Dual rows top and bottom.
  CROSS         = $06           'Single cross-shaped cursor in middle of 40 x 13 screen.
  BOX           = $07           'Single box-shaped cursor in middle of 40 x 13 screen.
  DOT           = $08           'Single dot cursor in middle of 40 x 13 screen.

  ' Window type names.

  REGWIN        = 0             'Regular window.
  HMS24         = 1             'Time window:  23:59:59
  HMS12         = 2             'Time window: 12:59:59pm
  YMD           = 3             'Date window: 2099-12-31
  MDY           = 4             'Date window: 12/31/2099
  DMY           = 5             'Date window: 31-12-2099
  YMDHMS24      = 6             'Date/time window: 2099-12-31 23:59:59
  MDYHMS12      = 7             'Date/time window: 12/31/2099 12:59:59pm
  DMYHMS12      = 8             'Date/time window: 31-12-2099 12:59:59pm

OBJ

  pr : "prop_backpack_tv_overlay2"

VAR

  byte  buffer[BUF_SIZE]

PUB start | i


  pr.start(@buffer, BUF_SIZE)
  pause(2000)
  pr.str(string(DEFWIN, 10, 40, DBL|2, CHGCLR, $f, _0, 8|TPT, 1, APNDSP, 10, SHO|10, _0, 20, SHODSP, 10, WDWRAP, 1))
  pr.str(string("This is a demonstration of the Propeller Backpack video overlay."))
  pause(2000)
  pr.str(string(DEFWIN, 1, 20, 6, CHGCLR, $f, 8, TPTor0, 8|TPT, WDWRAP, 1, APNDSP, 10, SHO|1, 75, 90))
  pr.str(string("Text is displayed in windows which can be stacked vertically on the screen.", CR))
  pause(4000)
  pace(50,string("Each window will scroll automatically when text flows off the bottom.", CR))
  pause(1500)
  pace(50, string("Word wrapping can be set to occur automatically for easy transmission of text.", CR))
  pause(1500)
  pr.str(string(SMSCRL, 50, "Windows can even be set to", CR, "scroll", CR, "smoothly", CR, "for easier", CR, "reading.", CR))
  pause(1500)
  pr.str(string(DEFWIN, 2, 40, 1, CHGCLR, $f, _0, 8|TPT, TPTor0, APNDSP, 10, SHO|2, _0, 210, CRSRX, 40, SMSCRL, 8))
  pr.str(string("Smooth scrolling can also be done horizontally to make marquees easier to read."))
  rep(" ", 44)
  pause(1000)
  pr.str(string(SMSCRL, _0, CRSRX, 1, "Windows can be turned off"))
  pause(1500)
  pr.str(string(SHOWIN, 11, _0))
  pause(2000)
  pr.str(string(" and back on."))
  pause(1500)
  pr.str(string(SHOWIN, 11, 1))
  pause(2000)
  pr.out(CLS)
  pause(1000)
  pr.str(string(CRSRX, 1, "Window 'colors' can be changed at will.", USEWIN, 1))
  pause(2000)
  pr.str(string(CHGCLR, $f, _0, 8|TPT, TPTor0))
  pause(1000)
  pr.str(string(CHGCLR, $f, _0, 4|TPT, 8|TPT))
  pause(1000)
  pr.str(string(CHGCLR, $f, $f, 8|TPT, TPTor0))
  pause(1000)
  pr.str(string(CHGCLR, $f, _0, 4|TPT, TPTor0))
  pause(1000)
  pr.str(string(CHGCLR, $f, _0, 8|TPT, TPTor0))
  pause(1000)
  pr.str(string(CHGCLR, $f, 8, TPTor0, 8|TPT))
  pause(3000)
  pr.str(string(USEWIN, 2, CLRWIN))
  pause(1000)
  pr.str(string(CRSRX, 1, "Windows can also move dynamically,"))
  pause(2000)
  pr.str(string(USEWIN, 1))
  repeat i from 0 to 40
    pr.str(string(MOVWIN, 11))
    pr.out(75 + i)
    pr.out(90 + i)
    pause(50)
  repeat i from 40 to 0
    pr.str(string(MOVWIN, 11))
    pr.out(75 + i)
    pr.out(90 + i)
    pause(50)
  pause(3000)
  pr.str(string(USEWIN, 2, SMSCRL, 8, " or blink automatically.", USEWIN, 1, BLINK, 1))
  pause(6000)
  pr.str(string(DEFWIN, 3, 33, 6, CHGCLR, $f, _0, 8|TPT, 1, APNDSP, 20, SHO|3, _0, 40, SHODSP, 20, WDWRAP, 1))
  pr.str(string("The entire screen can be switched from one set of windows to another ..."))
  pause(3000)
  pr.str(string(SHODSP, 10))
  pause(3000)
  pr.str(string(SHODSP, 20))
  pause(1000)
  pr.str(string(" and back ... instantaneously."))
  pause(3000)
  pr.str(string(CR, CR, "Thank you for watching!"))
  repeat

PRI pace(delay, straddr) | ch

  repeat while ch := byte[straddr++]
    pr.out(ch)
    pause(delay)

PRI pause(ms)

  waitcnt(cnt + clkfreq / 1000 * ms)

PRI rep(char, reps)

  repeat reps
    pr.out(char)

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