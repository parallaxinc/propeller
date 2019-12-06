'' ******************************************************************************
'' * SRF08 Object                                                            *
'' * James Burrows May 2006                                                     *
'' * Version 1.1                                                                *
'' ******************************************************************************
''
'' this object provides the PUBLIC functions:
''  -> Init  - sets up the address and inits sub-objects such
''  -> Start - try a re-start.
''  -> geti2cError - return the i2cobject error
''  -> isStarted - return the start status
''  -> getSwVersion  - read register 0 - the device revision
''  -> setSRFRangingMode - set the ranging mode
''  -> getRangingMode  - return the ranging mode
''  -> getSRFRange - get the max range returnable (sets the pulse timeout)
''  -> getLight - read the light.  Must be done after a "initranging"
''  -> initRanging - initiate a pulse.
''  -> DataReady - is the distance/light data ready.
''
'' this object provides the PRIVATE functions:
''  -> None
''
'' this object uses the following sub OBJECTS:
''  -> i2cObject
''
'' Revision History:
''  -> V1   - Release
''  -> V1.1 - Updated to allow i2cSCL line driving pass-true to i2cObject
''
'' SRF08 from Devantech Ltd - http://www.robotelectronics.co.uk 
''
'' Default address is %1110_0010


CON
  _SRF_CmdReg    = 0
  _SRF_SwReg     = 0  
  _SRF_InchRange = 80
  _SRF_CM_Range  = 81
  _SRF_Light     = 1
  _SRF_Distance  = 2
  ' approx SRF ranging values
  _SRF_Range1M   = 24     ' 24
  _SRF_Range3M   = 24 * 3 ' 72 
  _SRF_Range6M   = 24 * 6 ' 144
  _SRF_Range11M  = 255    ' maximum range

VAR
  long  SRF08Address
  long  started
  long  SRF_rangingMode
  long  SRF_range
  long  SRF_LastRange
  long  SRF_LastLight
  

OBJ
  i2cObject   : "i2cObject" 

PUB Init(_deviceAddress,_rangingMode, _range,_i2cSDA,_i2cSCL,_driveSCLLine): okay
  ' update object parameters
  SRF08Address := _deviceAddress
  SRF_rangingMode := _rangingMode
  SRF_range := _range
  i2cObject.init(_i2cSDA,_i2cSCL,_driveSCLLine)

  ' start
  okay := start
    
  return okay  

PUB start : okay
  ' check if device is present before allowing initialization
  if started == false
    if i2cObject.devicePresent(SRF08Address) == true
      ' setup SRF08
      i2cObject.writeLocation(SRF08Address, _SRF_CmdReg, SRF_RangingMode, 8,8)
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
  
PUB getSwVersion : version
  ' read the SRF's version register
  if started == true
    version := i2cObject.readLocation(SRF08Address, _SRF_SwReg,8,8)
    return version

PUB setSRFRangingMode(_rangingMode)
  ' update object parameters
  if started == true
    SRF_rangingMode := _rangingMode
    ' setup SRF08
    i2cObject.writeLocation(SRF08Address, _SRF_CmdReg, SRF_RangingMode, 8,8)  

PUB getRangingMode : result
  ' return the current ranging mode
  return (SRF_rangingMode)

PUB getSRFRange : result
  ' return the current range distance
  return (SRF_range)

PUB getRange : result
  ' return the last range
  if started == true
    i2cObject.i2cStart
    i2cObject.i2cWrite(SRF08Address | 0,8)
    i2cObject.i2cWrite(2,8)
    i2cObject.i2cStart
    i2cObject.i2cWrite(SRF08Address | 1,8)
    SRF_LastRange := 0
    SRF_LastRange := i2cObject.i2cRead(i2cObject#_i2cACK)
    SRF_LastRange <<= 8
    SRF_LastRange := SRF_LastRange + i2cObject.i2cRead(i2cObject#_i2cNAK)
    i2cObject.i2cStop
      
    return (SRF_LastRange)

PUB getLight : result
  ' return the last light reading
  if started == true
    SRF_LastLight := i2cObject.readLocation(SRF08Address, _SRF_Light, 8, 8) 
    return (SRF_LastLight) 
  
PUB initRanging : result | ackbit
  ' tell the SRF08 to start ranging
  if started == true
    ' init ranging
    i2cObject.i2cStart
    i2cObject.i2cwrite(SRF08Address,8)
    i2cObject.i2cwrite(_SRF_CmdReg,8)
    i2cObject.i2cwrite(_SRF_CM_Range,8)
    i2cObject.i2cStop
     
    ' data will be available in 65ms
    return result  

PUB dataReady : result | dev_ready
  ' if the SRF08 is busy it will not drive the SDA
  ' line - so you get a 255 back.
  ' when it goes to < 255 then the result is ready
  if started == true
    if getSwVersion == 255
      dev_ready := false
    else
      dev_ready := true
    return dev_ready        
   