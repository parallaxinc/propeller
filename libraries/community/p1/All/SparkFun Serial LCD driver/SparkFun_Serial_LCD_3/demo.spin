CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  TX_PIN        = 0
  BAUD          = 9_600

VAR
  byte i
                     
OBJ
  
  LCD           : "SparkFun_Serial_LCD.spin"

PUB Main

  LCD.init(TX_PIN, BAUD, 2, 16)        '2 line, 16 column display
  waitcnt(clkfreq / 100 + cnt)                


  waitcnt(clkfreq * 3 + cnt)
  LCD.backlight(140)                          '40% backlight
 ' waitcnt(clkfreq + cnt)
  LCD.cls
' LCD.str(@testmsg)
' waitcnt(clkfreq + cnt)

  LCD.cls
  LCD.cursor(0)
  LCD.str(string("Sparkfun serial LCD Demo"))
  repeat i from 129 to 157 step 4
    LCD.backlight(i)
    waitcnt(clkfreq / 3 + cnt)
  LCD.cls
  LCD.cursor(2)  'block cursor
'  waitcnt(clkfreq / 2 + cnt)
  LCD.home
  repeat 8
    LCD.cursorRight
    waitcnt(clkfreq / 2 + cnt)
  repeat 8
    LCD.cursorLeft
    waitcnt(clkfreq / 2 + cnt)
  LCD.cursor(0)  'cursor off
    
  LCD.gotoxy(2, 0)
  LCD.str(string("line 1"))
  waitcnt(clkfreq + cnt)
  LCD.gotoxy(2, 1)
  LCD.str(string("line 2"))
  waitcnt(clkfreq / 2 + cnt)

  repeat
    repeat i from 0 to 8
      LCD.scrollRight
      waitcnt(clkfreq / 2 + cnt)
    repeat i from 0 to 8
      LCD.scrollLeft
      waitcnt(clkfreq / 2 + cnt)
  LCD.finalize
 
                             