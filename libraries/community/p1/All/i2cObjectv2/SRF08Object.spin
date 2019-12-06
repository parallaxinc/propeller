'' ******************************************************************************
'' * SRF08 Object                                                               *
'' * James Burrows Oct 07                                                       *
'' * Version 2.0                                                                *
'' ******************************************************************************
''
'' this object provides the PUBLIC functions:
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
''  -> V2   - re-Release
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
  long  SRF_rangingMode
  long  SRF_range
  long  SRF_LastRange
  long  SRF_LastLight 

OBJ
  i2cObject   : "basic_i2c_driver" 


PUB getSwVersion(i2cSCL,_deviceAddress) : version
  ' read the SRF's version register
  version := i2cObject.readLocation(i2cSCL,_deviceAddress, _SRF_SwReg)
  return version

PUB setSRFRangingMode(i2cSCL,_deviceAddress,_rangingMode)
  ' update object parameters
  SRF_rangingMode := _rangingMode
  ' setup SRF08
  i2cObject.writeLocation(i2cSCL,_deviceAddress, _SRF_CmdReg, SRF_RangingMode)  

PUB getRangingMode : result
  ' return the current ranging mode
  return (SRF_rangingMode)

PUB getSRFRange : result
  ' return the current range distance
  return (SRF_range)

PUB getRange(i2cSCL,_deviceAddress) : result
  ' return the last range
  i2cObject.Start(i2cSCL)
  i2cObject.Write(i2cSCL,_deviceAddress | 0)
  i2cObject.Write(i2cSCL,2)
  i2cObject.Start(i2cSCL)
  i2cObject.Write(i2cSCL,_deviceAddress | 1)
  SRF_LastRange := 0
  SRF_LastRange := i2cObject.Read(i2cSCL,i2cObject#ACK)
  SRF_LastRange <<= 8
  SRF_LastRange := SRF_LastRange + i2cObject.Read(i2cSCL,i2cObject#NAK)
  i2cObject.Stop(i2cSCL)
      
  return (SRF_LastRange)

PUB getLight(i2cSCL,_deviceAddress) : result
  ' return the last light reading
  SRF_LastLight := i2cObject.readLocation(i2cSCL,_deviceAddress, _SRF_Light) 
  return (SRF_LastLight) 
   
PUB initRanging(i2cSCL,_deviceAddress) : result | ackbit
  ' initRanging - tell the SRF08 to start ranging
  i2cObject.Start(i2cSCL)
  i2cObject.Write(i2cSCL,_deviceAddress)
  i2cObject.Write(i2cSCL,_SRF_CmdReg)
  i2cObject.Write(i2cSCL,_SRF_CM_Range)
  i2cObject.Stop(i2cSCL)
     
  ' data will be available in 65ms
  return result  

PUB dataReady(i2cSCL,_deviceAddress) : result | dev_ready
  ' if the SRF08 is busy it will not drive the SDA
  ' line - so you get a 255 back.
  ' when it goes to < 255 then the result is ready
  if getSwVersion(i2cSCL,_deviceAddress) == 255
    dev_ready := false
  else
    dev_ready := true
  return dev_ready        
   