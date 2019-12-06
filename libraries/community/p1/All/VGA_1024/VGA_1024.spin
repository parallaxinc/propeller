'' VGA_1024.spin - see License at end of listing.
''
'' 1.0 - 9/25/07 added binFP( ) routine, to print binary of FP number.
'' 1.1 - 6/04/09 added MIT License
''
'' Start VGA and Keyboard routines for 1024 x 768 resolution (128 x 64 chars)
'' Works without change on Propeller Proto Board

'' Process keys and display on screen
'' Display Routines included: out, cls, bin, dec, hex, str, cursloc

'' Should be easy to convert to a different resolution by:
''   Change the constants: rows and columns to match the screen character resolution
''   Change the Object vgs_Hires_Text to a driver that supports the new resolution

'' Control keys supported: Enter, Tab, Backspace, Delete, Arrows, Home, End
''                         ESC key is used to exit the keyboard input processing, to do other code

'' ---------------------------------------------------------------------------
'' DOC for VGA driver (vga_Hires_Text), it's handy:

'' Starts two COGs for 1024 x 768 resolution, 128 x 64 characters
'' returns false if two COGs not available
''
''   BasePin = VGA starting pin (0, 8, 16, 24, etc.)
''
''   ScreenPtr = Pointer to 8,192 bytes containing ASCII codes for each of the
''               128x64 screen characters. Each byte's top bit controls color
''               inversion while the lower seven bits provide the ASCII code.
''               Screen memory is arranged left-to-right, top-to-bottom.
''
''               screen byte example: %1_1000001 = inverse "A"
''
''   ColorPtr =  Pointer to 64 words which define the foreground and background
''               colors for each row. The lower byte of each word contains the
''               foreground RGB data for that row, while the upper byte
''               contains the background RGB data. The RGB data in each byte is
''               arranged as %RRGGBB00 (4 levels each).
''
''               color word example: %%0020_3300 = gold on blue
''
''   CursorPtr = Pointer to 6 bytes which control the cursors:
''
''               bytes 0,1,2: X, Y, and MODE of cursor 0
''               bytes 3,4,5: X, Y, and MODE of cursor 1
''
''               X and Y are in terms of screen characters
''               (left-to-right, top-to-bottom)
''
''               MODE uses three bottom bits:
''
''                      %x00 = cursor off
''                      %x01 = cursor on
''                      %x10 = cursor on, blink slow
''                      %x11 = cursor on, blink fast
''                      %0xx = cursor is solid block
''                      %1xx = cursor is underscore
''
''               cursor example: 127, 63, %010 = blinking block in lower-right
''
''     SyncPtr = Pointer to long which gets written with -1 upon each screen
''               refresh. May be used to time writes/scrolls, so that chopiness
''               can be avoided. You must clear it each time if you want to see
''               it re-trigger.

CON
  cols     = 128                ' number of screen columns
  rows     = 64                 ' number of screen rows
  chars    = rows*cols          ' number of screen characters
  esc      = $CB                ' keyboard esc char

OBJ
'' Include VGA and Keyboard
  vga : "vga_Hires_Text"
  kbd : "Keyboard"

VAR
  byte  screen[chars]           ' screen character buffer
  word  colors[rows]            ' color specs for each screen row (see ColorPtr description above)                                                            
  byte  cursor[6]               ' cursor info array (see CursorPtr description above)
  long  sync, loc, xloc, yloc   ' sync used by VGA routine, others are local screen pointers
  long  kbdreq                  ' global val of kbdflag

PUB start(BasePin, kbdflag, kbd_dpin, kbd_cpin, kbd_lock, kbd_auto) | i, char
  ' start VGA and Keyboard (if kbdflag is TRUE)

  kbdreq := kbdflag                ' used in getkey routine

''start vga
  vga.start(BasePin, @screen, @colors, @cursor, @sync)
  waitcnt(clkfreq * 1 + cnt)    'wait 1 second for cogs to start
  
''init screen colors to gold on blue
  repeat i from 0 to rows - 1
    colors[i] := $08F0          '$2804 (if you want cyan on blue)

''init cursor attributes
  cursor[2] := %110             ' init cursor to underscore with slow blink

  cls                           ' clear screen

'' start keyboard
  if kbdflag
    kbd.startx(kbd_dpin, kbd_cpin, kbd_lock, kbd_auto)
    waitcnt(clkfreq * 1 + cnt)    'wait 1 second for cog to start

PUB bin(value, digits)

'' Print a binary number, specify number of digits

  repeat while digits > 32
    out("0")
    digits--

  value <<= 32 - digits

  repeat digits
    out((value <-= 1) & 1 + "0")

PUB binFP(value) | bitnum, bit, bitval
'' Prints FP long in special Binary format: sign, exp, mantissa

  repeat bitnum from 31 to 0
    bit := 1 << bitnum                ' create mask bit
    bitval := (bit & value) >> bitnum  ' extract bit and shift back to bit 0

    bin(bitval, 1)                    ' display one bit

    case bitnum
      27,20,16,12,8,4: out($20)       ' space after every 4 in group
      31,23: str(string("  "))        ' two after sign and exponent

PUB cls

'' clear screen

  longfill(@screen, $20202020, chars/4)

  xloc := yloc := loc := cursor[0] := cursor[1] := 0

PUB color(ColorVal) | i
''reset screen colors
  repeat i from 0 to rows - 1
    colors[i] := ColorVal          '$2804 (if you want cyan on blue)

PUB rowcolor(ColorVal, row)
'' reset row color to colorval
  row <#= constant(rows-1)
  colors[row] := ColorVal

PUB rowtextcolor(ColorVal, row)
'' reset row color to colorval
  row <#= constant(rows-1)
  colors[row] := (colors[row] & $FC00) + (ColorVal & $FC)

PUB screentextcolor(ColorVal) | i, txcolor ' use last byte for screen text color
''reset screen text color
  txcolor := ColorVal & $FC             ' use high six bits of lower byte for text color
  
  repeat i from 0 to rows - 1
    colors[i] := (colors[i] & $FC00) + txcolor

PUB cursloc(x, y)

'' move cursor to x, y position
  xloc := cursor[0] := x <#constant((cols-1))
  yloc := cursor[1] := y <#constant((rows-1))
  loc  := xloc + yloc*cols  

PUB dec(value) | i

'' Print a decimal number

  if value < 0
    -value
    out("-")

  i := 1_000_000_000

  repeat 10
    if value => i
      out(value/i + "0")
      value //= i
      result~~
    elseif result or i == 1
      out("0")
    i /= 10

PUB getkey : keypress
'' process keys
  if kbdreq                             ' if keyboard requested
    if kbd.present                      ' if keyboard plugged in
      return kbd.getkey                 ' if keyboard there, get and return the key
    else
      return esc                        ' return esc if no keyboard
  else
    return esc                          ' return esc if keyboard not requested in calling seq

PUB hex(value, digits)

'' Print a hexadecimal number, specify number of digits

  repeat while digits > 8
    out("0")
    digits--

  value <<= (8 - digits) << 2

  repeat digits
    out(lookupz((value <-= 4) & $f : "0".."9", "A".."F"))

PRI newline | i, j, len
  if ++yloc == rows                           ' if last line on screen, shift all up
    yloc--                                    ' reset yloc it at bottom of screen
    i := @screen
    i += cols
    len := (chars - cols)/4
    longmove(@screen, i, len)                 ' shift screen up one line
    
    i := @screen
    i += (chars - cols)                       ' set "i" for use below

  else                                        ' if not last line, shift lines down
    i := @screen
    i += (rows - 2)*cols                      ' init ptr to start of next-to-last line
    
    if yloc < rows - 1
      repeat j from rows - 2 to yloc
        longmove(i + cols, i, cols/4)           ' shift one line down
        i -= cols                               ' move i up one line

    i += cols                                 ' point to start of last line moved
    
  longfill(i, $20202020, cols/4)              ' clear the last line moved

  j := i - cols + xloc                        ' point to original cursor location
  bytemove(i, j, cols - xloc)                 ' move chars from cursor pos down to start of next line

  bytefill(j, $20, cols - xloc)               ' clear original part of line that was moved
 
  xloc := cursor[0] := 0                      ' reset xloc, loc and cursor position
  cursor[1] := yloc                           
  loc  := yloc*cols
  
PUB out(c) | i, j
'' Print a character
''
''  $09 = tab
''  $0D = return -> CR/LF
''  $20..$7E = display character
''  $7F = skip
''  $C0   left arrow
''  $C1 = right arrow
''  $C2 = up arrow
''  $C3 = down arrow
''  $C4 = home key - go to beginning of line
''  $C5 = end key - go past last char on line
''  $C6 = page up key - skip this key
''  $C7 = page down key - skip this key
''  $C8 = backspace key
''  $C9 = delete key
''  $CA = insert key - skip this key
''  $CB = esc - skip this key

  case c
    $09:                        ' tab command
      repeat
        out($20)                ' recursive call to out( )
      while xloc & 3            ' tab to multiples of 4

    $0D:                        ' CR/LF, return to start of new line
      newline

    $20..$7E:                   ' character
      screen[loc++] := c        ' output the character
             
      if ++xloc == cols         ' bump the xloc
        xloc := 0
        yloc++
        if yloc == rows
          yloc := loc := 0
          
      if loc == chars           ' wrap if needed
        loc := xloc := yloc := cursor[0] := cursor[1] := 0
      else
        cursor[0] := xloc
        cursor[1] := yloc
        
        
    $C0:                        ' left arrow
      if loc                    ' skip this if at upper left screen
        loc--
        if xloc
          xloc--
        else
          xloc := cols - 1
          yloc--
        cursor[0] := xloc
        cursor[1] := yloc
             
    $C1:                        ' right arrow
      if loc <> chars - 1       ' skip if at lower right of screen
        loc++
        if xloc <> cols - 1
          xloc++
        else
          xloc := 0
          yloc++
        cursor[0] := xloc
        cursor[1] := yloc
     
    $C2:                        ' up arrow
      if yloc                   ' skip if yloc at top of screen
        yloc--                  ' move yloc up one row
        loc -= cols             ' move loc var back one row
        cursor[1] := yloc       ' reset 'y' cursor position
      
    $C3:                        ' down arrow
      if yloc <> rows - 1       ' skip if at bottom of screen
        yloc++                  ' move yloc dowm one row
        loc += cols             ' move loc var down one row
        cursor[1] := yloc
    
    $C4:                        ' home key - move to 1st char of line
      xloc := cursor[0] := 0
      loc := xloc + yloc*cols
    
    $C5:                        ' end key - move to last char of line
      if xloc <> cols - 1
        repeat xloc from cols - 1 to 0
         loc := xloc + yloc*cols 
         if screen[loc] <> $20  ' continue until first non-space char
           if xloc <> cols - 1
             xloc++               ' move past non-blank char
             loc++
           quit
          
        cursor[0] := xloc       ' loc is already reset from above
    
    $C8:                        ' backspace
      if loc                    ' skip if at upper left of screen        
        if xloc                 ' do 'else' if at start of line
          xloc--                ' xloc left one space
          loc--

          i := @screen          ' calculate
          i += xloc + yloc*cols ' destination for shift left one
          bytemove(i, i+1, cols - xloc - 1)
          screen[cols - 1 + yloc*cols] := $20
            
        else                    ' here if xloc == 0
          if screen[loc-1] == $20   ' last char on prev line
            yloc--
            
            i := @screen          ' calculate
            i += loc - 1          ' destination for shift left one
            
            repeat while screen[--loc] == $20
              bytemove(i, i+1, cols) ' move one row's worth of chars
              i--                 ' dec "i" to correspond to --loc

              screen[loc + cols] := $20  ' clear old char
            
              if ++xloc == cols   ' use xloc as counter here, 0..., don't move > 1 row
                loc--             ' make as if loc had been bumped above B4 we quit
                quit
                              
            loc++                 ' bump loc to space char
            xloc := loc - yloc*cols ' re-calculate xloc from loc and yloc

        cursor[0] := xloc         ' reset cursor loc
        cursor[1] := yloc
                                                     
    $C9:                          ' delete
      if xloc == cols - 1
        screen[loc] := $20        ' if at last char on line, clear it and exit
        
      else
        repeat i from xloc to cols - 2
          j := i + yloc*cols
          screen[j] := screen[j+1]
        
       screen[j+1] := $20       ' clear last char on line after shift left
            
PUB str(string_ptr)

'' Print a zero terminated string

  repeat strsize(string_ptr)
    out(byte[string_ptr++])
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
           