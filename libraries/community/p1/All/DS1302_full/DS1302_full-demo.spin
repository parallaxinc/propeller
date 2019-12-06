{{ DS1302_full-demo.spin}}

CON
  _clkmode = xtal1 + pll16x 
  _xinfreq = 5_000_000

 
OBJ
  SN    : "Simple_Numbers"
  rtc   : "DS1302_full"
  debug : "SerialMirror"        'Same as fullDuplexSerial, but can also call from subroutines

  
VAR
  byte hour, minute, second, day, month, year, dow
  byte cmd, out
  byte data[12]

  
PUB main|i,_month,_day,_year,_dow,_hour,_min,_sec
  waitcnt(clkfreq * 5 + cnt)                      'wait 5 secs, start FullDuplexSerial
  Debug.start(31, 30, 0, 115200)
  Debug.Str(String("MSG,Initializing...",13))
 
  '==================================================================================
  'call this function each time the propeller starts
  rtc.init( 4, 5, 6 )                             'ports Clock, io, chip enable

  '==================================================================================
  'set time
  debug.str(string("=========== DS1302 demo ===========",13))
  debug.str(string("enter 1 to setup ds1302, 0 to proceed on to demo without setting time",13))
  if(debug.GetNumber<>0)
    debug.str(string("enter month (1-12)",13))
    _month:=debug.getnumber
    debug.str(string("enter day (1-31)",13))
    _day:=debug.getnumber
    debug.str(string("enter year (00-99)",13))
    _year:=debug.getnumber
    debug.str(string("enter day of week (1-7)",13))
    _dow:=debug.getnumber
    debug.str(string("enter hour (0-23)",13))
    _hour:=debug.getnumber
    debug.str(string("enter minute (0-60)",13))
    _min:=debug.getnumber
    debug.str(string("enter second (0-60)",13))
    _sec:=debug.getnumber

    'call this function only after DS1302 power on
    rtc.config                                    'Set configuration register

    'call this function to set DS1302 time
    rtc.setDatetime( _month, _day, _year, _dow, _hour, _min, _sec ) 'month, day, year, day of week, hour, minute, second
                                                        
  '==================================================================================
  'change the tricle charger setup from that currently defined in the config function
  'Trickle charger setup                       tc_enable     diodeSel   resistSel
  '                                                |            |          |
  rtc.write(rtc.command(rtc#clock,rtc#tc,rtc#w),(%1010 << 4) + (1 << 2)+ ( 1 ))
  out:=rtc.read(rtc.command(rtc#clock,rtc#tc,rtc#r))
  Debug.Str(string("Trickle charge register contents = "))
  Debug.bin(out,8)
  Debug.Str(String(13,13))

  '==================================================================================
  'write data values to ram registers
  repeat i from 0 to 30
    cmd:=rtc.command(rtc#ram,i,rtc#w)
    Debug.Str(string("Writing RAM address "))
    Debug.Dec(i)
    Debug.Str(string(" cmd byte = "))
    Debug.Bin(cmd,8)
    Debug.Str(String(13))
    rtc.write(cmd,i)
  Debug.Str(String(13,13))

  '==================================================================================
  'read data values from ram registers
  repeat i from 0 to 30
    cmd:=rtc.command(rtc#ram,i,rtc#r)
    Debug.Str(string("Reading RAM address "))
    Debug.Dec(i)
    Debug.Str(string(" = "))
    out:=rtc.read(cmd)
    Debug.Dec(out)
    Debug.Str(String(13))   
  Debug.Str(String(13,13))

  '==================================================================================
  'write data to registers 0-11 in burst mode
  Debug.Str(string("Writing RAM data in burst mode"))
  repeat i from 0 to 30
    data[i]:=30-i
  cmd:=rtc.command(rtc#ram,rtc#burst,rtc#w)
  rtc.writeN(cmd,@data,12)
  Debug.Str(String(13,13))

  '==================================================================================
  'read data registers 0-11 in burst mode
  Debug.Str(string("Reading RAM data in burst mode",13))
  cmd:=rtc.command(rtc#ram,rtc#burst,rtc#r)
  rtc.readN(cmd,@data,12)
  repeat i from 0 to 11
    Debug.Str(string("Data "))
    Debug.Dec(i)
    Debug.Str(string(" = "))
    Debug.Dec(data[i])
    Debug.Str(String(13))
  Debug.Str(String(13,13))

  '==================================================================================
  'read date and time, once per second
  repeat
     
    rtc.readTime( @hour, @minute, @second )     'read time from DS1302
    rtc.readDate( @day, @month, @year, @dow )   'read date from DS1302
    
    Debug.str( SN.decx(hour,2) )
    Debug.str( string(":"))
    Debug.str( SN.decx(minute,2) )
    Debug.str( string(":") )
    Debug.str( SN.decx(second,2))
    Debug.str( string(", ") )
    Debug.str( SN.decx(dow,2))
    Debug.str( string(" ") )
    Debug.str( SN.decx(month,2))
    Debug.str( string(" ") )
    Debug.str( SN.decx(day,2))
    Debug.str( string(" ") )
    Debug.str( SN.decx(year,2))
    Debug.Str(String(13))    
    waitcnt( clkfreq + cnt ) 

   