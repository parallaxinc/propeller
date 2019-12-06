''Robotics with the Boe-Bot - ServosP13CcwP12Cw.spin
''Run the servo connected to P13 at full speed counterclockwise
''and the servo connected to P12 at full speed clockwise

CON
                                       
  _clkmode        = xtal1 + pll8x
  _xinfreq        = 10_000_000

VAR

  long Pause, Pulsout
  
OBJ
   
  Debug: "FullDuplexSerialPlus"
  
PUB ServosP13CcwP12Cw     

  Debug.start(31, 30, 0, 9600)

  Pause := clkfreq/1_000
  Pulsout := clkfreq/500_000 
                                                          
  dira[12..13]~~
  outa[12..13]~

  Debug.str(string("Program Running!"))

  repeat
    outa[13]~~ 
    waitcnt(Pulsout * 850 + cnt)
    outa[13]~   
    outa[12]~~ 
    waitcnt(Pulsout * 650 + cnt)
    outa[12]~        
    waitcnt(Pause * 20 + cnt)

'********************************************************************************************

' Robotics with the Boe-Bot - ServosP13CcwP12Cw.bs2
' Run the servo connected to P13 at full speed counterclockwise
' and the servo connected to P12 at full speed clockwise

' {$STAMP BS2}
' {$PBASIC 2.5}

'DEBUG "Program Running!"

'DO
'PULSOUT 13, 850
'PULSOUT 12, 650
'PAUSE 20
'LOOP

     