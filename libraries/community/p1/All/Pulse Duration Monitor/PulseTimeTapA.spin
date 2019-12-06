'' File: PulseTimeTapA.spin
'' Measures Duration of Pulse (Tap Switch Activated) Negative Logic ON=LO.

' Copyright 2017 MIROX Corporation
' Tested OK
' First Version  (1.A)
' 2017-07-02
' Current Version
' Edited by: Miro Kefurt
' 
' Version 1.A   2017-07-02
' Version 1.B   2017-07-02      Add conversion to microseconds
' Vesrion 1.C   2017-07-02      Change INPUT/OUTPUT Labels
' Version 1.D   2017-07-03      Add MilliSeconds
' Version 2.0   2017-07-03      Change INJ to TAP
' Version 2.A   2017-07-03      Add Logic Definitions

' Note: PAB has Yellow LED on P26 and P27 already installed  (3-7b) used for test purposes   

CON

  _xinfreq = 5_000_000              ' use 5MHz External crystal
  _clkmode = xtal1 + pll16x         ' 5MHz * PLL16 = 80MHz Clock Frequency

  

  ON = 0                            '  Define negative logic high
  OFF = 1                           '  Define negative logic low

  TAP = 10                          ' Define Tap Sensor INPUT Port (LO=ON)     (Or Test Push Button)

  LED = 26                          ' Define  LED OUTPUT Port (HI=ON)  

OBJ
  pst : "Parallax Serial Terminal"   ' Use with Parallax Serial Terminal to display values  

PUB Init
'Start Parallax Serial Terminal; waits 2 s for you to click Enable button
    pst.Start(115_200)
    waitcnt(clkfreq*2 + cnt)

' Define Port to Monitor
    dira[TAP]~                      'Set Tap Sensor Port to INPUT
' Define Port as Status Indicator    
    dira[LED] := 1                  'Sets LED to Output [LED ON=HI] 
    
' Configure counter module.
' Setup Counter A
      ctra[30..26] := %01100                            'make Counter A a <NEG detector>
      ctra[5..0] := 10                                  'APIN bit field to store P10 which will monitor the Circuit
      frqa := 1                                         'Define number to be added for each clock tick

      Main                                              ' Go to Main 

PUB Main  | ticks, mms, ms

 repeat                                                   ' Repeat forever
      phsa~                                               'Clear register
      waitpeq(ON, |< TAP, 0)                               'Wait until TAP is LO=ON, then continue
      outa[LED]~~                                         'Set LED HI = Turn Test LED ON
      waitpne(ON, |< TAP, 0)                               'Wait until TAP is NOT LO=ON (is HI=OFF) 
      ticks := phsa #> 0                                  'Read Clock Ticks
      outa[LED]~                                          'Set LED LO = Turn Test LED OFF  
      mms := ticks / (clkfreq/1_000_000)                  'Convert ticks to microseconds
      ' Display Result on PST
      pst.Str(String(pst#NL, "ticks = "))
      pst.Dec(ticks)
      pst.Str(String(pst#TB, " = microSeconds = "))
      pst.Dec(mms)
      ms := mms / 1_000                                  ' Convert microseconds to milliseconds 
      pst.Str(String(pst#TB, " = milliSeconds = "))
      pst.Dec(ms)
      