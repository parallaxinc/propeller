''Title: Input Shift Register Object
''Author: Corbin Adkins (Microcontrolled)
''Version: 1.0
''Chipset: P8X32A
''Supported Hardware: Tested on the Texas Instuments SN74HC165 8-bit parallel load shift register.
''Description: Reads the input from a single shift register. Does not work with outputting shift
''registers. Requires no other objects to operate nor an XTAL.
''
VAR

  byte data
  byte SHLD,CLK,CLKINH,SER
  word chipcount

PUB Start(_SHLD,_CLK,_CLKINH,_SER)

  SHLD := _SHLD
  CLK := _CLK
  CLKINH := _CLKINH
  SER := _SER

PUB Read

  return ReadExplicit(SER)

PUB ReadExplicit(serial_pin) | i

  dira[SHLD]~~
  dira[CLK]~~
  dira[CLKINH]~~
  dira[serial_pin]~
  outa[CLKINH]~~      
  outa[SHLD]~                    
  outa[CLK]~                     
  outa[SHLD]~~                   
  outa[CLK]~~                    
  waitcnt(clkfreq/300 + cnt)     
  outa[CLK]~                     
  outa[CLKINH]~                  
  repeat i from 1 to 8           
    outa[CLK]~~                  
    data := data << 1 + ina[serial_pin]     
    outa[CLK]~                   
    waitcnt(clkfreq/1000 + cnt)  
  return data
   