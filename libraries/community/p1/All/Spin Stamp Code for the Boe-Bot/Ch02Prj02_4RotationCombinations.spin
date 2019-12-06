''Robotics with the Boe-Bot - Ch02Prj02_4RotationCombinations.spin
''Move servos through 4 clockwise/counterclockwise rotation
''combinations.

CON
                                       
  _clkmode        = xtal1 + pll8x
  _xinfreq        = 10_000_000

VAR

  byte counter
  long Pause, Pulsout
  
OBJ
   
  Debug: "FullDuplexSerialPlus"
  
PUB Ch02Prj02_4RotationCombination     

  Debug.start(31, 30, 0, 9600)

  Pause := clkfreq/1_000
  Pulsout := clkfreq/500_000 
                                                          
  dira[12..13]~~
  outa[12..13]~

  Debug.str(string("Program Running!"))

  repeat counter from 1 to 120                        ' Loop for three seconds
    outa[13]~~ 
    waitcnt(Pulsout * 850 + cnt)                      ' P13 servo counterclockwise
    outa[13]~
    outa[12]~~ 
    waitcnt(Pulsout * 850 + cnt)                      ' P12 servo counterclockwise
    outa[12]~
    waitcnt(Pause * 20 + cnt)

  repeat counter from 1 to 124                        ' Loop for three seconds
    outa[13]~~ 
    waitcnt(Pulsout * 650 + cnt)                      ' P13 servo clockwise
    outa[13]~ 
    outa[12]~~ 
    waitcnt(Pulsout * 650 + cnt)                      ' P12 srvo clockwise
    outa[12]~ 

  repeat counter from 1 to 122                        ' Loop for three seconds
    outa[13]~~ 
    waitcnt(Pulsout * 650 + cnt)                      ' P13 servo clockwise
    outa[13]~
    outa[12]~~ 
    waitcnt(Pulsout * 850 + cnt)                      ' P12 servo counterclockwise
    outa[12]~
    waitcnt(Pause * 20 + cnt)

  repeat counter from 1 to 122                        ' Loop for three seconds
    outa[13]~~ 
    waitcnt(Pulsout * 850 + cnt)                      ' P13 servo counterclockwise
    outa[13]~ 
    outa[12]~~ 
    waitcnt(Pulsout * 650 + cnt)                      ' P12 servo clockwise
    outa[12]~
    waitcnt(Pause * 20 + cnt)

'********************************************************************************************

' Robotics with the Boe-Bot - Ch02Prj02_4RotationCombinations.bs2
' Move servos through 4 clockwise/counterclockwise rotation
' combinations.

'{$STAMP BS2}
'{$PBASIC 2.5}

'DEBUG "Program Running!"

'counter        VAR     Word

'FOR counter = 1 TO 120                               ' Loop for three seconds
'PULSOUT 13, 850                                      ' P13 servo counterclockwise
'PULSOUT 12, 850                                      ' P12 servo counterclockwise
'PAUSE 20
'NEXT

'FOR counter = 1 TO 124                               ' Loop for three seconds
'PULSOUT 13, 650                                      ' P13 servo clockwise
'PULSOUT 12, 650                                      ' P12 servo clockwise
'PAUSE 20
'NEXT

'FOR counter = 1 TO 122                               ' Loop for three seconds
'PULSOUT 13, 650                                      ' P13 servo clockwise
'PULSOUT 12, 850                                      ' P12 servo counterclockwise
'PAUSE 20
'NEXT
                                               
'FOR counter = 1 TO 122                               ' Loop for three seconds
'PULSOUT 13, 850                                      ' P13 servo counterclockwise
'PULSOUT 12, 650                                      ' P12 servo clockwise
'PAUSE 20
'NEXT

'END
     