'   Code additions and VGA Demo     December 2008 - John Twomey AKA: QuattroRS4
' 
'   Copyright 2008   Radical Eye Software
'
'   See end of file for terms of use.
'
CON
        _clkmode        = xtal1 + pll16x
        _xinfreq        = 5_000_000
        
  cols = 64
  rows = 48
  tiles = cols * rows

  spacetile = $8000 + $20 << 6
  
obj
   term: "vga_1024x768_tile_driver_with_cursor"
   sd: "fsrw"
var
   byte tbuf[20]
   long colNo, rowNo
   long  col, row, color ,flag
  long Num
  long  array[tiles/2]
  long  cursor[1+32]
  'long trial
  long cursor_x, cursor_y, cursor_col, cursor_def


pub go | x
   x := \start
   ps(string("Returned from start", 13))
   dec(x)
   Print(13)
pub start | r, sta, bytes
   term.start(16, @array, @vgacolours, @cursor_x, 0, 0)
   print($100)     
   ps(string("Mounting.", 13))        
   sd.mount(0)
   ps(string("Mounted.", 13))
   ps(string("Dir: ", 13))
   sd.opendir
   repeat while 0 == sd.nextfile(@tbuf)
      ps(@tbuf)
      print(13)
   ps(string(">>> Above is the Directory", 13))
   
   print(13)
   
   ' Create or overwrite file
   r := sd.popen(string("VGATEXT.txt"), "w")
   ps(string("Opening returned "))
   dec(r)
   repeat 2
    print(13)
   sta := cnt
   bytes := 0

   num:=0 ' set variable to 0

   ' What to write to file 
   sd.sdstr(string("The following is a negative number test",13,10))
   repeat 10
      num:= num - 1
      sd.sddec(num)
      if num > -10
       sd.sdstr(string(", "))   
   sd.sdstr(string(13,10,13,10) )
   
   '-----------------------------------------
   
   sd.sdstr(string("The following is a Positive number test",13,10))
   num:=0
   repeat 10
      num:= num + 1
      sd.sddec(num)
      if num < 10
       sd.sdstr(string(", "))  
   sd.sdstr(string(13,10,13,10) ) ' cr & LF twice - using a different method   
  
   '-----------------------------------------
   
   sd.sdstr(string("Decimal Value of 25 = " )) 
   sd.sddec(25)
   
   sd.pputc(13)'' Carriage Return
   sd.pputc(10)'' Line Feed
   
   '----------------------------------------
   
   sd.sdstr(string("8 bit Binary Value of 25 = " ))  
   sd.sdbin(25,8)

   sd.pputc(13)'' Carriage Return
   sd.pputc(10)'' Line Feed

   '----------------------------------------

   sd.sdstr(string("Hexadecimal Value of 25 = " ))  
   sd.sdhex(25,2)

   sd.sdstr(string(13,10,13,10) ) ' cr & LF twice - using a different method
    
   sd.pclose

   '----------------------------------------
  
   ps(string("Wrote file.", 13,13))
   r := sd.popen(string("vgatext.txt"), "r")
   ps(string("Opening returned "))
   dec(r)
   Repeat 2
    print(13)
    
   repeat
      r := sd.pgetc
      if r < 0
         quit
      print(r)
  

PRI print(c) | i, k
'' Print a character
''
''       $0D = new line
''  $20..$FF = character
''      $100 = clear screen
''      $101 = home
''      $108 = backspace
''$110..$11F = select color

  case c
    $0D:                'return?
      newline

    $20..$FF:           'character?
      k := color << 1 + c & 1
      i := $8000 + (c & $FE) << 6 + k
      array.word[row * cols + col] := i
      array.word[(row + 1) * cols + col] := i | $40
      if ++col == cols
        newline

   
        
    $100:               'clear screen?
      wordfill(@array, spacetile, tiles)
      col := row := 0

    $101:               'home?
      col := row := 0

    $108:               'backspace?
      if col
        col--

    $110..$11F:         'select color?
      color := c & $F
      
PRI newline | i

  col := 0
  if (row += 2) == rows
    row -= 2
    'scroll lines
    repeat i from 0 to rows-3
      wordmove(@array.word[i*cols], @array.word[(i+2)*cols], cols)
    'clear new line
    wordfill(@array.word[(rows-2)*cols], spacetile, cols<<1)
    
PRI PS(ptr)

  repeat while byte[ptr]
    print(byte[ptr++])
PUB dec(value) | i

'' Print a decimal number

  if value < 0
    -value
    print("-")

  i := 1_000_000_000

  repeat 10
    if value => i
      print(value / i + "0")
      value //= i
      result~~
    elseif result or i == 1
      print("0")
    i /= 10

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
DAT
vgacolours long

  'Dedfault colour
  
  'long $ff07ff07        'white on blue
  'long $ffff0707

  ' Black Backgrounds
  '-------------------------------------
  long $30003000       'Green on Black
  long $30300000

  long $B001B001       'Yellow on Black
  long $B0B00101

  long $C000C000       'Red on Black
  long $C0C00000

  long $D001D001       'Orange on Black
  long $D0D00101

  long $ff00ff00       'White on Black
  long $ffff0000

  long $00ff00ff       'Black on white
  long $0000ffff
  
  long $ff80ff80       'White on Red
  long $ffff8080

  long $00300030       'black on green
  long $00003030
  
'non long "asdgfasd"
     