{{ ADC0831_Driver.spin    
   Copyright (c) 2009 Austin Bowen
   *See end of file for terms of use*

   Reads the output of the ADC0831 A/D Converter  
}}                      

VAR
  LONG CS, CLK, DATA

PUB START (_CS, _CLK, _DATA)
{{ Set the pin variables }}
  LONGMOVE(@CS, @_CS, 3)

PUB READ
{{ Reads the ADC0831 and returns the value }}  
  DIRA[CS]~~
  DIRA[CLK]~~
  DIRA[DATA]~

  OUTA[CS]~                        
  OUTA[CLK]~
  REPEAT 9
    !OUTA[CLK]
    !OUTA[CLK]                                
    RESULT := INA[DATA] + (RESULT << 1)
    WAITCNT(400+CNT)
  OUTA[CS]~~
  RESULT := RESULT << 24 >> 24

PUB CONVERT (VALUE, VMIN, VMAX)
{{ Give it the value of your reading, minimum voltage value,
   and maximum voltage value, and it returns the voltage of your reading

   HINT: Since this isn't floating point, you can get a higher voltage resolution
     by multiplying the VMIN and VMAX values by factors of 10, but remember where
     the decimal is supposed to be
}}
  RETURN ((VALUE*(VMAX-VMIN))/255)+VMIN


{{Permission is hereby granted, free of charge, to any person obtaining a copy of this software
  and associated documentation files (the "Software"), to deal in the Software without restriction,
  including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
  and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
  subject to the following conditions: 
   
  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. 
   
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
  PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
  FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}} 