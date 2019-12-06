'' ******************************************************************************
'' * MD23 Object                                                                *
'' * James Burrows Jan 2008                                                     *
'' * Version 1.0                                                                *
'' ******************************************************************************
''
'' Demo's the MD23 i2c Motor Controller
''
'' www.robotelectronics.co.uk  -   http://www.robot-electronics.co.uk/htm/md23tech.htm
''
'' this object provides the PUBLIC functions:
''  -> getSoftwareRev - read the device revision
''  -> readVoltage - read the module voltage (given in volts*10 - i.e. 11.1 = 111)
''  -> readCurrent1 & readCurrent2
''  -> readEncoder1 & readEncoder2
''  -> SetMode - set the command mode.  - see the constants below
''  -> readMode - read the command mode
''  -> SetSpeed - set the motors to drive
''
'' this object provides the PRIVATE functions:
''  -> readCurrent
''  -> readEncoder
''
'' this object uses the following sub OBJECTS:
''  -> basic_i2c_driver
''
'' Revision History:
''  -> V1 - Release
''
'' Modules default i2c address is %1011_0000

CON
  ' MD23 registers
  _MD23_LSpeed   = 0
  _MD23_RSpeed   = 1
  _MD23_enc1     = 2
  _MD23_enc2     = 6
  _MD23_VoltsReg = 10
  _MD23_Curr1Reg = 11
  _MD23_Curr2Reg = 12  
  _MD23_SwRev    = 13
  _MD23_Accel    = 14
  _MD23_Mode     = 15  
    
  ' MD23 Mode Constants
  _MD23_Mode0    = 0 ' Default.  Motor Speed is Reverse (0) to stop (128) forward (255)
  _MD23_Mode1    = 1 ' Motor Speed is Reverse (-128) to stop (0) forward (127)
  _MD23_Mode2    = 2 ' speed control both motors speed. Speed2 then becomes the turn value (type 1). 
  _MD23_Mode3    = 3 ' 3 is similar to Mode 2, except that the speed registers are interpreted as signed values. 
  _MD23_Mode4    = 4 ' (New from version 9) Alternate method of turning (type 2), the turn value being able to introduce power to the system.
  _MD23_Mode5    = 5 ' (New from version 9) Alternate method of turning (type 2), the turn value being able to introduce power to the system. 
  
OBJ
  i2cObject     : "basic_i2c_driver"

PUB getSoftwareRev(i2cSCL, _deviceAddress) : revision
    ' return the Software Revision
    revision := i2cObject.readLocation(i2cSCL,_deviceAddress,_MD23_SwRev)
    return revision

    
PUB readVoltage(i2cSCL, _deviceAddress) : voltage
    ' read the MD23 voltage register
    voltage := i2cObject.readLocation(i2cSCL,_deviceAddress,_MD23_VoltsReg)
    return voltage

PUB readCurrent1(i2cSCL, _deviceAddress) : result
    return readCurrent(i2cSCL, _deviceAddress, _MD23_Curr1Reg)

PUB readCurrent2(i2cSCL, _deviceAddress) : result
    return readCurrent(i2cSCL, _deviceAddress, _MD23_Curr2Reg)    

PRI readCurrent(i2cSCL, _deviceAddress, _CurrentReg) : current
    ' read the MD23 Current Reg
    current := i2cObject.readLocation(i2cSCL, _deviceAddress, _CurrentReg)
    return current    


PUB readEncoder1(i2cSCL, _deviceAddress) : result
    return readEncoder(i2cSCL,_deviceAddress, _MD23_enc1)

PUB readEncoder2(i2cSCL, _deviceAddress) : result
    return readEncoder(i2cSCL,_deviceAddress, _MD23_enc2)        

PRI readEncoder(i2cSCL, _deviceAddress, _EncoderRegAddress) | Encoder
    ' read the MD23 Wheel Encoder 
    i2cObject.Start(i2cSCL)
    i2cObject.Write(i2cSCL,_deviceAddress)
    i2cObject.Write(i2cSCL,_EncoderRegAddress)    
    i2cObject.Start(i2cSCL)
    i2cObject.write(i2cSCL,_deviceAddress | 1)
    Encoder := 0
    Encoder := i2cObject.Read(i2cSCL,i2cObject#ACK) & 255
    Encoder <<= 8
    Encoder += i2cObject.Read(i2cSCL,i2cObject#ACK) & 255
    Encoder <<= 8
    Encoder += i2cObject.Read(i2cSCL,i2cObject#ACK) & 255
    Encoder <<= 8
    Encoder += i2cObject.Read(i2cSCL,i2cObject#NAK) & 255        
    i2cObject.Stop(i2cSCL)
    return Encoder 
          

PUB SetMode(i2cSCL, _deviceAddress,md23Mode)
    ' set the MD23 Mode Register
    i2cObject.Start(i2cSCL)
    i2cObject.Write(i2cSCL,_deviceAddress | 0)
    i2cObject.Write(i2cSCL,_MD23_Mode)
    i2cObject.Write(i2cSCL,md23Mode)
    i2cObject.Stop(i2cSCL)

  
PUB readMode(i2cSCL, _deviceAddress) : modeReg
    ' read the MD23 Mode Reg
    i2cObject.Start(i2cSCL)
    i2cObject.Write(i2cSCL,_deviceAddress)
    i2cObject.Write(i2cSCL,_MD23_Mode)    
    i2cObject.Start(i2cSCL)
    i2cObject.Write(i2cSCL,_deviceAddress | 1)
    modeReg := i2cObject.Read(i2cSCL,i2cObject#NAK)
    i2cObject.Stop(i2cSCL)
    return modeReg 

    
PUB SetSpeed(i2cSCL, _deviceAddress, SpeedL, SpeedR)
    ' set the MD23 Motor Speed (L & R)
    i2cObject.Start(i2cSCL)
    i2cObject.Write(i2cSCL,_deviceAddress | 0)
    i2cObject.Write(i2cSCL,_MD23_LSpeed)
    i2cObject.Write(i2cSCL,SpeedL)
    i2cObject.Write(i2cSCL,SpeedR)
    i2cObject.Stop(i2cSCL)       