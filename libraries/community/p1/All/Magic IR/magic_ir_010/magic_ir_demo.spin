CON              
 _clkmode        = xtal1 + pll16x
 _xinfreq        = 5_000_000
 
OBJ
 magicir : "magicir_010"
 
VAR
LONG code1[128], code1len
PUB main
magicir.storecode(0, @code1, @code1len)

repeat
  magicir.playcode(1,@code1,@code1len)
  waitcnt(clkfreq  + cnt)  

  