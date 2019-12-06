{{ Program WXstart_
Date    17Jun18
Purpose;
Rev0_17Jun18;   First Pass to load into EEPROM - only hello world printed
Rev1_20Jun18;   Now add the reset to PGM pin
}}                                                                                                                                                
CON
  _clkmode = xtal1 + pll16x                                                      
  _xinfreq = 5_000_000

  WXDO = 0   'rx, serial in Prop P0 <- WXDO, see BS2 program
  WXDI = 1   'tx, serial out Prop P1 -> WXDI, see BS2 program 
  WXRST = 2  'reset pin to WX PGM pin 2 through 10K resistor
CON
                                                                                 
VAR
  long  cntr          'utility counter and byte value
   
DAT
 
OBJ
  PST  : "Parallax Serial Terminal"

PUB Main
'Main program structure
  A_Start
'  repeat
'    B_Main

PUB A_Start
'Start up and initialise
'Start PST and wait for keypress
  PST.start(115_200)
  PST.Clear
  PST.Home
  PST.Str(string("press any key to resume"))
  cntr := PST.CharIn
  A1_PSTDisp
  A2_ResetWX

PUB A1_PSTDisp
'This object is the only code in WXStart_0
'which is loaded into the EEPROM to ensure the WX does not have any conflict with
'the pins from the EEPROM program running at at startup
  PST.Newline
  PST.Str(string("Hello world"))

PUB A2_ResetWX
'This object is to force the WX into softAP by toggling WX module
'PGM pin 4 times in 2 secs
'Refer to WX API and Guide
'BEWARE The API mentions the module RES pin. THIS IS NOT THE PIN MARKED RES ON THE WX
'The pin for resetting on the WX is the PGM pin

  DIRA[WXRST]~~     'set Prop pin for reset routine to output
  OUTA[WXRST]~~      'set pin high initially
  repeat cntr from 1 to 4
    OUTA[WXRST]~     'pull the pin low
    waitcnt (clkfreq/20 + cnt) 'wait a short while
    OUTA[WXRST]~~    'pull the pin high
    waitcnt (clkfreq/3  + cnt) 'wait for less than 500mS
  DIRA[WXRST]~    'set the pin to input
  PST.Newline
  PST.Str(string("Reset toggle completed"))
      