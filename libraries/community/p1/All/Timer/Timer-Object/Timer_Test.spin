'' Timer Test
'' -- Jon Williams, Parallax
'' -- 06 APR 2006


CON

  _clkmode      = xtal1 + pll16x                        ' use crystal x 16
  _xinfreq      = 5_000_000
  

OBJ

  lcd   : "serial_lcd"
  timer : "timer"

  
PUB main

  if lcd.start(0, 19_200, 4)                            ' 4x20 Parallax LCD on A0, set to 19.2k
    lcd.cursor(0)                                       ' no cursor
    lcd.cls
    lcd.backlight(1)                                    ' backlight on
    lcd.str(string("TIMER"))
    if timer.start                                      ' start timer cog
      timer.run
      repeat
        lcd.gotoxy(0, 1)                                ' move to col 0 on line 1
        lcd.str(timer.showTimer)
    else
      lcd.cls
      lcd.str(string("No cog for Timer."))
      
  