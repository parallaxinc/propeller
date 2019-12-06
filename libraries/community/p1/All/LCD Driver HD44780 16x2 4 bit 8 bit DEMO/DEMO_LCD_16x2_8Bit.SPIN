CON
  _CLKMODE      = XTAL1 + PLL16X                        
  _XINFREQ      = 5_000_000

OBJ
  LCD : "LCD_16X2_8BIT"
  
PUB DEMO
  LCD.START
  
  LCD.MOVE(3,1)
  LCD.STR(STRING("Hello World!"))

  LCD.MOVE(3,2)
  LCD.STR(STRING("1 - 5 = "))

  LCD.DEC (1-5)

  WAITCNT(120_000_000 + CNT)
  LCD.CLEAR

  LCD.STR(STRING("HEX(255) = 0x"))

  LCD.HEX(255,2)

  WAITCNT(120_000_000 + CNT)
  LCD.CLEAR

  LCD.STR(STRING("DEC(170) = "))

  LCD.MOVE(1,2)
  
  LCD.BIN(170,8)
  
  WAITCNT(120_000_000 + CNT)
  LCD.CLEAR

  LCD.MOVE(3,1)
  LCD.STR(STRING("END OF DEMO."))
  LCD.MOVE(4,2)
  LCD.STR(STRING("HAVE FUN !"))
 