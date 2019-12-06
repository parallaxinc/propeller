''Robotics with the Boe-Bot - HighLowLed.spin
''Turn the LED connected to P13 on/off once every second.

CON
                                       
  _clkmode        = xtal1 + pll8x
  _xinfreq        = 10_000_000

Var

  long Pause
  
OBJ
   
  Debug: "FullDuplexSerialPlus"
  
PUB HighLowLed      

  Debug.start(31, 30, 0, 9600)

  Pause := clkfreq/1_000
                                                          
  dira[13]~~                                              ' Pin 13 output
  outa[13]~                                               ' Initialize pin 13 low
  
  Debug.str(string("The LED connected to Pin 13 is blinking!"))

  repeat
    outa[13]~~                                            ' Pin 13 high 
    waitcnt(Pause * 500 + cnt)                            ' Delay or wait 500ms or 0.5s
    outa[13]~                                             ' Pin 13 low 
    waitcnt(Pause * 500 + cnt)                            ' Delay or wait 500ms or 0.5s

'********************************************************************************************

' Robotics with the Boe-Bot - HighLowLed.bs2
' Turn the LED connected to P13 on/off once every second.

' {$STAMP BS2}
' {$PBASIC 2.5}

'DEBUG "The LED connected to Pin 13 is blinking!"

'DO
'HIGH 13
'PAUSE 500
'LOW 13
'PAUSE 500
'LOOP
     