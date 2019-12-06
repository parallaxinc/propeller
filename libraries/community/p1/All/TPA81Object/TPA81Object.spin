{{
******************************************************************************
* TPA81 Thermal Array Sensor                                                 *
* Version 1.0                                                                *
******************************************************************************

by Joe Lucia - 2joester@gmail.com
http://irobotcreate.googlepages.com

** No-COG Use:
Call Init
Call SetServo (if you have a Servo)
Call ReadValues to read the TPA81 values into a byte array (pass a pointer to a 10-byte array)

** COG use:
Call New()
Call the Set procedures
Call GetValue to read the value of a specific pixel at a specific position ount of the local byte array

The TPA81Object will scan based on the paramters you set and accumulate the readings into a local byte array.



}}

VAR
  long  started       ' i2c is started, if not, nothing will work
  long  mycog         ' cogid (if using a cog)
  long  stack[20]     ' cog stack
  byte  readings[10]  ' holding for TPA81 data
  byte  _sdapin, _sclpin
  long  spos          ' current servo position
  long  sdir          ' current servo scan direction
  byte  Values[288]   ' 32 columns x 9 rows
                      '' Values = Ambient,Pix1,2,3,4,5,6,7,8,Ambinet,Pix1,... 
  long  lowscan, highscan       ' low and high points for spos, set the SAME to not scan
  long  SCANSPEED               ' scan speed of servo + interval to take readings (must be > 40ms)
  long  _Version                ' last Version as read from the TPA81
  long  _AmbientTemp            ' last Ambient Temperature read from the TPA81 (based on last spos read) 
  long  _lastServoPosition      ' current position of the servo

OBJ
  i2cObject   : "i2cObject"

CON '' Cog Stuff, don't sue these if you don't call New() first
PUB New(sdapin, sclpin)                                 '' Start a new Cog to scan and collect readings
  _sdapin:=sdapin
  _sclpin:=sclpin
  
  ' set default values
  sdir:=1                                               ' direction servo is scanning 1=right, -1=left                                               
  scanspeed:=55                                         ' ms between servo-move and TPA Read (should be > 40ms)
  lowscan:=0                                            ' left-most servo position
  highscan:=31                                          ' right-most servo position                       

  if mycog
    cogstop(mycog)
    mycog:=0

  mycog := cognew(TPA81Run, @stack)+1

  if mycog
    Delay(100)  '' wait for object ot initialize

  return mycog

PRI Delay(ms)
  waitcnt(clkfreq/1000*ms+cnt)
  
PRI TPA81Run                                            '' main Cog routine
  '' Main COG Procedure
  Init(_sdapin, _sclpin)
  
  repeat
    if started
      setservo(0,spos)                                  ' move servo to spos
        
      Delay(SCANSPEED)                                  ' wait for servo and TPA81 to settle
      ReadValues(0, @readings)                          ' read the data from the TPA81 into readings array
       
      _Version := readings[0]                           ' store TPA81 version into _Version
       
      ' move new temperature reaqdings into Values
      if lowscan == highscan
        bytemove(@values[(spos)*9], @readings[1], 9)
      else
        if sdir>0
          bytemove(@values[(spos-1)*9], @readings[1], 9)  '' TUNE the -1 based on your servo movement
        else
          bytemove(@values[(spos+2)*9], @readings[1], 9)  '' TUNE the +2 based on your servo movement                        
         
      ' update next servo position
      if lowscan <> highscan
        spos := spos + sdir
         
        if spos>highscan
          sdir := -1
          spos := highscan-1
         
        if spos<lowscan
          sdir := 1
          spos := lowscan+1
       
PUB AmbientTemperature(sposi)                           '' Returns the Ambient Temperature at Servo Position                     
  if started
    return values[sposi*9]

PUB Version                                             '' Returns TPA81 Version
  if started
    return _Version

PUB GetValue(x, y)                                      '' Returns the Temperature for pixel y (0..7) at Servo Position x (0..31)
  if started
    return values[x*9+y+1]

PUB GetServoPosition                                    '' Returns Current Servo Position
  if started
    return _lastServoPosition

PUB SetLowScan(ls)                                      '' Sets the low point for Servo Position
  if started
    lowscan:=ls
    spos:=lowscan
  
PUB SetHighScan(hs)                                     '' Sets the high point for Servo Position
  if started
    highscan:=hs
    spos:=lowscan

PUB SetScanSpeed(ss)                                    '' Sets the rate (ms) to scan the TPA81 at
  ScanSpeed:=ss
  
CON '' i2c Stuff - call Init directly if you are not using a COG  
PUB Init(_i2cSDAPin, _i2cSCLPin) : OK                   '' Initialized i2c
  if started:=i2cObject.init(_i2cSDAPin, _i2cSCLPin, 0)
    started:=i2cObject.Start

  return started  

PRI devicePresent(vdev) : okay                          '' Check for existence of TPA81
  okay:=false
  ' check if device is present before allowing initialization
  if started == true
    okay := i2cObject.devicePresent(ADDRESSES[vdev])
  return okay

PRI isStarted : result                                  
  return started

PRI  geti2cError : errorCode
  return i2cObject.getError

CON '' Used by COG or call Directly if not running on a COG   
PUB ReadValues(vdev, ptr_values) | x                    '' Reads array values into an array of bytes
  ' pass in a pointer to an array of 10 bytes
  ' SoftwareRev,Ambient,pixel1,2,3,4,5,6,7,8
  if started == true
    i2cObject.i2cStart
    i2cObject.i2cWrite(ADDRESSES[vdev] | 0,8)
    i2cObject.i2cWrite(0,8)
    i2cObject.i2cStart
    i2cObject.i2cWrite(ADDRESSES[vdev] | 1,8)
    repeat x from 0 to 8
      BYTE[ptr_values][x] := i2cObject.i2cRead(i2cObject#_i2cACK)
    BYTE[ptr_values][9] := i2cObject.i2cRead(i2cObject#_i2cNAK)
    i2cObject.i2cStop

PUB SetServo(vdev, _spos)                               '' Set the Servo Position on the TPA81
  if started==true
    i2cObject.i2cStart
    i2cObject.i2cWrite(ADDRESSES[vdev] | 0,8)
    i2cObject.i2cWrite(0,8)
    i2cObject.i2cWrite(_spos,8)
    i2cObject.i2cStop
    _lastServoPosition:=_spos
    
DAT

ADDRESSES         byte    $D0                           '' TPA81 i2c Address