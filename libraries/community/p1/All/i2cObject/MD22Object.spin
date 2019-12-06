'' ******************************************************************************
'' * MD22 Object                                                                *
'' * James Burrows May 2006                                                     *
'' * Version 1.1                                                                *
'' ******************************************************************************
''
'' Demo's the MD22 i2c Motor Controller
''
'' www.robotelectronics.co.uk
''
'' this object provides the PUBLIC functions:
''  -> Init  - sets up the address and inits sub-objects such
''  -> geti2cError - get the i2c Error from the i2cObject
''  -> start - restart
''  -> stop - stop
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
''  -> V1 - Release
''  -> V1.1 - Updated to allow i2cSCL line driving pass-true to i2cObject
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
  

VAR
  long MD22_Address
  long started

OBJ
  i2cObject     : "i2cObject"

  
PUB Init(_deviceAddress, _deviceMode, _i2cSDA, _i2cSCL,_driveSCLLine): okay
  ' initialize the object
  MD22_Address := _deviceAddress   
  i2cObject.init(_i2cSDA,_i2cSCL,_driveSCLLine)    

  ' start
  okay := start
  
  return okay

PUB geti2cError : errorCode
  return i2cObject.getError

PUB start : okay
  ' start the object
  if started == false
    if i2cObject.devicePresent(MD22_Address)
      ' init the MD22 Mode reg.
      if setMode(MD22_Address) == i2cObject#_i2cACK
        ' return true
        started := true
      else
        started := false
  return started    

PUB stop
  if started == true
    started := false    

PUB isStarted : result
  return started
    
PUB getSoftwareRev : revision
  ' return the Software Revision
  if started == true  
    revision := i2cObject.readLocation(MD22_Address,_MD22_SwRev,8,8)
    return revision

PUB SetMode(md22Mode) : ackbit
  ' set the MD22 Mode Register
  ackbit := 0
  if started == true  
    i2cObject.i2cStart
    ackbit := (ackbit << 1) | i2cObject.i2cWrite(MD22_Address | 0,8)
    ackbit := (ackbit << 1) | i2cObject.i2cWrite(_MD22_Mode,8)
    ackbit := (ackbit << 1) | i2cObject.i2cWrite(md22Mode,8)
    i2cObject.i2cStop
  return ackbit

PUB readMode : modeReg
  ' read the MD22 Mode Reg
  if started == true  
    i2cObject.i2cStart
    i2cObject.i2cwrite(%1011_0000,8)
    i2cObject.i2cWrite(7,8)    
    i2cObject.i2cStart
    i2cObject.i2cwrite(%1011_0001,8)
    modeReg := i2cObject.i2cRead(i2cObject#_i2cNAK)
    i2cObject.i2cStop
    return modeReg

  
PUB SetSpeed(SpeedL, SpeedR) : ackbit
  ' set the MD22 Motor Speed (L & R)
  ackbit := 0
  if started == true
    i2cObject.i2cStart
    ackbit := (ackbit << 1) | i2cObject.i2cWrite(MD22_Address | 0,8)
    ackbit := (ackbit << 1) | i2cObject.i2cWrite(_MD22_LSpeed,8)
    ackbit := (ackbit << 1) | i2cObject.i2cWrite(SpeedL,8)
    ackbit := (ackbit << 1) | i2cObject.i2cWrite(SpeedR,8)
    i2cObject.i2cStop
  return ackbit

          