'' ******************************************************************************
'' * DS1621 Object                                                              *
'' * James Burrows Oct 07                                                       *
'' * Version 2.0                                                                *
'' ******************************************************************************
''
'' This object provides and example of use of the DS1621 i2c temperature sensor
'' See - for reference:   http://www.maxim-ic.com/quick_view2.cfm/qv_pk/2737   
''
'' Based on the Propeller DS1620 object by Jon Williams @ Parallax
''
'' this object provides the PUBLIC functions:
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
''  -> V2 - re-Release
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
  
OBJ
  i2cObject     : "basic_i2c_driver" 

pub writeConfig(i2cSCL, _deviceAddress, configByte)
  ' setup DS1621
  i2cObject.writeLocation(i2cSCL,_deviceAddress, _AccessConfig, configByte)

  
pub startConversion(i2cSCL,_deviceAddress) : AckBit
  ' init temp conversion
  i2cObject.start(i2cSCL)
  ackbit := i2cObject.Write(i2cSCL, _deviceAddress | 0)
  i2cObject.Write(i2cSCL, _StartConvert)
  i2cObject.Stop(i2cSCL)

  
pub readTempC(i2cSCL,_deviceAddress) : tempC
    ' read temp C (int only.  Not implemented decimal places! i.e. 20 not 20.5)
  tempC := i2cObject.readLocation(i2cSCL, _deviceAddress, _ReadTemp)
  return tempC

    
pub readConfig(i2cSCL,_deviceAddress) : configReg
' read Config register
  configReg := i2cObject.readLocation(i2cSCL, _deviceAddress, _AccessConfig)
  return configReg   


pub readTempF(i2cSCL,_deviceAddress) : tempF
  ' read temp C
  tempF := readTempC(i2cSCL,_deviceAddress)
  ' Change it to TempF    
  tempF := tempF * 9 / 5 + 320
  ' return it
  return tempF
    
  