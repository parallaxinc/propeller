''Robotics with the Boe-Bot - Ch02Prj01_DimlyLitLED.spin
''Run servo and send same signal to the LED on P14,
''to make it light dimly.

CON
                                       
  _clkmode        = xtal1 + pll8x
  _xinfreq        = 10_000_000

VAR

  long Pause, Pulsout
  
OBJ
   
  Debug: "FullDuplexSerialPlus"
  
PUB Ch02Prj01_DimlyLitLED     

  Debug.start(31, 30, 0, 9600)

  Pause := clkfreq/1_000
  Pulsout := clkfreq/500_000 
                                                          
  dira[12]~~     
  outa[12]~
  dira[14]~~
  outa[14]~

  Debug.str(string("Program Running!"))

  repeat
    outa[12]~~ 
    waitcnt(Pulsout * 650 + cnt)                      ' P12 servo clockwise
    outa[12]~
    outa[14]~~ 
    waitcnt(Pulsout * 650 + cnt)                      ' P14 LED lights dimly
    outa[14]~
    waitcnt(Pause * 20 + cnt)

'********************************************************************************************

' Robotics with the Boe-Bot - Ch02Prj01_DimlyLitLED.bs2
' Run servo and send same signal to the LED on P14,
' to make it light dimly.

'{$STAMP BS2}
'{$PBASIC 2.5}

'DEBUG "Program Running!"

'DO
'PULSOUT 12, 650                                      ' P12 servo clockwise
'PULSOUT 14, 650                                      ' P14 LED lights dimly
'PAUSE 20
'LOOP
     