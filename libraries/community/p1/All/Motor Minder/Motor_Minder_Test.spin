{{

      Motor_Minder_Test.spin
      Tom Doyle
      6 March 2007

    Motor_Minder monitors the speed and revolution count of a motor using a shaft encoder.
    It was tested with the Melexis 90217 Hall-Effect Sensor (Parallax 605-00005) and a single
    magnet mounted (Parallax 605-00006) on the shaft. It should work with any type of
    sensor that puts out one pulse per revolution. The object runs in a new cog updating
    varibles in the calling cogs address space. It has been tested with one motor. To clear
    the revolution counter memory call the start procedure again.
      
      
}}
      

CON

  _CLKMODE = XTAL1 + PLL16X        ' 80 Mhz clock
  _XINFREQ = 5_000_000

  Encoder1pin   =  7                ' shaft encoder - Propeller pin

  F1 = 1.0                          ' floating point 1
  F60000 = 60_000.0                 ' floating point 60,000


OBJ

  mm    : "Motor_Minder"
  lcd   : "serial_lcd"
  num   : "simple_numbers"
  F     : "FloatMath"
  FS    : "FloatString"

VAR

  long  period, revCount             ' motor period and revCount updated by Motor_Minder.spin
  long  Fwidth, Frpm                 ' floating point variables for display
  
PUB Init

  if lcd.start(0, 9600, 4)
    lcd.putc(lcd#LcdOn1)                                ' no cursor
    lcd.cls                                             ' setup screen
    lcd.backlight(1)
    lcd.str(string("Encoder")) 

    if mm.start(Encoder1pin, @period, @revCount) > 0
    
     repeat
       lcd.gotoxy(0,0)
      
       FS.setPrecision(4)
    
       Fwidth := F.FFloat(period)
       Fwidth := F.FDiv(F1, Fwidth)

       Frpm := F.FMul(Fwidth, F60000)

       lcd.str(FS.FloatToString(Frpm))
       lcd.str(string(" RPM     "))
      
       lcd.gotoxy(0,1)
       lcd.str(num.dec(revCount))
