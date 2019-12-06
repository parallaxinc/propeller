{{
 A simple example where the position of up to 4 LEDs is tracked and shown on the screen by a small sprite.

 1. Wire as per documentation in wiicamera.spin
 2. Change CON section if required to match wiring
 3. Connect TV, changing base pin if needed
 4. Wave IR leds in front of the camera :)
}}
CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  _stack = ($3000 + $3000 + 100) >> 2   'accomodate display memory and stack

  x_tiles = 16
  y_tiles = 12

  paramcount = 14       
  bitmap_base = $2000
  display_base = $5000

  lines = 5
  thickness = 2
  mode = 5

  scl = 0             ' Pins used for camera connections
  clk = 2
  reset = 3  

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
  long  out[37]

  byte  x[lines]
  byte  y[lines]
  byte  xs[lines]
  byte  ys[lines]
  

OBJ
  tv    : "tv"
  gr    : "graphics"
  wii   : "wiicamera"

PUB start | i, j, k, kk, dx, dy, pp, pq, rr, numx, numchr,blobs

  '*********** GRAPHICS SETUP ********************                                                                          
  'start tv
  longmove(@tv_status, @tvparams, paramcount)
  tv_screen := @screen
  tv_colors := @colors
  tv.start(@tv_status)

  'init colors
  repeat i from 0 to 63
    colors[i] := $00001010 * (i+4) & $F + $2B060C02

  'init tile screen
  repeat dx from 0 to tv_hc - 1
    repeat dy from 0 to tv_vc - 1
      screen[dy * tv_hc + dx] := display_base >> 6 + dy + dx * tv_vc + ((dy & $3F) << 10)

  'start and setup graphics
  gr.start
  gr.setup(16, 12, 128, 96, bitmap_base)
  gr.colorwidth(2,3)

  '************* The WII bit ****************  
  wii.Start(scl,clk,reset)     ' Start the wiicamera object  
  wii.initcam(mode,@level2)    ' Try different sensitivities if you have problems

  repeat
     wii.getblobs (@out)
     gr.clear
     repeat blobs from 0 to 3
        if wii.getx(@out,mode,blobs) <> 1023
           ' Draw the sprite, the positions are centered and scaled
           gr.pix((wii.getx(@out,mode,blobs)-512)/5, -(wii.gety(@out,mode,blobs)-383)/5,0,@mote)      
     gr.copy(display_base)

DAT

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


mote                    word                    ' Sprite of a wiimote
                        byte   1,12,0,0
                        word   %%02222200
                        word   %%02202200
                        word   %%02000200
                        word   %%02202200
                        word   %%02222200
                        word   %%02202200
                        word   %%02222200
                        word   %%02000200
                        word   %%02222200
                        word   %%02202200
                        word   %%02202200
                        word   %%02222200
                        

Marcan                 byte       $00,$00,$00,$00,$00,$00,$90,$00,$C0,$40,$00,$00   ' Suggested by Marcan
Cliff                  byte       $02,$00,$00,$71,$01,$00,$AA,$00,$64,$63,$03,$00   ' Suggested by Cliff
inio                   byte       $00,$00,$00,$00,$00,$00,$90,$00,$41,$40,$00,$00   ' Suggested by inio
level1                 byte       $02,$00,$00,$71,$01,$00,$64,$00,$FE,$FD,$05,$00   ' Wii level 1
level2                 byte       $02,$00,$00,$71,$01,$00,$96,$00,$B4,$B3,$04,$00   ' Wii level 2
level3                 byte       $02,$00,$00,$71,$01,$00,$AA,$00,$64,$63,$03,$00   ' Wii level 3 (as per Cliff)
level4                 byte       $02,$00,$00,$71,$01,$00,$C8,$00,$36,$35,$03,$00   ' Wii level 4
level5                 byte       $07,$00,$00,$71,$01,$00,$72,$00,$20,$1F,$03,$00   ' Wii level 5                        
                        

                                 