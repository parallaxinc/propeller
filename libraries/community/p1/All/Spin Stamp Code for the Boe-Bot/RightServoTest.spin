''Robotics with the Boe-Bot - RightServoTest.spin
''Right servo turns clockwise three seconds, stops 1 second, then
''counterclockwise three seconds.

CON
                                       
  _clkmode        = xtal1 + pll8x
  _xinfreq        = 10_000_000

VAR

  byte counter
  long Pause, Pulsout
  
OBJ
   
  Debug: "FullDuplexSerialPlus"
  
PUB RightServoTest     

  Debug.start(31, 30, 0, 9600)

  Pause := clkfreq/1_000
  Pulsout := clkfreq/500_000 
                                                          
  dira[12]~~
  outa[12]~

  Debug.str(string("Program Running!"))

  repeat counter from 1 to 122                        ' Clockwise just under 3 seconds.
    outa[12]~~ 
    waitcnt(Pulsout * 650 + cnt)
    outa[12]~
    waitcnt(Pause * 20 + cnt)

  repeat counter from 1 to 40                         ' Stop one second.
    outa[12]~~ 
    waitcnt(Pulsout * 750 + cnt)
    outa[12]~
    waitcnt(Pause * 20 + cnt)

  repeat counter from 1 to 122                        ' Counterclockwise three seconds.
    outa[12]~~ 
    waitcnt(Pulsout * 850 + cnt)
    outa[12]~
    waitcnt(Pause * 20 + cnt)    

'********************************************************************************************

' Robotics with the Boe-Bot - RightServoTest.bs2
' Right servo turns clockwise three seconds, stops 1 second, then
' counterclockwise three seconds.

' {$STAMP BS2}
' {$PBASIC 2.5}

'DEBUG "Program Running!"

'counter        VAR Word

'FOR counter = 1 TO 122                               ' Clockwise just under 3 seconds.
'PULSOUT 12, 650
'PAUSE 20
'NEXT

'FOR counter = 1 TO 40                                ' Stop one second.
'PULSOUT 12, 750
'PAUSE 20
'NEXT

'FOR counter = 1 TO 122                               ' Counterclockwise three seconds.
'PULSOUT 12, 850
'PAUSE 20
'NEXT

'END
     