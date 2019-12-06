'' DS1620 Demo
'' -- Jon Williams, Parallax
'' -- 28 MAR 2006
''
'' Uses 2x16 Serial LCD (Parallax) to display temperature


CON

  _clkmode      = xtal1 + pll16x                        ' use crystal x 16
  _xinfreq      = 5_000_000
  

OBJ

  lcd   : "serial_lcd"
  temp  : "ds1620"
  delay : "timing"
  num   : "simple_numbers"
  

PUB main | tc, tf

  if lcd.start(3, 19200, 2)
    lcd.putc(lcd#LcdOn1)                                ' no cursor
    lcd.custom(0, @DegSym)                              ' create degrees symbol
    lcd.cls                                             ' setup screen
    lcd.str(string("TEMP"))
    lcd.backlight(1)                                    ' backlight on
    temp.start(0, 1, 2)                                 ' initialize DS1620

    repeat
      delay.pause1ms(1000)                              ' wait one second
      
      lcd.putc(lcd#LcdLine0 + 9)
      tc := temp.gettempc
      lcd.str(num.decf(tc / 10, 3))
      lcd.putc(".")
      lcd.str(num.dec(tc // 10))
      lcd.putc(0)
      lcd.putc("C")      

      lcd.putc(lcd#LcdLine1 + 9)
      tf := temp.gettempf
      lcd.str(num.decf(tf / 10, 3))
      lcd.putc(".")
      lcd.str(num.dec(tf // 10))
      lcd.putc(0)
      lcd.putc("F")

      
DAT

  DegSym      byte      $0E, $0A, $0E, $00, $00, $00, $00, $00