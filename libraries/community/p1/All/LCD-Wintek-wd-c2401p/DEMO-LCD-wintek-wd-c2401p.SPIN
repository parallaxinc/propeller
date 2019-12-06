CON
  _CLKMODE      = XTAL1 + PLL16X                        
  _XINFREQ      = 5_000_000

OBJ
  LCD : "LCD-wintek-wd-c2401p"
  
PUB DEMO
    LCD.START

    repeat
        LCD.CLEAR    
        LCD.MOVE(1)
        LCD.STR(STRING("Hello World!"))
        LCD.MOVE(1)
         
        waitcnt(clkfreq * 5 + cnt)
        LCD.CLEAR
         
        LCD.MOVE(3)
        LCD.STR(STRING("1 - 5 = "))
        LCD.INT(1-5)
         
        waitcnt(clkfreq * 5 + cnt)
        LCD.CLEAR
         
        LCD.MOVE(5)
        LCD.STR(STRING("HEX(255) = 0x"))
        LCD.HEX(255,2)
         
        waitcnt(clkfreq * 5 + cnt)
        LCD.CLEAR
         
        LCD.MOVE(6)
        LCD.STR(STRING("BIN(170) = "))
        LCD.BIN(170,8)
         
        waitcnt(clkfreq * 5 + cnt)
        LCD.CLEAR
         
        LCD.MOVE(1)
        LCD.STR(STRING("END OF DEMO. HAVE FUN!"))
        waitcnt(clkfreq * 10 + cnt)
         