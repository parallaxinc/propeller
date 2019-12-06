CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  TX_PIN        = 0
  BAUD          = 9_600

VAR
  byte line
  byte col
  byte rval
                     
OBJ
  
  LCD           : "NewHaven_Serial_LCD.spin"
  Debug         : "Extended_FDSerial.spin"  

PUB Main | cidx, lidx

  Debug.start(31, 30, 0, 57600)             ' ignore tx echo on rx
  waitcnt(clkfreq * 1 + cnt)                ' Pause for FullDuplexSerial.spin to initialize

  LCD.init(TX_PIN, BAUD, 4, 20)    
  waitcnt(clkfreq / 100 + cnt)                

  waitcnt(clkfreq * 3 + cnt)

  LCD.displayOn
  waitcnt(clkfreq / 100 + cnt)

  LCD.cls
  waitcnt(clkfreq / 100 + cnt)                

  LCD.backLight(2)
  waitcnt(clkfreq / 100 + cnt)                

  lcd.contrast(30)

'  go_to
'  hex_rtn
  cursors
  
PUB go_to | lidx, cidx  
  repeat lidx from 0 to 3
    repeat cidx from 0 to 19
      lcd.gotoxy(cidx, lidx)
      lcd.putc("*")
      waitcnt(clkfreq / 20 + cnt)
    LCD.clrln(lidx)

pub hex_rtn | lidx    
  waitcnt(clkfreq + cnt)
  lcd.cls
  repeat lidx from $00 to $50
    lcd.gotoxy(0,0)
    lcd.hex(lidx, 4)
    lcd.gotoxy(10,0)
    lcd.dec(lidx)
    waitcnt(clkfreq / 4 + cnt)

pub Cursors | cidx
  lcd.cls
  lcd.cursor(LCD#LCD_ULCURS_ON)
  repeat cidx from 0 to 19
    lcd.cursorRight
    waitcnt(clkfreq / 4 + cnt)

  lcd.cursor(LCD#LCD_BLKCURS_ON)
  repeat cidx from 0 to 19
    lcd.cursorLeft
    waitcnt(clkfreq / 4 + cnt)

  lcd.cursor(LCD#LCD_BLKCURS_OFF)
  lcd.cursor(LCD#LCD_ULCURS_OFF) 
     