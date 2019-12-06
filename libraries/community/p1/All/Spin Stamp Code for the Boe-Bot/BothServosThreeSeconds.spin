''Robotics with the Boe-Bot - BothServosThreeSeconds.spin
''Run both servos in opposite directions for three seconds, then reverse
''the direction of both servos and run another three seconds.

CON
                                       
  _clkmode        = xtal1 + pll8x
  _xinfreq        = 10_000_000

VAR

  byte counter
  long Pause, Pulsout
  
OBJ
   
  Debug: "FullDuplexSerialPlus"
  
PUB BothServosThreeSeconds     

  Debug.start(31, 30, 0, 9600)

  Pause := clkfreq/1_000
  Pulsout := clkfreq/500_000 
                                                          
  dira[12..13]~~
  outa[12..13]~

  Debug.str(string("Program Running!"))

  repeat counter from 1 to 122  
    outa[13]~~ 
    waitcnt(Pulsout * 850 + cnt)
    outa[13]~
    outa[12]~~ 
    waitcnt(Pulsout * 650 + cnt)
    outa[12]~ 
    waitcnt(Pause * 20 + cnt)

  repeat counter from 1 to 122
    outa[13]~~ 
    waitcnt(Pulsout * 650 + cnt)
    outa[13]~   
    outa[12]~~ 
    waitcnt(Pulsout * 850 + cnt)
    outa[12]~
    waitcnt(Pause * 20 + cnt)

'********************************************************************************************

' Robotics with the Boe-Bot - BothServosThreeSeconds.bs2
' Run both servos in opposite directions for three seconds, then reverse
' the direction of both servos and run another three seconds.

' {$STAMP BS2}
' {$PBASIC 2.5}

'DEBUG "Program Running!"

'counter VAR Byte

'FOR counter = 1 TO 122
'PULSOUT 13, 850
'PULSOUT 12, 650
'PAUSE 20
'NEXT

'FOR counter = 1 TO 122
'PULSOUT 13, 650
'PULSOUT 12, 850
'PAUSE 20
'NEXT

'END
     