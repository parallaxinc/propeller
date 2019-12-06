CON
  _clkmode       = xtal1 + pll16x
  _xinfreq       = 5_000_000

''Board I/0
'' P0..P8   - Open I/O  (HDR1 [1-9])
'' P9..P11  - Active High Buttons
'' P12..P14 - TV Out
'' P15      - Yellow LED
'' P16..P18 - Open I/O  (HDR1 [10-12])
'' P19..P23 - Short Protected I/O (HDR2 [1-5]) 220 Ohms
'' P24..P27 - LEDs
'' P28..P29 - I2C
'' P30..P31 - PRG tx/rx


  

SCL_PIN     = 19 
SDA_PIN     = 20
INT_PIN     = 21
LED_PIN     = 24
HRT_LED_PIN = 15
TV_PIN      = 12
BTN1_PIN    = 9
BTN2_PIN    = 10
BTN3_PIN    = 11

OBJ
  button:       "Button"
  vid:          "TV_Text"
  rtc:          "PCF8583"

PUB ButtonBlinkTime |  cntr, year, ryear, date, month, dow, hsecs, seconds, minutes, hours, pm

  dira[LED_PIN]~~

  vid.Start(TV_PIN)

  vid.gotoxy(0,0)
  vid.str(String("RTC Test"))
  
  if rtc.Init(SCL_PIN, SDA_PIN, INT_PIN, 1)
    vid.str(string("...started "))
  else
    vid.str(string("...Init failed"))

  rtc.SetYear(2009)
  rtc.SetMonth(10)
  rtc.SetDate(01)
  rtc.SetHours(12)

  cntr := 0   
  repeat
    outa[LED_PIN] := ina[INT_PIN] 
    waitcnt(clkfreq/200 + cnt)
    if phsb > cntr
      cntr := phsb
      rtc.GetFullTimeTwelve(@hsecs, @seconds, @minutes, @hours, @pm)

      vid.gotoxy(0,1)
      vid.str(string("Cog PHSB    : "))
      vid.dec(phsb)
      vid.gotoxy(0,2)
       
      vid.gotoxy(0,4)
      if hours < 10
        vid.dec(0) 
      vid.dec(hours)
      vid.out(58)
      if minutes < 10
        vid.dec(0)
      vid.dec(minutes)
      vid.out(58)
      if seconds < 10
        vid.dec(0)
      vid.dec(seconds)
      vid.out(32)
      case pm
        0:
          vid.str(string("AM"))
        1:
          vid.str(string("PM"))

      rtc.GetFullDate(@date, @month, @ryear, @dow, @year)
       
      vid.gotoxy(0,5)
      case dow
        1: vid.str(string("Sun"))
        2: vid.str(string("Mon"))
        3: vid.str(string("Tue"))
        4: vid.str(string("Wed"))
        5: vid.str(string("Thu"))
        6: vid.str(string("Fri"))
        7: vid.str(string("Sat"))
        other: vid.dec(dow)
      vid.out(32)  
      vid.str(string("          "))
      vid.gotoxy(4,5) 
      vid.dec(month)
      vid.out(47)
      vid.dec(date)
       
      vid.gotoxy(0,6)
      vid.dec(year)
      vid.out(40)
      vid.dec(ryear)
      vid.out(41)
  
    if button.ChkBtnPulse(BTN1_PIN, 1, 30)
      rtc.SetSeconds(0)
      rtc.SetMinutes(0)
      rtc.SetHours(0)
      
    if button.ChkBtnPulse(BTN2_PIN, 1, 30)
      rtc.SetYearRaw(ryear++)
        if ryear == 4
          ryear~

    if button.ChkBtnPulse(BTN3_PIN, 1, 30)
      rtc.CorrectYear
               