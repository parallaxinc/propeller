''Robotics with the Boe-Bot - ControlServoRunTimes.spin
''Run the P13 servo at full speed counterclockwise for 2.3 s, then
''run the P12 servo for twice as long.

CON
                                       
  _clkmode        = xtal1 + pll8x
  _xinfreq        = 10_000_000

VAR

  byte counter
  long Pause, Pulsout
  
OBJ
   
  Debug: "FullDuplexSerialPlus"
  
PUB ControlServoRunTimes     

  Debug.start(31, 30, 0, 9600)

  Pause := clkfreq/1_000
  Pulsout := clkfreq/500_000 
                                                          
  dira[12..13]~~
  outa[12..13]~

  Debug.str(string("Program Running!"))

  repeat counter from 1 to 100  
    outa[13]~~ 
    waitcnt(Pulsout * 850 + cnt)
    outa[13]~
    waitcnt(Pause * 20 + cnt)

  repeat counter from 1 to 200  
    outa[12]~~ 
    waitcnt(Pulsout * 850 + cnt)
    outa[12]~
    waitcnt(Pause * 20 + cnt)

'********************************************************************************************

' Robotics with the Boe-Bot - ControlServoRunTimes.bs2
' Run the P13 servo at full speed counterclockwise for 2.3 s, then
' run the P12 servo for twice as long.

' {$STAMP BS2}
' {$PBASIC 2.5}

'DEBUG "Program Running!"

'counter VAR Byte

'FOR counter = 1 TO 100
'PULSOUT 13, 850
'PAUSE 20
'NEXT

'FOR counter = 1 TO 200
'PULSOUT 12, 850
'PAUSE 20
'NEXT

'END
     