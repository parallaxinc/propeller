''Robotics with the Boe-Bot - TimedMessages.spin
''Show how the waitcnt command can be used to display messages at human speeds.

CON
                                       
  _clkmode        = xtal1 + pll8x
  _xinfreq        = 10_000_000
  CR = 13

VAR

  long Pause
  
OBJ
   
  Debug: "FullDuplexSerialPlus"
  
PUB TimedMessages   

  Debug.start(31, 30, 0, 9600)

  Pause := clkfreq/1_000 

  Debug.str(string("Start timer..."))
   
  waitcnt(Pause * 1000 + cnt)                         ' Delay or wait 1000ms or 1s
  Debug.str(string(CR, "One second elapsed..."))
   
  waitcnt(Pause * 2000 + cnt)                         ' Delay or wait 2000ms or 2s
  Debug.str(string(CR, "Three seconds elapsed...")) 
  
  Debug.str(string(CR, "Done."))

'********************************************************************************************

' Robotics with the Boe-Bot - TimedMessages.bs2
' Show how the PAUSE command can be used to display messages at human speeds.

' {$STAMP BS2}
' {$PBASIC 2.5}

'DEBUG "Start timer..."

'PAUSE 1000
'DEBUG CR, "One second elapsed..."

'PAUSE 2000
'DEBUG CR, "Three seconds elapsed..."

'DEBUG CR, "Done."

'END
     