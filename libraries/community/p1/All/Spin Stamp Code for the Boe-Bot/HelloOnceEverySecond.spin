''Robotics with the Boe-Bot - HelloOnceEverySecond.spin
''Display a message once every second.

CON
   
  _clkmode = xtal1 + pll8x
  _xinfreq = 10_000_000
  CR = 13

VAR

  long Pause
  
OBJ
   
  Debug: "FullDuplexSerialPlus"
   
   
PUB HelloOnceEverySecond
 
  Debug.start(31, 30, 0, 9600)

  Pause := clkfreq/1_000
  
  repeat
    Debug.str(string("Hello!", CR))
    waitcnt(Pause * 1000 + cnt)

'********************************************************************************************

' Robotics with the Boe-Bot - HelloOnceEverySecond.bs2
' Display a message once every second.

' {$STAMP BS2}
' {$PBASIC 2.5}

'DO
'DEBUG "Hello!", CR
'PAUSE 1000
'LOOP