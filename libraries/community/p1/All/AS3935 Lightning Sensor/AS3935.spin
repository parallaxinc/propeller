{{
      AS3935 Lightning Sensor v1.0
      Author: Randy Kesler
      11-02-2012
}}

con
  base_read  = %01_000000        

var
  long CS,IRQ,SCLK,MISO,MOSI

obj               
  spi : "SPI_Spin"

pub start(base_pin)                         
  CS:=base_pin                         ' assign pins
  IRQ:=base_pin+1
  SCLK:=base_pin+2
  MISO:=base_pin+3
  MOSI:=base_pin+4
  
  outa[CS]~~                           ' preset CS high (active low)
  dira[CS]~~                           ' CS output
  dira[IRQ]~                           ' IRQ input
  outa[SCLK]~                          ' preset SCLK low
  dira[SCLK]~~                         ' SCLK output
  dira[MISO]~                          ' MISO input from AS3935
  outa[MOSI]~                          ' preset MOSI low
  dira[MOSI]~~                         ' MOSI output

  spi.start(40,0)
  waitcnt(clkfreq+cnt)

pub get_AFE_GB                         ' AFE Gain Boost -- register 0 bits 5..1
  return (read(0)&%00111110)>>1

pub get_PWD                            ' Power Down -- register 0 bit 0
  return read(0)&1

pub get_NF_LEV                         ' Noise Floor Level -- register 1 bits 6..4
  return (read(1)&%01110000)>>4

pub get_WDTH                           ' Watchdog Threshold -- register 1 bits 3..0
  return read(1)&%01111

pub get_CL_STAT                        ' Clear Statistics -- register 2 bit 6
  return (read(2)&%01000000)>>6

pub get_MIN_NUM_LIGH                   ' Minimum Number of Lightning -- register 2 bits 5..4
  return (read(2)&%00110000)>>4

pub get_SREJ                           ' Spike Rejection -- register 2 bits 3..0
  return read(2)&%01111

pub get_LCO_FDIV                       ' Frequency Division Ratio for antenna tuning -- register 3 bits 7..6
  return (read(3)&%11000000)>>6

pub get_MASK_DIST                      ' Mask Disturber -- register 3 bit 5
  return (read(3)&%00100000)>>5

pub get_INT                            ' Interrupt -- register 3 bits 3..0
  return read(3)&%01111

pub get_S_LIG_L                        ' Energy of the Single Lightning LSBYTE -- register 4 bits 7..0
  return read(4)

pub get_S_LIG_M                        ' Energy of the Single Lightning MSBYTE -- register 5 bits 7..0
  return read(5)

pub get_S_LIG_MM                       ' Energy of the Single Lightning MMSBYTE -- register 6 bits 4..0
  return read(6)&%011111

pub get_DISTANCE                       ' Distance Estimation -- register 7 bits 5..0
  return read(7)&%00111111

pub get_DISP_LCO                       ' Display LCO on IRQ pin -- register 8 bit 7
  return read(8)>>7

pub get_DISP_SRCO                      ' Display SRCO on IRQ pin -- register 8 bit 6 
  return (read(8)&%01000000)>>6

pub get_DISP_TRCO                      ' Display TRCO on IRQ pin -- register 8 bit 5 
  return (read(8)&%00100000)>>5

pub get_TUN_CAP                        ' Internal Tuning Capacitors (0 to 120pF in steps of 8pF) -- register 8 bits 3..0
  return read(8)&%01111

pub set_AFE_GB(val)                    ' Range: 0-31
  write(0,(read(0)&%11000001)|(val<<1)) 

pub set_PWD(val)                       ' Range: 0-1
  write(0,(read(0)&%11111110)|val)

pub set_NF_LEV(val)                    ' Range: 0-7
  write(1,(read(1)&%10001111)|(val<<4))

pub set_WDTH(val)                      ' Range: 0-15
  write(1,(read(1)&%11110000)|val)

pub set_CL_STAT(val)                   ' Range: 0-1
  write(2,(read(2)&%10111111)|(val<<6))

pub set_MIN_NUM_LIGH(val)              ' Range: 0-3
  write(2,(read(2)&%11001111)|(val<<4))

pub set_SREJ(val)                      ' Range: 0-15
  write(2,(read(2)&%11110000)|val)

pub set_LCO_FDIV(val)                  ' Range: 0-3
  write(3,(read(3)&%00111111)|(val<<6))

pub set_MASK_DIST(val)                 ' Range: 0-1
  write(3,(read(3)&%11011111)|(val<<5))

pub set_DISP_LCO(val)                  ' Range: 0-1
  write(8,(read(8)&%01111111)|(val<<7))

pub set_DISP_SRCO(val)                 ' Range: 0-1
  write(8,(read(8)&%10111111)|(val<<6))

pub set_DISP_TRCO(val)                 ' Range: 0-1
  write(8,(read(8)&%11011111)|(val<<5))

pub set_TUN_CAP(val)                   ' Range: 0-15
  write(8,(read(8)&%11110000)|val)

pub calibrate_rco                      ' automatic calibration of rco
  write(%111101,%10010110)

pub preset_default                     
  write(%111100,%10010110)

pub read(register) | rec_byte          ' read AS3935 address
  outa[CS]~  
  spi.SHIFTOUT(MOSI,SCLK,5,8,base_read+register)
  rec_byte := spi.SHIFTIN(MISO,SCLK,2,8)
  outa[CS]~~
  outa[CS]~                            
  outa[CS]~~
  return rec_byte

pri write(register,write_val)          ' write AS3935 address
  write_val|=(register<<8)
  outa[CS]~
  spi.SHIFTOUT(MOSI,SCLK,5,16,write_val)
  outa[CS]~~

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
  