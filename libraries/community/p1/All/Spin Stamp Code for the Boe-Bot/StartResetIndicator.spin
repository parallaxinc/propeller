''Robotics with the Boe-Bot - StartResetIndicator.spin
''Test the piezospeaker circuit.

CON
   
  _clkmode = xtal1 + pll8x
  _xinfreq = 10_000_000
  CR = 13
  CLS = 0

VAR

  long Pause
  
OBJ
   
  Debug: "FullDuplexSerialPlus"
  Piezo: "Piezospeaker"
   
   
PUB StartResetIndicator
 
  Debug.start(31, 30, 0, 9600)

  Pause := clkfreq/1_000
  
  Debug.tx(CLS)
  Debug.str(string("Beep!!!"))                  ' Display while speaker beeps. 
  Piezo.beep(4, 3000, 12000)                     ' Signal program start/reset.
' Piezo.beep(pin, freq, dur)                    ' dur = 2 second = 12000 cycles
  
  repeat                                        ' REPEAT...LOOP
    Debug.str(string(CR, "Waiting for reset"))  ' Display message 
    waitcnt(Pause * 500 + cnt)                  ' every 0.5 seconds

'********************************************************************************************

' Robotics with the Boe-Bot - StartResetIndicator.bs2
' Test the piezospeaker circuit.

' {$STAMP BS2}                                  ' Stamp directive.
' {$PBASIC 2.5}                                 ' PBASIC directive.

'DEBUG CLS, "Beep!!!"                           ' Display while speaker beeps.
'FREQOUT 4, 2000, 3000                          ' Signal program start/reset.

'DO                                             ' DO...LOOP
'DEBUG CR, "Waiting for reset"                  ' Display message
'PAUSE 500                                      ' every 0.5 seconds
'LOOP 