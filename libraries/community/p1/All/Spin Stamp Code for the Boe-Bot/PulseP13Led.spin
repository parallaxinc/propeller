''Robotics with the Boe-Bo - PulseP13Led.spin
''Send a 0.13 second pulse to the LED circuit connected to P13 every 2 s.

CON
                                       
  _clkmode        = xtal1 + pll8x
  _xinfreq        = 10_000_000

VAR

  long Pause, Pulsout
  
OBJ
   
  Debug: "FullDuplexSerialPlus"
  
PUB PulsoutP13Led      

  Debug.start(31, 30, 0, 9600)

  Pause := clkfreq/1_000
  Pulsout := clkfreq/500_000
                                                          
  dira[13]~~                                              ' Pin 13 to output
  outa[13]~                                               ' Initialize pin 13 low

  Debug.str(string("Program Running!"))

  repeat
    outa[13]~~                                            ' Pin 13 high 
    waitcnt(Pulsout * 65000 + cnt)                        ' Delay 130ms or 0.13s
    outa[13]~                                             ' Pin 13 low 
    waitcnt(Pause * 2000 + cnt)                           ' Delay 2000ms or 2s

'********************************************************************************************

' Robotics with the Boe-Bot - PulseP13Led.bs2
' Send a 0.13 second Pulse to the LED circuit connected to P13 every 2 s.

' {$STAMP BS2}
' {$PBASIC 2.5}

'DEBUG "Program Running!"

'DO
'PULSOUT 13, 65000
'PAUSE 2000
'LOOP
     