'********************************
'*    ADC 0838 Channel Debug    * 
'********************************

'code compiled and revised by Bryan Kobe June, 2007
'This code is used for addressing and accessing all 8 channels on the ADC 0838
'It will address and debug all 8 channels, returning the value 0-255.

CON

' data for Din to start conversion for each ADx channel

  AD0 = %11000          
  AD1 = %11100          ' Note: See Datasheet MUX Addressing for more details
  AD2 = %11001          ' Bit 4 = Start Bit, Bit 3 = SGL/DIF, Bit 2 = ODD/SIGN, Bit 1 = SELECT 1, Bit 0 = SELECT 0
  AD3 = %11101
  AD4 = %11010
  AD5 = %11110
  AD6 = %11011
  AD7 = %11111

' pin configuration

  clk     = 12
  cs      = 13
  dataout = 14
  datain  = 15

OBJ

  bs2   : "BS2_Functions"
  debug : "PC_Debug"
  num   : "Numbers"
  
VAR

  byte ADC             ' Analog to Digital Channel Din Value.  Set using CON values.
  long datar           ' 8 Bit return value from conversion
  'long clockstack[5]

PUB main

  dira[cs]~~         'set Chip Select to output 
  outa[cs] := 1      'set Chip Select High
  dira[clk]~~        'set clk pin to output
  outa[clk]:=0       'set clock pin low
  dira[datain]~       'set data in pin to an input
  dira[dataout]~~      'set data out pin to an output

debug.start(9600)
debug.str(string("ADC0838 Channel Debug"))

repeat
  debug.newline
  debug.str(string("Ch.0 = "))
  debug.str(num.ToStr(GetADC(0), Num#dec))
  debug.str(string(" "))
  debug.str(string("Ch.1 = "))
  debug.str(num.ToStr(GetADC(1), Num#dec))
  debug.str(string(" "))
  debug.str(string("Ch.2 = "))
  debug.str(num.ToStr(GetADC(2), Num#dec))
  debug.str(string(" "))
  debug.str(string("Ch.3 = "))
  debug.str(num.ToStr(GetADC(3), Num#dec))
  debug.str(string(" "))
  debug.str(string("Ch.4 = "))
  debug.str(num.ToStr(GetADC(4), Num#dec))
  debug.str(string(" "))
  debug.str(string("Ch.5 = "))
  debug.str(num.ToStr(GetADC(5), Num#dec))
  debug.str(string(" "))
  debug.str(string("Ch.6 = "))
  debug.str(num.ToStr(GetADC(6), Num#dec))
  debug.str(string(" "))
  debug.str(string("Ch.7 = "))
  debug.str(num.ToStr(GetADC(7), Num#dec))
  debug.str(string(" "))      
  
  waitcnt(5_000_000 + cnt)



PRI GetADC( chan ) : value

  if (chan == 0)
    ADC := AD0
  if (chan == 1)
    ADC := AD1
  if (chan == 2)
    ADC := AD2
  if (chan == 3)
    ADC := AD3
  if (chan == 4)
    ADC := AD4
  if (chan == 5)
    ADC := AD5
  if (chan == 6)
    ADC := AD6
  if (chan == 7)
    ADC := AD7
  
  datar := write(ADC)    'write MUX Address to start conversion for ADC channel and set result to the datar value
  return datar

PRI write( ADCaddr ) : ADC_value  

  outa[cs] := 0                                         'set Chip Select LOW, activating the ADC chip
  bs2.SHIFTOUT(dataout, clk, ADCaddr, BS2#MSBFIRST, 5)  'shift out the addressing byte to the ADC via DI pin on ADC 
  ADC_value := bs2.SHIFTIN(datain, clk, BS2#MSBPOST, 8) 'shift in the byte from the ADC via the DO pin on the ADC
                                                        'the first byte is a start bit, to initiate reading sequence
  outa[cs]:=1                                           'set Chip Select HIGH, de-activating the ADC chip
  return ADC_value                                      'return value of the ADC