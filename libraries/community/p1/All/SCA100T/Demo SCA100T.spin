{{
************************************************************
* Demo SCA100T inclino meter                               *
* Author:       Rob van den Berg (robvdberg@kabelfoon.net) *
* date:         12 augustus 2008                           *
*                                                          *
************************************************************
}}

CON
  ' PROP
'    _CLKMODE = XTAL1 + PLL16X      'Note Clock Speed for your setup!! 
'    _XINFREQ = 5_000_000

  'SPIN STAMP settings
   _CLKMODE = XTAL1 + PLL8X         'Note Clock Speed for your setup!! 
   _XINFREQ = 10_000_000
 
 '//Spin stamp pin assignments
 'VTI SCA100T-D01 
  SPI_CS  = 0    'Chip select out connected to SCA100T CSB pin
  SPI_CLK = 1    'Clock out to SCA100T SCK pin
  SPI_SDI = 2    'Data in connected to SCA100T MISO pin
  SPI_SDO = 3    'Data out connected to SCA100T MOSI pin

 '//Proller pin assignments
  propTX = 30 'programming output
  propRX = 31 'programming input  

  CR = 13 'carriage return
  LF = 10 'line feed
  

VAR
  long Value_X,Value_Y  

    
OBJ
  VTI   : "SCA100T"             'inclino meter object
  BS2   : "BS2_Functions"       'create BS2 Object

PUB Demo_SCA100T
  BS2.start (31,30) 

  'init inclino meter 
  VTI.Init(SPI_CS,SPI_CLK,SPI_SDI,SPI_SDO)              'Initialize VTI chip
  
  repeat
    Value_X := VTI.GetValue(0)  'duration time ~  1msec
    Value_Y := VTI.GetValue(1)
    
    BS2.debug_str(string("Val_X: "))
    BS2.debug_dec(Value_X)
    BS2.debug_str(string(" Val_Y: "))
    BS2.debug_dec(Value_Y)
 
    BS2.debug_str(string(13))             
    BS2.debug_str(string(10))
    waitcnt(clkfreq / 2 + cnt)    
      