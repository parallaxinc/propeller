'' ******************************************************************************
'' * DS1307 Object                                                              *
'' * James Burrows May 2006                                                     *
'' * Version 1.2                                                                *
'' ******************************************************************************
''
'' This object provides and example of use of the DS1307 i2c real time clock (RTC)
'' See - for reference:   http://www.maxim-ic.com/quick_view2.cfm/qv_pk/2688
''
'' this object provides the PUBLIC functions:
''  -> Init  - sets up the address and inits sub-objects such
''  -> geti2cError - returns the error passthru from the i2c sub object
''  -> settime - sets the clock time
''  -> setdate - sets the date
''  -> gettime - gets the time into the object - use getday, getmonth etc to read the variables
''  -> getdate - gets the date into the object - see above
''  -> getday/getmonth etc - returns the data got when you call gettime/getdate
''
'' this object provides the PRIVATE functions:
''  -> i2c2bcd - performs integer to BCD conversion
''  -> bcd2int - performs BCD to integer conversion
''
'' this object uses the following sub OBJECTS:
''  -> i2cObject
''
'' Revision History:
''  -> V1 - Release
''      -> V1.1 - Documentation update, slight code tidy-up
''                Changed to include a start status
''                Changed to stop object initializing if device not present on i2cBus
''      -> V1.2 - Updated to allow i2cSCL line driving pass-true to i2cObject
''
'' The default address is %1101_0000

CON

VAR
  long  DS1307_Address
  long  DS1307_Seconds
  long  DS1307_Minutes
  long  DS1307_Hours
  long  DS1307_Date
  long  DS1307_Days
  long  DS1307_Months    
  long  DS1307_Years
  long  started
   
OBJ
  i2cObject     : "i2cObject"

  
PUB Init(_deviceAddress,_i2cSDA,_i2cSCL,_driveSCLLine): okay
  DS1307_Address := _deviceAddress
  i2cObject.init(_i2cSDA, _i2cSCL,_driveSCLLine)

  ' start
  okay := start
  
  return okay

PUB start : okay
  ' start the object
  if started == false
    if i2cObject.devicePresent(DS1307_Address) == true
      started := true
    else
      started := false
  return started     

PUB stop
  ' stop the object
  if started == true
    started := false
    
PUB isStarted : result
  return started

PUB geti2cError : errorCode
  return i2cObject.getError

PUB setTime(ds_hour, ds_minute, ds_seconds)
  if started == true
    ' set the time
    i2cObject.i2cStart
    i2cObject.i2cWrite (DS1307_Address | 0,8)
    i2cObject.i2cwrite(0,8)
    DS1307_Hours   := int2bcd(ds_hour)
    DS1307_Minutes := int2bcd(ds_minute)
    DS1307_Seconds := int2bcd(ds_seconds)  
    i2cObject.i2cWrite (DS1307_Seconds,8)
    i2cObject.i2cWrite (DS1307_Minutes,8)
    i2cObject.i2cWrite (DS1307_Hours,8)        
    i2cObject.i2cStop
  

PUB setDate(ds_date,ds_day,ds_month,ds_year)
  if started == true
  ' set the date 
    i2cObject.i2cStart
    i2cObject.i2cWrite (DS1307_Address | 0,8)
    i2cObject.i2cwrite(3,8)
    DS1307_Date   := int2bcd(ds_date)
    DS1307_Days   := int2bcd(ds_day)
    DS1307_Months := int2bcd(ds_month)
    DS1307_Years  := int2bcd(ds_year)      
    i2cObject.i2cWrite (DS1307_Date,8)
    i2cObject.i2cWrite (DS1307_Days,8)  
    i2cObject.i2cWrite (DS1307_Months,8) 
    i2cObject.i2cWrite (DS1307_Years,8) 
    i2cObject.i2cStop    

  
PUB getDate : ds_seconds | ackbit
  ' get the date bytes from the clock
  if started == true
    i2cObject.i2cStart
    i2cObject.i2cWrite (DS1307_Address | 0,8)
    i2cObject.i2cwrite(3,8)
    i2cObject.i2cStart
    i2cObject.i2cWrite (DS1307_Address | 1,8)
    DS1307_Date   := i2cObject.i2cRead(i2cObject#_i2cACK)
    DS1307_Days   := i2cObject.i2cRead(i2cObject#_i2cACK)
    DS1307_Months := i2cObject.i2cRead(i2cObject#_i2cACK)
    DS1307_Years  := i2cObject.i2cRead(i2cObject#_i2cNAK)
    i2cObject.i2cStop

  
PUB getTime : ds_seconds | ackbit
  ' get the time bytes from the clock
  if started == true
    i2cObject.i2cStart
    i2cObject.i2cWrite (DS1307_Address | 0,8)
    i2cObject.i2cwrite(0,8)
    i2cObject.i2cStart
    i2cObject.i2cWrite (DS1307_Address | 1,8)
    DS1307_Seconds := i2cObject.i2cRead(i2cObject#_i2cACK)
    DS1307_Minutes := i2cObject.i2cRead(i2cObject#_i2cACK)
    DS1307_Hours   := i2cObject.i2cRead(i2cObject#_i2cNAK)
    i2cObject.i2cStop
    return bcd2int(DS1307_Seconds)    
  
  
PUB getHours : result
  return bcd2int(DS1307_Hours)

PUB getMinutes : result
  return bcd2int(DS1307_Minutes)

PUB getSeconds : result
  return bcd2int(DS1307_Seconds)  

PUB getDays : result
  return bcd2int(DS1307_Days)

PUB getMonths : result
  return bcd2int(DS1307_Months)

PUB getYears : result
  return bcd2int(DS1307_Years)      
  
pri int2bcd(value) : result
  ' convert integer to BCD (Binary Coded Decimal)
  result := ((value / 10) *16) + (value // 10) 
  return result

pri bcd2int(value) : result
  ' convert BCD (Binary Coded Decimal) to Integer
  result :=((value / 16) *10) + (value // 16) 
  return result 