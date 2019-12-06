'' ******************************************************************************
'' * DS1621 Object                                                              *
'' * James Burrows May 2006                                                     *
'' * Version 1.2                                                                *
'' ******************************************************************************
''
'' This object provides and example of use of the DS1621 i2c temperature sensor
'' See - for reference:   http://www.maxim-ic.com/quick_view2.cfm/qv_pk/2737   
''
'' Based on the Propeller DS1620 object by Jon Williams @ Parallax
''
'' this object provides the PUBLIC functions:
''  -> Init  - sets up the address and inits sub-objects such
''  -> geti2cError - returns the error passthru from the i2c sub object
''  -> writeConfig - write to the config byte
''  -> readConfig - read from the config byte
''  -> startConversion - write a $EE to start a temp conversion process
''  -> readTempC - read the temperature in C (integer only)
''  -> readTempF - read the temp C and convert to F
'' 
'' this object provides the PRIVATE functions:
''  -> None
''
'' this object uses the following sub OBJECTS:
''  -> i2cObject
''
'' Revision History:
''  -> V1 - Release
''      -> V1.1 - Documentation update, slight code tidy-up
''                Changed to include a started status
''                Changed to stop object initializing if device not present on i2cBus
''      -> V1.2 - Updated to allow i2cSCL line driving pass-true to i2cObject
''
'' The default address is %1001_0000

CON
  _ReadTemp      = $AA
  _AccessTH      = $A1
  _AccessTL      = $A2
  _AccessConfig  = $AC
  _ReadCounter   = $A8
  _ReadScope     = $A9
  _StartConvert  = $EE
  _StopConvert   = $22
  _OneShotMode   = 1

VAR
  long  DS1621Address
  long  started
  
OBJ
  i2cObject     : "i2cObject" 
  
pub Init(_deviceAddress, _i2cSDA, _i2cSCL, _driveSCLLine): okay
  DS1621Address := _deviceAddress
  i2cObject.init(_i2cSDA,_i2cSCL,_driveSCLLine)

  ' start
  okay := start

  return okay

PUB start : okay
  ' try a restart - recheck the device
  if started == false
    if i2cObject.devicePresent(DS1621Address) == true
      started := true
    else
      started := false     
  return started  

PUB stop
  if started == true
    started := false
  
PUB isStarted : result
  ' return the started state
  return started
  
pub geti2cError : errorCode
  return i2cObject.getError  
  
pub writeConfig(configByte) : AckBit
  ' setup DS1621
  if started == true
    i2cObject.writeLocation(DS1621Address, _AccessConfig, configByte, 8,8)
    return AckBit

  
pub startConversion : AckBit
  ' init temp conversion
  if started == true
    i2cObject.i2cstart
    ackbit := i2cObject.i2cWrite(DS1621Address | 0,8)
    i2cObject.i2cWrite(_StartConvert,8)
    i2cObject.i2cStop
    return AckBit

  
pub readTempC : tempC
    ' read temp C (int only.  Not implemented decimal places! i.e. 20 not 20.5)
    if started == true
      tempC := i2cObject.readLocation(ds1621Address, _ReadTemp, 8, 9)
      return tempC

    
pub readConfig : configReg
  ' read Config register
  if started == true
    configReg := i2cObject.readLocation(ds1621Address, _AccessConfig, 8,8)
    return configReg   


pub readTempF : tempF
  if started == true
    ' read temp C
    tempF := readTempC
    ' Change it to TempF    
    tempF := tempF * 9 / 5 + 320
    ' return it
    return tempF
    
  