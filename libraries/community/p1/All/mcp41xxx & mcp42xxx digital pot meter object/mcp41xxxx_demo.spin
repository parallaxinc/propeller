{ mcp41xxx/42xxx demo code }

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  
  POT_NONE      = %0000_0000
  POT_0         = %0000_0001
  POT_1         = %0000_0010
  POT_BOTH      = %0000_0011
  
OBJ
  pot : "mcp41xxx"

PUB main | value
  pot.init(0, 1, 2)
  pot.setpot(POT_0, 0)
  waitcnt(cnt + clkfreq)
  pot.setpot(POT_0, 128)
  waitcnt(cnt + clkfreq)
  pot.setpot(POT_0, 255)

  value := 255
  repeat while value <> 0
    pot.setpot(POT_0, value)
    value--
    waitcnt(cnt + clkfreq / 100)   