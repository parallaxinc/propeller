''Robotics with the Boe-Bot - CenterServoP12.spin
''This program sends 1.5 ms pulses to the servo connected to
''P12 for manual centering.

CON
                                       
  _clkmode        = xtal1 + pll8x
  _xinfreq        = 10_000_000

VAR

  long Pause, Pulsout
  
OBJ
   
  Debug: "FullDuplexSerialPlus"
  
PUB CenterServoP12     

  Debug.start(31, 30, 0, 9600)

  Pause := clkfreq/1_000
  Pulsout := clkfreq/500_000 
                                                          
  dira[12]~~                                          ' Pin 12 output
  outa[12]~                                           ' Initialize pin 12 low

  Debug.str(string("Program Running!"))

  repeat
    outa[12]~~                                        ' Pin 12 high 
    waitcnt(Pulsout * 750 + cnt)                      ' Delay 1.5ms
    outa[12]~                                         ' Pin 12 low 
    waitcnt(Pause * 20 + cnt)                         ' Delay 20ms

'********************************************************************************************

' Robotics with the Boe-Bot - CenterServoP12.bs2
' This program sends 1.5 ms pulses to the servo connected to
' P12 for manual centering.

' {$STAMP BS2}
' {$PBASIC 2.5}

'DEBUG "Program Running!"

'DO
'PULSOUT 12, 750
'PAUSE 20
'LOOP
     