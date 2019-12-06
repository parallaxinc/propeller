{{ DS1302-demo.spin}}

CON
  _clkmode = xtal1 + pll16x 
  _xinfreq = 5_000_000

 
OBJ
  text  : "TV_Text"
  SN    : "Simple_Numbers"
  rtc   : "DS1302"

VAR

  byte heure, minute, seconde

PUB main 
  text.Start(12)
  text.out($00)
 
  ' to call each time the propeller start 
  rtc.init( 4, 5, 6 )                         ' ports Clock, io, chip enable

  ' to call only after the DS1302 power on 
  rtc.config                                  ' Set configuration register

  ' to call all time you want to set time
  rtc.setDatetime( 01, 17, 07, 3, 5, 59, 50 )    '  month, day, year, day of week, hour, minute, seconde
                                                        
  repeat
    text.out($00)                             ' clear screen
     
    rtc.readTime( @heure, @minute, @seconde ) ' read time from DS1302 
    
    text.str( SN.decx(heure,2) )
    text.str( string(":"))
    text.str( SN.decx(minute,2) )
    text.str( string(":") )
    text.str( SN.decx(seconde,2))
    
    waitcnt( clkfreq + cnt ) 

   