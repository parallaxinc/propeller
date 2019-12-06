''Robotics with the Boe-Bot - AsciiName.spin
''Use ASCII code in a DEBUG command to display the words BASIC Stamp 2.

CON
   
  _clkmode = xtal1 + pll8x
  _xinfreq = 10_000_000

OBJ
   
  Debug: "FullDuplexSerialPlus"
   
   
PUB AsciiName
 
  Debug.start(31, 30, 0, 9600)

  Debug.str(string(66,65,83,73,67,32,83,116,97,109,112,32,50))

'********************************************************************************************

' Robotics with the Boe-Bot - AsciiName.bs2
' Use ASCII code in a DEBUG command to display the words BASIC Stamp 2.

' {$STAMP BS2}
' {$PBASIC 2.5}

'DEBUG 66,65,83,73,67,32,83,116,97,109,112,32,50

'END