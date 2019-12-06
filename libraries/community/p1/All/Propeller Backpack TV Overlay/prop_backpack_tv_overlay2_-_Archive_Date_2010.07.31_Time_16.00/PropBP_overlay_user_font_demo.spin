'' Demo program Copyright (c) 2010 Philip C. Pilgrim
'' See end of file for terms of use.

CON

  _clkmode      = xtal1 + pll8x
  _xinfreq      = 10_000_000

  USER_BLOCKS   = 4             'This represents the number of 16-character blocks to be set aside for user-defined glyphs.
  _free         = 256 * USER_BLOCKS

  BUF_SIZE      = 4096          'Size (in bytes) of the character buffer provided to the overlay object.
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
  word  custom[32]

PUB start | i, addr

  pr.start(@buffer, USER_BLOCKS << 16 | BUF_SIZE)
  repeat i from 0 to 16
    wordfill(@custom[8], $ffff << (16 - i), 16)
    pr.setchar($e0 + i, @custom)
  pr.str(string(DEFWIN, 10, DBL | 15, DBL | 2, CHGCLR, $f, _0, 8|TPT, 1, APNDSP, 10, SHO|10, _0, 20, SHODSP, 10, WDWRAP, 1))
  pr.str(string(DEFWIN, 60, _0, HMS24, CHGCLR, $f, _0, _0, 8|TPT, APNDSP, 10, SHO|60, 100, 200, SETTIM, _0, _0, _0, _0, _0, _0))
  pr.str(string(USEWIN, 10, $f1, " ", $f1, " ", $f1, " ", $f1, " ", $f1, " ", $f1, " ", $f1, " ", $f1, CR))
  waitcnt(cnt + clkfreq * 2)
  repeat
    repeat i from 0 to 239 step 4
      pr.setchar($f1, @hi_0)
      setbar(i)
      waitcnt(cnt + (clkfreq >> 4))
      pr.setchar($f1, @hi_1)
      setbar(i + 1)
      waitcnt(cnt + (clkfreq >> 4))
      pr.setchar($f1, @hi_2)
      setbar(i + 2)
      waitcnt(cnt + (clkfreq >> 4))
      pr.setchar($f1, @hi_1)
      setbar(i + 3)
      waitcnt(cnt + (clkfreq >> 4))
       
PUB setbar(i)

  pr.str(string(CRSRXY, ZERO, 1))
  repeat i >> 4
    pr.out($f0)
  pr.out($e0 + (i & $0f))
  pr.out(CLREOL)
     
DAT

hi_0                    word    %0000000000000000
                        word    %0000000000000000
                        word    %0000000000000000
                        word    %0000000000000000
                        word    %0000001111000000
                        word    %0000001111000000
                        word    %0000011001100000
                        word    %0000110000110000
                        word    %0000110000110000
                        word    %0000110000110000
                        word    %0000011001100000
                        word    %1100001111000000
                        word    %1100001111000000
                        word    %1100000110000000
                        word    %0110000110000000
                        word    %0110000110000000
                        word    %0111111111111111
                        word    %0111111111111111
                        word    %0000000110000000
                        word    %0000000110000000
                        word    %0000000110000000
                        word    %0000001111000000
                        word    %0000011111100000
                        word    %0000111001110000
                        word    %0001110000111000
                        word    %0011100000011100
                        word    %0111000000001110
                        word    %1110000000000111                        
                        word    %0000000000000000
                        word    %0000000000000000
                        word    %0000000000000000
                        word    %0000000000000000

hi_1                    word    %0000000000000000
                        word    %0000000000000000
                        word    %0000000000000000
                        word    %0000000000000000
                        word    %0000001111000000
                        word    %0000001111000000
                        word    %0000011001100000
                        word    %0000110000110000
                        word    %0000110000110000
                        word    %0000110000110000
                        word    %0000011001100000
                        word    %0110001111000000
                        word    %0110001111000000
                        word    %0110000110000000
                        word    %0110000110000000
                        word    %0110000110000000
                        word    %0111111111111111
                        word    %0111111111111111
                        word    %0000000110000000
                        word    %0000000110000000
                        word    %0000000110000000
                        word    %0000001111000000
                        word    %0000011111100000
                        word    %0000111001110000
                        word    %0001110000111000
                        word    %0011100000011100
                        word    %0111000000001110
                        word    %1110000000000111                        
                        word    %0000000000000000
                        word    %0000000000000000
                        word    %0000000000000000
                        word    %0000000000000000

hi_2                    word    %0000000000000000
                        word    %0000000000000000
                        word    %0000000000000000
                        word    %0000000000000000
                        word    %0000001111000000
                        word    %0000001111000000
                        word    %0000011001100000
                        word    %0000110000110000
                        word    %0000110000110000
                        word    %0000110000110000
                        word    %0000011001100000
                        word    %0011001111000000
                        word    %0011001111000000
                        word    %0011000110000000
                        word    %0110000110000000
                        word    %0110000110000000
                        word    %0111111111111111
                        word    %0111111111111111
                        word    %0000000110000000
                        word    %0000000110000000
                        word    %0000000110000000
                        word    %0000001111000000
                        word    %0000011111100000
                        word    %0000111001110000
                        word    %0001110000111000
                        word    %0011100000011100
                        word    %0111000000001110
                        word    %1110000000000111                        
                        word    %0000000000000000
                        word    %0000000000000000
                        word    %0000000000000000
                        word    %0000000000000000

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