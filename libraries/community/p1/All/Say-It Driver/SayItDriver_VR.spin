{{
 ***************************************
 * SayItDriver_VR.spin,                *
 *  Copyright (c) 2011 Jeffrey J. Rick *
 *  Last update: 01-15-11              *
 *  *See end of file for terms of use* *
 ***************************************

  This is a driver for the Parallax Say-It Module (AKA VeeaR Module).
     This program requires the "FullDuplexSerial" and the "BS2_Functions"
     objects for proper communication between the Propeller and Say-It
     Module. It also does not use an additional COG for operation. Check
     each subroutine below for the documentation on how to use them.
     
                                ********
  NOTE: THIS OBJECT DOES NOT PROGRAM THE SAY-IT MODULE WITH CUSTOM COMMANDS!
        TO PROGRAM THE SAY-IT MODULE, YOU MUST DOWNLOAD AND INSTALL THE
        PROGRAMMING SOFTWARE FROM EITHER PARALLAX OR ANOTHER WEBSITE THAT
        OFFERS SUPPORT FOR THE SAY-IT MODULE OR VEEAR MODULE.
                                ********
                                
  This object makes the following assumptions:
  
     * You have connected the Say-It Module (or VeeaR Module) to the propeller
     and have assigned its pins to their appropriate functions designations
     (ex.    COM_RX   = 13       ' Say-It Module RX Pin)

     * You have placed the "FullDuplexSerial" and the "BS2_Functions" objects
     in the same folder as this object to allow this object to use the
     methods in the "FullDuplexSerial" and the "BS2_Functions" objects.

     * You have connected the Say-It Module to a 5VDC power supply.

     * If using custom commands with the Say-It Module, you have modified the
     'constants' list labeled "Groups and Commands" to reflect these changes.
                                                                            
  There are two ways this driver may be used:
  
     1) Use this as an object and call it's methods as needed by
     incorperating this driver into your top file as described below.
     If this is done, you may test its pre-programmed functions with the
     ACTION method below or by modifying either the ACTION method or
     VR_ACTION method to incorperate the pre-programmed and custom commands.
       
     2)Use this driver as a top object by adding additional objects to the
     objects declaration list and editing the Action method or the VR_Action
     method with additional commands to fit your needs.
      
       * NOTE: If this option is chosen, it is recommended to start any new
       objects in seperate cogs. While this object does not require the use
       of an additional cog itself, calling methods in other objects by using
       this driver considerably slows down the performance of this driver. By
       starting additional methods in new cogs it will optimize the execution
       speed of this driver.   

  *******************************************************************************
                                
   Here's how to include the object:

OBJ
     SAY : "SayItDriver_VR"     'Say-It Module driver
   
CON
     _CLKMODE = XTAL1 + PLL16X
     _XINFREQ = 5_000_000
    
  'Pins                    
  COM_RX   = 13       ' Say-It Module RX Pin             
  COM_TX   = 12       ' Say-It Module TX Pin             
  VRLED    = 14       ' Say-It Module LED Pin   
  SAY_BAUD = 9600     'Required Baud rate for Say-It Module is 9600
     
PUB MAIN
 
  SAY.START(13, 12, 14, 9600)                   'use to start using Say-It Module

  *******************************************************************************

}}   

CON
' Protocol Command

CMD_BREAK           =         "b" ' abort recog or ping
CMD_SLEEP           =         "s" ' go to power down
CMD_KNOB            =         "k" ' set si knob <1>
CMD_LEVEL           =         "v" ' set sd level <1>
CMD_LANGUAGE        =         "l" ' set si language <1>
CMD_TIMEOUT         =         "o" ' set timeout <1>
CMD_RECOG_SI        =         "i" ' do si recog from ws <1>
CMD_RECOG_SD        =         "d" ' do sd recog at group <1> (0 = trigger mixed si/sd)

' Protocol Status
STS_AWAKEN          =         "w" ' back from power down mode
STS_ERROR           =         "e" ' signal error code <1-2>
STS_INVALID         =         "v" ' invalid command or argument
STS_TIMEOUT         =         "t" ' timeout expired
STS_INTERR          =         "i" ' back from aborted recognition (see 'break')
STS_SUCCESS         =         "o" ' no errors status
STS_RESULT          =         "r" ' recognised sd command <1> - training similar to sd <1>
STS_SIMILAR         =         "s" ' recognised si <1> (in mixed si/sd) - training similar to si <1>

' Protocol arguments are in the range 0x40 (-1) TO 0x60 (+31) inclusive
ARG_MIN             =         64 ' 0x40
ARG_MAX             =         96 ' 0x60
ARG_ZERO            =         65 ' 0x41

ARG_ACK             =         32 ' 0x20    'TO READ more status arguments

' Wordset
WST                 =         0  ' wordset trigger
WS1                 =         1  ' Wordset 1 commands
WS2                 =         2  ' Wordset 2 actions
WS3                 =         3  ' Wordset 3 numbers

'Wordset Commands
WS1_Action          =   0
WS1_Move            =   1
WS1_Turn            =   2
WS1_Run             =   3
WS1_Look            =   4
WS1_Attack          =   5
WS1_Stop            =   6
WS1_Hello           =   7

WS2_Left            =   0
WS2_Right           =   1
WS2_Up              =   2
WS2_Down            =   3
WS2_Forward         =   4
WS2_Backward        =   5

WS3_Zero            =   0
WS3_One             =   1
WS3_Two             =   2
WS3_Three           =   3
WS3_Four            =   4
WS3_Five            =   5
WS3_Six             =   6
WS3_Seven           =   7
WS3_Eight           =   8
WS3_Nine            =   9
WS3_Ten             =   10

WS_Timeout          =   254
WS_Error            =   255

DAT
VAR_LANG           LONG 0       ' DATA 0                     
VAR_KNOB           LONG 2       ' DATA 2
VAR_LEVEL          LONG 2       ' DATA 2
CON
'----------------------------------------------------------------------------------------------
'-----------------------------Commands generated by GUI----------------------------------------
'----------The following commands are generated by the Say-It software's GUI.------------------
'----------Please remember to edit this portion with additional commands you will be ----------
'----------using in your application. This program will not recognize any words not -----------
'----------included in this section.  ---------------------------------------------------------
'---------------------------------------------------------------------------------------------- 
{{
               NOTE: THESE COMMANDS ARE EXAMPLES ONLY! THEY WILL NOT BE RECOGNIZED
               BY THE SAY-IT MODULE UNLESS THEY ARE PROGRAMMED INTO THE MODULE USING
               THE SAY-IT MODULE'S PROGRAMMING SOFTWARE (AVAILABLE AT PARALLAX OR
               OTHER SAY-IT OR VEEAR MODULE SUPPLIERS).
 }}
               
 'Groups and Commands                          'these are user programmed voice commands
               
GROUP_0             =   0    '(Command count: 1)
G0_CUSTOM_TRIGGER                          =   0
      
GROUP_1             =   1    '(Command count: 6)
G1_GREEN                            =   0
G1_RED                              =   1
G1_GREEN_BLINK                      =   2
G1_RED_BLINK                        =   3
G1_BLINK_BOTH                       =   4
G1_BOTH_BLINK                       =   5

GROUP_2             =   2    '(Command count: 2)
G2_YES                              =   0
G2_NO                               =   1

GROUP_3             =   3    '(Command count: 3)
G3_HOW_ARE_YOU                      =   0
G3_WHAT_TIME_IS_IT                  =   1
G3_WHAT_IS                          =   2

GROUP_4             =   4    '(Command count: 3)
G4_TIME                             =   0
G4_TEMPRATURE                       =   1
G4_YOUR_NAME                        =   2

'Groups and Commands                          'these are error codes   
RES_ERROR           = 255
RES_TIMEOUT         = 254
RES_COMMFAIL        = 253
RES_BUILTIN         = 32

'---------------------------------------------------------------------------------------------
'----------------------------------End of User Programmed GUI---------------------------------
'---------------------------------------------------------------------------------------------

CON   
'--------------------------------------------------------------------------------------------
'------------------------This section is from the GUI interface software---------------------
'-------------------------------------for the SAY-IT Module.---------------------------------
'--------------------------------------------------------------------------------------------

  COM_TIMEOUT =   5000                    

  ' Protocol Command
  CMD_SEND           =   1 ' send request
  CMD_SEND_RECEIVE   =   2 ' send and receive request
  CMD_RECEIVE        =   3 ' receive request
  CMD_LED            =   4 ' receive request
  CMD_SET_LANG       =   5 ' receive request
  CMD_GET_LANG       =   6 ' receive request


  CODE_ERROR         =  48  ' 0x30           
  CODE_ACK           =  32  ' 0x20
  
CON
  Mode = 1  '1=non inverted, 0 = inverted
  bits = 8
   
'--------------------------------------------------------------------------------------------
'------------These subroutines are used at the start up of the SAY-IT Module-----------------
'--------------------------------------------------------------------------------------------
   
VAR
'Global Variables
Word    counter             
Byte    VRA, VRA1, WS, RXC, RXC_PREV, VRLED
Byte    VRGROUP, VRCOMMAND, MSG    
Long    COM_RX, COM_TX, SAY_BAUD

OBJ
        DEBUG   : "FullDuplexSerial"                                'communicates with serial terminal
        BS2     : "BS2_Functions"                                   'Basic Stamp 2 library 
        
PUB START (_COM_RX, _COM_TX, _VRLED, _SAY_BAUD)               'Say-It CODE START
'Main Start
{{ Saves the Communication Pins and sets the baud rate   }}
                                
  IF (CLKFREQ <> 80_000_000)
    RETURN
  COM_RX := _COM_RX #> 0 <# 31
  COM_TX := _COM_TX #> 0 <# 31
  SAY_BAUD := 9600
  VRLED := _VRLED #> 0 <# 31
  dira[VRLED]~~
  DEBUG.start(31, 30, 0, 57600)   'start debug (FullDuplexSerial)
  waitcnt(clkfreq + cnt)  
  DEBUG.tx($0D)
  waitcnt(clkfreq + cnt)
  BS2.start(13, 12)                'starts BS2_Functions (say_it rx, tx)
  
  BEGIN_VR                             ' Goto BEGIN_VR sub routine
                                    
PUB BEGIN_VR                'THIS METHOD INITIALIZES THE SAY-IT MODULE AND PREPARES IT FOR USE
' Main Start                      
  outa[VRLED]~~                     'LED LOW
  MSG := $22
  BS2.SEROUT_Char(COM_TX, MSG, 9600, BS2#NInv,8)
  MSG := BS2.SERIN_Char(COM_RX, SAY_BAUD, BS2#NInv,8)
  IF MSG <> $55
     MAIN_CONTROL
     
  'Wake up or stop recognition
  VR_Wakeup 
 
  'Set Language
  VRA1 := 0
  VR_SetLanguage 
  DEBUG.str(string("        language "))
  DEBUG.dec(VRA1)
  DEBUG.str(string( " ... (0 = English)", 13))

  BS2.SEROUT_Char(COM_TX, MSG, 9600, BS2#NInv,8)
  DEBUG.str(string("VR system is ready!", 13))
 
  BLINK
  
  MAIN_LOOP

PUB MAIN_CONTROL

    DEBUG.str(string("SAY-IT DRIVER", 13))
    DEBUG.str(string("Last Update: 01-15-11", 13))
    DEBUG.str(string("Wake Up Voice Module", 13))
           
    'start with trigger
    WS := WST
        
PUB ACTION               'YOUR OWN COMMANDS MAY BE ADDED TO THIS METHOD IF YOU ARE USING THIS AS YOUR TOP FILE

  'SELECT WS
  CASE WS
    WST :      WS := WS1
               IF RXC > 0 
                DEBUG.str(string("Custom Trigger", 13)) 'WS = WST? debug message

    WS1 :      RXC_PREV := RXC
               WS := WST
               'SELECT RXC
                CASE RXC
                  WS1_Move :   DEBUG.str(string("Move", 13)) 'RXC = WS1_Move? debug message (MOVE)
                               WS := WS2                     
                               '-- write your code here
                  WS1_Turn :   DEBUG.str(string("Turn", 13)) 'RXC = WS1_TurnT? debug message(TURN)
                               WS := WS2
      
                  WS1_Run  :   DEBUG.str(string("Run", 13)) 'RXC = WS1_Run? debug message'(RUN)
                               WS := WS2

                  'This command is for testing numbers
                  WS1_Action:  DEBUG.str(string("Action", 13)) 'RXC = WS1_Action? debug message
                               'BS2.PAUSE(1000)
                               WS := WS3

                 'Following commands do nothing
                  WS1_Look  :  DEBUG.str(string("Look", 13)) 'RXC = WS1_Look? debug message
                               'BS2.PAUSE(1000)
                               WS:= WS2

                  WS1_Attack:  DEBUG.str(string("Attack", 13)) 'RXC = WS1_Attack? debug message
                               'BS2.PAUSE(2000)
     
                  WS1_Hello :  DEBUG.str(string("Hello", 13)) 'RXC = WS1_Hello? debug message
                               'BS2.PAUSE(2000)
                                
                  WS1_Stop  :  DEBUG.str(string("Stop", 13)) 'RXC = WS1_Stop? debug message
                               'BS2.PAUSE(2000)
    
                  OTHER     :  DEBUG.str(string("Invalid Command", 13)) 'case else? debug message
                               'BS2.PAUSE(2000)
                  

    WS2 :      'SELECT RXC
               CASE RXC
                  WS2_Left    :  DEBUG.str(string("Left", 13)) 'RXC = WS2_Left? debug message (LEFT)
       
                  WS2_Right   :  DEBUG.str(string("Right", 13)) 'RXC = WS2_Right? debug message(RIGHT)
      
                  WS2_Forward :  DEBUG.str(string("Forward", 13)) 'RXC = WS2_Forward? debug message(FORWARD)

                  WS2_Backward:  DEBUG.str(string("Backward", 13)) 'RXC = WS2_Backward? debug message(BACKWARD)


                                    'Following commands do nothing
                  WS2_Up      :  DEBUG.str(string("Up", 13)) 'RXC = WS2_Up? debug message (UP)
       
                  WS2_Down    :  DEBUG.str(string("Down", 13)) 'RXC = WS2_Down? debug message(DOWN)
      
                  OTHER       :  DEBUG.str(string("Invalid Command", 13)) 'case else? debug message
               'ENDSELECT
               WS := WST

    WS3 :      DEBUG.str(string("Number  ")) 'RXC = WS3? debug message
               DEBUG.dec(RXC)
               DEBUG.str(string(" ", 13)) 
               WS := WST

  'ENDSELECT

  RETURN
                                   
PUB MAIN_LOOP
 outa[VRLED]~~
 DEBUG.str(string("Wait for "))
 
  CASE WS                       'SELECT WS
   0 :   DEBUG.str(string("Trigger", 13))               'WS = 0? debug message
         BS2.PAUSE(150)
   1 :   DEBUG.str(string("WS1", 13))                   'WS = 1? debug message
         outa[VRLED]~
   2 :   DEBUG.str(string("WS2", 13))                   'WS = 2? debug message
         BS2.PAUSE(150)
         outa[VRLED]~
   3 :   DEBUG.str(string("WS3", 13))                   'WS = 3? debug message
         BS2.PAUSE(150)
         outa[VRLED]~
  'ENDSELECT

 VRA1 := WS
 VR_Recognize
 RXC := VRA1
 outa[VRLED]~~

 IF RXC < WS_Timeout
    ACTION
    MAIN_LOOP
 elseIF  RXC == WS_Timeout            'was if, not elseif
    DEBUG.str(string("Timeout",13))
 ELSE'IF RXC = WS_Error
    DEBUG.str(string("Error",13))
 WS := WST
 MAIN_LOOP
               
 'VR_Loop                           'use this to call VR_Loop method instead of MAIN_LOOP method
                                    '(remember to comment out MAIN_LOOP method if VR_Loop is used)
'END MAIN LOOP

{{
****************************************************************************************************
****************************************************************************************************
****************************************************************************************************
}}                                
PUB VR_Loop             'THIS METHOD IS SUGGESTED FOR THE VEEAR MODULE
 
  DEBUG.str(string("VRbot in group ", 13))
  DEBUG.dec(VRGROUP)
  DEBUG.str(string(" waiting for command... ", 13))
  outa[VRLED]~~                                               'LED LOW
  BS2.Pause(150)                                                                             
  IF VRGROUP > 0
   'outa[VRLED]~
  VRA1 := VRGROUP
  VR_RecognizeSD
  '-- handle errors or timeout  
  IF VRA1 == RES_ERROR
    DEBUG.str(string("error", 13))
    'try again in the same group
    VR_Loop
  'ENDIF
  IF VRA1 == RES_TIMEOUT
    DEBUG.str(string("timed out", 13))
    VRGROUP := 0 ' back to trigger
    VR_Loop
  'ENDIF
  IF VRA1 == RES_COMMFAIL
    DEBUG.str(string("comm failed", 13))
    'resync and try again
    VR_Wakeup
    VR_Loop
  'ENDIF
  '-- got a command
  VRCOMMAND := VRA1

  IF VRCOMMAND <= RES_BUILTIN
    VR_Action                              
  VR_Loop
   

PUB VR_Action           'THIS METHOD IS SUGGESTED FOR THE VEEAR MODULE
{{
  This method is meant to be a sample and will not work properly unless you have programmed
the Say-It Module with commands matching the ones described below and defined in the "constants"
list labled "Groups and Commands" in the declarations above. Further, to use this method as-is,
you must also connect LEDs TO Propeller pins 14 and 15. Change this method as needed to accomodate
your personalized commands and outputs.
}}  
  DEBUG.str(string("got "))
  DEBUG.dec(VRCOMMAND)
  DEBUG.str(string(" ", 13))
   
  IF vrcommand == 32
   vrgroup := 1

  CASE VRGROUP                  'SELECT VRGROUP
    GROUP_1:  CASE VRCOMMAND      'SELECT VRCOMMAND
                G1_GREEN   :         BS2.PAUSE (0)
                                     OUTA[14]~~       'GREEN LED
                                     OUTA[15]~        'RED LED
                G1_RED     :         BS2.PAUSE (0)
                                     OUTA[14]~
                                     OUTA[15]~~       '-- write your code here 
         
                G1_GREEN_BLINK :     BS2.PAUSE (0)
                                     OUTA[14]~~
                                     REPEAT  15
                                      OUTA[15]~
                                      BS2.PAUSE (100)
                                      OUTA[15]~~
                                      BS2.PAUSE (100)
                                      OUTA[15]~
                                     OUTA[15]~~
         
                G1_RED_BLINK   :     BS2.PAUSE (0)
                                     OUTA[15]~~
                                     REPEAT  15
                                      OUTA[14]~
                                      BS2.PAUSE (100)
                                      OUTA[14]~~
                                      BS2.PAUSE (100)
                                      OUTA[14]~
                                     OUTA[14]~~
         
                G1_BLINK_BOTH  :     BS2.PAUSE (0)
                                     OUTA[14]~
                                     OUTA[15]~~
                                     REPEAT  15
                                      OUTA[14]~
                                      OUTA[15]~
                                      BS2.PAUSE (100)
                                      OUTA[14]~~
                                      OUTA[15]~~
                                      BS2.PAUSE (100)
                                      OUTA[14]~
                                      OUTA[15]~
                                     OUTA[15]~~
                                     OUTA[14]~~                 
      'ENDSELECT
  'ENDSELECT
  RETURN
  
{{
****************************************************************************************************
****************************************************************************************************
****************************************************************************************************
}}      
PRI VR_Wakeup        
      DEBUG.str(string("        Starting VR_Wakeup... ",13))
    VRA := CMD_BREAK
    BS2.SEROUT_Char(COM_TX, VRA, 9600, BS2#NInv,8)       
       
    VRA:= BS2.SERIN_Char(COM_RX, SAY_BAUD, BS2#NInv,8)     
         
  IF (VRA <> STS_SUCCESS)
    VR_Wakeup 
                    
  RETURN
                                                   
PRI VR_SetLanguage 
    DEBUG.str(string("        Starting VR_SetLanguage... ",13))     
    VRA := CMD_LANGUAGE
    BS2.SEROUT_Char(COM_TX, VRA, 9600, BS2#NInv,8)     
    VRA1 := VRA1 + ARG_ZERO
    BS2.SEROUT_Char(COM_TX, VRA1, 9600, BS2#NInv,8)
      
  VRA := BS2.SERIN_Char(COM_RX, SAY_BAUD, BS2#NInv,8)
  
  VRA1 := VRA1 - ARG_ZERO                                                       
  RETURN                          
' Inputs:
'   VRA1 = timeout (in ms, 0=forever, 255=default)       

PRI VR_SetLanguage1                       
  VRA := BS2.SERIN_Char(COM_RX, SAY_BAUD, BS2#NInv,8)
  RETURN

PRI VR_SetTimeout    
      DEBUG.str(string("        Starting VR_SetTimeout... ",13))
      VRA := CMD_TIMEOUT
      BS2.SEROUT_Char(COM_TX, VRA, 9600, BS2#NInv,8) 
      VRA1 := VRA1 + ARG_ZERO
      BS2.SEROUT_Char(COM_TX, VRA1, 9600, BS2#NInv,8)
    VR_SetTimeout1
    
PRI VR_SetTimeout1           
  VRA := BS2.SERIN_Char(COM_RX, SAY_BAUD, BS2#NInv,8)

  RETURN
  
' Inputs:
'   VRA1 = SI knob (0=loosest, 2=normal, 4=tightest)

PRI VR_SetKnob          
    DEBUG.str(string("          Starting VR_SetKnob... ",13))    
    VRA := CMD_KNOB
    BS2.SEROUT_Char(COM_TX, VRA, 9600, BS2#NInv,8) 
    VRA1 := VRA1 + ARG_ZERO
    BS2.SEROUT_Char(COM_TX, VRA1, 9600, BS2#NInv,8)
    VRA := BS2.SERIN_STR(COM_RX, VRA, SAY_BAUD, Mode, bits)
   VRA1 := VRA1 - ARG_ZERO

  RETURN

' Inputs:
'   VRA1 = SD level (1=easy, 2=default, 5=hard)

PRI VR_SetLevel 
  DEBUG.str(string("            Starting VR_SetLevel... ",13))          
  VRA := CMD_LEVEL
  BS2.SEROUT_Char(COM_TX, VRA, 9600, BS2#NInv,8)
   
  VRA1 := VRA1 + ARG_ZERO
  BS2.SEROUT_Char(COM_TX, VRA1, 9600, BS2#NInv,8)
  VRA1:= BS2.SERIN_Char(COM_RX, SAY_BAUD, BS2#NInv,8)
  VRA1 := VRA1 - ARG_ZERO      
  RETURN

' Inputs:
'   VRA1 = wordset (0=trigger)
' Ouputs:
'   VRA1 = result (0-31=word, 32..=builtin, 253=comm err, 254=timeout, 255=error)

'********************************  Say-It Commands  ***********************************
PRI VR_Recognize      
   IF VRA == 0
     VRA := CMD_RECOG_SD
   ELSE
     VRA := CMD_RECOG_SI
   'ENDIF
   BS2.SEROUT_Char(COM_TX, VRA, 9600, BS2#NInv,8)
   VR_Recognize1
   
PRI VR_Recognize1
   VRA1 := VRA1 + ARG_ZERO
   BS2.SEROUT_Char(COM_TX, VRA1, 9600, BS2#NInv,8)
   VRA:= BS2.SERIN_Char(COM_RX, SAY_BAUD, BS2#NInv,8)
   IF VRA == STS_RESULT
     VRA := ARG_ACK
     BS2.SEROUT_Char(COM_TX, VRA, 9600, BS2#NInv,8)
     VR_Recognize2
     
   ELSEIF VRA == STS_SIMILAR
    VRA := ARG_ACK
    BS2.SEROUT_Char(COM_TX, VRA, 9600, BS2#NInv,8)
    VR_Recognize3
   ELSEIF VRA == STS_TIMEOUT
    VRA := 254   
   ELSE
    VRA := 255
   RETURN                                                                                                                                     
PRI VR_Recognize2
   VRA1:= BS2.SERIN_Char(COM_RX, SAY_BAUD, BS2#NInv,8)
   VRA1 := VRA1 - ARG_ZERO + 1
   RETURN
PRI VR_Recognize3
   VRA1:= BS2.SERIN_Char(COM_RX, SAY_BAUD, BS2#NInv,8)
   VRA1 := VRA1 - ARG_ZERO
   RETURN
   
'******************************  VeeaR Commands  **************************************   
PRI VR_RecognizeSI                                     
  VRA := CMD_RECOG_SI
  VR_Recognize0 (13, 9600, 12)
  
PRI VR_RecognizeSD                                  
  VRA := CMD_RECOG_SD
  
PRI VR_Recognize0 (_COM_TX, _SAY_BAUD, _COM_RX)     
  BS2.SEROUT_Char(COM_TX, VRA, 9600, BS2#NInv,8)   
       ' send Group/WS
  VRA1 := VRA1 + ARG_ZERO
  
  BS2.SEROUT_Char(COM_TX, VRA1, 9600, BS2#NInv,8)
  ' wait for answer 
  VRA:= BS2.SERIN_Char(COM_RX, SAY_BAUD, BS2#NInv,8)
              
  IF VRA == STS_RESULT
    ' send ack
    VRA := ARG_ACK
      BS2.SEROUT_Char(COM_TX, VRA, 9600, BS2#NInv,8)   
    ' wait for recognised command code
    VRA:= BS2.SERIN_Char(COM_RX, SAY_BAUD, BS2#NInv,8)
  '                       
    VRA1 := VRA1 - ARG_ZERO
  ELSEIF VRA == STS_SIMILAR
    ' send ack
    VRA := ARG_ACK
    BS2.SEROUT_STR(COM_TX, VRA, SAY_BAUD, Mode, bits)   
       ' wait for recognised command code
    VRA:= BS2.SERIN_Char(COM_RX, SAY_BAUD, BS2#NInv,8)
  '                
    VRA1 := VRA1 - ARG_ZERO + RES_BUILTIN
  ELSEIF VRA == STS_TIMEOUT
    VRA1 := RES_TIMEOUT
  ELSE
    VRA1 := RES_ERROR
  'ENDIF
  RETURN
  
'******************************  ERROR Commands  **************************************
PRI VR_CommFailed                                               
  VRA1 := RES_COMMFAIL
   
PRI RX_ERROR
  MSG := CODE_ERROR
  BS2.SEROUT_CHAR(COM_TX, MSG, SAY_BAUD, Mode, bits)
  DEBUG.str(string("RX_ERROR! ",13))
   
PUB BLINK             'this commands makes the LED on the Say-It Module blink 3 times

 repeat  3
  !outa[VRLED]                     'toggle led
  BS2.PAUSE(100)                   'short pause
 outa[VRLED]~~
RETURN
                                                                

'*****************************************************************************************************
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