''Robotics with the Boe-Bot - Ch03Prj02_DebuginMotion.spin
''Enter servo pulsewidth & duration for both wheels via Debug Terminal.

CON
                                       
  _clkmode        = xtal1 + pll8x
  _xinfreq        = 10_000_000
  CR = 13

VAR

  word ltPulseWidth                                     ' Left servo pulse width
  word rtPulseWidth                                     ' Right servo pulse width
  word pulseCount                                       ' Number of pulses to servo
  word counter                                          ' Loop counter
  long Pause, Pulsout
  
OBJ
   
  Debug: "FullDuplexSerialPlus"
  
PUB Ch03Prj02_DebuginMotion     

  Debug.start(31, 30, 0, 9600)
                                                              
  Pause := clkfreq/1_000
  Pulsout := clkfreq/500_000 
                                                          
  dira[12..13]~~
  outa[12..13]~ 

  repeat
    Debug.str(string("Enter left servo pulse width: ")) ' Enter values in Debug 
    ltPulseWidth := Debug.GetDec                        ' Terminal 
    waitcnt(Pause * 300 + cnt)                          ' Time delay for Debug to finish

    Debug.str(string("Enter right servo pulse width: "))
    rtPulseWidth := Debug.GetDec
    waitcnt(Pause * 300 + cnt)                          ' Time delay for Debug to finish

    Debug.str(string("Enter number of pulses: "))
    pulseCount := Debug.GetDec

    repeat counter from 1 to pulseCount                 ' Send specific number of pulses
      outa[13]~~ 
      waitcnt(Pulsout * ltPulseWidth + cnt)             ' Left servo motion
      outa[13]~
      outa[12]~~ 
      waitcnt(Pulsout * rtPulseWidth + cnt)             ' Right servo motion
      outa[12]~
      waitcnt(Pause * 20 + cnt)

'********************************************************************************************

' Robotics with the Boe-Bot - Ch03Prj02_DebuginMotion.bs2
' Enter servo pulsewidth & duration for both wheels via Debug Terminal.

'{$STAMP BS2}
'{$PBASIC 2.5}

'ltPulseWidth   VAR     Word                            ' Left servo pulse width
'rtPulseWidth   VAR     Word                            ' Right servo pulse width
'pulseCount     VAR     Byte                            ' Number of pulses to servo
'counter        VAR     Word                            ' Loop counter

'DO
'  DEBUG "Enter left servo pulse width: "               ' Enter values in Debug
'  DEBUGIN DEC ltPulseWidth                             ' Terminal

'  DEBUG "Enter right servo pulse width: "
'  DEBUGIN DEC rtPulseWidth

'  DEBUG "Enter number of pulses: "
'  DEBUGIN DEC pulseCount

'  FOR counter = 1 TO pulseCount                        ' Send specific number of pulses
'    PULSOUT 13, ltPulseWidth                           ' Left servo motion
'    PULSOUT 12, rtPulseWidth                           ' Right servo motion
'    PAUSE 20
'  NEXT

'LOOP
     