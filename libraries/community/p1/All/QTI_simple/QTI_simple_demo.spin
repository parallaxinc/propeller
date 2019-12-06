con
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  qti_pin = 0
  
obj
  pst  : "parallax serial terminal"                            
  qti  : "qti_simple"

pub go

  pst.start(115200)

  repeat
    pst.dec(qti.readQTI(qti_pin))     'read QTI sensor on prop pin 0
    pst.newline
    waitcnt(clkfreq/5+cnt)