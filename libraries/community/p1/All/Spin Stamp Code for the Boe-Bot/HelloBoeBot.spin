''Robotics with the Boe-Bot - HelloBoeBot.spin
''Propeller sends a Hello message to your PC/laptop

CON
   
  _clkmode = xtal1 + pll8x
  _xinfreq = 10_000_000

OBJ
   
  Debug: "FullDuplexSerialPlus"
   
   
PUB HelloBoeBot
 
  Debug.start(31, 30, 0, 9600)

  Debug.str(string("Hello, this is a message from your Boe-Bot."))

'********************************************************************************************  

' Robotics with the Boe-Bot - HelloBoeBot.bs2
' BASIC Stamp sends a text message to your PC/laptop.

' {$STAMP BS2}
' {$PBASIC 2.5}

'DEBUG "Hello, this is a message from your Boe-Bot."

'END