''Robotics with the Boe-Bot - HelloBoeBotCh01Project02.spin
''Prints ASCII 7 * 11

CON
   
  _clkmode = xtal1 + pll8x
  _xinfreq = 10_000_000

OBJ
   
  Debug: "FullDuplexSerialPlus"
   
   
PUB HelloBoeBotCh01Project02
 
  Debug.start(31, 30, 0, 9600)

  Debug.str(string(7 * 11))

'********************************************************************************************  

' Robotics with the Boe-Bot - HelloBoeBotCh01Project02.bs2
' Prints ASCII 7 * 11

' {$STAMP BS2}
' {$PBASIC 2.5}

'DEBUG 7 * 11

'END