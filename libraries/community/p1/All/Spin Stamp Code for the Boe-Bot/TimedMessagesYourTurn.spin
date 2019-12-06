''Robotics with the Boe-Bot - TimedMessagesYourTurn.spin
''Show how the waitcnt command can be used to display messages at human speeds.

CON
                                       
  _clkmode        = xtal1 + pll8x
  _xinfreq        = 10_000_000
  CR = 13

VAR

  long Pause
  
OBJ
   
  Debug: "FullDuplexSerialPlus"
  
PUB TimedMessagesYourTurn      

  Debug.start(31, 30, 0, 9600)

  Pause := clkfreq/1_000

  Debug.str(string("Start timer..."))
  
  waitcnt(Pause * 5000 + cnt)                          ' Delay or wait 5000ms or 5s
  Debug.str(string(CR, "Five seconds elapsed..."))
  
  waitcnt(Pause * 10000 + cnt)                         ' Delay or wait 10000ms or 10s
  Debug.str(string(CR, "Fifteen seconds elapsed..."))
     
  Debug.str(string(CR, "Done."))

'********************************************************************************************

' Robotics with the Boe-Bot - TimedMessagesYourTurn.bs2
' Show how the PAUSE command can be used to display messages at human speeds.

' {$STAMP BS2}
' {$PBASIC 2.5}

'DEBUG "Start timer..."

'PAUSE 5000
'DEBUG CR, "Five seconds elapsed..."

'PAUSE 10000
'DEBUG CR, "Fifteen seconds elapsed..."

'DEBUG CR, "Done."

'END
     