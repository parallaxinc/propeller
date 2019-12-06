''Robotics with the Boe-Bot  PulseBothLedsYourTurn_1.spin
''Send a 0.13/100 second pulse to P12 and P13 every 2/100 seconds.

CON
                                       
  _clkmode        = xtal1 + pll8x
  _xinfreq        = 10_000_000

VAR

  long Pause, Pulsout
  
OBJ
   
  Debug: "FullDuplexSerialPlus"
  
PUB PulseBothLedsYourTurn_1     

  Debug.start(31, 30, 0, 9600)

  Pause := clkfreq/1_000
  Pulsout := clkfreq/500_000 
                                                          
  dira[12..13]~~                                       ' Pin 12, pin 13 output
  outa[12..13]~                                        ' Initialize pin 12, pin 13 low

  Debug.str(string("Program Running!"))

  repeat
    outa[12..13]~~                                     ' Pin 12, pin 13 high 
    waitcnt(Pulsout * 650 + cnt)                       ' Delay 1.3ms
    outa[12..13]~                                      ' Pin 12, pin 13 low 
    waitcnt(Pause * 20 + cnt)                          ' Delay 20ms

'********************************************************************************************

' Robotics with the Boe-Bot  PulseBothLedsYourTurn_1.bs2
' Send a 0.13/100 second pulse to P13 and P12 every 2/100 seconds.

' {$STAMP BS2}
' {$PBASIC 2.5}

'DEBUG "Program Running!"

'DO
'PULSOUT 13, 650
'PULSOUT 12, 650
'PAUSE 20
'LOOP
     