{A trending barometer using the Parallax
Barometer modules and a generic Real Time
Clock module.

Uses a serial 4 x 20 serial LCD to display:

- Current Pressure
- 3 hour tend (narrative)
- 1 hour tred (narrative)
- instantaneous trend (narrative)

By Richard Newstead, G3CWI, June 2012}


CON

  _clkmode      = xtal1 + pll16x  
  _xinfreq      = 5_000_000       

  ALTITUDE      = 145 'Your altitude in metres ASL
  
  'Define some EEPROM storage locations
  'Note $9000 to $905C reserved
  Time = $9060

  'Storage for trend values
  T3   = $9064
  T1   = $9068
  Ti   = $906c
  
  'Flag for initial boot detection
  Flag = $9070
 

OBJ

  bar   : "29124_altimeter"
  rtc   : "DS1302_full"
  SN    : "Simple_Numbers" 
  DEBUG : "Debug_LCD03"
  EEPROM: "I2C_ROMEngine"

Var

  byte hour, minute, second
  Long time_long,Trend3,Trend1,Trendi

PUB Start | temp 'Start everything running

  
  rtc.init( 4, 5, 6 ) 'define ports for Real Time Clock
  
  bar.start_explicit( 0, 1, true )
  bar.set_resolution( bar#highest )  'Set to highest resolution. 

  DEBUG.start( 15, 9600, 4 ) '4 lines serial LCD  
  
  EEPROM.ROMEngineStart( 29, 28, 0 )            
  Initialise_EEPROM
 
  Main
     
Pub Main | p

  DEBUG.CLS 
  DEBUG.Backlight(true)
  DEBUG.Cursor(0)
 
  Display
  
  repeat

    rtc.readTime( @hour, @minute, @second )  'read time from DS1302

    'Update everything once a minute
    IF minute<>EEPROM.ReadLong(Time)
    
      p  := bar.average_press 'Get the average pressure.
       
      EEPROM.WriteLong(Time, minute)
   
      time_long := hour * 10000 + minute * 100 + second 'Concatenate
 
        'Store hourly readings
        If minute := 0 and second :=0
          EEPROM.WriteLong($9000+hour*4,  p)
          
        'Using obs, calculate 3 hour trend and store
        Trend3 := EEPROM.ReadLong($9000+hour*4) - EEPROM.ReadLong($9000 +((hour+21)//24)*4)
        EEPROM.WriteLong(T3,Trend3)
        
        'Using obs, calculate 1 hour trend and store
        Trend1 := EEPROM.ReadLong($9000+hour*4) - EEPROM.ReadLong($9000 +((hour+23)//24)*4)   
        EEPROM.WriteLong(T1,Trend1)
        
        'Using obs, calculate instantaneous trend and store
        Trendi := p - EEPROM.ReadLong($9000 +((hour+23)//24)*4)
        EEPROM.WriteLong(Ti,Trendi)

      Display    

Pub Display | sp, cm, p

      p  := bar.average_press
      
      cm := ALTITUDE * 100
             
      sp := bar.sealevel_press(p, cm)

      DEBUG.cls
                              
      DEBUG.str(string("QNH :")) 'Print sea-level pressure heading.

      DEBUG.str(bar.formatn(sp, bar#MILLIBARS | bar#CECR, 6))   ' Print sea-level pressure in millibars, clear-to-end, and CR.

      DEBUG.nl
      
         'Print medium-term trend narrative
        Debug.Str(string("3hr :"))
        
        Trend_Test(EEPROM.ReadLong(T3))
        
         'Print short-term trend narrative
        Debug.Str(string("1hr :"))
        
        Trend_Test(EEPROM.ReadLong(T1)) 
        
          'Print instantaneous trend narrative
        Debug.Str(string("inst:"))
        
        Trend_Test(EEPROM.ReadLong(Ti)) 
          
Pri Initialise_EEPROM | p, Loc

 'Fill EEPROM with default data
  'if not already filled
  
  p := bar.average_press

  If EEPROM.Readlong(Flag)<>$5555 'check fill flag
  
     Repeat Loc from $9000 to $905c step 4
        EEPROM.WriteLong (Loc, p)
  
    EEPROM.WriteLong(Flag,$5555)  
  
  'get starting minutes and store
  rtc.readTime( @hour, @minute, @second )
  EEPROM.WriteLong(Time, minute)

Pri Trend_Test (Trend)

  Case Trend
      -9999..-600:Debug.Str(string("Very rapid fall"))
      -599..-360 :Debug.Str(string("Falling rapidly"))
      -359..-160 :Debug.Str(string("Falling"))
      -159..-10  :Debug.Str(string("Falling slowly"))
      -9..9      :Debug.Str(string("Steady"))
      10..159    :Debug.Str(string("Rising slowly"))
      160..359   :Debug.Str(string("Rising"))
      360..600   :Debug.Str(string("Rising rapidly"))
      600..9999  :Debug.Str(string("Very rapid rise"))
      Other      :Debug.Str(string("Error"))

  Debug.nl
  