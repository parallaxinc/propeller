''Robotics with the Boe-Bot - HelloOnceEverySecondYourTurn.spin
''Display a message once every second.

CON
   
  _clkmode = xtal1 + pll8x
  _xinfreq = 10_000_000
  CR = 13

VAR

  long Pause
  
OBJ
   
  Debug: "FullDuplexSerialPlus"
   
   
PUB HelloOnceEverySecondYourTurn
 
  Debug.start(31, 30, 0, 9600)

  Pause := clkfreq/1_000  

  Debug.str(string("Hello!"))
  
  repeat
    Debug.str(string("!"))
    waitcnt(Pause * 1000 + cnt)

'********************************************************************************************

' Robotics with the Boe-Bot - HelloOnceEverySecondYourTurn.bs2
' Display a message once every second.

' {$STAMP BS2}
' {$PBASIC 2.5}

'DEBUG "Hello!"

'DO
'DEBUG "!"
'PAUSE 1000
'LOOP