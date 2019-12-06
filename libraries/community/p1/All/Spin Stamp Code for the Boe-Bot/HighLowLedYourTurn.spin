''Robotics with the Boe-Bot - HighLowLedYourTurn.spin
''Turn the LEDs connected to P12, P13 on/off once every second.

CON
                                       
  _clkmode        = xtal1 + pll8x
  _xinfreq        = 10_000_000

VAR

  long Pause
  
OBJ
   
  Debug: "FullDuplexSerialPlus"
  
PUB HighLowLedYourTurn      

  Debug.start(31, 30, 0, 9600)

  Pause := clkfreq/1_000
                                                          
  dira[12..13]~~                                          ' Pin 12, pin 13 output
  outa[12..13]~                                           ' Iniatialize pin 12, pin 13 low

  Debug.str(string("The LEDs connected to Pin 12 and Pin 13 is blinking!"))

  repeat
    outa[12..13]~~                                        ' Pin 12, pin 13 high 
    waitcnt(Pause * 500 + cnt)                            ' Delay or wait 500ms or 0.5s
    outa[12..13]~                                         ' Pin 12, pin 13 low 
    waitcnt(Pause * 500 + cnt)                            ' Delay or wait 500ms or 0.5s

'********************************************************************************************

' Robotics with the Boe-Bot - HighLowLedYourTurn.bs2
' Turn the LEDs connected to P12, P13 on/off once every second.

' {$STAMP BS2}
' {$PBASIC 2.5}

'DEBUG "The LEDs connected to Pin 12, Pin 13 is blinking!"

'DO
'HIGH 12
'HIGH 13
'PAUSE 500
'LOW 12
'LOW 13
'PAUSE 500
'LOOP
     