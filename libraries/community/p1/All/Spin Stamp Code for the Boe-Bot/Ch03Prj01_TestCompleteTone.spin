''Robotics with the Boe-Bot - Ch03Prj01_TestCompleteTone.spin
''Right servo turns clockwise three seconds, stops 1 second, then
''counterclockwise three seconds. A tone signifies that the
''test is complete.

CON
                                       
  _clkmode        = xtal1 + pll8x
  _xinfreq        = 10_000_000

VAR

  word counter
  long Pause, Pulsout
  
OBJ
   
  Debug: "FullDuplexSerialPlus"
  Piezo: "Piezospeaker"
  
PUB Ch03Prj01_TestCompleteTone     

  Debug.start(31, 30, 0, 9600)

  Pause := clkfreq/1_000
  Pulsout := clkfreq/500_000 
                                                          
  dira[12]~~
  outa[12]~

  Debug.str(string("Program Running!"))

  Piezo.beep(4, 3000, 12000)                          ' Signal start of program.

  repeat counter from 1 to 122                        ' Clockwise just under 3 seconds.
    outa[12]~~ 
    waitcnt(Pulsout * 650 + cnt)
    outa[12]~ 
    waitcnt(Pause * 20 + cnt)

  repeat counter from 1 to 40                         ' Stop one second.
    outa[12]~~ 
    waitcnt(Pulsout * 750 + cnt)
    outa[12]~  
    waitcnt(Pause * 20 + cnt)

  repeat counter from 1 to 122                        ' Counterclockwise three seconds.
    outa[12]~~ 
    waitcnt(Pulsout * 850 + cnt)
    outa[12]~ 
    waitcnt(Pause * 20 + cnt)

  Piezo.beep(4, 3500, 3500)                           ' Signal end of program
' Piezo.beep(pin, freq, dur)                          ' dur = 0.5 second = 3500 cycles  

'********************************************************************************************

' Robotics with the Boe-Bot - Ch03Prj01_TestCompleteTone.bs2
' Right servo turns clockwise three seconds, stops 1 second, then
' counterclockwise three seconds. A tone signifies that the
' test is complete.

' {$STAMP BS2}
' {$PBASIC 2.5}
'DEBUG "Program Running!"

'counter        VAR     Word

'FREQOUT 4, 2000, 3000                                ' Signal start of program.

'FOR counter = 1 TO 122                               ' Clockwise just under 3 seconds.
'PULSOUT 12, 650
'PAUSE 20
'NEXT

'FOR counter = 1 TO 40                                ' Stop one second.
'PULSOUT 12, 750
'PAUSE 20
'NEXT

'FOR counter = 1 TO 122                               ' Counterclockwise three seconds.
'PULSOUT 12, 850
'PAUSE 20
'NEXT

'FREQOUT 4, 500, 3500                                 ' Signal end of program

'END
     