''Robotics with the Boe-Bot - CountToTenYourTurn_1.spin
''Use a variable in a repeat loop.

CON
   
  _clkmode = xtal1 + pll8x
  _xinfreq = 10_000_000
  CR = 13

VAR

  byte myCounter
  long Pause
  
OBJ
   
  Debug: "FullDuplexSerialPlus"
   
   
PUB CountToTenYourTurn_1
 
  Debug.start(31, 30, 0, 9600)

  Pause := clkfreq/1_000

  repeat myCounter from 21 to 9 step 3
    Debug.str(string("myCounter = "))
    Debug.dec(myCounter)
    Debug.tx(CR)
    waitcnt(Pause * 500 + cnt)

  Debug.str(string(CR, "All done!"))  

'********************************************************************************************  

' Robotics with the Boe-Bot - CountToTenYourTurn.bs2
' Use a variable in a FOR...NEXT loop.

' {$STAMP BS2}
' {$PBASIC 2.5}

'myCounter         VAR Word

'FOR myCounter = 21 TO 9 step 3
'DEBUG ? myCounter
'PAUSE 500
'NEXT

'DEBUG CR, "All done!"

'END