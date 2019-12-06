'' ******************************************************************************
'' * DS1307 Object                                                              *
'' * James Burrows Oct 07                                                       *
'' * Version 2.0                                                                *
'' ******************************************************************************
''
'' This object provides and example of use of the DS1307 i2c real time clock (RTC)
'' See - for reference:   http://www.maxim-ic.com/quick_view2.cfm/qv_pk/2688
''
'' this object provides the PUBLIC functions:
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
''  -> V2 - re-Release
''
'' The default address is %1101_0000

CON

VAR
  long  DS1307_Seconds
  long  DS1307_Minutes
  long  DS1307_Hours
  long  DS1307_Date
  long  DS1307_Days
  long  DS1307_Months    
  long  DS1307_Years 
   
OBJ
  i2cObject     : "basic_i2c_driver"

PUB setTime(i2cSCL, _deviceAddress, ds_hour, ds_minute, ds_seconds)
  ' set the time
  i2cObject.Start (i2cSCL)
  i2cObject.Write (i2cSCL, _deviceAddress | 0)
  i2cObject.write (i2cSCL, 0)
  DS1307_Seconds := int2bcd(ds_seconds)
  DS1307_Minutes := int2bcd(ds_minute)     
  DS1307_Hours   := int2bcd(ds_hour)
  i2cObject.Write (i2cSCL, DS1307_Seconds)
  i2cObject.Write (i2cSCL, DS1307_Minutes)
  i2cObject.Write (i2cSCL, DS1307_Hours)        
  i2cObject.Stop(i2cSCL)

  
PUB getTime(i2cSCL,_deviceAddress) : ds_seconds
  ' get the time bytes from the clock
  i2cObject.Start (i2cSCL)
  i2cObject.Write (i2cSCL,_deviceAddress | 0)
  i2cObject.Write (i2cSCL,0)
  i2cObject.Start (i2cSCL)
  i2cObject.Write (i2cSCL,_deviceAddress | 1)
  DS1307_Seconds := i2cObject.Read(i2cSCL, i2cObject#ACK)
  DS1307_Minutes := i2cObject.Read(i2cSCL, i2cObject#ACK)
  DS1307_Hours   := i2cObject.Read(i2cSCL, i2cObject#NAK)
  i2cObject.Stop(i2cSCL)
  return bcd2int(DS1307_Seconds)  

  
PUB setDate(i2cSCL, _deviceAddress, ds_date, ds_day, ds_month, ds_year)
  ' set the date 
  i2cObject.Start (i2cSCL)
  i2cObject.Write (i2cSCL,_deviceAddress | 0)
  i2cObject.Write (i2cSCL, 3)
  DS1307_Date   := int2bcd(ds_date)
  DS1307_Days   := int2bcd(ds_day)
  DS1307_Months := int2bcd(ds_month)
  DS1307_Years  := int2bcd(ds_year)      
  i2cObject.Write (i2cSCL,DS1307_Date)
  i2cObject.Write (i2cSCL,DS1307_Days)  
  i2cObject.Write (i2cSCL,DS1307_Months) 
  i2cObject.Write (i2cSCL,DS1307_Years) 
  i2cObject.Stop(i2cSCL)    

  
PUB getDate(i2cSCL,_deviceAddress) : ds_seconds
  ' get the date bytes from the clock
  i2cObject.Start (i2cSCL)
  i2cObject.Write (i2cSCL,_deviceAddress | 0)
  i2cObject.Write (i2cSCL,3)
  i2cObject.Start (i2cSCL)
  i2cObject.Write (i2cSCL,_deviceAddress | 1)
  DS1307_Date   := i2cObject.Read(i2cSCL,i2cObject#ACK)
  DS1307_Days   := i2cObject.Read(i2cSCL,i2cObject#ACK)
  DS1307_Months := i2cObject.Read(i2cSCL,i2cObject#ACK)
  DS1307_Years  := i2cObject.Read(i2cSCL,i2cObject#NAK)
  i2cObject.Stop(i2cSCL)

  
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