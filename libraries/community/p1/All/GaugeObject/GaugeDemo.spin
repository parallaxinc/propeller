


''******************************************
''*  GaugeDemo for Gaugfe Object           *
''*  Author: Gregg Erickson  2011          *
''*  See MIT License for Related Copyright *
''*  See end of file and objects for .     *
''*  related copyrights and terms of use   *
''*                                        *
''*  This used code from and based on:     *
''*  Graphics Demo by Chip Gracey 2005     *
''*  TV Object by Chip Gracey 2004         *
''*  Numbers by Jeff Marten 2005           *
''*  and other Parallax Inc & Forum Demos  *
''******************************************

{{  The Gauge Object provides a simple gauge face method for use with the Graphics Object by the top object.
 It handles some common overhead issues such as scaling, fitting within the screen, converting readings to
 degrees and uniform handling of colors.  It uses default values but allows customization.  The resulting
 bitmap can be displayed by the TV.SRC or VGA.SRC driver called by the top object.  By using multiple
 copies of the object, many gauges can easily be drawn with minimum effort.
   
 This Object was designed to be used with single or double buffered graphics memory with a minimum of gitter.
 There is plenty of room to refine and optimize the code for a particular application.  
 For more detailed refinements  that optimize each pixel, the programmer can copy/modify the methods and/or
 access the graphics routine directly.  The "Numbers" Object can also be dropped by using predefined
 text instead doing conversions as was done by example for the scale ratio "t" using in ScaleGauge Method.    

 If no other methods in the top object are using graphics then the programmer may chose to add the TV object
 to a version of this object by incorporating related code such as tile definitions and clock speeds into
 this object. It could also be run in automatic mode thus displaying readings independent of other actions if
 the user  modifies it to launch  in another cog with a repeat loop and pointer to the reading variables.  
 For limited term use such as diagnostics, the ability to start and stop cogs would also allow a user to
 determine the need for video (e.g sense the video plug) and only use the resources to run the TV, Graphics
 and Gauge Objects when needed without recompiling or modifying code. 
  
 }}

{ TypicalCOG and Hardware Pin Assignments are listed below:


***** COGs *****

0 Main     - Control Program, Serial, Gauge Output, Clock Speed, Bilge Monitor
1 TV       - Send Out NTSC Video Signals to TV
2 Graphics - Drawing Graphics and Put in Memory for TV

*****I/O Pins*****

12 Video - Digital Out through 1.1K ohm resistor
13 Video - Digital Out through 560 ohm resistor
14 Video - Digital Out through 220 ohm resistor
15 Audio - (Piezo Disc)

28 EEPROM Clock
29 EEPROM Data
30 Serial Rx - Receive
31 Serial Tx - Transmit

Vss      ground
Vdd      3.3 Volt
}

CON
'------------Constants for Memory and Clock Speed----------

  _clkmode = xtal1 + pll16x           ' Set clock mode to 16x the speed of the crystal
  _xinfreq = 5_000_000                ' Define crystal speed at 5M so clockspeed is 5x16 or 80 Mhz
  _stack = ($2000 +524) >> 2          ' Set Stack large enough for display and variables

'------------Constants for Video ------------------

  x_tiles = 16                        ' Define tiles for video memory used for mapping
  y_tiles = 12                        ' Define tiles for video memory used for mapping    
  paramcount = 14                     ' Define parameter count to pass to the TV object
  display_base = $5000                ' Location of video memory passed to TV

VAR
'------- Variable for TV Output -------------------

  long  tv_status                      '0/1/2 = off/visible/invisible           read-only
  long  tv_enable                      '0/? = off/on                            write-only
  long  tv_pins                        '%ppmmm = pins                           write-only
  long  tv_mode                        '%ccinp = chroma,interlace,ntsc/pal,swap write-only
  long  tv_screen                      'pointer to screen (words)               write-only
  long  tv_colors                      'pointer to colors (longs)               write-only
  long  tv_hc                          'horizontal cells                        write-only
  long  tv_vc                          'vertical cells                          write-only
  long  tv_hx                          'horizontal cell expansion               write-only
  long  tv_vx                          'vertical cell expansion                 write-only
  long  tv_ho                          'horizontal offset                       write-only
  long  tv_vo                          'vertical offset                         write-only
  long  tv_broadcast                   'broadcast frequency (Hz)                write-only
  long  tv_auralcog                    'aural fm cog                            write-only

 ' --------Variables for Graphics ---------
                                       
  word  screen[x_tiles * y_tiles]      ' graphics tiles
  long  colors[64]                     ' color variables
  long  i, dx, dy                      ' index counters used to initialize graphics

' ----------Gauge Variables-----------------------

  Long  testvalue,oldvalue

OBJ                                    
 
  tv       : "tv"                         ' Display Output to TV
  Gge[4]   : "GaugeObject_V1"               ' Draws [multiple] Gauges


PUB start
 
    '-----------Start TV Object and point to the address of the TV variables ---

  longmove(@tv_status, @tvparams, paramcount)
  tv_screen := @screen
  tv_colors := @colors
  tv.start(@tv_status)

                         '---------- initialize colors ----------------
  repeat i from 0 to 63
'
'                  Text (Muted Green?)
'                  |  Dial (Muted Brown?)
'                  |  |  Needle (Light Grey)
'                  |  |  |  Background (Black)
'                  |  |  |  |
    colors[i] := $4b_AC_06_02         ' use 3=text,2=dial,1=needle,0=background

                                 '------- Initilize Tile Screen ---------
  repeat dx from 0 to tv_hc - 1
    repeat dy from 0 to tv_vc - 1
      screen[dy * tv_hc + dx] := display_base >> 6 + dy + dx * tv_vc + ((dy & $3F) << 10)


' ----- Start Gauge Objects -----------------

Gge[0].start(-60,+65,46,display_base)
Gge[1].start(60,+55,56,display_base)
Gge[2].start(-60,-65,46,display_base)
Gge[3].start(60,-65,46,display_base)

'------------------ Main Program---------------
{
GaugeC:=2                 ' Set Inner Bezel to Typical Dial Color
GaugeS:=1                 ' Set Out Bezel to 1 for Colot Contrast
GaugeB:=0                 ' Keep Bezel Thin
BezelOffset:=1            ' Place Inner Bezel 1 Pixel from the Outer
GaugeF:=3                 ' Set Faceplate Color to Typical
GaugeD:=3                 ' Set color of band behind ticks
GaugeP:=1                 ' Set the NeedlePin Color to Typical Needle Color
GaugeN:=1                 ' Set Color of the Needle to Typical Needle
GaugeQ:=GaugeF            ' Set the Needle Background Color to Faceplate Color to Hide Movement.
GaugeW:=2                 ' Set Needlewidth to double thickness
GaugeZ:=1                 ' Set color of scale text
}
'---------------------- Call Methods ----------------


' -----Draw Typical Gauge with Red Zone -------
   Gge[0].Colors(2,1,1,0,1,3,2,1,0,3,1)
   Gge[0].Offsets(6,true,45,315,30,15)
   Gge[0].GaugeAdjust
   Gge[0].Tickband
   Gge[0].GaugeBezel
   Gge[0].GaugeTicks

'-----Draw Hemisphere Gauge------------
   Gge[1].Offsets(6,true,115,255,15,15)
   Gge[1].GaugeAdjust
   Gge[1].GaugeTicks
   Gge[1].GaugeFace

'-----Draw Typical Gauge with Reverse Rotation and Grey Face----
   Gge[2].Offsets(9,false,45,315,30,15)
   Gge[2].GaugeAdjust
   Gge[2].GaugeBezel
   Gge[2].GaugeTicks
   Gge[2].GaugeFace

'-----Draw Simple Gauge with 9 O'Clock as the Origin
   Gge[3].Colors(2,1,1,0,1,3,2,1,0,3,3)
   Gge[3].Offsets(9,true,45,315,30,15)
   Gge[3].GaugeAdjust
   Gge[3].GaugeBezel
   Gge[3].GaugeTicks

'---- Update Dynamic Portions of Gauges

repeat testvalue from 1 to 400
     Gge[0].GaugeScale(0,10,10)
     Gge[0].SmartNumber(testvalue)
     Gge[0].SmartNeedle(testvalue)
     Gge[0].GaugePin
     Gge[0].GaugeTimes

     Gge[1].GaugeScale(0,10,10)
     Gge[1].SmartNumber(testvalue)
     Gge[1].SmartNeedle(testvalue)
     Gge[1].GaugePin
'     Gge[1].GaugeTimes

     Gge[2].GaugeScale(10,10,10)
     Gge[2].SmartNumber(testvalue)
     Gge[2].SmartNeedle(testvalue)
     Gge[2].GaugePin
     Gge[2].GaugeTimes

     Gge[3].GaugeScale(0,100,1)
     Gge[3].SmartNumber(testvalue)
     Gge[3].SmartNeedle(testvalue)
     Gge[3].GaugePin
     Gge[3].GaugeTimes

     oldvalue:=testvalue





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
