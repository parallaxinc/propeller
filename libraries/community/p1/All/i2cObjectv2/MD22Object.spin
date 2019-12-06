'' ******************************************************************************
'' * MD22 Object                                                                *
'' * James Burrows Oct 07                                                       *
'' * Version 2.0                                                                *
'' ******************************************************************************
''
'' Demo's the MD22 i2c Motor Controller
''
'' this object provides the PUBLIC functions:
''  -> getSoftwareRev - read the device revision
''  -> SetMode - set the command mode.  - see the constants below
''  -> readMode - read the command mode
''  -> SetSpeed - set the motors to drive
''
'' this object provides the PRIVATE functions:
''  -> None
''
'' this object uses the following sub OBJECTS:
''  -> i2cObject
''
'' Revision History:
''  -> V2 - re-Release
''
'' MD22 from Devantech Ltd - http://www.robotelectronics.co.uk
''
'' Default i2c address %1011_0000

CON
  ' MD22 registers
  _MD22_Mode     = 0
  _MD22_LSpeed   = 1
  _MD22_RSpeed   = 2
  _MD22_Accel    = 3
  _MD22_SwRev    = 7
  ' MD22 Mode Constants
  _MD22_Mode0    = 0 ' Default.  Motor Speed is Reverse (0) to stop (128) forward (255)
  _MD22_Mode1    = 1 ' Motor Speed is Reverse (-128) to stop (0) forward (127)
  _MD22_Mode2    = 2 ' speed control both motors speed. Speed2 then becomes the turn value (type 1). 
  _MD22_Mode3    = 3 ' 3 is similar to Mode 2, except that the speed registers are interpreted as signed values. 
  _MD22_Mode4    = 4 ' (New from version 9) Alternate method of turning (type 2), the turn value being able to introduce power to the system.
  _MD22_Mode5    = 5 ' (New from version 9) Alternate method of turning (type 2), the turn value being able to introduce power to the system. 


OBJ
  i2cObject     : "basic_i2c_driver"
  
    
PUB getSoftwareRev(i2cSCL,_deviceAddress) : revision
  ' return the Software Revision
  revision := i2cObject.readLocation(i2cSCL,_deviceAddress,_MD22_SwRev)
  return revision

PUB SetMode(i2cSCL,_deviceAddress,md22Mode)
  ' set the MD22 Mode Register
  i2cObject.Start(i2cSCL)
  i2cObject.Write(i2cSCL,_deviceAddress | 0)
  i2cObject.Write(i2cSCL,_MD22_Mode)
  i2cObject.Write(i2cSCL,md22Mode)
  i2cObject.Stop(i2cSCL)

PUB readMode(i2cSCL,_deviceAddress) : modeReg
  ' read the MD22 Mode Reg
  i2cObject.Start(i2cSCL)
  i2cObject.write(i2cSCL,_deviceAddress)
  i2cObject.Write(i2cSCL,7)    
  i2cObject.Start(i2cSCL)
  i2cObject.write(i2cSCL,_deviceAddress)
  modeReg := i2cObject.Read(i2cSCL,i2cObject#NAK)
  i2cObject.Stop(i2cSCL)
  return modeReg

  
PUB SetSpeed(i2cSCL,_deviceAddress,SpeedL, SpeedR) : ackbit
  ' set the MD22 Motor Speed (L & R)
  i2cObject.Start(i2cSCL)
  i2cObject.Write(i2cSCL,_deviceAddress | 0)
  i2cObject.Write(i2cSCL,_MD22_LSpeed)
  i2cObject.Write(i2cSCL,SpeedL)
  i2cObject.Write(i2cSCL,SpeedR)
  i2cObject.Stop(i2cSCL)
  return ackbit

          