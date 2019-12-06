''LCD_DisplayDriver.spin
{{ Simple LCD Display Driver for Parallax LCD Displays: #27976, #27977, #27979
   by David Hamilton (David@Holeinthenet.Net). Version 1.0, 12/01/2009 - Initial Release
                                               Version 1.1, 01/22/2010 - Added OutHex and OutBin methods
   Copyright(c) 2009, 2010 by David Hamilton, See end of file for terms of use...
}}

CON
  INIT_OK = 0                   'object status values
  INIT_ALREADY_RUN = 1
  INIT_NOT_RUN = 2
  INVALID_CONTROL_PIN = 3
  INVALID_BAUD_RATE = 4
  INVALID_BACKLIGHT = 5
  INVALID_DISPLAY_LINES = 6
  NO_BACKLIGHT = 7
  INVALID_ROW = 8
  INVALID_COL = 9

  BACKLIGHT_ON = $11            'device control codes from .pdf
  BACKLIGHT_OFF = $12
  CURSOR_ON = $18
  CURSOR_OFF = $16
  CARRIAGE_RETURN = $0D
  FORM_FEED = $0C
  ASCII_ZERO = $30
  ASCII_a = $61
  GOTO_ROW_COL = $80
  
VAR
  byte initWasRun               'private global object variables
  byte cPin
  long baud
  byte blCapable
  byte numLines
  byte blIsLit
  byte crsrIsOn

{{ Init method (call only once) required values:
  ControlPin - Propeller I/O Pin attached to the device (0 to 27)
  BaudRate - Desired BaudRate for communicating to device (2400, 9600, 19200)
             **Value must match DIP switch settings on back of device
  HasBacklight - If device has Backlight capability (true, false)
  NumberDisplayLines - Number of lines for displaying characters (2, 4)
}}
PUB Init(ControlPin,BaudRate,HasBacklight,NumberDisplayLines)
  if initWasRun
    return INIT_ALREADY_RUN

  'do sanity check of init values
  if NOT lookdown(ControlPin : 0..27)
    return INVALID_CONTROL_PIN
  if NOT lookdown(BaudRate : 2400, 9600, 19200)
    return INVALID_BAUD_RATE
  if NOT lookdown(HasBacklight : false, true)
    return INVALID_BACKLIGHT
  if NOT lookdown(NumberDisplayLines : 2, 4)
    return INVALID_DISPLAY_LINES

  cPin := ControlPin            'save init values    
  baud := BaudRate
  blCapable := HasBacklight                                 
  numLines := NumberDisplayLines
  blIsLit := false              'set initial backlight status (off)
  crsrIsOn := true              'set initial cursor status (on)

  dira[cPin] := 1               'set cPin to output
  outa[cPin] := 1               'set cPin - idles high
  waitcnt(clkfreq/10 + cnt)     'wait for 100ms

  initWasRun := true
  return INIT_OK

PUB OutChar(aChar)
{{ Transmit code in aChar; blocks caller until transmitted. }}
  if NOT initWasRun
    return INIT_NOT_RUN
  txChar(aChar)                 'transmit char to device
  
PUB OutText(aString) | len
{{ Transmit z-string at aString; blocks caller until string transmitted. }}
  if NOT initWasRun
    return INIT_NOT_RUN
  len := strsize(aString)       'get length of string
  repeat len                    'for each character in string
    txChar(byte[aString++])     'transmit the character and advance pointer to next character

PUB OutStr(aString) | len
{{ Transmit z-string at aString, then transmit a CR; blocks caller until CR is transmitted. }}
  if NOT initWasRun
    return INIT_NOT_RUN
  len := strsize(aString)       'get length of string
  repeat len                    'for each character in string
    txChar(byte[aString++])     'transmit the character and advance pointer to next character
  txChar(CARRIAGE_RETURN)       'transmit extra carriage return after string is transmitted

PUB OutBin(aNum)
{{ Transmit value in aNum after converting to an ASCII bin string, blocks caller until transmitted. }}
  valToStr(aNum, 2)

PUB OutHex(aNum)
{{ Transmit value in aNum after converting to an ASCII hex string, blocks caller until transmitted. }}
  valToStr(aNum, 16)

PUB OutNum(aNum)
{{ Transmit value in aNum after converting to an ASCII numeric string, blocks caller until transmitted. }}
  valToStr(aNum, 10)

PRI valToStr(aNum, base) | n, temp
{{ Convert aNum to string values using base, transmit each when done, blocks caller until all transmitted. }}
  if NOT initWasRun
    return INIT_NOT_RUN

  temp := 1                                     'start temp base at 1
  repeat until temp * base > aNum               'repeast until temp base is just less than aNum
    temp *= base                                'adjust temp base to next power of base

  repeat
    n := aNum / temp                            'divide aNum by temp base to get first whole digit
    if n < 10                                   'check value of n, 0 - 9 is Numeric or Binary, 10 or > is Hex
      txChar(n + ASCII_ZERO)                    'n is 0 - 9 so add it to '0' to make it ASCII and transmit it
    else
      txChar(n + ASCII_a - 10)                  'n is 10 - 15 so add it to 'a' to make it ASCII and transmit it
    if temp == 1                                'if temp base is back to 1, all digits processed
      return
    aNum := aNum // temp                        'aNum becomes whole remainder of division above (rest of digits)
    temp /= base                                'adjust temp base to previous power of base

PUB ClearDisplay            
  if NOT initWasRun
    return INIT_NOT_RUN
  txChar(FORM_FEED)             'transmit char code for form feed (effectively clears the display)
  waitcnt(clkfreq/200 + cnt)    'wait for 5ms

PUB GotoRowCol(row, col) | pos
  if NOT initWasRun
    return INIT_NOT_RUN
  'do sanity check of passed in values based on given display capability
  if row => numLines
    return INVALID_ROW
  if (col => 16 AND numLines == 2) OR col => 20
    return INVALID_COL
  pos := (row * 20) + col + GOTO_ROW_COL        'calculate desired position on display from row and col
  txChar(pos)                                   'transmit new position to device
    
PUB BacklightOn
  if NOT initWasRun
    return INIT_NOT_RUN
  if NOT blCapable              'make sure device has backlight
    return NO_BACKLIGHT
  if NOT blIsLit                'make sure backlight is not already on
    blIsLit := true             'mark internal backlight status
    txChar(BACKLIGHT_ON)        'transmit char code for backlight on to device
      
PUB BacklightOff  
  if NOT initWasRun
    return INIT_NOT_RUN
  if NOT blCapable              'make sure device has backlight
    return NO_BACKLIGHT
  if blIsLit                    'make sure backlight is not already off
    blIsLit := false            'mark internal backlight status
    txChar(BACKLIGHT_OFF)       'transmit char code for backlight off to device
  
PUB CursorOff
  if NOT initWasRun
    return INIT_NOT_RUN
  if crsrIsOn                   'make sure cursor is not already off
    crsrIsOn := false           'mark internal cursor status
    txChar(CURSOR_OFF)          'transmit char code for cursor off
  
PUB CursorOn
  if NOT initWasRun
    return INIT_NOT_RUN
  if NOT crsrIsOn               'make sure cursor is not already on
    crsrIsOn := true            'mark internal cursor status
    txChar(CURSOR_ON)           'transmit char code for cursor on

PRI txChar(char) | bitTime, t
{{ Transmit a char code; blocks caller until byte transmitted. }}
  bitTime := clkfreq / baud                             'calculate serial bit time  
  char := (char | $100) << 2                            'add start amd stop bits
  t := cnt                                              'sync clock count into t
  repeat 10                                             'output all bits (start + eight data bits + stop = 10)
    waitcnt(t += bitTime)                               'wait time for 1 bit to be output
    outa[cPin] := (char >>= 1) & 1                      'output bit and move pointer to next bit to be output

{{                                    MIT/X11 License - Terms of Use
                                     --------------------------------
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the "Software"), to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions
of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
}}

