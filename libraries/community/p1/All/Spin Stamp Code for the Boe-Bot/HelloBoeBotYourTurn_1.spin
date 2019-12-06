''Robotics with the Boe-Bot - HelloBoeBotYourTurn_1.spin
''Propeller sends a Hello message to your Debug Terminal
''BASIC Stamp does simple math, and sends the results
''to the Debug Terminal.

CON
   
  _clkmode = xtal1 + pll8x
  _xinfreq = 10_000_000
  CR = 13

OBJ
   
  Debug: "FullDuplexSerialPlus"
   
   
PUB HelloBoeBotYourTurn_1
 
  Debug.start(31, 30, 0, 9600)

  Debug.str(string("Hello, this is a message from your Boe-Bot."))
  Debug.str(string(CR,"What's 7 X 11?"))
  Debug.str(string(CR,"The answer is: "))
  Debug.dec(7 * 11)
  Debug.tx(CR)
  Debug.dec(7 + 11)

'********************************************************************************************  

' Robotics with the Boe-Bot - HelloBoeBotYourTurn_1.bs2
' BASIC Stamp does simple math, and sends the results
' to the Debug Terminal.

' {$STAMP BS2}
' {$PBASIC 2.5}

'DEBUG "Hello, this is a message from your Boe-Bot."
'DEBUG CR, "What's 7 X 11?"
'DEBUG CR, "The answer is: "
'DEBUG DEC 7 * 11
'DEBUG CR, DEC 7 + 11

'END