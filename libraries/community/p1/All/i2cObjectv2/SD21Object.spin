'' ******************************************************************************
'' * SD21 Object                                                                *
'' * James Burrows Jan 08                                                       *
'' * Version 1.0                                                                *
'' ******************************************************************************
''
'' Demo's the SD21 i2c Servo Controller
''
'' www.robotelectronics.co.uk  -   http://www.robot-electronics.co.uk/htm/sd21tech.htm
''
'' this object provides the PUBLIC functions:
''  -> getSoftwareRev - read the device revision
''  -> 
''
'' this object provides the PRIVATE functions:
''  -> None
''
'' this object uses the following sub OBJECTS:
''  -> basic_i2c_driver
''
'' Revision History:
''  -> V1 - Release
''
'' Modules default i2c address is %1100_0010

CON
  ' SD21 registers
  _SD21_SwRev    = 64
  _SD21_Voltage  = 65
  
  
OBJ
  i2cObject     : "basic_i2c_driver"


PUB getSoftwareRev(i2cSCL, _deviceAddress) : revision
    ' return the Software Revision
    revision := i2cObject.ReadLocation(i2cSCL,_deviceAddress,_SD21_SwRev)    
    return revision


PUB getModuleVoltage(i2cSCL, _deviceAddress) : Voltage
    ' return the Module Voltage
    voltage := i2cObject.ReadLocation(i2cSCL,_deviceAddress,_SD21_Voltage)
    return voltage    


PUB CommandServo(i2cSCL, _deviceAddress, servoNumber, servoSpeed, servoPosition)
    ' command the module to control a servo...
    i2cObject.Start(i2cSCL)
    i2cObject.Write(i2cSCL,_deviceAddress | 0)
    i2cObject.Write(i2cSCL,(servoNumber-1) * 3)
    i2cObject.Write(i2cSCL,servoSpeed)
    i2cObject.Write(i2cSCL,servoPosition & 255)     ' send the low byte first
    i2cObject.Write(i2cSCL,servoPosition >> 8)      ' send the high byte second             
    i2cObject.Stop(i2cSCL)
    
    