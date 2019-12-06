''*****************************
''*  Fishtank v1.0
''*  something absurd for cube
''*       
''*  Doug.Squires@citizensnob.com
''*
''*  uses the graphics libraries i stole from the lamothe book
''*
''*  might do it tile engine style next time
''*  
''*  if you think of something cool to do with it
''*  just email me your changes at doug.squires atAtaT citizensnob.com
''*****************************


CON

  _clkmode = xtal1 + pll8x
  _xinfreq = 10_000_000 + 0000
  _stack = ($3000 + $3000 + 100) >> 2   'accomodate display memory and stack

  x_tiles = 16
  y_tiles = 12

  paramcount = 14       
  bitmap_base = $2000
  display_base = $5000

  lines = 70

  COL_Black =                %0001_0010
  COL_Green =                %0101_1100
  COL_Grey =                 %0000_0100
  COL_Blue =                 %0010_1100

  COLOR_0 = (COL_Black        << 0)
  COLOR_1 = (COL_Green  << 8)
  COLOR_2 = (COL_Grey  << 16)
  COLOR_3 = (COL_Blue  << 24)

   
VAR
  'each color set is a 32 bit var that contains 4 colors
  'the system will support up to 64 of these color sets
  'you can only draw with one of them at a time.
  long currentColorSet 'this is an num indx to the color set, not the color set itself
  long numColors

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
  
  'seed values used by random number generator
  long grassSeed[lines]
  byte leanSeed[lines]
  byte lengthViaAngleStepSeed[lines]
  byte colorRandSeed[lines]
  
  'working x position of line
  byte x[lines]
  'for reset of image to original 
  byte xPure[lines]

  'working lean of blade of grass
  byte grassLean[lines]
  byte grassLeanPure[lines]
  byte grassLeanAccel[lines]
  
  byte  lengthViaAngleStep[lines]
  byte  colorRand[lines]
  byte  lengthViaY[lines]
    
  byte  grassSwayDirection
  byte  grassSwayInc
  byte  accelSwitch

  byte  fishInflateInc
  byte  fishInflateDir

  byte  byteRand

  long refreshTimerCnt

OBJ

  tv    : "tv_drv_010.spin"
  gr    : "graphics_drv_010.spin"


PUB start      | i, j, dx, dy, fpsCnt, xPosInc, yPosInc, swimDir, lastTurnInc, elevateDir, elevateTurnInc

  'start tv
  longmove(@tv_status, @tvparams, paramcount)
  tv_screen := @screen
  tv_colors := @colors
  tv.start(@tv_status)
  
  'init colors
  repeat i from 0 to 64
    'colors[i] := $00001010 * (i+4) & $F + $2B060C02
    colors[i] := COLOR_3 | COLOR_2 | COLOR_1  | COLOR_0
    
  'init tile screen
  repeat dx from 0 to tv_hc - 1
    repeat dy from 0 to tv_vc - 1
      screen[dy * tv_hc + dx] := display_base >> 6 + dy + dx * tv_vc + ((dy & $3F) << 10)

  'initGrass method sets all the initial grass values
  'if i put this method After the gr.start stuff, creates a glitch?
  initGrass
  
  'start and setup graphics
  gr.start  
  gr.setup(16, 12, -25, -5, bitmap_base)

  fpsCnt := 0

  'global var used to reset grass values
  'incremented in drawGrass()
  refreshTimerCnt := 0
  'incrementer between 3 and 30...
  grassSwayInc := 3
  'determines which way we're incrementing
  grassSwayDirection := 0
  'multiplying inc between 0 and 4
  fishInflateInc := 0
  fishInflateDir := 0

  '0=Right, 1=Left
  swimDir:= 0
  'inc since last changed right/left direction
  lastTurnInc := 0

  'this is the things current location and it incs
  xPosInc:=100
  yPosInc:=100

  'duh
  byteRand := 0

  '0=Up, 1=Down
  elevateDir := 0
  'inc since last changed up/down direction
  elevateTurnInc := 0
  
  repeat
    fpsCnt := CNT + 10_333_333
    lastTurnInc++
    elevateTurnInc++
          
   'so far, have observed that calling any "gr." methods in secondary methods causes a glitch?
    gr.clear   

    'obviously, i hope this method call draws grass
    drawGrass

    '****** START Up/Down Direction and Incrementer
    if ( elevateTurnInc > 50 )
      byteRand := ?SPR[1]
      byteRand := byteRand & %00001111
      if ( byteRand == 15)
        elevateDir++
        elevateTurnInc := 0
        if ( elevateDir == 2 )
          elevateDir:=0    

    if ( elevateDir == 0 )
      yPosInc := yPosInc + 1
      if ( yPosInc > 165 )
        elevateDir := 1
        elevateTurnInc := 0
    elseif ( elevateDir == 1 )
      yPosInc := yPosInc - 1            
     if ( yPosInc < 30 )
        elevateDir := 0
        elevateTurnInc := 0
    '****** END Up/Down Direction and Incrementer

    '****** START Right Left Direction and Incrementer
    if ( lastTurnInc > 50 )
      byteRand := ?SPR[1]
      byteRand := byteRand & %00001111
      if ( byteRand == 15)
        swimDir++
        lastTurnInc := 0
        if ( swimDir == 2 )
          swimDir:=0    

    if ( swimDir == 0 )
      drawGloopFishRight( xPosInc, yPosInc, fishInflateInc )
      xPosInc := xPosInc + 1
      if ( xPosInc > 240 )
        swimDir := 1
        lastTurnInc := 0
    elseif ( swimDir == 1 )
      drawGloopFishLeft( xPosInc, yPosInc, fishInflateInc )
      xPosInc := xPosInc - 1            
     if ( xPosInc < 70 )
        swimDir := 0
        lastTurnInc := 0
    '****** END Right Left Direction and Incrementer

    '****** START Inflate        
    byteRand := ?SPR[1]
    byteRand := byteRand & %00001111
    ' stick fishInflateInc in the param to make it swell
    if ( byteRand > 4 )
      if ( fishInflateDir == 0 )
        'fish is growing
        fishInflateInc++
        'gets a certain size and switches dir
        if (fishInflateInc > 8)
          fishInflateDir := 3    

      else
        'fish is shrinking
        fishInflateInc--
        'gets a certain size and switches dir
        if (fishInflateInc == 3)
          fishInflateDir := 0
    '******* END Inflate
      
    gr.copy(display_base)     
    waitcnt(fpsCnt)

' inflate is value between 1 and 4
PUB drawGloopFishRight ( xPos, yPos, inflateFlag ) | inflateAmt

      '' in this frame, glooper is facing right, at rest - mouth closed
      
      '' arc() reference - for the protection of my own sanity:
      '' Draw grass, otherwise called an arc
      ''   x, y
      ''   xr,yr          - radii of arc , am using these values to create a very extreme oval to make grass.
      ''                    also used to create length in a practical sense
      ''           
      ''   angle          - initial angle in bits[12..0] (0..$1FFF = 0°..359.956°) - ? enh.  i'm not seeing it.  
      ''   anglestep      - intended to be length, but isn't exactly because i'm using the arc as an effed up oval of grass
      ''   steps          - number of steps (0 just leaves (x,y) at initial arc position)
      ''                    (will probably gi8ve better grass resolution at higher numbers - but more processing  
      ''   arcmode        - 0: plot point(s)
      ''                    1: line to point(s)
      ''                    2: line between points
      ''                    3: line from point(s) to center

      inflateAmt := 20 + (inflateFlag * 2)
 
      'gray
      gr.colorwidth(2,0)
      'body
      gr.arc(xPos, yPos, 25, inflateAmt, 30, 25, 360, 2)
      'outer eye
      gr.arc(xPos+12, yPos+10, 5, 10, 30, 25, 360, 2)

      'mouth is a straight line - sad
      'gr.plot(xPos+11, yPos-10)
      'gr.line(xPos+21, yPos-10)

      'mouth - smirk
      'gr.arc(xPos+16, yPos-10, 5, 5, 180, 10, 180, 2)      

      'mouth - determined
      gr.arc(xPos+11, yPos-6, 10, 5, -30, -60, 40, 2)      
      
      'fins
      gr.arc(xPos-28, yPos+10, 5, 10, 75, 25, 360, 2)
      gr.arc(xPos-28, yPos-10, 5, 10, 75, 25, 360, 2)
      
      'blue eye ball
      gr.colorwidth(3,0)
      gr.arc(xPos+16, yPos+7, 5, 5, 30, 25, 360, 3)


' inflate is value between 1 and 4
PUB drawGloopFishLeft ( xPos, yPos, inflateFlag ) | inflateAmt

      '' in this frame, glooper is facing right, at rest - mouth closed
      
      '' arc() reference - for the protection of my own sanity:
      '' Draw grass, otherwise called an arc
      ''   x, y
      ''   xr,yr          - radii of arc , am using these values to create a very extreme oval to make grass.
      ''                    also used to create length in a practical sense
      ''           
      ''   angle          - initial angle in bits[12..0] (0..$1FFF = 0°..359.956°) - ? enh.  i'm not seeing it.  
      ''   anglestep      - intended to be length, but isn't exactly because i'm using the arc as an effed up oval of grass
      ''   steps          - number of steps (0 just leaves (x,y) at initial arc position)
      ''                    (will probably gi8ve better grass resolution at higher numbers - but more processing  
      ''   arcmode        - 0: plot point(s)
      ''                    1: line to point(s)
      ''                    2: line between points
      ''                    3: line from point(s) to center

      inflateAmt := 20 + (inflateFlag * 2)

      'gray
      gr.colorwidth(2,0)
      'body
      gr.arc(xPos, yPos, 25, inflateAmt, 30, 25, 360, 2)
      'outer eye
      gr.arc(xPos-12, yPos+10, 5, 10, 30, 25, 360, 2)

      'mouth is a straight line - sad
      gr.plot(xPos-21, yPos-10)
      gr.line(xPos-11, yPos-10)

      'fins
      gr.arc(xPos+28, yPos+10, 5, 10, 75, 25, 360, 2)
      gr.arc(xPos+28, yPos-10, 5, 10, 75, 25, 360, 2)
      
      'blue eye ball
      gr.colorwidth(3,0)
      gr.arc(xPos-16, yPos+7, 5, 5, 30, 25, 360, 3)
      
      
PUB initGrass | i, initLengthViaY
  'the smallest blades of grass are this length:
  initLengthViaY := 20

  'add an accelerator var that changes reactivity of blades to direction
  accelSwitch := 0  
  repeat i from 0 to lines - 1
    'randomizes the x location of the blades    
    grassSeed[i] := SPR[1]
    x[i] := ?grassSeed[i] + 15
    xPure[i] := x[i]

    ' mask MSB to turn this into a 5 bit value?
    leanSeed[i] :=  SPR[1] & %00001111
    grassLean[i] := ?leanSeed[i] & %00111111
    ' if during the course of this thing swaying, the number
    ' gets too small, it will glitch...  buffering with +5 for now
    grassLeanPure[i] := grassLean[i] + 5
    
    'colorRandSeed[i] := SPR[1] & %00000011
    'colorRand[i] := ?colorRandSeed[i] & %00000011
    colorRand[i] := 1
    
    if initLengthViaY > 70
      initLengthViaY := 20
    lengthViaY[i] := initLengthViaY += 1 
    
    lengthViaAngleStepSeed[i] := SPR[1] & %01111111
    lengthViaAngleStep[i] := ?lengthViaAngleStepSeed[i]

    if (accelSwitch == 0)       
      grassLeanAccel[i] := 1
      accelSwitch := 1
    elseif (accelSwitch == 1)
      grassLeanAccel[i] := 2
      accelSwitch := 2
    elseif (accelSwitch == 2)
      grassLeanAccel[i] := 3
      accelSwitch := 0  

PUB drawGrass | i 

    refreshTimerCnt++
    ' every 12 loops of this method - the amount
    ' of reactivity of each blade of grass should change
    ' between 1 and 3 (should make constants)...
    if ( refreshTimerCnt > 12 )
      repeat i from 0 to lines - 1 
        if ( grassLeanAccel[i] == 3 )
          grassLeanAccel[i] := 1
        else
          grassLeanAccel[i]++    
      refreshTimerCnt := 0

    ' changes the direction of grass sway within certain boundaries
    ' right now between 4 and 8...  (should make constants)
    if ( grassSwayInc > 8  )
      grassSwayDirection := 0
    elseif ( grassSwayInc < 4  )
      grassSwayDirection := 1
      'the image drifts, so this should be an reset of the original image
      'every time the blade of grass finds itself "near" it's original origin      
      repeat i from 0 to lines - 1 
        x[i] := xPure[i]
        grassLean[i] := grassLeanPure[i]

    'this increments the sway variable in the overall direction of the blades
    if ( grassSwayDirection == 1 )
      grassSwayInc += 1
    elseif ( grassSwayDirection == 0 )
      grassSwayInc -= 1
   
    repeat i from 0 to lines - 1
      gr.colorwidth(colorRand[i],0)
    '
    '' for the protection of my own sanity:
      '' Draw grass, otherwise called an arc
      ''   x, y
      ''   xr,yr          - radii of arc , am using these values to create a very extreme oval to make grass.
      ''                    also used to create length in a practical sense
      ''           
      ''   angle          - initial angle in bits[12..0] (0..$1FFF = 0°..359.956°) - ? enh.  i'm not seeing it.  
      ''   anglestep      - intended to be length, but isn't exactly because i'm using the arc as an effed up oval of grass
      ''   steps          - number of steps (0 just leaves (x,y) at initial arc position)
      ''                    (will probably gi8ve better grass resolution at higher numbers - but more processing  
      ''   arcmode        - 0: plot point(s)
      ''                    1: line to point(s)
      ''                    2: line between points
      ''                    3: line from point(s) to center
      gr.arc(x[i], 0, 10 + grassLean[i], lengthViaY[i], 0, 100+lengthViaAngleStep[i], 8, 2)

      'based on current direction of blades of grass, moves the blade by
      'it's individual accelerator
      if ( grassSwayDirection == 1 )
        grassLean[i] += grassLeanAccel[i]
        x[i] -= grassLeanAccel[i]
      elseif ( grassSwayDirection == 0 ) 
        grassLean[i] -= grassLeanAccel[i]
        x[i] += grassLeanAccel[i] 

DAT

pchipDos                byte    "Computer",0 

tvparams                long    0               'status
                        long    1               'enable
                        long    %011_0000       'pins
                        long    %0000           'mode
                        long    0               'screen
                        long    0               'colors
                        long    x_tiles         'hc
                        long    y_tiles         'vc
                        long    10              'hx
                        long    1               'vx
                        long    0               'ho
                        long    0               'vo
                        long    60_000_000'_xinfreq<<4  'broadcast
                        long    0               'auralcog

vecdef                  word    $4000+$2000/3*0         'triangle
                        word    50
                        word    $8000+$2000/3*1+1
                        word    50
                        word    $8000+$2000/3*2-1
                        word    50
                        word    $8000+$2000/3*0
                        word    50
                        word    0

vecdef2                 word    $4000+$2000/12*0        'star
                        word    50
                        word    $8000+$2000/12*1
                        word    20
                        word    $8000+$2000/12*2
                        word    50
                        word    $8000+$2000/12*3
                        word    20
                        word    $8000+$2000/12*4
                        word    50
                        word    $8000+$2000/12*5
                        word    20
                        word    $8000+$2000/12*6
                        word    50
                        word    $8000+$2000/12*7
                        word    20
                        word    $8000+$2000/12*8
                        word    50
                        word    $8000+$2000/12*9
                        word    20
                        word    $8000+$2000/12*10
                        word    50
                        word    $8000+$2000/12*11
                        word    20
                        word    $8000+$2000/12*0
                        word    50
                        word    0

pixdef                  word                            'crosshair
                        byte    2,7,3,3
                        word    %%00333000,%%00000000
                        word    %%03020300,%%00000000
                        word    %%30020030,%%00000000
                        word    %%32222230,%%00000000
                        word    %%30020030,%%02000000
                        word    %%03020300,%%22200000
                        word    %%00333000,%%02000000

pixdef2                 word                            'dog
                        byte    1,4,0,3
                        word    %%20000022
                        word    %%02222222
                        word    %%02222200
                        word    %%02000200

           'text