
{Receiver for PAM-7Q GPS sentences
 The receiver runs in a separate cog; the interface in the using cog}
CON  
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
 
dat
DaysinMonth byte 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31

VAR
  long stack[40]               'stack for receiver cog
  byte cog
  byte  mychar                 'current character from string
  byte  mystring[100]           'maximum length sentence
  word  Ginpoint, Goutpoint    'pointers into sentence
  word  SGOutPoint             'saved GOutPoint
  long  GPSMask                'single 'one' corresponding to gps pin  
  long  BitTime, HalfBitTime, LongTime   'used in getchar
  byte  BufferLock              ' 0 says instring not being updated
  byte  LocTimeValid             '0 says loc time not being updated 
  byte  UTCHour, UTCMinute, UTCSecond, UTCDate, UTCMonth, UTCYear
  long  FracSec                'fractions of second
  byte  GPSStatus              '"A" or "V"
  long  Latitude[2]             'degrees, minutes, N/S, then fractional part
  long  Longitude[2]            'degrees, minutes, E/W, then fraction
  long  Speed[2]                 'speed over ground"  integer, fraction
  long  Course[2]                 'Course over ground
  long  Altitude[2]              'altitude in meters
  byte  SatInView                 'satellites in view     
  byte  LocHour, LocMinute, LocSecond, LocDate, LocMonth, LocYear, Day 
  long  Zone                   'time zone, hours from GMT

PUB Start(ThePin)               'begin here
    stop                        'by convention
    GPSMask := 1 << ThePin      'mask in IO register
    BitTime := clkfreq/9600     'serial timing
    HalfBitTime := BitTime / 2
    cog := cognew(GPSRcvr, @stack) + 1  'start the receiver
    return (cog - 1)                    'actual cog number   

PUB Stop
    if cog
       cogstop(cog~ -1)

'++++++++++These are the user interface methods+++++++++++++++
'++++++++Wherever the input parameter is Address, it must an address       

PUB SetZone(TheZone)                 'set time zone Greenwich +/- hour
    Zone := TheZone       

PUB  GetString(Address)                            'this MUST be an address
     repeat until (BufferLock == 0)                'wait for valid sentence
     bytemove(Address, @MyString, strsize(@MyString))  'up to and including zero
                                                                                                                  
PUB  GetStatus                                 'return an "A" or "V"
     return GPSStatus       

PUB GetTime(Address)
    repeat until (LocTimeValid == 0)
    bytemove (Address, @LocHour, 7)            'give up seven bytes of time, date and day

PUB GetLatitude(Address)                       'return two words of Latitude
    longmove(Address, @Latitude, 2)

PUB GetLongitude(Address)        
    longmove(Address, @Longitude, 2)

PUB GetSpeed(Address)
    longmove(Address, @Speed, 2)

PUB GetCourse(Address)        
    longmove(Address, @Course, 2)

PUB GetAltitude(Address)                    'altitude in meters        
    longmove(Address, @Altitude, 2)

PUB GetSatInView
    return SatInView        
            
'+++++++++++++This is the code that runs in its own cog++++++++++++++++

PUB GPSRcvr                                     'this runs in its own cog
  repeat
     repeat until (MyChar == "$")                 'get aligned with message frame
       MyChar := SerialChar

     BufferLock := 1                                'we are filling the buffer    
     GinPoint := 0                                  'beginning of buffer    
     repeat until (MyChar == "*")                    'collect a whole message
       MyChar := SerialChar
       mystring[GinPoint++] := MyChar                'into string  
       MyString[GInPoint] := 0                       'zero terminated
     BufferLock := 0                                 'buffer is stable   

     if (mystring[2] == "R") and (mystring[3] == "M") and (mystring[4] == "C")      
        ParseRMC                                     'take apart a RMC Sentence
        UTC2Loc                                      'UTC time/date to local 
        Day := CalcDOW                               'day of week 

     elseif (mystring[2] == "G") and (mystring[3] == "G") and (mystring[4] == "A")
        ParseGGA                                      'altitude

     elseif (mystring[2] == "G") and (mystring[3] == "S") and (mystring[4] == "V")
        ParseGSV                                      'satellites in view

'+++++++++++to use this, change the address in cognew here+++++++++++
PUB ForceSentence                     'can be used to force any sentence (for testing)
        bytemove(@MyString, string("GPRMC,060000.000,A,3723.2475,N,12158.3416,W,0.13,309.62,311215,,*"),99)
    repeat                                  'keep this running in case te zone is changed       
        ParseRMC         
        UTC2Loc          
        Day := CalcDOW
        waitcnt(clkfreq/10+cnt)   

Pri ParseRMC                                       'parse a RMC sentence
        GOutPoint := 0                               'parse from the front
        FindComma                                   'advance to UTC Time
        UTCHour := TwoDigBin                        'get the time
        UTCMinute := TwoDigBin
        UTCSecond := TwoDigBin                      'leaves pointer at decimal point

        GOutPoint++                                 'skip over decimal point
        FracSec := Dig2Punc                         '3 digits of fractional seconds

        GPSStatus := myString[GOutPoint++]          'A or V
        FindComma

        Latitude.byte[0] := TwoDigBin               'latitude
        Latitude.byte[1] := TwoDigBin
        SGoutPoint := GOutPoint++                    'skip over decimal point
        Latitude[1] := Dig2Punc                      'fractions of degrees
        if ((GOutPoint - SGoutPoint) == 5)            'if five digits of fraction
          Latitude[1] := (Latitude[1] + 5) / 10       'round and reduce to 4 digits
        Latitude.byte[2] := myString[GOutPoint++]    'N or S             
        FindComma

        Longitude.byte[0] := ThreeDigBin            'longitude
        Longitude.byte[1] := TwoDigBin
        SGoutPoint := GOutPoint++                    'skip over decimal point 
        Longitude[1] := Dig2Punc                     'fractions of degrees
        if ((GOutPoint - SGoutPoint) == 5)            'if five digits of fraction
          Longitude[1] := (Longitude[1] + 5) / 10     'round and reduce to 4 digits
        Longitude.byte[2] := myString[GOutPoint++]    'N or S             
        FindComma

        Speed := Dig2Punc                            'speed over ground
        Speed[1] := Dig2Punc

        if MyString[GOutPoint] <> ","                  'check for course present 
            Course := Dig2Punc                        'course over ground
            Course[1] := Dig2Punc
        else
            FindComma                                 'no course, skip comma    
                
        UTCDate := TwoDigBin                       'get the date
        UTCMonth := TwoDigBin
        UTCYear := TwoDigBin

pri FindComma                                     'find a comma, leave pointer just past it
  repeat until myString[GOutPoint++] == ","        

pri TwoDigBin                                     'convert two chars to binary, leave pointer just past
    Result := (myString[GOutPoint++] - "0") * 10
    Result += (myString[GOutPoint++] - "0")

pri ThreeDigBin                                     'convert three chars to binary, leave pointer just past
    Result := (myString[GOutPoint++] - "0") * 100   'used to extract longitude
    Result += (myString[GOutPoint++] - "0") * 10
    Result += (myString[GOutPoint++] - "0")    

pri Dig2Punc                                       'accumulate decimal digits until puncuation
    repeat
      MyChar := myString[GOutPoint++]                'get next character
      if (MyChar == ",") or (MyChar == ".")          'terminator
          return                                     'GoutPoint is past term
      Result := (Result * 10) + (MyChar - "0")        'shift and add

pri ParseGGA                         'get the altitude
    GOutPoint := 0          
    repeat 9                         'skip to altitude
       findcomma
    Altitude := Dig2Punc               'integer part
    Altitude[1] := Dig2Punc            'fraction part

pri ParseGSV                           'get satellites in view
    GOutPoint := 0          
    repeat 3                         'skip to sat in view
       findcomma
    SatInView := TwoDigBin     

pri SerialChar                 'de-serialize one character
  waitpeq(0, GpsMask , 0)      'wait until beginning of start bit
  waitcnt(halfBitTime+cnt)     'little bit past half way through start bit
  result := 0
  LongTime := cnt
  repeat 8
    result := result >> 1     'scale what we have
    waitcnt(LongTime += BitTime)
    if (ina & GpsMask) <> 0 
        result := result | $80        'set the bit  
  waitpeq(GpsMask, GpsMask, 0)  'wait until stop bit in case the last data bit is a zero
  return result

PRI UTC2Loc                       'utc time/date to local time/date
    LocTimeValid := 1             'local time being updated
    Bytemove (@LocHour, @UTCHour, 6)  'move 
    if (Zone == 0)
       LocTimeValid := 0         
       return                         'greenwich needs no differences
          
    elseif (Zone < 0)                'lagging (western himesphere 
      LocHour := UTCHour + Zone       'Zone will be negative
       if ((LocHour & $80) <> 0)           'it is still yesterday here
          LocHour := LocHour + 24         'correct time 
          LocDate := UTCDate - 1            'fix up date
          if UTCDate == 1                     'it is the first of a month at Greenwich
             LocMonth := UTCMonth - 1       'still last month here
             LocDate := DaysInMonth[LocMonth - 1]  'last day of the month
             if (UTCMonth == 3) and((UTCYear // 4) == 0)
                LocDate := 29              'Sadi Hawkins day
             if UTCMonth == 1                 'may still be last YEAR (New Years Eve)
                LocYear := UTCYear -1       'fix up year
                LocMonth := 12              'December
                LocDate := 31               'new years eve
      LocTimeValid := 0         
               
    else                                   'leading (Eastern Hemisphere          
       LocHour := UTCHour + Zone             
       if LocHour > 23                       'it is tomorrow here
          LocHour := LocHour - 24           'correct time
          LocDate := UTCDate + 1              'and date
          if (LocDate > DaysInMonth[LocMonth]) or ((UTCMonth == 2) and (UTCDate == 29))'past the end of the month?
             LocDate := 1                          'first day of next month
             LocMonth := UTCMonth + 1
             if (UTCMonth == 2) and (UTCDate == 28) and ((UTCYear//4) ==0)   'feb 28 in london
                LocDate := 29                      'Sady Hawkins
                LocMonth := 2
             if (UTCMonth == 12) and (UTCDate == 31)     'still new years eve in london
                LocMonth := 1                         'Jan 1 next year
                LocYear := UTCYear + 1
       LocTimeValid := 0                 
              
PRI CalcDOW 
    Result := Lookup(LocMonth: 7, 10, 10, 6, 8, 11, 6, 9, 12, 7, 10, 12)   'first day of month in 2001
    Result += (LocYear - 1)                       'one day later per year
    Result += (LocYear -1) / 4                     'leap years come and gone 
    if ((LocYear // 4) == 0) and (LocMonth > 2)
       Result += 1                                  'this is leap year in March or later
    result += LocDate
    Result := (Result // 7) + 1                       'sunday is 1 and so on
 