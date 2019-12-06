''Robotics with the Boe-Bot - CenterServoP13.spin
''This program sends 1.5 ms pulses to the servo connected to
''P13 for manual centering.

CON
                                       
  _clkmode        = xtal1 + pll8x
  _xinfreq        = 10_000_000

VAR

  long Pause, Pulsout
  
OBJ
   
  Debug: "FullDuplexSerialPlus"
  
PUB CenterServoP13     

  Debug.start(31, 30, 0, 9600)

  Pause := clkfreq/1_000
  Pulsout := clkfreq/500_000 
                                                          
  dira[13]~~                                          ' Pin 13 output
  outa[13]~                                           ' Initialize pin 13 low

  Debug.str(string("Program Running!"))

  repeat
    outa[13]~~                                        ' Pin 13 high 
    waitcnt(Pulsout * 750 + cnt)                      ' Delay 1.5ms
    outa[13]~                                         ' Pin 13 low 
    waitcnt(Pause * 20 + cnt)                         ' Delay 20ms

'********************************************************************************************

' Robotics with the Boe-Bot - CenterServoP13.bs2
' This program sends 1.5 ms pulses to the servo connected to
' P13 for manual centering.

' {$STAMP BS2}
' {$PBASIC 2.5}

'DEBUG "Program Running!"

'DO
'PULSOUT 13, 750
'PAUSE 20
'LOOP
     