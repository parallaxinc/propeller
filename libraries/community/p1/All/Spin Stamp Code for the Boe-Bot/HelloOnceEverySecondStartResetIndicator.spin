''Robotics with the Boe-Bot - HelloOnceEverySecondStartResetIndicator.spin
''Display a message once every second.

CON
   
  _clkmode = xtal1 + pll8x
  _xinfreq = 10_000_000
  CR = 13

VAR

  long Pause
  
OBJ
   
  Debug: "FullDuplexSerialPlus"
  Piezo: "Piezospeaker"
   
   
PUB HelloOnceEverySecondStResInd
 
  Debug.start(31, 30, 0, 9600)

  Pause := clkfreq/1_000

  Piezo.beep(4, 3000, 12000)                    ' Signal program start/reset.
' Piezo.beep(pin, freq, dur)                    ' dur = 2 second = 12000 cycles   
  
  repeat
    Debug.str(string("Hello!", CR))
    waitcnt(Pause * 1000 + cnt) 

'********************************************************************************************

' Robotics with the Boe-Bot - HelloOnceEverySecondStartResetIndicator.bs2
' Display a message once every second.

' {$STAMP BS2}
' {$PBASIC 2.5}

'FREQOUT 4, 2000, 3000                          ' Signal program start/reset.

'DO
'DEBUG "Hello!", CR
'PAUSE 1000
'LOOP
 