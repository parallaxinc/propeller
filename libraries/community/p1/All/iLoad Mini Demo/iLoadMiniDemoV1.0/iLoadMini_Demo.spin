''***************************************
''* iLoad Mini Demo v1.0                *
''* (C) 2008 Loadstar Sensors           *
''* Author:  Oliver Theile              *
''* based on Ping_Demo                  *
''* Started: 01-10-2008                 *
''***************************************

CON

  _clkmode  = xtal1 + pll16x
  _xinfreq  = 5_000_000

  Freq_Pin  = 0                                  ' I/O Pin For Frequency
  Ctrl_Pin  = 1                                  ' I/O Pin For Control
                                                 
  LCD_Pin   = 2                                  ' I/O Pin For LCD
  LCD_Baud  = 19_200                             ' LCD Baud Rate
  LCD_Lines = 2                                  ' Parallax 2X16 LCD

  qA =  -1.94432E-11                             ' quadratic Constants (given with every Sensor)
  qB =  3.67429E-04                              ' replace these calibration
  qC =  -1.15625E+03                             ' values with the ones provided
  k0 =  0.567248                                 ' with your sensor

VAR

  long  load
    
OBJ

  LCD   : "debug_lcd"
  Mini  : "iLoadMini"
  
PUB Start

  LCD.start(LCD_Pin, LCD_Baud, LCD_Lines)        ' Initialize LCD Object
  LCD.cursor(0)                                  ' Turn Off Cursor
  LCD.backlight(true)                            ' Turn On Backlight   
  LCD.cls                                        ' Clear Display
  LCD.str(string("iLoad Mini Demo", 148, "Load:", 161, "lbs"))

  Mini.SetParam(qA, qB, qC, k0)                  ' Set the Parameters
  Mini.GetFreq(Freq_Pin, Ctrl_Pin)               ' Start measuring the frequency
  WaitCnt(clkfreq/ 1000*1000 + CNT)                      
  Mini.SetTare                                   ' Tare the sensor

  repeat                                         ' Repeat Forever
    LCD.gotoxy(7, 1)                             ' Position Cursor
    load := Mini.GetLoad                         ' Get Load In Pounds
    LCD.decf(load/ 10, 3)                        ' Print Fractional Part
    LCD.putc(".")                                ' Print Decimal Point
    LCD.decx(load// 10, 1)                       ' Print Fractional Part
    waitcnt(clkfreq/ 10+ cnt)                    ' Pause 1/10 Second
  