{{ CMUcamDriver.spin, v1.5
   Copyright (c) 2009 Austin Bowen
   *See end of file for terms of use*     

   The baud setting on the CMUcam MUST be jumpered for 9600 baud (JP2 & JP3 set)   
   The camera takes 6 seconds from power up to adjust to the light, it is up to
   the user to make sure your program gives it the time it needs.

   Example:

    OBJ
      CAM : "CMUcamDriver"
   
    VAR
      BYTE N_PACK[9], S_PACK[7]

    CON
      _CLKMODE = XTAL1 + PLL16X
      _XINFREQ = 5_000_000

      'CMUcam pins
      CAM_TX = 22                   'The pin connected to CMUcam's TX pin
      CAM_RX = 23                   'The pin connected to CMUcam's RX pin

      'N Packet
      SPOS     = 0                  '<< "SPOS" used for S Packet too << Servo position
      MIDX     = 1                  'Middle-X
      MIDY     = 2                  'Middle-Y
      OBX1     = 3                  'Object size-X1
      OBY1     = 4                  'Object size-Y1
      OBX2     = 5                  'Object size-X2
      OBY2     = 6                  'Object size-Y2
      PIXCNT   = 7                  'Tracked pixel count
      CONFID   = 8                  'Confidence
       
      'S Packet
      RMEAN    = 1                  'Red mean
      GMEAN    = 2                  'Green mean
      BMEAN    = 3                  'Blue mean
      RDEV     = 4                  'Red deviation
      GDEV     = 5                  'Green deviation
      BDEV     = 6                  'Blue deviation
      
    PUB MAIN
      CAM.START(CAM_TX, CAM_RX, @N_PACK, @S_PACK)


   Packets:
    N Packet: [0]Servo position, [1]Middle-X, [2]Middle-Y, [3]Object size-X1, [4]Object size-Y1,
              [5]Object size-X2, [6]Object size-Y2, [7]Tracked pixel count, [8]Confidence
    S Packet: [0]Servo position, [1]Red mean, [2]Green mean, [3]Blue mean,
              [4]Red deviation, [5]Green deviation, [6]Blue deviation


   Notes:
     * I've made the TX and RX family of subroutines (at the bottom) public so that you may
       send custom commands to the CMUcam if so needed.
     * I specifically chose to use only the N and S packets to give you nearly the most
       information possible.
     * No external objects needed for this program, completely self-contained.    
     * See the subroutines below for information about their functions and how to use them. 
}}

VAR
  'Serial input stacks
  BYTE DATAIN[13], VERSION[12]
  
  'CMUcam TX and RX pins
  LONG CAM_TX, CAM_RX                  
  'RXed packet variable address holders              
  LONG N_ADDR, S_ADDR
  'Statuses
  LONG INIT, ACTIVE, MODE_PM            

PUB START (_CAM_TX, _CAM_RX, _N, _S) | TIMER
{{ Returns TRUE if successful or FALSE if not (ie the camera's not connected/turned on)

   CAM_TX: The pin that is connected to the CMUcam TX pin
   CAM_RX: The pin that is connected to the CMUcam RX pin                  
   _N    : The address of an N Packet stack (9 needed) in the main program 
   _S    : The address of an S Packet stack (7 needed) in the main program
}}                                                     
  IF (CLKFREQ < 80_000_000)     'Return false if the clock frequency is too low
    RETURN                                                                             
  LONGMOVE(@CAM_TX, @_CAM_TX, 2)  'Copy pins
  LONGMOVE(@N_ADDR, @_N, 2)       'Copy packet addresses           
  BYTEFILL(@VERSION, 0, 12)     'Null VERSION string       
  MODE_PM~                      'Reset the Poll Mode variable 
  STOP                          'Stop if already running    
  IDLE                          'Send CR twice to sync with CMUcam
  TX(13)
  TIMER := CNT                  'Return false if CMUcam not connected
  REPEAT UNTIL INA[CAM_TX]
    IF (CNT-TIMER)/(CLKFREQ/2)
      RETURN
  WAITCNT(CLKFREQ/10+CNT)                                          
  TX_STR(STRING("RS", 13))      'Reset
  RX                            'RX extra character
  RX_STR(@VERSION, 13)          'Recieve software version from reset
  WAITCNT(CLKFREQ/10+CNT)                      
  TX_STR(STRING("RM 3", 13))    'Raw Mode %011
  WAITCNT(CLKFREQ/10+CNT)
  TX_STR(STRING("MM 8", 13))    'Set Middle Mass to type N packets %1000
  WAITCNT(CLKFREQ/10+CNT)                                
  TX_STR(STRING("DM 1", 13))    'Set the TX delay
  WAITCNT(CLKFREQ/10+CNT)                            
  'REGISTER(5, 9)                'Set register for 9 frames/s 
  RETURN INIT := TRUE           'Set INIT true and return


'---------- Tracking Related Commands ---------- 
  
PUB TRACK_COLOR (R_MIN, R_MAX, G_MIN, G_MAX, B_MIN, B_MAX)
{{ Tracks a color, defined by the RGB min/max.
    R/G/B_MIN: The minimum Red/Green/Blue color values to track
    R/G/B_MAX: The maximum Red/Green/Blue color values to track
    *NOTE* Set all variables to 0 to track the last color tracked
}}
  IF ACTIVE~~                   'If active, go idle
    IDLE                                                      
  TX_STR(STRING("TC "))         'Send the Track Color command
  IF R_MIN AND R_MAX AND G_MIN AND G_MAX AND B_MIN AND B_MAX  
    TX_DEC(R_MIN)
    TX(" ")
    TX_DEC(R_MAX)
    TX(" ")
    TX_DEC(G_MIN)
    TX(" ")
    TX_DEC(G_MAX)
    TX(" ")
    TX_DEC(B_MIN)
    TX(" ")
    TX_DEC(B_MAX)
  TX(13) 
  RX_WAIT("N")                  'Wait for beginning of N packet
  RX_STR(N_ADDR, 255)           'Recieve the N packet       
  IF MODE_PM                    'If Poll Mode, go idle
    IDLE

  WAITCNT(CLKFREQ/10+CNT)

PUB TRACK_WINDOW
{{ Tracks the color found in the central region of the currently set window.
   After the color is grabbed, the Track Color function is called using the colors grabbed,
   and resets the window size to the default full size (80x143). This can be useful for
   tracking an object held in front of the camera. 
}}
  IF ACTIVE~~                   'If active, go idle
    IDLE           
  TX_STR(STRING("TW", 13))      'Send Track Window command
  RX_WAIT("S")                  'Wait for beginning of S packet
  RX_STR(S_ADDR, 255)           'Recieve S packet
  RX_WAIT("N")                  'Wait for beginning of N packet
  RX_STR(N_ADDR, 255)           'Recieve N packet
  IF MODE_PM                    'If Poll Mode, go idle
    IDLE

  WAITCNT(CLKFREQ/10+CNT)
  
PUB GET_MEAN
{{ Gets the mean (average) color value in the current image. This function only operates
   on the selected region of the image. Also gets a measure of the average absolute
   deviation of color found in that region. Returns the address of your S_PACK.
}}
  IF ACTIVE~~                   'If active, go idle
    IDLE             
  TX_STR(STRING("GM", 13))      'Send Get Mean command
  RX_WAIT("S")                  'Wait for beginning of S packet
  RX_STR(RESULT := S_ADDR, 255) 'Recieve S packet and set RESULT to S_ADDR
  IF MODE_PM                    'If Poll Mode, go idle
    IDLE
  
  WAITCNT(CLKFREQ/10+CNT)
                                                                       
PUB TRACK_LIGHT (MODE)
{{ Controls the tracking light.
    MODE: 2 (default) automatically turns on and off weather the color is tracked or not
          1 turns it on
          0 turns it off
}}                                                                                  
  IF ACTIVE~                    'If active, go idle
    IDLE
  TX_STR(STRING("L1 "))         'Send Track Light command
  TX_DEC(MODE)                  'Send mode
  TX(13)          

  WAITCNT(CLKFREQ/10+CNT)
                      
PUB POLL_MODE (MODE)
{{ Returns only 1 packet when an image processing function is called. This could be useful
   if you would like to rapidly change parameters or you have a slow processor.
    MODE: 1 enables
          0 (default) disables

   *NOTE* This does not truely activate Poll Mode on the CMUcam, but it tells the CMUcam
   to go idle after a color tracking or mean data gathering command is executed.
}}                                                                  
  MODE_PM := MODE        
                      
PUB SWITCHING (MODE)
{{ When enabled, it alternates each frame between returning an S packet and an N packet.
   When disabled, it only returns N packets after the first S packet (if sent).
    MODE: 1 enables
          0 (default) disables
}}                                                                                  
  IF ACTIVE~                    'If active, go idle
    IDLE
  TX_STR(STRING("SM "))         'Send Switching Mode command
  TX_DEC(MODE)                  'Send mode
  TX(13)
                     
PUB UPDATE
{{ Updates the N packet or the S packet, if in a color tracking or mean data gathering loop }}
  IF ACTIVE                     'Proceed if actively tracking or gathering mean data 
    RX_WAIT(255)                'Wait for 255
    CASE RESULT := RX           'Recieve packet type and set RESULT to packet type     
      "N" :                     'Recieve the N packet
        RX_STR(N_ADDR, 255)
      "S" :                     'Recieve the S packet
        RX_STR(S_ADDR, 255)
    

'---------- Servo Related Commands ----------
  
PUB SERVO_TRACKING (MODE)
{{ Tells the servo what to do while tracking colors.
    MODE: 0 disables servo tracking
          1 enables servo tracking
          2 enables servo tracking and reverses the direction
}}
  IF ACTIVE~                    'If active, go idle
    IDLE
  CASE MODE                     'Translate MODE
    0 : MODE := %1000           
    1 : MODE := %1010
    2 : MODE := %1110
  IF (MODE == %1000) OR (MODE == %1010) OR (MODE == %1110)
    TX_STR(STRING("MM "))       'Send Middle Mass command
    TX_DEC(MODE)                'Send MODE
    TX(13)

  WAITCNT(CLKFREQ/10+CNT)

PUB SERVO_POS (VALUE)
{{ Sets the position of the servo. In order for the servo to work, the camera must be in
   either a tracking loop or mean data gather loop.
    VALUE: 0 turns off the servo and holds the line low (useful for digital output)
           1-127 (63 center) sets the servo to that position while tracking or getting mean data 
           128+ sets the line high (useful for digital output)
}}                                                                              
  IF ACTIVE~                    'If active, go idle
    IDLE
  TX_STR(STRING("S1 "))         'Send Servo command
  TX_DEC(RESULT := VALUE)       'Send position value and set RESULT to VALUE
  TX(13)                                                 

  WAITCNT(CLKFREQ/10+CNT)

PUB INPUT
{{ Uses the servo port as a digital input. Returns either a 1 (high) or 0 (low) depending
   on the current voltage level of the servo line. The line is internally pulled high.
}}                                                                                      
  IF ACTIVE~                    'If active, go idle
    IDLE
  TX_STR(STRING("I1", 13))      'Send Servo Input command             
  RESULT := RX                  'Set RESULT to the RXed servo pin state

  WAITCNT(CLKFREQ/10+CNT)


'---------- Other ----------

PUB GET_VER
{{ Returns the address of the string the version was stored in at reset }}                      
  RETURN @VERSION                      
     
PUB IDLE 
{{ Puts the camera into an idle state }}
  TX(13)                        'Send a CR to put the CMUcam into an idle state
  ACTIVE~                       'Clear the ACTIVE variable

  WAITCNT(CLKFREQ/10+CNT)
                                           
PUB NOISE_FILTER (MODE)
{{ Makes the camera more conservative about how it selects tracked pixels, requiring 2
   sequential pixelsfor a pixel to be tracked.
    MODE: 1 (default) enables
          0 disables
}}                                                                                    
  IF ACTIVE~                    'If active, go idle
    IDLE                        
  TX_STR(STRING("NF "))         'Send Noise Filter command
  TX_DEC(MODE)                  'Send MODE 
  TX(13)

  WAITCNT(CLKFREQ/10+CNT)

PUB REGISTER (REG, VALUE)
{{ Sets the camera's internal registers. See page 10 of the User Guide for possible configurations.
    REG  : The register to edit, 0 - 16
    VALUE: The value to set the register to
}}                                           
  IF ACTIVE~                    'If active, go idle
    IDLE
  TX_STR(STRING("CR "))         'Send Change Register command
  TX_DEC(REG)                   'Send the register to change
  TX(" ")                       'Space
  TX_DEC(VALUE)                 'Send the value to change the register to
  TX(13)                                              

  WAITCNT(CLKFREQ/10+CNT)

PUB SET_WINDOW (X1, Y1, X2, Y2)
{{ Sets the window size of the camera. Can be called before an image processing command
   to constrain the field of view. Accepts the X and Y cartesian coordinates of the
   upper left corner followed by the lower right of the window you wish to set.
   *NOTE* The default window size (full screen) is 80x143. Set all to 0 to go full screen
}}                                                                               
  IF ACTIVE~                    'If active, go idle
    IDLE
  TX_STR(STRING("SW "))         'Send Set Window command
  IF X1 AND Y1 AND X2 AND Y2    'If all coordinates are true, transmit coordinates
    TX_DEC(X1)                  
    TX(" ")
    TX_DEC(Y1)
    TX(" ")
    TX_DEC(X2)
    TX(" ")
    TX_DEC(Y2)
  TX(13)

  WAITCNT(CLKFREQ/10+CNT)
     
PUB STOP
{{ Shuts down the CMUcam and CMUcamDriver program }}    
  IDLE                        'Go idle    
  TX_STR(STRING("RS", 13))    'Send Reset command
  BYTEFILL(@DATAIN, 0, 13)    'Null DATAIN
  DIRA[CAM_TX]~               'Set pin registers to inputs and low
  DIRA[CAM_RX]~
  OUTA[CAM_TX]~
  OUTA[CAM_RX]~                
  WAITCNT(CLKFREQ/5+CNT)                              

 
'---------- Serial Communications Subroutines ----------

PUB TX (CHAR) | BR
  BR := CLKFREQ/9600-1700 #> 381                        'Calculate baud rate
  CHAR := ((1 << 8) + CHAR) << 2                        'Set up character with start & stop bit
  DIRA[CAM_RX]~~                                  
  REPEAT 10                                             'Send each bit based on baud rate       
    OUTA[CAM_RX] := CHAR >>= 1 
    WAITCNT(BR+CNT) 

PUB TX_STR (STRPTR)
{{ Transmit a string.
    CAM.TX_STR(STRING("GM", 13"))
}}
  REPEAT STRSIZE(STRPTR)
    TX(BYTE[STRPTR++])

PUB TX_DEC (VALUE) | I
{{ Transmit a decimal value.
    CAM.TX_DEC(63)
}}                                             
  I := 1_000_000_000                                                                          
  REPEAT 10                                                       
    IF (VALUE => I)                                     
      TX(VALUE/I+"0")                   
      VALUE //= I                                                                             
      RESULT~~                                                                                                
    ELSEIF RESULT OR (I == 1)                                                                   
      TX("0")                         
    I /= 10                                                                          

PUB RX | X
{{ Recieve a character.
    STATE := CAM.RX
}}                                     
  DIRA[CAM_TX]~                                        
  WAITPNE(0, |<CAM_TX, 0)                                            
  WAITPEQ(0, |<CAM_TX, 0)                              
  WAITCNT(CLKFREQ/1_000_000*(104+17)*100/90+CNT)
  RESULT := INA[CAM_TX]                                 
  REPEAT X FROM 1 TO 7                                 
    WAITCNT(CLKFREQ/1_000_000*(104-70)+CNT)               
    RESULT := RESULT | (INA[CAM_TX] << X)               

PUB RX_STR (STRPTR, STREND) | ADDR
{{ Recieve a string, ending with STREND
    CAM.RX_STR(@MYSTR, ":")
}}
  ADDR~                                                 
  BYTEFILL(@DATAIN, 0, 13)                     
  REPEAT
    DATAIN[ADDR] := RX                                  
    IF (DATAIN[ADDR] == STREND)                         
      DATAIN[ADDR]~
      IF (STRPTR => 0)
        BYTEMOVE(STRPTR, @DATAIN, ADDR)                            
      RETURN @DATAIN
    ELSE                                                
      IF (ADDR < 13)
        ADDR++
      ELSE
        DATAIN[ADDR]~
    
PUB RX_WAIT (CHAR)
{{ Waits until the specified character is recieved.
    CAM.RX_WAIT(255)
}}
  REPEAT UNTIL (RX == CHAR)
                                   
    
{{Permission is hereby granted, free of charge, to any person obtaining a copy of this software
  and associated documentation files (the "Software"), to deal in the Software without restriction,
  including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
  and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
  subject to the following conditions: 
   
  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. 
   
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
  PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
  FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}}