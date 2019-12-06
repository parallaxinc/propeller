{
**************************
* Format object test     *
* Coded by Peter Verkaik *
**************************
}

CON
  'clock settings for spin stamp
  _CLKMODE = XTAL1
  _XINFREQ = 10_000_000
  
  debugPort = 2 '0=none, 1=propeller TX/RX, 2=spin stamp SOUT/SIN
  
  '//Spin stamp pin assignments
  stampSOUT = 16 'serial out (pin 1 of spin stamp)
  stampSIN  = 17 'serial in  (pin 2 of spin stamp)
  stampATN  = 18 'digital in (pin 3 of spin stamp, when activated, do reboot)

  '//Propeller system pin assignments
  propSCL = 28 'external eeprom SCL
  propSDA = 29 'external eeprom SDA
  propTX  = 30 'programming output
  propRX  = 31 'programming input

DAT
  instr BYTE "hex representation 0x13Ab is 5035 decimal",0

OBJ
  '//debug port
  debug: "SerialMirror"
  '//Format object
  fmt: "Format"
  
VAR
  LONG value      'will hold scanned value from input string instr
  '//buffer
  BYTE buffer[64] 'buffer to assemble output strings
  LONG atnStack[10]  'stack for monitoring ATN pin
  
PUB main | i
  'start debug
  case debugPort
    1: debug.start(propRX,propTX,0,9600)
    2: debug.start(stampSIN,stampSOUT,0,9600) 'mode 0 when 1k resistor from SIN to GND
  'monitor ATN pin (optional)
'  COGNEW(atnReset,atnStack)
  repeat
'    fmt.sprintf(@buffer,string("%s"),@instr)
'    debug.str(@buffer)
'    debug.tx(32)
'    fmt.sscanf(@instr,string("hex representation 0x%x is 5035 decimal"),@value)
'    fmt.sprintf(@buffer,string("scanned value is %d%% decimal\a\\\t\r\n"),value)
'    debug.str(@buffer)
'    debug.tx(32)
'    fmt.sprintf(@buffer,string("%c"),"Z")
    fmt.sprintf(@buffer,string("%s"),string("ABCD"))
'    fmt.sprintf(@buffer,string("%d"),16)
'    fmt.sprintf(@buffer,string("%i"),16)
'    fmt.sprintf(@buffer,string("%08.8b"),16)
'    fmt.sprintf(@buffer,string("%o"),16)
'    fmt.sprintf(@buffer,string("%u"),16)
'    fmt.sprintf(@buffer,string("%04.4x"),16)
    debug.str(@buffer)
'    debug.tx(32)
    waitcnt(clkfreq / 1000 * 100 + cnt)

PUB atnReset
  repeat  'loop endlessly
    if INA[stampATN] == 1
      reboot
      