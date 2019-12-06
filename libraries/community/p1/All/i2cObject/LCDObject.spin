'' ******************************************************************************
'' * LCD Object                                                                 *
'' * James Burrows May 2006                                                     *
'' * Version 0.5                                                                *
'' ******************************************************************************
''
'' for reference look at: www.milinst.com - Audio Visual section
'' portions adapted from Parallax's SimpleNumbers library
''
'' this object provides the PUBLIC functions:
''  -> Init  - sets up the address and inits sub-objects such
''  -> Start - init the serial and setup
''  -> Stop  - stop the serial and release the IO pin
''  -> putlinec - put a character to the LCD on a specific line
''  -> putlines - put a string to the LCD on a specific line 
''  -> clearLCD - Clear the lcd
''  -> positionLCD - set the cursor position. Valid: lines (1-4), chars (0-19)
''  -> output - output byte
''  -> outputstring - output a string to current cursor loc 
''  -> outputnumber - output a number to the current cursor loc  
''
'' this object provides the PRIVATE functions:
''  -> none
''
'' this object uses the following sub OBJECTS:
''  -> SimpleSerial (tx only!)
''  -> SimpleNumbers
''

CON
  PinHigh       = 1
  PinLow        = 0
  LCDCommand    = $FE
  LCDClear      = $1


VAR
  word  LineLength
  long  div,zpad
  long  running
  word  LCD_Pin, LCD_Baud
  word  negative  

obj
  SimpleNumbers  : "Simple_Numbers"
  serial         : "simple_serial" 

  
PUB  Init(_LCD_Pin, _LCD_Baud, _negative, _lineLength): okay
  LineLength := _lineLength
  LCD_Pin := _LCD_Pin
  LCD_Baud := _LCD_Baud
  negative := _negative
  running := false
  start


PUB  Start
  if running == false
    running := true
    if negative == true
      serial.start(-1, LCD_Pin, -LCD_Baud)
    else
      serial.start(-1, LCD_Pin, -LCD_Baud)

  
PUB  Stop
  if running == true
    serial.stop  
    running := false
     
PUB  Changeline(lineref,str_address)
  clearline(lineref)
  outputstring(str_address)
    
PUB  ClearLCD
  if running == true
    serial.tx(LCDCommand)
    serial.tx(LCDClear)

PUB  ClearLine(lineref)
  if running == true
    positionLCD(lineref,0)
    repeat lineLength
      serial.tx(" ")
    positionLCD(lineref,0)

PUB  output(value)
  if running == true
    serial.tx(value)
  
PUB  PositionLCD (lineref,charRef)
  ' 128 / 192 / 148 / 212
  if running == true  
    serial.tx(LCDCommand)
    case lineref
      1 : serial.tx(128 + charref)
      2 : serial.tx(192 + charref)
      3 : serial.tx(148 + charref)
      4 : serial.tx(212 + charref)
      other : serial.tx(128)

      
PUB  OutputString(str_addr)
  ' output a STRING to the current X,Y
  if running == true
    repeat strsize(str_addr)                            
        serial.tx(byte[str_addr++])     

PUB outputHex(value,digits)
  ' output a HEX number to the current X,Y
  if running == true
    outputstring (simplenumbers.hex(value,digits))        
        
PUB  outputNumber(value)
  ' output a dec number to the current X,Y
  if running == true
    outputstring (simplenumbers.dec(value))

PUB outputBinary(value, digits)
  ' output a binary number to the current X,Y
  if running == true
    outputstring (simplenumbers.bin(value,digits))      