''Program to Demonstrate  HDC10x0 Library
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

CON
   _clkmode = xtal1 + pll16x
   _xinfreq = 5_000_000
   
''LCDisplay 27976
   DisplayTXPin = 30   '6
   DisplayRXPin = 31    '-1
   DisplayBaud = 115_200  '19_200
   CS = 12  ''CS: Clear Screen      
   CB = 12  ''CB: Clear all lines go to 0,0 
   CR = 13  ''CR: carrigage return     
   LF = 10  ''LF: Line Feed       
   TB =  9  ''TB: TaB          
   BS =  8  ''BS: BackSpace          
   
''display locations
   Line0 = $80
   Line1 = $94
''Cursor control 
   CursorOn = $18
   CursorOnBlink = $19
   CursorOff = $16
   BacklightOn = $11     ''only on models 27977, 27979
   BacklightOff = $12   ''only on models 27977, 27979



'' '''''''''''''''''''''''''''''' 12c constants for HD1000 ''''''''''''''''''''''''''
   HDCAddr = $40  '' address with addr inputs grounded
   HDCclockPin = 1
   HDCdataPin = 2
   HDCdataReady = 0  '' when this is 0 data is ready only if clock is high(Not used here)
   HDCclockDrive = 0   '' pull up resistor yes=0 or no pullup =1
'' '''''''''''''''i2c ''''''''''''



OBJ
  LCD           : "Parallax Serial Terminal.spin"
                 
  f             : "Float32Full.spin"
  fst           : "FloatString.spin"
  HDC           : "HDC00x0.spin"
  
VAR
   byte i2cAddr   '' address with addr inputs grounded

PUB   Main  | i2c_cog, serial_cog,f_cog, manuf,F_Humidity,F_Temperature,test1,test2,manuf1,manuf2,config
    WaitMS(15)    ''wait for hdc1000 to boot
    serial_cog := LCD.startRxTx(DisplayRXPin, DisplayTXPin, 0, DisplayBaud)
    WaitMS(5)                ' Pause for FullDuplexSerial.spin to initialize
    f_cog := f.start         'Start Float32full                                           ' 
'    LCD.Char(BacklightOn)'used for 2 line serial display
'    serial_display_clear 'used for 2 line serial display
    i2c_cog := HDC.Start(HDCclockPin) 'start pasm-i2c_driver
    i2cAddr := HDCAddr 
    i2cAddr <<= 1
    i2cAddr &= -2                ''Clear i2cAddr.bit0 (write)
    LCD.Str(String("MFR "))                             
    LCD.Hex(HDC.ReadManufacturer(HDCclockPin,i2cAddr),4) 
    LCD.Str(String(" Battery Stat "))
    LCD.Dec( HDC.BatteryStatus(HDCclockPin,i2cAddr))
    LCD.Char(CR)  
    LCD.Str(String("Config Reg Binary "))
    LCD.Bin(HDC.ReadConfig(HDCclockPin,i2cAddr) ,32)
    LCD.Char(CR)
    LCD.Str(String("Config Decimal "))  
    LCD.Dec(config ) 'last 8 all 0
    LCD.Char(CR)  
    LCD.Str(String("WriteConfig Hum 8bit "))
    HDC.WriteHumidityResolution(HDCclockPin,i2cAddr,8)
    LCD.Str(String("ReadConfig Hum 8bit  "))
    config := HDC.ReadHumidityResolution (HDCclockPin,i2cAddr)
    LCD.Bin(HDC.ReadConfig(HDCclockPin,i2cAddr) ,32)
    LCD.Char(CR)  
    LCD.Str(String ("Config H8 Dec " ))
    LCD.DEC(config ) 'last 8 all 0
    LCD.Char(CR)                       
    HDC.ReadSN(HDCclockPin,i2cAddr,@SN)               
    LCD.Str(String ("SerialNo " ))
    LCD.Hex(SN[0],4)
    LCD.Hex(SN[1],4)
    LCD.Hex(SN[2],4)
    LCD.Char(CR)                       
    HDC.ReadTemp(HDCclockPin,i2cAddr,@Temperature)
    F_Temperature := f.FSub(  f.FMul( f.FDiv(f.FFloat(long[@Temperature][0] ),65536.0), 165.0), 40.0)
    HDC.ReadHumid(HDCclockPin,i2cAddr,@Humidity)
    LCD.Str(String("Temperature C= "))
    LCD.Str(fst.FloatToFormat(F_Temperature,4,1))
    LCD.Char(CR)
    F_Humidity :=  f.FMul( f.FDiv(f.FFloat(long[@Humidity][0]),65536.0), 100.0)
    LCD.Str(String("Humidity %= "))
    LCD.Str(fst.FloatToFormat(F_Humidity,5,1))
    LCD.Char(CR)
    WaitMS(5_000)
    repeat
      HDC.ReadTempHumid(HDCclockPin,i2cAddr,@Temperature,@Humidity)
      F_Humidity :=  f.FMul( f.FDiv(f.FFloat(long[@humidity][0]),65536.0), 100.0)
      F_Temperature := f.FSub(  f.FMul( f.FDiv(f.FFloat(long[@temperature][0] ),65536.0), 165.0), 40.0)
 '     LCD.Char(Line0) 'used in 2 line serial display
      LCD.Str(String("T= "))
      LCD.Str(fst.FloatToFormat(F_Temperature,4,1))
      LCD.Str(String(" H= "))
      LCD.Str(fst.FloatToFormat(F_Humidity,5,1))
      LCD.Char(CR)
      WaitMS(3000)    
     

PUB serial_display_clear
	LCD.Char(CS)            ' goto 0,0 and clear screen
   waitcnt(clkfreq / 100 + cnt)            ' must wait 5 msec for clearing



Pub WaitMS(millisec) |time
   time := clkfreq /1_000 * millisec
   waitcnt(time +cnt)

DAT
   SN word $0000[3]
   Temperature long 0
   Humidity long 0
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


