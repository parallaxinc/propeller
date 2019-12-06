''Robotics with the Boe-Bot - PulseBothLeds.spin
''Send a 0.13 second pulse to P12 and P13 every 2 seconds.

CON
                                       
  _clkmode        = xtal1 + pll8x
  _xinfreq        = 10_000_000

VAR

  long Pause, Pulsout
  
OBJ
   
  Debug: "FullDuplexSerialPlus"
  
PUB PulseBothLeds      

  Debug.start(31, 30, 0, 9600)

  Pause := clkfreq/1_000
  Pulsout := clkfreq/500_000
                                                          
  dira[12..13]~~                                       ' Pin 12, pin 13 output
  outa[12..13]~                                        ' Initialize pin 12, pin 13 low

  Debug.str(string("Program Running!"))

  repeat
    outa[12..13]~~                                     ' Pin 12, pin 13 high 
    waitcnt(Pulsout * 65000 + cnt)                     ' Delay 130ms or 0.13s
    outa[12..13]~                                      ' Pin 12, pin 13 low 
    waitcnt(Pause * 2000 + cnt)                        ' Delay 2000ms or 2s

'********************************************************************************************

' Robotics with the Boe-Bot - PulseBothLeds.bs2
' Send a 0.13 second pulse to P13 and P12 every 2 seconds.

' {$STAMP BS2}
' {$PBASIC 2.5}

'DEBUG "Program Running!"

'DO
'PULSOUT 13, 65000
'PULSOUT 12, 65000
'PAUSE 2000
'LOOP
     