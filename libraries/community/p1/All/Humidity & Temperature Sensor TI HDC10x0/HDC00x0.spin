''HDC10x0,spin
''Library of routines for the TI Humidity/Temperature Sensor  
'' Reads Temperature and humidity from HDC1000 sensor but does not use DRDY pin 
''  as the clock must be kept high for it to work.
'' Should also work for HDC1008 and HDC1050 but these do not have DRDY pin
''-------------------
'' Consider using the HDC1080 as this is +-2% accuracy rather than 3% humidity.
'' Temperature is +-0.2C  (March 2016) 
''----------------------
'' Temperature and humidity are displayed on Parallax serial displays 27976 etc.
''  Author: Michael Forsyth
''  
'' Updated: March 2016
'' Designed For: P8X32A
'' Version: 1.0
'' Copyright (c) 2015 Michael P Forsyth
'' See end of file for terms of use.
''
''
Con
'' TI Temp/Humidity sensor  HDC1000 Registers 

   TI = $FE '' Manufacturer ID $5449
   DevID = $FF         
   tempReg = $00
   humidReg = $01
   configReg = $02
'added from pasm_i2c...
   ACK           = 0            ' I2C Acknowledge
   NAK           = 1            ' I2C No Acknowledge
   Xmit          = 0            ' I2C Direction Transmit
   Recv          = 1            ' I2C Direction Receive
   
   
Obj
  i2c           : "pasm_i2c_driver.spin"        
  
Var
  
 
Pub Start(HDCclockPin)
   result := i2c.Initialize(HDCclockPin)      'start pasm-i2c_driver  
                                               '
Pub WaitMS(millisec) |time
   time := clkfreq /1_000 * millisec
   waitcnt(time +cnt)  
   
PUB ReadTempHumid(SCLPin,devAddr,TempAddr,HumidAddr) : x  | config ,temp,hum     
   config := ReadRegister(SCLPin,devAddr,configReg) 
   if ((config >> 28) & 1) == 0
     x := WriteConfig(SCLPin,devAddr,config |= %00010000)
   i2c.Start(SCLPin)
   i2c.Write(SCLPin, devAddr | Xmit)
   i2c.Write(SCLPin, $00)
   
'  Data Ready pin is not used and is no longer included in latest product. 
'  Clock must remain high on last write to use Data Ready pin
   x := 0
   repeat while    i2c.Write(SCLPin, devAddr | Recv) == NAK
      x += 1
      WaitMS(1)  'wait 1 ms   12 loops
                         '
   temp := (i2c.Read(SCLPin,ACK) << 8)   
   temp |= i2c.Read(SCLPin,ACK)
   hum := (i2c.Read(SCLPin,ACK) << 8)
   hum  |= i2c.Read(SCLPin,NAK)
   i2c.Stop(SCLPin)
   long[TempAddr][0] := temp 'write to global vars
   long[HumidAddr][0]  := hum    

PUB WriteConfig(SCLPin,devAddr,config): x 
   i2c.Start(SCLPin)
   if i2c.Write(SCLPin, devAddr | Xmit) == ACK
      x := 1
   if i2c.Write(SCLPin, $02) == ACK
      x += 1
   if i2c.Write (SCLPin, config ) == ACK
      x += 1 
   if i2c.Write (SCLPin, $00) == ACK 'last 8 bits must be 0
      x += 1
   i2c.Stop(SCLPin)
 
Pub ReadConfig(SCLPin,devAddr)
   result :=  ReadRegister(SCLPin,devAddr,configReg)

Pub Reset(SCLPin,devAddr) : x  | config
   config := ReadRegister(SCLPin,devAddr,configReg) 
   WriteConfig(SCLPin,devAddr,config |= %10000000)
   WaitMS(15)
   
Pub SetHeat(SCLPin,devAddr,status): x |config 'status 1=on 0=off
'' turns the heater on or off 
'' returns 0 on invalid status  4 on success
   config := ReadRegister(SCLPin,devAddr,configReg) 
   if status == 1
       x := WriteConfig(SCLPin,devAddr,config |= %00100000)
   elseif status == 0                                  
       x := WriteConfig(SCLPin,devAddr,config &= %11011111)
   else
       x:= 0    
       
Pub SetMode(SCLPin,devAddr,status): x |config 'status 1=Temp&Humidity 0= Temp or Humidity       
    config := ReadRegister(SCLPin,devAddr,configReg)    
   if status == 1
       x := WriteConfig(SCLPin,devAddr,config |= %00010000)
   elseif status == 0                                  
       x := WriteConfig(SCLPin,devAddr,config &= %11101111)
   else
       x:= 0    
    
Pub ReadMode(SCLPin,devAddr) |config  
''  Reads mode and returns 1 if temp&Humidity  or 0 if Temp or Humidity    
    config := ReadRegister(SCLPin,devAddr,configReg) 
    result :=(config >> 12)' & 1
                                 '
Pub BatteryStatus(SCLPin,devAddr) |config  
''Could also be power status   < 2.8v or > 2.8v Returns 0= ok or 1=low
    config := ReadRegister(SCLPin,devAddr,configReg) 
    result :=(config >> 11) & 1
    
Pub ReadTempResolution(SCLPin,devAddr) |config
'' Reads temperature resolution. Returns 0 for 14 bit and 1 for 11 bit      
    config := ReadRegister(SCLPin,devAddr,configReg)
    if  ((config >> 10) & 1) == 0
      result := 14
    else
      result := 11
      
Pub ReadHumidityResolution(SCLPin,devAddr) |config
'' Reads humidity resolution. Returns 14 for 14 bit, 11 for 11 bit and 8 for 8 bit      
    config := ReadRegister(SCLPin,devAddr,configReg)      
    if  (config >> 9) & 1 == 1
      result := 8
    elseif   (config >> 8) & 1 == 1 
      result := 11
    else
      result := 14 
      
      
Pub WriteTempResolution(SCLPin,devAddr,resolution) | config 'resolution = 14 or 11
    config := ReadRegister(SCLPin,devAddr,configReg)                                                        '
    if resolution == 14
        config &= %11111011
    else
        config |= %00000100    
    result := WriteConfig(SCLPin,devAddr,config)

Pub WriteHumidityResolution(SCLPin,devAddr,resolution)|config  'resolution = 14,11 or 8
    config := ReadRegister(SCLPin,devAddr,configReg)  
    config &= %11111100
    case resolution
        14: result := WriteConfig(SCLPin,devAddr,config)
        11: result := WriteConfig(SCLPin,devAddr,config |= %00000001)
        8:  result := WriteConfig(SCLPin,devAddr,config |= %00000010)
        other: result := 0

      
      
PUB ReadRegister(SCLPin,devAddr,regAddr) : data  | x,y
'' reads the entire register and returns most sig 16 bits
   devAddr |= regAddr >> 15 & %1110    '
   i2c.Start(SCLPin)
   i2c.Write(SCLPin, devAddr | Xmit)
   i2c.Write(SCLPin, regAddr)
   i2c.Stop(SCLPin)
   i2c.Start(SCLPin)
   i2c.Write(SCLPin, devAddr | Recv)
   x := i2c.Read(SCLPin,ACK)
   y := i2c.Read(SCLPin,NAK)
   i2c.Stop(SCLPin)
   data := (x << 8) | y  
   
PUB ReadSN(SCLPin,devAddr,SNaddr)',@SN[0]
'  The SN is 40 bits long so it is read into a DAT byte[]
'  3 words  FB FC FD
   Word[SNaddr][0] := ReadRegister(SCLPin,devAddr,$FB)
   Word[SNaddr][1] := ReadRegister(SCLPin,devAddr,$FC)
   Word[SNaddr][2] := ReadRegister(SCLPin,devAddr,$FD)

   
PUB ReadTemp(SCLPin,devAddr,TempAddr) : x  | config ,temp
   config := ReadRegister(SCLPin,devAddr,configReg) 
   if ((config >> 28) & 1) == 1
     x := WriteConfig(SCLPin,devAddr,config &= %11101111)
   i2c.Start(SCLPin)
   i2c.Write(SCLPin, devAddr | Xmit)
   i2c.Write(SCLPin, $00)
   
'  Data Ready pin is not used and is no longer included in latest product. 
'  Clock must remain high on last write to use Data Ready pin
   x := 0
   repeat while    i2c.Write(SCLPin, devAddr | Recv) == NAK
      x += 1
      WaitMS(1)  'wait 1 ms   12 loops
   temp := (i2c.Read(SCLPin,ACK) << 8)   
   temp |= i2c.Read(SCLPin,NAK)
   i2c.Stop(SCLPin)
   long[TempAddr][0] := temp 'write to global vars
   
PUB ReadHumid(SCLPin,devAddr,HumidAddr)  : x  | config ,hum    
   config := ReadRegister(SCLPin,devAddr,configReg) 
   if ((config >> 28) & 1) == 1
     x := WriteConfig(SCLPin,devAddr,config &= %11101111)
   i2c.Start(SCLPin)
   i2c.Write(SCLPin, devAddr | Xmit)
   i2c.Write(SCLPin, $01)
   
'  Data Ready pin is not used and is no longer included in latest product. 
'  Clock must remain high on last write to use Data Ready pin
   x := 0
   repeat while    i2c.Write(SCLPin, devAddr | Recv) == NAK
      x += 1
      WaitMS(1)  'wait 1 ms   12 loops
   hum := (i2c.Read(SCLPin,ACK) << 8)
   hum  |= i2c.Read(SCLPin,NAK)
   i2c.Stop(SCLPin)
   long[HumidAddr][0]  := hum  ' write to global  
   
Pub ReadDeviceID(SCLPin,devAddr)  
   Result := ReadRegister(SCLPin,devAddr,DevID)
   
Pub ReadManufacturer(SCLPin,devAddr)
   Result := ReadRegister(SCLPin,devAddr,TI)   
   
DAT
    SerialNo word $0000[3] 
    Temper long 0
    Humid long 0
    
    
{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}        
