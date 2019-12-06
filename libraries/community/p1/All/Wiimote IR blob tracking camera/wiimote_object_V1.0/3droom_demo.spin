{{
Head tracking demo for wiimote:

1. Connect the wii camera up as per instructions in object, modify CON section if required to match pin assignments used.
2. Place camera above TV screen facing away from screen (at the viewer).
3. Attach IR led to glasses or similar, notice how the screen changes as you move your head.
4. Enjoy

Note the 3D stuff is just a quick hack.  To draw a cube two of the corners for the front and back faces of the cube
are defined in the dat section, these are projected on to the screen based on their 3D position and the position
of the head being tracked.  The two squares are then drawn and the remaining edges added.

}}
CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  _stack = ($3000 + $3000 + 100) >> 2   'accomodate display memory and stack

  x_tiles = 16
  y_tiles = 12
    
  scl = 0             ' Pins used for camera connections
  clk = 2
  reset = 3
  
  paramcount = 14       
  bitmap_base = $2000
  display_base = $5000

  vd = 1024
  lines = 5
  thickness = 2

VAR

  long  mousex, mousey
  long  tv_status     '0/1/2 = off/visible/invisible           read-only
  long  tv_enable     '0/? = off/on                            write-only
  long  tv_pins       '%ppmmm = pins                           write-only
  long  tv_mode       '%ccinp = chroma,interlace,ntsc/pal,swap write-only
  long  tv_screen     'pointer to screen (words)               write-only
  long  tv_colors     'pointer to colors (longs)               write-only               
  long  tv_hc         'horizontal cells                        write-only
  long  tv_vc         'vertical cells                          write-only
  long  tv_hx         'horizontal cell expansion               write-only
  long  tv_vx         'vertical cell expansion                 write-only
  long  tv_ho         'horizontal offset                       write-only
  long  tv_vo         'vertical offset                         write-only
  long  tv_broadcast  'broadcast frequency (Hz)                write-only
  long  tv_auralcog   'aural fm cog                            write-only
  word  screen[x_tiles * y_tiles]
  long  colors[64]
  long  out_data[12]
  long  xold
  long  yold

OBJ
  tv    : "tv"
  gr    : "graphics"
  wii   : "wiicamera"

PUB start | i, j, k, kk, dx, dy, pp, pq, rr, numx, numchr ,dir

  wii.Start(scl,clk,reset)     ' Start the wiicamera object  
  wii.initcam(3,@level5)       ' Initilize for mode3 using wii sensitivity 5 (see dat section)

  ' GRAPHICS STUFF:
  'start tv
  longmove(@tv_status, @tvparams, paramcount)
  tv_screen := @screen
  tv_colors := @colors
  tv.start(@tv_status)

  'init colors
  repeat i from 0 to 63
    colors[i] := %11001100_00111110_00111110_00000100
   
  'init tile screen
  repeat dx from 0 to tv_hc - 1
    repeat dy from 0 to tv_vc - 1
      screen[dy * tv_hc + dx] := display_base >> 6 + dy + dx * tv_vc + ((dy & $3F) << 10)

  'start and setup graphics
  gr.start
  gr.setup(16, 12, 128, 96, bitmap_base)
  
  dir := 1

  ' THE INTERESTING BIT:
  
  repeat     
     repeat k from 0 to 20
       wii.getblobs(@out_data)  ' Load blob positions in to out_data 

       gr.clear       
       gr.colorwidth(1,2)

       ' Draw the "room"              
       projection(@square1)     ' Works out position on the screen of the face of one of the cubes
       projection(@square2)     ' Does the same for the other face
       cube(@square1,@square2)  ' Draws the two faces and then joins up the corners

       ' Draw the sticking out cube
       projection(@square3)
       projection(@square4) 
       cube(@square3,@square4) 

       ' Draw its base
       projection(@square5)
       projection(@square6) 
       cube(@square5,@square6) 

       'modify positon values of flying cube
       if dir == 1
         square7[4] := (k*25)
         square8[4] := (k*25+20)
       else
         square7[4] := (25*20)-(k*25)
         square8[4] := (25*20)-(k*25+20)

        'Draw flying cube 
       projection(@square7)
       projection(@square8) 
       cube(@square7,@square8)

        'Draw other big cube
       gr.colorwidth(1,2)  
       projection(@square9)
       projection(@square10) 
       cube(@square9,@square10)

       gr.copy(display_base)          ' Copy to screen 
     !dir                             ' Reverse direction of flying cube


pub cube (boxaddress1,boxaddress2)
{{
Draws two squares representing the front and back faces of a cube and then joins up the corners so they look like cubes
}}
    ' Draws the two faces
    wirebox(long[boxaddress1][5],long[boxaddress1][6],long[boxaddress1][7],long[boxaddress1][8])     
    wirebox(long[boxaddress2][5],long[boxaddress2][6],long[boxaddress2][7],long[boxaddress2][8])

    ' Joins up the corners
    gr.plot(long[boxaddress1][5],long[boxaddress1][6]) 'x1y1   
    gr.line(long[boxaddress2][5],long[boxaddress2][6])
    
    gr.plot(long[boxaddress1][5],long[boxaddress1][8]) 'x1y2
    gr.line(long[boxaddress2][5],long[boxaddress2][8])

    gr.plot(long[boxaddress1][7],long[boxaddress1][8]) 'x1y1
    gr.line(long[boxaddress2][7],long[boxaddress2][8])

    gr.plot(long[boxaddress1][7],long[boxaddress1][6]) 'x1y1
    gr.line(long[boxaddress2][7],long[boxaddress2][6])
 
pub wirebox (x1,y1,x2,y2)
{{ Draws a box }}

    gr.plot(x1,y1)
    gr.line(x1,y2)
    gr.line(x2,y2)
    gr.line(x2,y1)
    gr.line(x1,y1)
    
pub projection (boxaddress)| xv,yv,zv,xo,yo,zo,halfangle
{{ Projects the coordinates of two corners of a square on to the screen from the 3D position inside the "room"}}

    xv := out_data[0]     ' If the led goes off the screen then just use the old x value
    if xv == 1023
      xv := xold
    else
      xv := xv - 512

    yv := out_data[1]     ' Same for y
    if yv == 1023
      yv := yold
    else
      yv := yv - 383

    xold := xv
    yold := yv      

    zv := vd              ' The depth, kept constant at the moment
    
    xo   := long[boxaddress][0]       ' Get corner positions from dat section
    yo   := long[boxaddress][1]
    zo   := long[boxaddress][4]
    long[boxaddress][5] :=  (((xo - xv)*zv)/(zv+zo))+ xv     ' Project on to screen, maths based on similar triangles
    long[boxaddress][6] :=  (((yo + yv)*zv)/(zv+zo))- yv 
    xo   := long[boxaddress][2]                              ' And the other corner
    yo   := long[boxaddress][3]
    long[boxaddress][7] := (((xo - xv)*zv)/(zv+zo))+ xv
    long[boxaddress][8] := (((yo + yv)*zv)/(zv+zo))- yv 

                                   
DAT
' TV parameters:
tvparams                long    0               'status
                        long    1               'enable
                        long    %001_0101       'pins
                        long    %0000           'mode
                        long    0               'screen
                        long    0               'colors
                        long    x_tiles         'hc
                        long    y_tiles         'vc
                        long    10              'hx
                        long    1               'vx
                        long    0               'ho
                        long    0               'vo
                        long    0               'broadcast
                        long    0               'auralcog

' Defining the 3D objects
'Room                        
square1                 long    -134            ' x1 position              0
                        long    -100            ' y1                       1 
                        long    134             ' x2                       2
                        long    100             ' y2                       3
                        long    0               ' z                        4
                        long    0               ' x1 position projected    5
                        long    0               ' y1                       6 
                        long    0               ' x2                       7
                        long    0               ' y2                       8


square2                 long    -134            ' x1 position              0
                        long    -100            ' y1                       1 
                        long    134             ' x2                       2
                        long    100             ' y2                       3
                        long    500             ' z                        4
                        long    0               ' x1 position projected    5
                        long    0               ' y1                       6 
                        long    0               ' x2                       7
                        long    0               ' y2                       8
'cube sticking out
square3                 long    0               ' x1 position              0
                        long    0               ' y1                       1 
                        long    40              ' x2                       2
                        long    40              ' y2                       3
                        long    -10             ' z                        4
                        long    0               ' x1 position projected    5
                        long    0               ' y1                       6 
                        long    0               ' x2                       7
                        long    0               ' y2                       8

square4                 long    0               ' x1 position              0
                        long    0               ' y1                       1 
                        long    40              ' x2                       2
                        long    40              ' y2                       3
                        long    -100            ' z                        4
                        long    0               ' x1 position projected    5
                        long    0               ' y1                       6 
                        long    0               ' x2                       7
                        long    0               ' y2                       8
'base
square5                 long    -20             ' x1 position              0
                        long    -20             ' y1                       1 
                        long    60              ' x2                       2
                        long    60              ' y2                       3
                        long    -10             ' z                        4
                        long    0               ' x1 position projected    5
                        long    0               ' y1                       6 
                        long    0               ' x2                       7
                        long    0               ' y2                       8

square6                 long    -30             ' x1 position              0
                        long    -30             ' y1                       1 
                        long    70              ' x2                       2
                        long    70              ' y2                       3
                        long    0               ' z                        4
                        long    0               ' x1 position projected    5
                        long    0               ' y1                       6 
                        long    0               ' x2                       7
                        long    0               ' y2                       8
                                               
'Moving cube
square7                 long    60              ' x1 position              0
                        long    60              ' y1                       1 
                        long    80              ' x2                       2
                        long    80              ' y2                       3
                        long    1500            ' z                        4
                        long    0               ' x1 position projected    5
                        long    0               ' y1                       6 
                        long    0               ' x2                       7
                        long    0               ' y2                       8

square8                 long    60              ' x1 position              0
                        long    60              ' y1                       1 
                        long    80              ' x2                       2
                        long    80              ' y2                       3
                        long    1520            ' z                        4
                        long    0               ' x1 position projected    5
                        long    0               ' y1                       6 
                        long    0               ' x2                       7
                        long    0               ' y2                       8

'large cube
square9                 long    -60             ' x1 position              0
                        long    -60             ' y1                       1 
                        long    -30             ' x2                       2
                        long    -30             ' y2                       3
                        long    100             ' z                        4
                        long    0               ' x1 position projected    5
                        long    0               ' y1                       6 
                        long    0               ' x2                       7
                        long    0               ' y2                       8

square10                long    -60             ' x1 position              0
                        long    -60             ' y1                       1 
                        long    -30             ' x2                       2
                        long    -30             ' y2                       3
                        long    130             ' z                        4
                        long    0               ' x1 position projected    5
                        long    0               ' y1                       6 
                        long    0               ' x2                       7
                        long    0               ' y2                       8
                             

' Wiimote sensitivity settings, use custom or choose one of the others
                        
custom_settings        byte       $00
                       byte       $00
                       byte       $00
                       byte       $00
                       byte       $00
                       byte       $00
                       byte       $90     ' Max blob size
                       byte       $00
                       byte       $41     ' Gain
                       byte       $40     ' Gain limit
                       byte       $03     ' Min blob size 

                       ' Some settings used by wii and suggested by others, from http://wiibrew.org/wiki/Wiimote

Marcan                 byte       $00,$00,$00,$00,$00,$00,$90,$00,$C0,$40,$00   ' Suggested by Marcan
Cliff                  byte       $02,$00,$00,$71,$01,$00,$AA,$00,$64,$63,$03   ' Suggested by Cliff
inio                   byte       $00,$00,$00,$00,$00,$00,$90,$00,$41,$40,$00   ' Suggested by inio
level1                 byte       $02,$00,$00,$71,$01,$00,$64,$00,$FE,$FD,$05   ' Wii level 1
level2                 byte       $02,$00,$00,$71,$01,$00,$96,$00,$B4,$B3,$04   ' Wii level 2
level3                 byte       $02,$00,$00,$71,$01,$00,$AA,$00,$64,$63,$03   ' Wii level 3 (as per Cliff)
level4                 byte       $02,$00,$00,$71,$01,$00,$C8,$00,$36,$35,$03   ' Wii level 4
level5                 byte       $07,$00,$00,$71,$01,$00,$72,$00,$20,$1F,$03   ' Wii level 5                          