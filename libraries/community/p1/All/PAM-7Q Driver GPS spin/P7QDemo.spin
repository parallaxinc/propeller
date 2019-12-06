


{  Demo program for PAM7Q GPS Receiver}

CON
   
  _clkmode = xtal1 + pll16x           'standard clock mode
  _xinfreq = 5_000_000                '80 MHz

  GpsPin = 15                         'serial in from PAM7Q  
  thebutton = 0                      'adjust time zone 
  pressed = 0                        'when pressed

  CS = 16  ''CS: Clear Screen        'a very few pst constants   
  PC =  2  ''PC: Position Cursor in x,y          
  CE = 11  ''CE: Clear to End of line
 
OBJ

  pst : "Parallax Serial Terminal"
  p7q : "pam7q"

VAR  
  byte  gpsstring[100], thechar, spoint     'display a sentence
  byte LocalHour, LocalMinute, LocalSecond, LocalDate, LocalMonth, LocalYear, DayOfWeek
  byte ValidityCode   '  "A" or "V" from RMC sentence
  long MyLat[2]       'latitude
  long LatSecs        'fractional minutes converted to seconds 
  long MyLon[2]       'longitude
  long LonSecs         'long seconds
  long MySpeed[2]     'speed over ground
  long MyCourse[2]    'course "
  long MyAltitude[3]  'meters, fractions, converted to feet
  byte MySatInView     'satellites in view
  long myzone         'time zone, signed hours from GMT
  byte TheCog         'the actual cog started by PAM7Q
  byte DSTFlag        'if <> 0, we are falling back

PUB Main                  'begin here
  pst.Start (115_200)                      'start up ser terminal
  pst.str(String("hello, world   "))       'runs in cog 1
  pst.NewLine
  waitcnt(clkfreq/10+cnt)

  Thecog := p7q.start(GpsPin)              'start up gps receiver cog
  pst.str(string("Start GPS Rcvr:  "))
  pst.dec (thecog)
  pst.newline
  
  MyZone := -7                          'summer in california   
  p7q.setzone(myzone)
  waitcnt(clkfreq * 2 + cnt) 

  pst.char(CS)                          'format the display
  crsrxy(0,0)
  pst.str(string("+++PAM-7Q Demo+++"))
  crsrxy(0,1)
  pst.str(string("Latest Sentence:   "))
  crsrxy(0,2)
  pst.str(string("GPS Validity Code: "))
  crsrxy(30,2)
  pst.str(string("Time Zone:  "))
  crsrxy(0,3)
  pst.str(string("Local Time:    Hrs     Min     Sec"))
  crsrxy(40,3)
  pst.str(string("Local Date:  "))
  crsrxy(0,4)
  pst.str(string("Latitude:      Deg           Min       Min            Sec"))
  crsrxy(0,5)
  pst.str(string("Longitude:     Deg           Min       Min            Sec"))
  crsrxy(0,6)
  pst.str(string("Speed Over Ground:           Course Over Ground"))
  crsrxy(0,7)
  pst.str(string("Altitude (Meters):          Feet: "))
  crsrxy(0,8)
  pst.str(string("Satellites in View:"))

'++++++++++++now just obtain and display PAM information forever++++++++++
  repeat                                          'forever
     if (ina[thebutton] == pressed)              'around the world in 25 seconds
       if (++myzone) > 12                        'just does whole hours
          myzone := -12
       p7q.setzone(myzone)  

     p7q.getstring(@gpsstring)                    'display the raw string
     crsrxy(20,1)
     repeat spoint from 0 to 99
       thechar := gpsstring[spoint]
       if (thechar == "*") or (thechar == 0)
          quit
       pst.char(thechar)
     pst.char(CE)                              'clear to end of line      
       
     ValidityCode := p7q.GetStatus                 'validity status
     if (ValidityCode <> "A") and (ValidityCode <> "V")
       ValidityCode := "x"                         'force it to an ascii char
     crsrxy(20,2)
     pst.char(ValidityCode)
       
     crsrxy(41,2)               'time zone
     pst.str(lookupz((myzone+12):@UTCM12, @UTCM11, @UTCM10, @UTCM9, @UTCM8, @UTCM7, @UTCM6, @UTCM5,{
                                } @UTCM4, @UTCM3, @UTCM2, @UTCM1, @UTC, @UTCP1, @UTCP2, @UTCP3, {
                                } @UTCP4, @UTCP5, @UTCP6, @UTCP7, @UTCP8, @UTCP9, @UTCP10, @UTCP11, @UTCP12))
     pst.char(CE) 

     
     p7q.GetTime(@LocalHour)         'seven bytes of time, date, and day
     crsrxy(12,3)
     print2(LocalHour)
     crsrxy(20,3)
     print2(LocalMinute)
     crsrxy(28,3)
     print2(Localsecond)

     crsrxy(52,3)
     pst.str(Lookup(LocalMonth: @SMon1, @SMon2, @SMon3, @SMon4, @SMon5, @SMon6, {
                              } @SMon7, @SMon8, @SMon9, @SMon10, @SMon11, @SMon12))
     pst.char(" ")
     print2(LocalDate)
     pst.str(string(", 20"))
     print2(LocalYear)

     crsrxy(65,3)
     pst.str(lookup(DayOfWeek: @Day1, @Day2, @Day3, @Day4, @Day5, @Day6, @Day7))

     p7q.GetLatitude(@MyLat)
     crsrxy(12,4)
     pst.dec(byte[@MyLat.byte[0]])    'degrees
     crsrxy(20,4)
     pst.dec(byte[@MyLat.byte[1]])    'minutes
     pst.char(".")
     pst.dec(MyLat[1])                'frac minutes
     crsrxy(36,4)
     pst.dec(byte[@MyLat.byte[1]])    'minutes
     LatSecs := MyLat[1] * 60         '100_000 times seconds
     crsrxy(45,4)
     pst.dec(LatSecs / 100_000)
     pst.char(".")
     pst.dec(LatSecs // 100_000)
     crsrxy(60,4)
     if MyLat.byte[2] == "N"
        pst.str(@LatTN)
     else
        pst.str(@LatTS)   

     p7q.GetLongitude(@MyLon)
     crsrxy(12,5)
     pst.dec(byte[@MyLon.byte[0]])    'degrees
     crsrxy(20,5)
     pst.dec(byte[@MyLon.byte[1]])    'minutes
     pst.char(".")
     pst.dec(MyLon[1])                'frac minutes
     crsrxy(36,5)
     pst.dec(byte[@MyLon.byte[1]])    'minutes
     LonSecs := MyLon[1] * 60         '100_000 times seconds
     crsrxy(45,5)
     pst.dec(LonSecs / 100_000)
     pst.char(".")
     pst.dec(LonSecs // 100_000)
     crsrxy(60,5)
     if MyLon.byte[2] == "E"
        pst.str(@LongE)
     else
        pst.str(@LongW)                                     

     p7q.GetSpeed(@MySpeed)
     crsrxy(20,6)
     pst.str(string("  "))
     pst.dec(MySpeed)
     pst.char(".")
     pst.dec(MySpeed[1])

     p7q.GetCourse(@MyCourse)
     crsrxy(50,6)
     pst.str(string("  "))
     pst.dec(MyCourse)
     pst.char(".")
     pst.dec(MyCourse[1])

     p7q.GetAltitude(@MyAltitude)
     crsrxy(20,7)
     pst.dec(MyAltitude)
     pst.char(".")
     pst.dec(MyAltitude[1])
     MyAltitude[2] := MyAltitude * 100 + MyAltitude[1]   'tenths of meters
     crsrxy(36, 7)
     pst.dec((MyAltitude[2] * 328) / 10_000)            'feet  

     mySatInView := p7q.GetSatInView
     crsrxy(20,8)
     pst.dec(MySatInView)
                           
     pst.newline
     waitcnt(clkfreq/2+cnt)

     
PUB CRSRXY(x,y)                  'position pst cursor
    pst.char(PC)
    pst.char(x)
    pst.char(y)

PUB Print2(x)                     'pst decimal with leading zero if needful
   if (x < 10)
     pst.char("0")
   pst.dec(x)

PUB CheckDST                             'see if we need to turn DST on or off
    if (LocalMonth == 3) and (DayOfWeek == 1)         'sunday in march
      if (LocalDate > 7) and (LocalDate < 15)
         if (LocalHour == 1) and (LocalMinute == 59) and (LocalSecond == 59)  'magic moment
             MyZone++                         'spring forward
             p7q.SetZone(MyZone)              

    elseif (LocalMonth == 11) and (DayOfWeek == 1)    'sunday in Nov
       if (LocalDate < 8)
         if (LocalHour == 1) and (LocalMinute == 59) and (LocalSecond == 59)
            if (DSTFlag <> 0)                     'first time this year?
               DSTFlag := 1                     'set the flag
               MyZone--                          'fall back
               p7q.SetZone(MyZone)
            else                 
               DSTFlag := 0                      'second time, all done  
               

dat    'here are a bunch of text strings

Day1    BYTE  "  Sunday  ", 0
Day2    BYTE  "  Monday  ", 0
Day3    BYTE  " Tuesday  ", 0
Day4    BYTE  " Wednesday", 0
Day5    BYTE  " Thursday ", 0
Day6    BYTE  "  Friday  ", 0
Day7    BYTE  " Saturday ", 0

SMon1   BYTE  "Jan", 0
SMon2   BYTE  "Feb", 0
SMon3   BYTE  "Mar", 0
SMon4   BYTE  "Apr", 0
SMon5   BYTE  "May", 0
SMon6   BYTE  "Jun", 0
SMon7   BYTE  "Jul", 0
SMon8   BYTE  "Aug", 0
SMon9   BYTE  "Sep", 0
SMon10  BYTE  "Oct", 0
SMon11  BYTE  "Nov", 0
SMon12  BYTE  "Dec", 0

UTCM12  BYTE  "-12", 0
UTCM11  BYTE  "-11", 0
UTCM10  BYTE  "-10 Hawai'i", 0
UTCM9   BYTE  "-9 Alaska", 0
UTCM8   BYTE  "-8 PST", 0
UTCM7   BYTE  "-7 MST/PDT", 0
UTCM6   BYTE  "-6 CST/MDT", 0
UTCM5   BYTE  "-5 EST/CDT", 0
UTCM4   BYTE  "-4 EDT", 0
UTCM3   BYTE  "-3 Greenland", 0
UTCM2   BYTE  "-2", 0
UTCM1   BYTE  "-1", 0
UTC     BYTE  "0 Greenwich", 0
UTCP1   BYTE  "+1 Holland", 0
UTCP2   BYTE  "+2 Eastern Europe", 0
UTCP3   BYTE  "+3 Ukraine", 0
UTCP4   BYTE  "+4 Moscow", 0
UTCP5   BYTE  "+5", 0
UTCP6   BYTE  "+6", 0
UTCP7   BYTE  "+7", 0
UTCP8   BYTE  "+8 China", 0
UTCP9   BYTE  "+9 Japan", 0
UTCP10  BYTE  "+10 Tasmania", 0
UTCP11  BYTE  "+11", 0
UTCP12  BYTE  "+12", 0

LatTN   BYTE  "North ", 0
LatTS   BYTE  "South ", 0
LongE   byte  "East ", 0
LongW   byte  "West ", 0

     