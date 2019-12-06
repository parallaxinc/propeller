{{General purpose Seven-segment display object. Can control from one to eight digits.

   Author: Steve Nicholson
   Version: 1.0 (4 Jan 2007)
   Email: ssteve@mac.com
   Copyright: none

}}

VAR
  long LowDigitPin, HighDigitPin                        'The pins for specifying digits.
                                                        ' Must be contiguous
                                                        ' HighDigitPin can be from 0 to 7 more than LowDigitPin
  long Seg0Pin, Seg8Pin                                 'The pins for the segments.
                                                        ' Must be contiguous
                                                        ' Segment 8 is the decimal point
  long flags
  long myStack[10]
  long runningCogID
  long myValue

CON
  isEnabled = %0001  

PUB Start(dLow, digits, s0, enabled)
'' Start the display
'' Parameters:
''   dLow - the pin number of the least significant digit
''   digits - the number of digits to display  (up to 8)
''   s0 - the pin number of segment 0
''   enabled - the initial enabled state
  myValue := 0
  LowDigitPin := dLow
  HighDigitPin := dLow + ((digits - 1) <# 7)            'Limit to eight digits
  Seg0Pin := s0
  Seg8Pin := s0 + 7
  dira[Seg0Pin..Seg8Pin]~~                              'Set segment pins to outputs
  dira[LowDigitPin..HighDigitPin]~~                     'Set digit pins to outputs
  outa[Seg0Pin..Seg8Pin]~                               'Turn off all segments
  dira[LowDigitPin..HighDigitPin]~~                     'Turn off all digits
  if enabled                                            'Set initial enabled state
    flags |= isEnabled
  else
    flags~
  stop
  runningCogID := cognew(ShowValue, @myStack) + 1

PUB Stop
'' Stop the display
  if runningCogID
    cogstop(runningCogID~ - 1)

PUB Enable
'' Enable the display
  flags |= isEnabled

PUB Disable
'' Disable the display
  flags &= !isEnabled
  
PUB SetValue(theValue)
'' Set the value to display
  myValue := theValue

PRI ShowValue | digPos, divisor, displayValue
' ShowValue runs in its own cog and continually updates the display
  dira[Seg0Pin..Seg8Pin]~~                              'Set segment pins to outputs
  dira[LowDigitPin..HighDigitPin]~~                     'Set digit pins to outputs
  repeat
    if flags & isEnabled
      displayValue := myValue                           'take snapshot of myValue so it can't be changed
                                                        ' while it is being displayed
      divisor := 1                                      'divisor is used to isolate a digit to display
      repeat digPos from 0 to HighDigitPin - LowDigitPin 'only display as many digits as there are pins
        outa[Seg8Pin..Seg0Pin]~                         'clear the segments to avoid flicker
        outa[HighDigitPin..LowDigitPin] := byte[@DigSel + digPos] 'enable the next digit
        outa[Seg8Pin..Seg0Pin] := byte[@Digit0 + displayValue / divisor // 10] 'display the digit
        waitcnt (clkfreq / 10_000 + cnt)                'the delay value can be tweaked to adjust
                                                        ' display brightness
        divisor *= 10
    else
      outa[HighDigitPin..LowDigitPin]~~                 'disable all digits
      waitcnt (clkfreq / 10 + cnt)                      'wait 1/10 second before checking again
     
DAT
        'Common cathode 7-segment displays are activated by bringing the cathode to ground
        DigSel          byte    %11111110
                        byte    %11111101
                        byte    %11111011
                        byte    %11110111
                        byte    %11101111
                        byte    %11011111
                        byte    %10111111
                        byte    %01111111
        
        Digit0          byte    %00111111
        Digit1          byte    %00000110
        Digit2          byte    %01011011
        Digit3          byte    %01001111
        Digit4          byte    %01100110
        Digit5          byte    %01101101
        Digit6          byte    %01111101
        Digit7          byte    %00000111
        Digit8          byte    %01111111
        Digit9          byte    %01100111

