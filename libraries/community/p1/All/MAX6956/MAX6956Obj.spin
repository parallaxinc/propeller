'' ******************************************************************************
'' * MAX6956 Object                                                             *
'' * Robert Jan Wiepkes 2006                                                   *
'' * Version 1.0                                                                *
'' ******************************************************************************
''
'' This object provides and example of use of the MAX6956 i2c LED driver/GPIO port
'' See - for reference:   http://www.maxim-ic.com/   
''
'' this object provides the PUBLIC functions:
''  -> Init  - sets up the address and inits sub-objects such
''  -> SetAddress  - sets up the address and inits sub-objects such
''  -> geti2cError - returns the error passthru from the i2c sub object
''  -> writeConfig - write to the config bytes
''  -> writePortMode - write mode of port (LED driver, Output, Input, Input with pull up)
''  -> DisplayTest - Activate display test, override registers, but not overwrite values
''  -> writePortCurrent - write indivual port current (only when set in config register)
''  -> setPortOn - set one port on
''  -> setPortOff - set one port off
''  -> readPort - read one ports
''  -> setPorts - set a group of ports on or off
''  -> readPorts - read a group of ports
''  -> readRegister - read one register
''  -> readAllRegister - read all registers (single port registers and duplicates excluded)
'' 
'' this object provides the PRIVATE functions:
''  -> None
''
'' this object uses the following sub OBJECTS:
''  -> i2cObject
''
'' Revision History:
''  -> V1 - Release
''
'' Address calculation
''   pin AD1 to     GND GND GND GND V+  V+  V+  V+  SDA SDA SDA SDA SCL SCL SCL SCL  
''   pin AD0 to     GND V+  SDA SCL GND V+  SDA SCL GND V+  SDA SCL GND V+  SDA SCL 
''   address gives  $80 $82 $84 $86 $88 $8A $8C $8E $90 $92 $94 $96 $98 $9A $9C $9E

CON
  'Subadressen
  _GlobalCurrent = $02
  _Configuration = $04
  _DetectMask   = $06
  _Display_Test  = $07
  _PortConfig    = $09
  _PortCurrent   = $12
  _Port0         = $20
  _Ports4_11     = $44
  _Ports12_19    = $4C
  _Ports20_27    = $54
  _Ports28_31    = $5C
  'Waarden
  _LEDdriver     = $00
  _GP_output     = $01
  _GP_input      = $02
  _GP_pull_up    = $03
  _NormalOperation = $01
  _NO = $01
  _IndividualCurrent = $40
  _IC = $40
  _TransitionDetect = $80
  _TD = $80
  _NormalMode    = $00
  _TestMode      = $01

VAR
  long  MAX6956Address
  long  started
  
OBJ
  i2cObject     : "i2cObject" 
  
pub Init( _deviceAddress, _i2cSDA, _i2cSCL, _driveSCLLine): okay
  MAX6956Address := _deviceAddress
  i2cObject.init(_i2cSDA,_i2cSCL,_driveSCLLine)

  ' start
  okay := start

  return okay

PUB start : okay
  ' try a restart - recheck the device
  if started == false
    if i2cObject.devicePresent(MAX6956Address) == true
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
  
pub writeConfig(Current, Config, Mask) : AckBit
  ' setup MAX6956
  if started == true
    i2cObject.writeLocation(Max6956Address, _GlobalCurrent, Current, 8,8)
    i2cObject.writeLocation(Max6956Address, _Configuration, Config, 8,8)
    i2cObject.writeLocation(Max6956Address, _DetectMask, Mask, 8,8)
    return AckBit

  
pub writePortMode(port, mode) : AckBit | subadres, data
  ' set port mode
  if started == true
    subadres := (port>>2)+ _PortConfig - 1
    data :=  i2cObject.readLocation(Max6956Address, subadres, 8, 8)
    case (port & $03)
      0: data := (data & $FC ) + mode  'LED current driver
      1: data := (data & $F3 ) + (mode << 2)  'GP output
      2: data := (data & $CF ) + (mode << 4)  'GP input
      3: data := (data & $3F ) + (mode << 6)  'GP input with pull-up
  
    i2cObject.writeLocation(Max6956Address, subadres, data, 8,8)
    return AckBit

  
pub setAllPorts2LED : AckBit | tel
  ' set port mode
  if started == true
    i2cObject.writeLocation(Max6956Address, $44, 0, 8,8)
    i2cObject.writeLocation(Max6956Address, $4C, 0, 8,8)
    i2cObject.writeLocation(Max6956Address, $54, 0, 8,8)
    i2cObject.writeLocation(Max6956Address, $5C, 0, 8,8)
    i2cObject.i2cstart
    ackbit := i2cObject.i2cWrite(Max6956Address,8)
    ackbit := i2cObject.i2cWrite($09,8)
    repeat 7
      i2cObject.i2cWrite($00,8)
    i2cObject.i2cStop
    i2cObject.i2cstart
    ackbit := i2cObject.i2cWrite(Max6956Address,8)
    ackbit := i2cObject.i2cWrite($12,8)
    repeat tel from 1 to 14
      i2cObject.i2cWrite($FF,8)
    i2cObject.i2cStop
    return AckBit

  
pub DisplayTest( mode ) : ackBit
    ' _TestMode of _NormalMode
    if started == true
      i2cObject.writeLocation(Max6956Address, _display_Test, mode, 8,8)
      return _display_Test

    
pub writePortCurrent( port, current) : AckBit | subadres, data 
  ' read Config register
  if started == true
    subadres :=  (port>>1) + _portCurrent - 2 
    data := i2cObject.readLocation(Max6956Address, subadres, 8,8)
    if (port & 1) == 1
      data := (data & $0F ) + ( current << 4 )
    else
      data := (data & $F0 ) + current
    i2cObject.writeLocation(Max6956Address, subadres, data, 8,8)
    return ackBit   

pub portOn( port ) : ackBit | subadres
  if started == true
    i2cObject.writeLocation(Max6956Address, port + $20, 1, 8,8)
    
pub portOff( port ) : ackBit | subadres
  if started == true
    i2cObject.writeLocation(Max6956Address, port + $20, 1, 8,8)
    
pub portWalk( port ) : ackBit
  if started == true
    i2cObject.writeLocation(Max6956Address, $44, 0, 8,8)
    i2cObject.writeLocation(Max6956Address, $4C, 0, 8,8)
    i2cObject.writeLocation(Max6956Address, $54, 0, 8,8)
    i2cObject.writeLocation(Max6956Address, $5C, 0, 8,8)
    i2cObject.writeLocation(Max6956Address, port + $20, 1, 8,8)
    
pub multiPort( firstport, count, data )
  if started == true
    i2cObject.i2cstart
    i2cObject.i2cWrite(Max6956Address,8)
    i2cObject.i2cWrite(firstport + $20,8)
    repeat count
      i2cObject.i2cWrite( data & %1,8)
      data >>= 1
    i2cObject.i2cStop
    