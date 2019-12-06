''LM34_SensorDemo.spin
{{ a simple program to display temperature from an LM34 sensor
   by David Hamilton (David@Holeinthenet.Net). Version 1.0, 02/08/2010 - Initial Release
                                               Version 1.1, 02/20/2010 - Added blinking LED to show program is running
   Copyright(c) 2010 by David Hamilton, See end of file for terms of use...
}}

CON
  'crystal and clock constants for a SpinStamp on a BOE
  '_xinfreq = 10_000_000        'Frequency of external crystal (10Mhz)
  '_clkmode = xtal1 + pll8x     'Set clock mode to external * 8 (80Mhz)
  'crystal and clock constants for a Propeller Demo Board
  _xinfreq = 5_000_000          'Frequency of external crystal (5Mhz)
  _clkmode = xtal1 + pll16x     'Set clock mode to external * 16 (80Mhz)

  controlLCD_Pin = 0            'pin used for LCD display
  blinkLED_Pin = 17             'on-board pin to blink to show program running

  adcCS_Pin = 5                 'pins used for ADC chip
  adcCLK_Pin = 7
  adcDO_Pin = 6

  INIT_OK = 0                   'drivers successfull return code value

VAR
  byte curTemp_Bin              'private global object variables
  byte curTemp_Dec
  byte ledState

OBJ
  LCD : "LCD_DisplayDriver"     'Propeller Objects used in program
  ADC : "ADC_Driver"

PUB Main | rcLCD, rcADC                                         ''Main method (entry point)
  'init LCD Display driver, exit program if error
  rcLCD := LCD.Init(controlLCD_Pin, 19200, true, 4)
  if rcLCD <> INIT_OK
    return
  LCD.BacklightOn                                               'turn backlight on
  LCD.CursorOff                                                 'turn cursor off
  LCD.OutStr(string("LM34 Sensor Demo"))                        'output a startup message

  'init ADC driver, print message and exit program if error
  rcADC := ADC.Init(adcCS_Pin, adcCLK_Pin, adcDO_Pin)
  if rcADC <> INIT_OK
    LCD.OutStr(string("ADC chip init err"))
    return
  LCD.OutText(string("cur temp: "))                             'output row label

  dira[blinkLED_Pin] := 1                                       'set pin with led attached to be an output
  ledState := 1                                                 'set 1st state for led (1 = on)

  repeat                                                        'repeat main loop indefinately
    curTemp_Bin := ADC.GetConvertedVal                          'get temperature from ADC (binary)
    curTemp_Dec := BinaryToDecimal(curTemp_Bin)                 'convert temperature to decimal
    LCD.OutNum(curTemp_Dec)                                     'output to display
    LCD.OutText(string("   "))                                  'output a couple trailing spaces in case
                                                                '  temperature value changed number of digits
    LCD.GotoRowCol(1, 10)                                       'move cursor back to end of row label
    outa[blinkLED_Pin] := ledState                              'output state to led pin
    ledState ^= 1                                               'toggle state for next output
    waitcnt(clkfreq/2 + cnt)                                    'wait for 500ms

'Main ends here

PUB BinaryToDecimal(aBinVal) : rVal | multiplier, bitMask
  rVal := 0                     'empty returned val
  multiplier := 1               'start with multiplier of 1
  bitMask := 1                  'start with bitMask of 1 (LSB)
  repeat 8                      'repeat for all 8 bits
    if aBinVal & bitMask > 0    'if bit at position of bitMask is 1
      rVal += multiplier        'add multiplier to aVal
    multiplier *= 2             'double value of multiplier
    bitMask := bitMask << 1     'move bit in bitMask to left
  return rVal

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

