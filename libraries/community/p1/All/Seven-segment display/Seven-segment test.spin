{Demo program for SevenSegment object.}

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  lowDigit = 3                  'Low digit cathode
  digits = 5                    'Number of digits to display
  Segment0 = 9                  'Segment start pin

VAR
  long  counter

OBJ
  sevenseg : "SevenSegment"
  
PUB Start
  sevenseg.start(lowDigit, digits, Segment0, true)
  
  counter := 0
  repeat
    sevenseg.SetValue(counter++)
    if (counter / 10 // 10) == 0
      sevenseg.disable                                  'disable the display when the second digit is 0
    else
      sevenseg.enable
    waitcnt(clkfreq/10 + cnt)
  sevenseg.SetValue(99)
  