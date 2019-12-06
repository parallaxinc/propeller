{{
      TCS34717 Color Light-to-Digital Converter Test v1.0
      Author: Randy Kesler
      04-08-2013
}}

{ Tested on the Propeller Professional Development Board }
con
  _clkmode = xtal1+pll16x
  _clkfreq = 80_000_000

  SCL = 0
  SDA = 1
  INT = 2

obj                          
  tcs : "TCS3471"
  pst : "Parallax Serial Terminal"

pub main | data
  pst.Start(115200)
  data:=tcs.Start(SCL)                       ' starts i2c communication with TCS3471
                                                      
  pst.str(string(13, "TCS3471 ID = $"))
  pst.hex(tcs.get_DATA(SCL,tcs#TCS_ID),2)    ' read and print ID value

  read_color

pri read_color | data
  data:=tcs.set_AIEN(SCL,1)                  ' write AIEN (RGBC interrupt enable bit)
  data:=tcs.set_WEN(SCL,1)                   ' wait enable
  data:=tcs.set_AEN(SCL,1)                   ' write AEN (RGBC enable bit)
  data:=tcs.set_PON(SCL,1)                   ' power on
                                             ' set threshold and interrupt persistence if desired
  repeat
    waitpne(1,INT,0)                         ' wait for interrupt (pin 2 low)
    
    if tcs.get_AVALID(SCL)                   ' determine if RGBC is valid
      pst.str(string(13,13, "CDATA  = $"))   ' print values
      pst.hex(tcs.get_DATA(SCL,tcs#TCS_CDATA),2)
      pst.str(string(13, "CDATAH = $"))
      pst.hex(tcs.get_DATA(SCL,tcs#TCS_CDATAH),2) 
      pst.str(string(13, "RDATA  = $"))
      pst.hex(tcs.get_DATA(SCL,tcs#TCS_RDATA),2)
      pst.str(string(13, "RDATAH = $"))
      pst.hex(tcs.get_DATA(SCL,tcs#TCS_RDATAH),2)
      pst.str(string(13, "GDATA  = $"))
      pst.hex(tcs.get_DATA(SCL,tcs#TCS_GDATA),2)
      pst.str(string(13, "GDATAH = $"))
      pst.hex(tcs.get_DATA(SCL,tcs#TCS_GDATAH),2)
      pst.str(string(13, "BDATA  = $"))
      pst.hex(tcs.get_DATA(SCL,tcs#TCS_BDATA),2)
      pst.str(string(13, "BDATAH = $"))
      pst.hex(tcs.get_DATA(SCL,tcs#TCS_BDATAH),2)
      tcs.clear_RGBC_interrupt(SCL)
  '
    waitcnt(80_000_000+cnt)

{{                                                                                                                          
                                                    TERMS OF USE: MIT License                                                  
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation     
 files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    
 modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
 is furnished to do so, subject to the following conditions:                                                                   
                                                                                                                               
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
                                                                                                                               
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          
 WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         
 COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   
 ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
                        
}}
  