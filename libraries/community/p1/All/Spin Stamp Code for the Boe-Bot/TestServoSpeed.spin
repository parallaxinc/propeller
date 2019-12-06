''Robotics with the Boe-Bot - TestServoSpeed.spin
''Enter pulse width, then count revolutions of the wheel.
''The wheel will run for 6 seconds
''Multiply by 10 to get revolutions per minute (RPM).

CON
                                       
  _clkmode        = xtal1 + pll8x
  _xinfreq        = 10_000_000

VAR

  word counter
  long Pause, Pulsout, pulseWidth, pulseWidthComp
  
OBJ
   
  Debug: "FullDuplexSerialPlus"
  Piezo: "Piezospeaker"
  
PUB TestServoSpeed     

  Debug.start(31, 30, 0, 9600)

  Pause := clkfreq/1_000
  Pulsout := clkfreq/500_000 
                                                          
  dira[12..13]~~
  outa[12..13]~

  Piezo.beep(4, 3000, 6000)                           ' Signal program start/reset.

  repeat

    Debug.str(string("Enter pulse width: "))

    pulseWidth := Debug.GetDec

    pulseWidthComp := 1500 - pulseWidth

    repeat counter from 1 to 244
      outa[12]~ 
      waitcnt(Pulsout * pulseWidth + cnt)              
      outa[12]~
      outa[13]~~ 
      waitcnt(Pulsout * pulseWidthComp + cnt)
      outa[13]~
      waitcnt(Pause * 20 + cnt)

'********************************************************************************************

' Robotics with the Boe-Bot - TestServoSpeed.bs2
' Enter pulse width, then count revolutions of the wheel.
' The wheel will run for 6 seconds
' Multiply by 10 to get revolutions per minute (RPM).

'{$STAMP BS2}
'{$PBASIC 2.5}

'counter          VAR    Word
'pulseWidth       VAR    Word
'pulseWidthComp   VAR    Word

'FREQOUT 4, 2000, 3000                                ' Signal program start/reset.

'DO

'  DEBUG "Enter pulse width: "

'  DEBUGIN DEC pulseWidth

'  pulseWidthComp = 1500 - pulseWidth

'  FOR counter = 1 TO 244
'    PULSOUT 12, pulseWidth
'    PULSOUT 13, pulseWidthComp
'    PAUSE 20
'  NEXT

'LOOP
     