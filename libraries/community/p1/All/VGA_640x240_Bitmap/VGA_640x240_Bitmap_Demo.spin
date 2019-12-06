CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  tiles    = vga#xtiles * vga#ytiles
  tiles32  = tiles * 16


OBJ

  vga : "vga_640x240_bitmap"


VAR

  long  sync, pixels[tiles32]
  word  colors[tiles]


PUB start | h, i, j, k, x, y

  'start vga
  vga.start(16, @colors, @pixels, @sync)

  'init colors to cyan on blue
  repeat i from 0 to tiles - 1
    colors[i] := $2804

  'draw some lines  
  repeat y from 0 to 15
    repeat x from 0 to 639
      plot(x, x/y)

  'wait ten seconds
  waitcnt(clkfreq * 5 + cnt)

  'randomize the colors and pixels
  repeat
    colors[||?h // tiles] := ?i
    repeat 100
      pixels[||?j // tiles32] := k?


PRI plot(x,y) | i
    if x => 0 and x < 640 and y => 0 and y < 239
      pixels[y * 20 + x >> 5] |= |< x  
    