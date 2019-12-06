''Robotics with the Boe-Bot - HelloBoeBotCh01Project01.spin
''Adds together 4 numbers with DEBUG

CON
   
  _clkmode = xtal1 + pll8x
  _xinfreq = 10_000_000
  CR = 13

OBJ
   
  Debug: "FullDuplexSerialPlus"
   
   
PUB HelloBoeBotCh01Project01
 
  Debug.start(31, 30, 0, 9600)

  Debug.str(string("What's 1+2+3+4"))
  Debug.str(string(CR, "The answer is: "))
  Debug.dec(1+2+3+4)

'********************************************************************************************  

' Robotics with the Boe-Bot - HelloBoeBotCh01Project01.bs2
' Adds together 4 numbers with DEBUG
'{$STAMP BS2}
'{$PBASIC 2.5}

'DEBUG "What's 1+2+3+4?"
'DEBUG CR, "The answer is: "
'DEBUG DEC 1+2+3+4

'END