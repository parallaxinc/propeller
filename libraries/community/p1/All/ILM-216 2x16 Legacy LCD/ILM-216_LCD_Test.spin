'' ILM-216_LCD.spin Object Test Program
'' -- Tom Doyle
'' -- 31 January 2007

CON

  _clkmode      = xtal1 + pll16x                        ' use crystal x 16
  _xinfreq      = 5_000_000

OBJ

  lcd   : "ILM-216_LCD"

VAR

  long i, j
  
PUB main

  if lcd.start(0, 9600)                     ' lcd serial pin, baud
                                   
    lcd.cls                                 ' clear display
    lcd.backlight(1)                        ' backlight on
    lcd.cursorOff                           ' cursor off
    lcd.home                                ' home                               
    
    '' position cursor
    i := 0                                  
    j := 15                                 
    repeat 16
      lcd.gotoxy(i,0)
      lcd.putc("+")
      lcd.gotoxy(j,1)
      lcd.putc("-")
      i++
      j--
      waitcnt(7_000_000 + cnt)

    '' clear line
    waitcnt(40_000_000 + cnt) 
    lcd.clrln(0)
    waitcnt(40_000_000 + cnt)
    lcd.clrln(1)
    waitcnt(40_000_000 + cnt)

    '' backlight control  
    lcd.backlight(0)
    waitcnt(40_000_000 + cnt)
    lcd.backlight(1)

    '' Display Configuration Screen Text
    lcd.putc(27)
    lcd.putc("E")
    lcd.putc("0")
    waitcnt(180_000_000 + cnt)  
    

    '' display string - new line
    lcd.clrln(0)
    lcd.clrln(1)
    lcd.home
    lcd.str(string("    Keep On"))
    lcd.newLine
    lcd.str(string("   Spinning!   "))

    '' cursor control
    lcd.cursorBlock
    waitcnt(120_000_000 + cnt)
    lcd.cursorUline
    waitcnt(120_000_000 + cnt)
    lcd.cursorOff



      
  