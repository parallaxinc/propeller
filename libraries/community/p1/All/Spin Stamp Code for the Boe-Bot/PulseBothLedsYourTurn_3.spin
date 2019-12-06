''Robotics with the Boe-Bot  PulseBothLedsYourTurn_3.spin
''Send a 0.15/100 second pulse to P13 every 2/100 seconds.
''Send a 0.15/100 second pulse to P12 every 2/100 seconds.

CON
                                       
  _clkmode        = xtal1 + pll8x
  _xinfreq        = 10_000_000

VAR

  long Pause, Pulsout
  
OBJ
   
  Debug: "FullDuplexSerialPlus"
  
PUB PulseBothLedsYourTurn_3      

  Debug.start(31, 30, 0, 9600)

  Pause := clkfreq/1_000
  Pulsout := clkfreq/500_000
                                                          
  dira[12..13]~~                                      ' Pin 12, pin 13 output
  outa[12..13]~                                       ' Initialize pin 12, pin 13 low

  Debug.str(string("Program Running!"))

  repeat
    outa[13]~~                                        ' Pin 13 high
    waitcnt(Pulsout * 750 + cnt)                      ' Delay 1.5ms        
    outa[13]~                                         ' Pin 13 low        
    outa[12]~~                                        ' Pin 12 high 
    waitcnt(Pulsout * 750 + cnt)                      ' Delay 1.5ms
    outa[12]~                                         ' Pin 12 low     
    waitcnt(Pause * 20 + cnt)                         ' Delay 20ms

'********************************************************************************************

' Robotics with the Boe-Bot  PulseBothLedsYourTurn_3.bs2
' Send a 0.15/100 second pulse to P13 and P12 every 2/100 seconds.

' {$STAMP BS2}
' {$PBASIC 2.5}

'DEBUG "Program Running!"

'DO
'PULSOUT 13, 750
'PULSOUT 12, 750
'PAUSE 20
'LOOP
     