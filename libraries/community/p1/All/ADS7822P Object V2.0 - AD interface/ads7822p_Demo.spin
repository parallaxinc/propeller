''********************************************
''*  ADS7822P object demo v2.0               *
''*  (C) 2007 William Henning                *
''*  http://www.mikronauts.com               *
''********************************************
''
'' This program demonstrates how to use the ADS7822P object I wrote.
''
'' The ADS7822P is a 12 bit ADC capable of 200k samples per second while consuming only
'' 1.6mW, and it is available in a nice friendly DIP-8 package. It will quite happily
'' work with a 3.3V supply so it is very Propeller friendly.  
''
'' This program uses the 640x240 VGA driver to display the analog input as it changes.
''
'' Think of it as a 1D Etch-A-Sketch :) 
''
'' William Henning
'' http://www.mikronauts.com
''

CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  tiles    = vga#xtiles * vga#ytiles
  tiles32  = tiles * 16

OBJ

  vga : "vga_640x240_bitmap"
  a2d : "ads7822p"

VAR

  long  a2dinp
  long  sync, pixels[tiles32]
  word  colors[tiles]

PUB start | i, y, s, val

  vga.start(16, @colors, @pixels, @sync)

  'init colors to cyan on blue
  repeat i from 0 to tiles - 1
    colors[i] := $2804

  'a2d.init(0) ' call .init if you want spin version, a2d pins start at pin 0
  a2d.start(@a2dinp,0,9) ' call .start if you want to use a cog and asm version

  repeat
    s := 0 
    repeat y from 0 to 239
      val := a2dinp ' use this line if you want to pick up value from asm version
      'val := a2d.fain9  ' use this line if you init and did not start for spin version
      pixels[s + val >> 5] |= |< val
      s += 20
    if (val == 511) or (val == 0)
      longfill(@pixels,0,tiles32)
 
