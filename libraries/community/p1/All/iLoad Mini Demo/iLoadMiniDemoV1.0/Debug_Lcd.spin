'' *****************************
'' *  Debug_Lcd                *
'' *  (C) 2006 Parallax, Inc.  *
'' *****************************
''
'' Debugging wrapper for Serial_Lcd object
''
'' Author.... Jon Williams
'' Updated... 29 APR 2006


OBJ

  lcd : "serial_lcd"                                    ' driver for Parallax Serial LCD
  num : "simple_numbers"                                ' number to string conversion


PUB start(pin, baud, lines) : okay

'' Starts serial LCD object
'' -- returns true if all parameters okay

  okay := lcd.start(pin, baud, lines) 


PUB stop

'' Stops lcd object -- frees the pin (floats)

  lcd.stop

  
PUB putc(txbyte)

'' Send a byte to the terminal

  lcd.putc(txbyte)
  
  
PUB str(strAddr)

'' Print a zero-terminated string

  lcd.str(strAddr)


PUB dec(value)

'' Print a signed decimal number

  lcd.str(num.dec(value))  


PUB decf(value, width) 

'' Prints signed decimal value in space-padded, fixed-width field

  lcd.str(num.decf(value, width))   
  

PUB decx(value, digits) 

'' Prints zero-padded, signed-decimal string
'' -- if value is negative, field width is digits+1

  lcd.str(num.decx(value, digits)) 


PUB hex(value, digits)

'' Print a hexadecimal number

  lcd.str(num.hex(value, digits))


PUB ihex(value, digits)

'' Print an indicated hexadecimal number

  lcd.str(num.ihex(value, digits))   


PUB bin(value, digits)

'' Print a binary number

  lcd.str(num.bin(value, digits))


PUB ibin(value, digits)

'' Print an indicated (%) binary number

  lcd.str(num.ibin(value, digits))     
    

PUB cls

'' Clears LCD and moves cursor to home (0, 0) position

  lcd.cls 


PUB home

'' Moves cursor to 0, 0

  lcd.home
  

PUB gotoxy(col, line)

'' Moves cursor to col/line

  lcd.gotoxy(col, line)

  
PUB clrln(line)

'' Clears line

  lcd.clrln(line)


PUB cursor(type)

'' Selects cursor type
''   0 : cursor off, blink off  
''   1 : cursor off, blink on   
''   2 : cursor on, blink off  
''   3 : cursor on, blink on

  lcd.cursor(type)
       

PUB display(status)

'' Controls display visibility; use display(false) to hide contents without clearing

  if status
    lcd.displayOn
  else
    lcd.displayOff


PUB custom(char, chrDataAddr)

'' Installs custom character map
'' -- chrDataAddr is address of 8-byte character definition array

  lcd.custom(char, chrDataAddr)

      
PUB backLight(status)

'' Enable (true) or disable (false) LCD backlight
'' -- affects only backlit models

  lcd.backLight(status)

  