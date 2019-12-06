CON
 
  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz


VAR
BYTE    str[256]
  
OBJ

Debug: "FullDuplexParallel"  
PUB Main  
   Debug.start(8, 9, 10, 11, 0)
  waitcnt(clkfreq*2 + cnt)
Debug.tx(Debug#CLS)
repeat
   Debug.str(String("What hath FTDI wrought?", Debug#CR))
   Debug.getstr(@str)
   Debug.str(String("Yes, it hath wrought '"))
   Debug.str(@str)
   Debug.str(String("'.", Debug#CR))