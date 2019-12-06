''ADC_Driver.spin
{{ Simple Driver for ADC0831 Analog to Digital Converter Chip
   by David Hamilton (David@Holeinthenet.Net). Version 1.0, 02/08/2010 - Initial Release
   Copyright(c) 2010 by David Hamilton, See end of file for terms of use...
}}
 
CON
  INIT_OK = 0                   'object status values
  INIT_ALREADY_RUN = 1
  INIT_NOT_RUN = 2
  INVALID_CS_PIN = 3
  INVALID_CLK_PIN = 4
  INVALID_DO_PIN = 5

VAR
  byte initWasRun               'private global object variables
  byte pCS
  byte pCLK
  byte pDO

{{ Init method (call only once) required values:
  CS_Pin - Propeller I/O Pin attached to the Chips CS Pin (0 to 27)
  CLK_Pin - Propeller I/O Pin attached to the Chips CLK Pin (0 to 27)
  DO_Pin - Propeller I/O Pin attached to the Chips DO Pin (0 to 27)
}}
PUB Init(CS_Pin,CLK_Pin,DO_Pin)
  if initWasRun
    return INIT_ALREADY_RUN

  'do sanity check of init values
  if NOT lookdown(CS_Pin : 0..27)
    return INVALID_CS_PIN
  if NOT lookdown(CLK_Pin : 0..27)
    return INVALID_CLK_PIN
  if NOT lookdown(DO_Pin : 0..27)
    return INVALID_DO_PIN

  pCS := CS_Pin                 'save init values
  pCLK := CLK_Pin
  pDO := DO_Pin

  dira[pCS] := 1                'set CS and CLK ports to output
  dira[pCLK] := 1

  outa[pCS] := 1                'chip select port CS idles high

  initWasRun := true
  return INIT_OK

PUB GetConvertedVal : rData
  if NOT initWasRun
    return INIT_NOT_RUN

  outa[pCS] := 0                'set CS low, start communication to chip
  rData := readChip             'read conversion data from the chip
  outa[pCS] := 1                'set CS high, terminate communication to chip
  return rData

PRI readChip : rData
  rData := 0                                    'set return data to empty
  outa[pCLK] := 1                               'do one clock cycle (high - low) chip setup
  outa[pCLK] := 0
  repeat 8                                      'repeat for number of conversion bits (8)
    outa[pCLK] := 1                             'set CLK high
    outa[pCLK] := 0                             'set CLK low so CPU makes a bit ready to be read
    rData := rData << 1                         'rotate data making room for next conversion bit
    rData |= (ina[pDO] & $01)                   'get the bit from the data port, place in return data
  return rData

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

