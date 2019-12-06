{{
Modified Tiny Basic for use with Propeller Demo Board and Hydra.
Windowed text tv driver written by Phil Pilgrim, modified by Michael Green.
Based on tv_text driver written by Parallax, Inc. originally copyright (c) 2006.

Copyright (c) 2008 Phil Pilgrim with portions copyright (c) Michael Green.
See end of file for terms of use.
}}

CON

  cols = 40
  rows = 13

  screensize = cols * rows

  tv_count = 14

  ZAP_COLOR = 1 << 10 + $2FE
  ZAP_CHAR  = ($FFFF_FFFF ^ ZAP_COLOR) | $200 

VAR

  long  col, row, clr, flag
  byte  eol, wleft, wtop, wcols, wrows
  byte  params[8], window, pcnt, pptr                            
  
  word  screen[screensize]
  byte  lastcolor[16], lastrow[16], lastcol[16]
  long  colors[16 * 2]

  long  tv_status     '0/1/2 = off/invisible/visible              read-only   (14 longs)
  long  tv_enable     '0/non-0 = off/on                           write-only
  long  tv_pins       '%pppmmmm = pin group, pin group mode       write-only
  long  tv_mode       '%tccip = tile,chroma,interlace,ntsc/pal    write-only
  long  tv_screen     'pointer to screen (words)                  write-only      
  long  tv_colors     'pointer to colors (longs)                  write-only                            
  long  tv_ht         'horizontal tiles                           write-only                            
  long  tv_vt         'vertical tiles                             write-only                            
  long  tv_hx         'horizontal tile expansion                  write-only                            
  long  tv_vx         'vertical tile expansion                    write-only                            
  long  tv_ho         'horizontal offset                          write-only                            
  long  tv_vo         'vertical offset                            write-only                            
  long  tv_broadcast  'broadcast frequency (Hz)                   write-only                            
  long  tv_auralcog   'aural fm cog                               write-only


OBJ

  vga : "tv"


PUB start(basepin) : okay

'' Start terminal - starts a cog
'' returns false if no cog available

  setcolors(@palette)
  usewindow(0)
  out(0)
  
  longmove(@tv_status, @tv_params, tv_count)
  tv_pins := (basepin & $38) << 1 | (basepin & 4 == 4) & %0101
  tv_screen := @screen
  tv_colors := @colors
  
  okay := vga.start(@tv_status)


PUB stop

'' Stop terminal - frees a cog

  vga.stop


PUB str(stringptr)

'' Print a zero-terminated string

  repeat strsize(stringptr)
    out(byte[stringptr++])


PUB dec(value) | i

'' Print a decimal number

  if value < 0
    -value
    out("-")

  i := 1_000_000_000

  repeat 10
    if value => i
      out(value / i + "0")
      value //= i
      result~~
    elseif result or i == 1
      out("0")
    i /= 10


PUB hex(value, digits)

'' Print a hexadecimal number

  value <<= (8 - digits) << 2
  repeat digits
    out(lookupz((value <-= 4) & $F : "0".."9", "A".."F"))


PUB bin(value, digits)

'' Print a binary number

  value <<= 32 - digits
  repeat digits
    out((value <-= 1) & 1 + "0")

'' Display control codes
CON
  ClrWin      = $00                            ' clear window  
  Home        = $01                            ' home in window
  MoveXY      = $02                            ' move to X,Y in window (X and Y follow)
  CursLt      = $03                            ' cursor left
  CursRt      = $04                            ' cursor right
  CursUp      = $05                            ' cursor up
  CursDn      = $06                            ' cursor down
  Color       = $07                            ' select color C (0-63) (C follows)
  Bsp         = $08                            ' backspace
  Tab         = $09                            ' tab (8 spaces per)
  Lf          = $0A                            ' linefeed
  ClrEol      = $0B                            ' clear to end of line
  ClrEow      = $0C                            ' clear to end of active window
  Cr          = $0D                            ' carriage return
  MoveX       = $0E                            ' move to X in window (X follows)
  MoveY       = $0F                            ' move to Y in window (Y follows)
  SetWin      = $10                            ' set bounds of window (1-15,x,y,cols,rows)
                                               ' If cols or rows supplied as zero, use max. available
  UseWin      = $11                            ' change to selected window (0-15) (W follows)
  SetColor    = $12                            ' change color (0-63) to FG, BG (C, FG, BG follow)
                                               ' This actually changes a pair of colors for text use
                                               '  to FG,BG,FG,BG (even) and FG,FG,BG,BG (odd)
  WinColor    = $17                            ' change all colors in active window (C follows)
  EscChr      = $1F                            ' (ESC) print next character C as-is (C follows)
  Alt00       = $FF                            ' changed to $00 by out (for use in string())
  ClrScr      = Alt00                          ' equivalent to ClrWin (for use in string())
  
PUB out(c) | i, j, k

'' Output a character
''
''     $00 = clear active window
''     $01 = home in active window
''     $02 = move to X,Y in active window (X and Y follow)
''     $03 = cursor left
''     $04 = cursor right
''     $05 = cursor up
''     $06 = cursor down
''     $07 = select color C (0 - 15) (C follows)
''     $08 = backspace
''     $09 = tab (8 spaces per)
''     $0A = linefeed
''     $0B = clear to end of line
''     $0C = clear to end of active window
''     $0D = return
''     $0E = move to X in active window (X follows)
''     $0F = move to Y in active window (Y follows)
''     $10 = define window W (1 - 15) (W, Left, Top, nCols, nRows follow)
''     $11 = use window W (0 - 15) (W follows)
''     $12 = change color C (0 - 15) to FG, BG (C, FG, BG follow)
''     $17 = change all colors in active window to C (0 - 15) (C follows)
''     $1F = (ESC) print next character C as-is (C follows)
''  others = printable characters

  if flag
    if c == $FF
      c~
    params[pptr++] := c
    if pptr == pcnt
      case flag
        $02: col := params[0] <# wcols - 1
             row := params[1] <# wrows - 1
             eol~

        $07: clr := c

        $0E: col := c <# wcols - 1
             eol~

        $0F: row := c <# wrows - 1
             if eol
               col~
               eol~                   

        $10: setwindow(params[0], params[1], params[2], params[3], params[4])

        $11: usewindow(c)

        $12: if params[1] == 0
               params[1] := $FF
             if params[2] == 0
               params[2] := $FF
             set1color(params[0], params[1], params[2])

        $17: repeat i from wtop to wtop + wrows - 1
               repeat j from wleft to wleft + wcols - 1
                 k :=  i * cols + j
                 screen[k] := screen[k] & ZAP_COLOR | c << 11
             clr := c

        $1F: print(c)
      flag~
                     
  else
    case c
      $00, $1E:
           if window
             repeat i from wtop to wtop + wrows - 1
                wordfill(@screen[i * cols + wleft], clr << 11 | $220, wcols)
           else
             wordfill(@screen, clr << 11 | $220, screensize)
           col~
           row~
           eol~
           
      $01: col~
           row~
           eol~

      $03: col := col - 1 #> 0
           eol~

      $04: col := col + 1 <# wcols
           if col == wcols
             eol~~

      $05: row := row - 1 #> 0

      $06: row := row + 1 <# wrows
           if row == wrows
             row--
             eol~~

      $08: if (col | row)
             if col
               col--
             else
               col := wcols
               row--
             i := col
             k := row
             print(" ")
             col := i
             row := k

      $09: repeat
             print(" ")
           while col & 7
      
      $0A: if row == wrows - 1
             i := col
             newline
             col := i
           else
             row++
      
      $0B: cleartoeol
     
      $0C: i := row
           k := col
           repeat row from i to wrows - 1
             cleartoeol
             col~
           row := i
           col := k              
     
      $0D: cleartoeol
           newline

      $13: repeat i from wtop to wtop + wrows - 1
             k := i * cols + wleft
             if wcols > 1
               wordmove(@screen[k], @screen[k + 1], wcols - 1)
             screen[k + cols - 1] := screen[k + cols - 1] & ZAP_CHAR | $20
             
      $14: repeat i from wtop to wtop + wrows - 1
             k := i * cols + wleft
             if wcols > 1
               wordmove(@screen[k+1], @screen[k], wcols - 1)
             screen[k] := screen[k] & ZAP_CHAR | $20
       
      $15: scrollup
       
      $16: if wrows > 1
             repeat i from wtop + wrows - 1 to wtop + 1
               k := i * cols + wleft
               wordmove(@screen[k], @screen[k - cols], wcols)
           wordfill(@screen[wtop * cols + wleft], clr << 11 | $220, wcols)
       
      $07, $0E, $0F, $11, $17, $1F:
           flag := c
           pptr~
           pcnt := 1

      $02: flag := c
           pptr~
           pcnt := 2

      $12: flag := c
           pptr~
           pcnt := 3

      $10: flag := c
           pptr~
           pcnt := 5

      other: print(c)

PRI setcolors(colorptr) | i, fore, back

'' Override default color palette
'' colorptr must point to a list of up to 8 colors
'' arranged as follows:
''
''               fore   back
''               ------------
'' palette  byte color, color     'color 0
''          byte color, color     'color 1
''          byte color, color     'color 2
''          ...

  repeat i from 0 to 15
    fore := byte[colorptr][i << 1]
    back := byte[colorptr][i << 1 + 1]
    set1color(i, fore, back)

PRI set1color(colrptr, fore, back)

    colrptr &= $0f
    colors[colrptr << 1]     := fore << 24 + back << 16 + fore << 8 + back
    colors[colrptr << 1 + 1] := fore << 24 + fore << 16 + back << 8 + back

PRI usewindow (w)

  lastcol[window] := col
  lastrow[window] := row
  lastcolor[window] := clr
  window := w & $0F
  wleft := byte[@windows[window]][0]
  wtop := byte[@windows[window]][1]
  wcols := byte[@windows[window]][2]
  wrows := byte[@windows[window]][3]
  clr := lastcolor[window]
  col := lastcol[window]
  row := lastrow[window]

PRI setwindow (w, xleft, ytop, xcols, yrows)

  if w := w & $0F
    xleft <#= cols
    xleft #>= 0
    ytop <#= rows
    ytop #>= 0
    xcols <#= cols - xleft
    xcols #>= 1
    yrows <#= rows - ytop
    yrows #>= 1
    windows[w] := yrows << 24 | xcols << 16 | ytop << 8 | xleft
    lastcol[w] := lastrow[w] := lastcolor[w] := 0
    if w == window
      col~
      row~

PRI print(c)

  if eol
    newline
  screen[(wtop + row) * cols + wleft + col] := (clr << 1 + c & 1) << 10 + $200 + c & $FE
  if ++col == wcols
    eol~~

PRI newline | i

  col~
  eol~
  if ++row == wrows
    row--
    scrollup

PRI scrollup | i, k

    if wrows > 1
      if window
        repeat i from wtop to wtop + wrows - 2
          k := i * cols + wleft
          wordmove(@screen[i * cols + wleft], @screen[(i + 1) * cols + wleft], wcols)
      else
        wordmove(@screen, @screen[cols], constant(screensize - cols))   'scroll lines
    k := col
    col~
    cleartoeol
    col := k

PRI cleartoeol

   wordfill(@screen[(wtop + row) * cols + wleft + col], clr << 11 | $220, wcols - col)
       

DAT

tv_params               long    0               'status
                        long    1               'enable
                        long    0               'pins
                        long    %10010          'mode
                        long    0               'screen
                        long    0               'colors
                        long    cols            'hc
                        long    rows            'vc
                        long    4               'hx
                        long    1               'vx
                        long    0               'ho
                        long    0               'vo
                        long    0               'broadcast
                        long    0               'auralcog


                        '       fore   back
                        '       color  color
palette                 byte    $07,   $03    '0    white / black
                        byte    $0E,   $03    '1 lavender / black
                        byte    $2E,   $03    '2     blue / black
                        byte    $4E,   $03    '3     aqua / black
                        byte    $6E,   $03    '4    green / black
                        byte    $8E,   $03    '5   yellow / black
                        byte    $AE,   $03    '6   orange / black
                        byte    $CE,   $03    '7      red / black
                        
                        byte    $03,   $07    '8    black / white
                        byte    $03,   $0E    '9    black / lavender
                        byte    $03,   $2E    'A    black / blue
                        byte    $03,   $4E    'B    black / aqua
                        byte    $03,   $6E    'C    black / green
                        byte    $03,   $8E    'D    black / yellow
                        byte    $03,   $AE    'E    black / orange
                        byte    $03,   $CE    'F    black / red

windows                 long    rows << 24 | cols << 16
                        long    rows << 24 | cols << 16
                        long    rows << 24 | cols << 16
                        long    rows << 24 | cols << 16
                        long    rows << 24 | cols << 16
                        long    rows << 24 | cols << 16
                        long    rows << 24 | cols << 16
                        long    rows << 24 | cols << 16
                        long    rows << 24 | cols << 16
                        long    rows << 24 | cols << 16
                        long    rows << 24 | cols << 16
                        long    rows << 24 | cols << 16
                        long    rows << 24 | cols << 16
                        long    rows << 24 | cols << 16
                        long    rows << 24 | cols << 16
                        long    rows << 24 | cols << 16

{{
                            TERMS OF USE: MIT License

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
}}
