CON

  { ==[ CLOCK SET ]== }
  _CLKMODE      = XTAL1 + PLL4X
  _XINFREQ      = 5_000_000                          ' 5MHz Crystal


  Vclk_p        = 20  
  Vn_p          = 19
  Vo_p          = 19
  Vcs_p         = 18


OBJ

  DEBUG  : "FullDuplexSerial"    
  FREQ   : "ADC_FREQ_READ"

VAR    

PUB Main | f
      
  DEBUG.start(31, 30, 0, 57600)
  waitcnt(clkfreq + cnt)  
  DEBUG.tx($0D)   

  REPEAT
    f := FREQ.getfreq(Vo_p, Vn_p, Vclk_p, Vcs_p, 5, %11010)
    DEBUG.str(string("Frequency: "))
    DEBUG.dec(f)
    DEBUG.tx($0D)
    
    DEBUG.str(string("Max Value: "))
    DEBUG.dec(FREQ.getmax)
    DEBUG.tx($0D)

    DEBUG.str(string("Min Value: "))
    DEBUG.dec(FREQ.getmin)
    DEBUG.tx($0D)

    DEBUG.str(string("Samples:   "))
    DEBUG.dec(FREQ.getsamples)
    DEBUG.tx($0D)
    DEBUG.tx($0D)
    
    