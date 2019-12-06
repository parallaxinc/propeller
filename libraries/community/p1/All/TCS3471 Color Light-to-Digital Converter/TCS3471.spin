{{
      TCS3471 Color Light-to-Digital Converter v1.0
      Author: Randy Kesler
      03-13-2013
}}

con
  TCS_ADDRESS = $29<<1
  ' Registers -- See datasheet for detailed description.                           
  TCS_COMMAND = $80                       ' write only    bit(7) must be 1, type=bit(6..5), add=bit(4..0)
  TCS_SPECIAL = $60                       '               enables special function field of COMMAND register
  TCS_INT_CLR = $06                       '               Clear RGBC interrupt
  
  TCS_ENABLE  = $00                       ' read / write  bit(7..5) must be 0, bit(4)=AIEN, bit(3)=WEN,2=reserved,1=AEN,0=PON
  TCS_ATIME   = $01                       ' r/w           RGBC acceptable timings are $FF, $F6, $D5, $C0, $00
  TCS_WTIME   = $03                       ' r/w           Wait time acceptable values are $FF, $AB, $00
  TCS_AILTL   = $04                       ' r/w           RGBC clear channel low threshold lower byte
  TCS_AILTH   = $05                       ' r/w           RGBC clear channel low threshold upper byte
  TCS_AIHTL   = $06                       ' r/w           RGBC clear channel high threshold lower byte
  TCS_AIHTH   = $07                       ' r/w           RGBC clear channel high threshold upper byte
  TCS_PERS    = $0C                       ' r/w           bit(7..4)=reserved, bits(3..0)=APERS; acceptable values $00..$0F
  TCS_CONFIG  = $0D                       ' r/w           Wait long time WLONG=bit(1) sets wait time to WTIME*12
  TCS_CONTROL = $0F                       ' r/w           RGBC Gain control, AGAIN=bit(1..0); acceptable 0..3 [1..60x gain]
  
  TCS_ID      = $12                       ' read only     Part number
  TCS_STATUS  = $13                       ' read only     bit(7..5&&3..1)=res.,RGBC clear chan int. AINT=bit(4), AVALID=bit(0)
  TCS_CDATA   = $14                       ' read only     Clear data low byte
  TCS_CDATAH  = $15                       ' read only     Clear data high byte
  TCS_RDATA   = $16                       ' read only     Red low byte
  TCS_RDATAH  = $17                       ' read only     Red high byte
  TCS_GDATA   = $18                       ' read only     Green low byte
  TCS_GDATAH  = $19                       ' read only     Green high byte
  TCS_BDATA   = $1A                       ' read only     Blue low byte
  TCS_BDATAH  = $1B                       ' read only     Blue high byte

  'BYTE_PROTOCOL = %0010_0000

obj               
  i2c : "Basic_I2C_Driver_1"

pub start(SCL) 
  i2c.Initialize(SCL)      

pub get_DATA(SCL,TCS_REGISTER) : DATA                        
  return i2c.ReadByte(SCL,TCS_ADDRESS,TCS_COMMAND|TCS_REGISTER|i2c#OneAddr)

pub set_DATA(SCL,TCS_REGISTER,value) : DATA                        
  if i2c.WriteByte(SCL,TCS_ADDRESS,TCS_COMMAND|TCS_REGISTER|i2c#OneAddr,value)
    return -1

pub get_AIEN(SCL) : AIEN                  ' read ENABLE register's AIEN (RGBC interrupt enable) bit--allows interrupts to be generated
  return (get_DATA(SCL,TCS_ENABLE)&$10)>>4

pub set_AIEN(SCL,value) : AIEN | t        ' write ENABLE register's AIEN (RGBC interrupt enable) bit
  t:=get_DATA(SCL,TCS_ENABLE)&%1110_1111
  t|=value<<4
  if set_DATA(SCL,TCS_ENABLE,t)
    return -1
  
pub get_WEN(SCL) : WEN                    ' read ENABLE register's WEN (Wait enable) bit
  return (get_DATA(SCL,TCS_ENABLE)&$08)>>3
  
pub set_WEN(SCL,value) : WEN | t          ' write ENABLE register's WEN (Wait enable) bit
  t:=get_DATA(SCL,TCS_ENABLE)&%1111_0111
  t|=value<<3
  if set_DATA(SCL,TCS_ENABLE,t)
    return -1

pub get_AEN(SCL) : AEN                    ' read ENABLE register's AEN (RGBC enable) bit
  return (get_DATA(SCL,TCS_ENABLE)&$02)>>1
  
pub set_AEN(SCL,value) : AEN | t          ' write ENABLE register's AEN (RGBC enable) bit
  t:=get_DATA(SCL,TCS_ENABLE)&%1111_1101
  t|=value<<1
  if set_DATA(SCL,TCS_ENABLE,t)
    return -1

pub get_PON(SCL) : PON                    ' read ENABLE register's PON (Power ON) bit
  return get_DATA(SCL,TCS_ENABLE)&$01
  
pub set_PON(SCL,value) : PON | t          ' write ENABLE register's PON (Power ON) bit
  t:=get_DATA(SCL,TCS_ENABLE)&%1111_1110
  t|=value
  if set_DATA(SCL,TCS_ENABLE,t)
    return -1

pub get_APERS(SCL) : APERS                ' read PERS (Persistence) register's APERS (Interrupt persistence) bits(3..0)
  return get_DATA(SCL,TCS_PERS)&$0F
  
pub set_APERS(SCL,value) : APERS | t      ' write PERS register's APERS (Interrupt persistence) bits(3..0)
  t:=get_DATA(SCL,TCS_PERS)&%1111_0000    ' see datasheet for persistence values (page 14, table 7)
  t|=value
  if set_DATA(SCL,TCS_PERS,t)
    return -1

pub get_WLONG(SCL) : WLONG                ' read CONFIG register's WLONG (Wait long) bit
  return (get_DATA(SCL,TCS_CONFIG)&$02)>>1
  
pub set_WLONG(SCL,value) : WLONG | t      ' write CONFIG register's WLONG (Wait long) bit
  t:=get_DATA(SCL,TCS_CONFIG)&%1111_1101
  t|=value<<1
  if set_DATA(SCL,TCS_CONFIG,t)
    return -1
    
pub get_AGAIN(SCL) : AGAIN                ' read CONTROL register's AGAIN (RGBC Gain control) bits(1..0)
  return get_DATA(SCL,TCS_CONTROL)&$03
    
pub set_AGAIN(SCL,value) : AGAIN | t      ' write CONTROL register's AGAIN (RGBC Gain control) bits(1..0)
  t:=get_DATA(SCL,TCS_CONTROL)&%1111_1100 ' value: %00 = 1x gain, %01 = 4x gain, %10 = 16x gain, %11 = 60x gain
  t|=value
  if set_DATA(SCL,TCS_CONTROL,t)
    return -1

pub get_AINT(SCL) : AINT                  ' RGBC clear chan interrupt bit
  return (get_DATA(SCL,TCS_STATUS)&$10)>>4

pub get_AVALID(SCL) : AVALID              ' RGBC valid bit
  return get_DATA(SCL,TCS_STATUS)&$01

pub clear_RGBC_interrupt(SCL) : cleared
  if set_DATA(SCL,TCS_SPECIAL|TCS_INT_CLR,0)
    return -1

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
    