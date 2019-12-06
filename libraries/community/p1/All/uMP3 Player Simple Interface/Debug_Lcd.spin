'' *****************************
'' *  Debug_Lcd                *
'' *  (C) 2006 Parallax, Inc.  *
'' *****************************
''
'' Debugging wrapper for Serial_Lcd


OBJ

  lcd  : "serial_lcd"                                   ' driver for Parallax Serial LCD
  ncnv : "simple_numbers"                               ' number to string conversion


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
  
  
PUB str(str_addr) | i

'' Print a zero-terminated string

  lcd.str(str_addr)


PUB dec(value)

'' Print a signed decimal number

  lcd.str(ncnv.dec(value)) 


PUB decf(value, width) 

'' Prints signed decimal value in fixed-width field

  lcd.str(ncnv.decf(value, width))  
  

PUB hex(value, digits)

'' Print a hexadecimal number

  lcd.str(ncnv.hex(value, digits))


PUB ihex(value, digits)

'' Print an indicated hexadecimal number

  lcd.str(ncnv.ihex(value, digits))  


PUB bin(value, digits)

'' Print a binary number

  lcd.str(ncnv.bin(value, digits))


PUB ibin(value, digits)

'' Print an indicated binary number

  lcd.str(ncnv.ibin(value, digits))    
    

PUB cls

'' Clears LCD and moves cursor to home (0, 0) position

  lcd.cls 


PUB home

'' Moves cursor to 0, 0

  lcd.home
  

PUB clrln(line)

'' Clears line

  lcd.clrln(line)
  

PUB newline

'' Moves cursor to next line, column 0; will wrap from line 3 to line 0

  lcd.newline


PUB gotoxy(col, line)

'' Moves cursor to col/line

  lcd.gotoxy(col, line)


PUB cursor(crsr_type)

'' Selects cursor type
''   0 : cursor off, blink off  
''   1 : cursor off, blink on   
''   2 : cursor on, blink off  
''   3 : cursor on, blink on

  lcd.cursor(crsr_type) 


PUB custom(char, chr_addr)

'' Installs custom character map

  lcd.custom(char, chr_addr)

      
PUB backlight(status)

'' Enable (1) or disable (0) LCD backlight

  lcd.backlight(status)

  