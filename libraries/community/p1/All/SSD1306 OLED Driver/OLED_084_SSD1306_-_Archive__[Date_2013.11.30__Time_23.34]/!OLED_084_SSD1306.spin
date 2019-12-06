{{
  Code: Testing OLED 0.84"
  Author: Kenichi Kato (a.k.a. MacTuxLin)
  Date 9th August 2013
}}


CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  _ConClkFreq = ((_clkmode - xtal1) >> 6) * _xinfreq
  _Ms_001   = _ConClkFreq / 1_000


  SCL   = 9
  SDA   = 10
  RST   = 8


  OLED_WriteAdd = $3C<< 1 | $00
  OLED_ReadAdd = $3C<< 1 | $01

  Contrast_level  = $7F 
  Start_column    = $00
  Start_page      = $00
  StartLine_set   = $00
  
   
OBJ
  I2C:  "Basic_I2C_Driver.spin"
  
PUB Main | i

  '--- HW Init
  DIRA[RST]~~

  I2C.Initialize(SCL)
  Pause(100)

  OLED_Init
  Pause(100)
       
  repeat
    OLED_Clear
    OLED_Init
    DisplayOn
    PrintMacTuxLin
    Pause(1000)
    

PRI PrintMacTuxLin | i, j, k
  I2C.Start(SCL)
  I2C.Write(SCL, OLED_WriteAdd)
  
  ' Setting Memory Address Mode
  I2C.Write(SCL, $80)
  I2C.Write(SCL, $20)   ' Set Memory Address Mode
  I2C.Write(SCL, $80)
  I2C.Write(SCL, %000000 << 2 | $00)    ' Horizontal Addressing Mode
  I2C.Write(SCL, $40)

  j := 0
  repeat i from 0 to 191
    I2C.Write(SCL, MacTuxLin3[i])

  I2C.Stop(SCL)
  return  

PRI DisplayOn
  I2C.Start(SCL)
  I2C.Write(SCL, OLED_WriteAdd)
  I2C.Write(SCL, $80)
  I2C.Write(SCL, $AF)
  I2C.Stop(SCL)
  return  

PRI DisplayOff
  I2C.Start(SCL)
  I2C.Write(SCL, OLED_WriteAdd)
  I2C.Write(SCL, $80)
  I2C.Write(SCL, $AE)
  I2C.Stop(SCL)
  return  



PRI OLED_Clear | i, j, totalCol  
{{
  Clear Display
}}

  I2C.Start(SCL)
  I2C.Write(SCL, OLED_WriteAdd)

  ' Setting Memory Address Mode
  I2C.Write(SCL, $80)
  I2C.Write(SCL, $20)   ' Set Memory Address Mode
  I2C.Write(SCL, $80)
  I2C.Write(SCL, %000000 << 2 | $10)    ' Page Addressing Mode

  ' Clear Page# 0
  I2C.Write(SCL, $80)
  I2C.Write(SCL, $B0)   ' Page# 0   
  I2C.Write(SCL, $80)
  I2C.Write(SCL, $00)   ' Lower Col
  I2C.Write(SCL, $40)  
  repeat i from 0 to 127*2    
    I2C.Write(SCL, $00)

  I2C.Stop(SCL)
  return  


PRI OLED_Reset
  OUTA[RST]~~
  Pause(1)
  OUTA[RST]~
  Pause(150)
  OUTA[RST]~~
  Pause(1)


PRI OLED_Init | ackBit, controlByte

  controlByte := $80  'Previously = $80

  OLED_Reset

  I2C.Start(SCL)
  
  ackBit := 1
  repeat while ackBit 
    ackBit := I2C.Write(SCL, OLED_WriteAdd)
    
  ackBit := 1
  repeat while ackBit
    ackBit := I2C.Write(SCL, controlByte)  
    ackBit := I2C.Write(SCL, $AE)    '//--turn off oled panel
    

  ackBit := 1
  repeat while ackBit
    ackBit := I2C.Write(SCL, controlByte)
    ackBit := I2C.Write(SCL, $D5)   '//--set display clock divide ratio/oscillator frequency
    ackBit := I2C.Write(SCL, controlByte)
    'ackBit := I2C.Write(SCL, $F0)   ';//--set divide ratio
    ackBit := I2C.Write(SCL, $80)   'Adafruit E.g.

  ackBit := 1
  repeat while ackBit
    ackBit := I2C.Write(SCL, controlByte)
    ackBit := I2C.Write(SCL, $A8)   '//--set multiplex ratio(1 to 64)
    ackBit := I2C.Write(SCL, controlByte)
    ackBit := I2C.Write(SCL, $0F)   ';//--1/16 duty

  ackBit := 1
  repeat while ackBit
    ackBit := I2C.Write(SCL, controlByte)
    ackBit := I2C.Write(SCL, $D3)   ';//-set display offset
    ackBit := I2C.Write(SCL, controlByte)
    ackBit := I2C.Write(SCL, $00)   ';//-not offset

  ackBit := 1
  repeat while ackBit
    ackBit := I2C.Write(SCL, controlByte)
    ackBit := I2C.Write(SCL, $40)   ';//--set start line address
    'ackBit := I2C.Write(SCL, $40 | $08)   'Adafruit E.g.  <- Didn't work. Page 1 shows distortions with its data in Page 0


  ackBit := 1
  repeat while ackBit
    ackBit := I2C.Write(SCL, controlByte)
    ackBit := I2C.Write(SCL, $8D)   ';//--set Charge Pump enable/disable
    ackBit := I2C.Write(SCL, controlByte)
    ackBit := I2C.Write(SCL, $14)   ';//--set(0x10) disable

  '*** Setting Col Start/End & Page Start/End
  ackBit := 1
  repeat while ackBit
    ackBit := I2C.Write(SCL, controlByte)
    ackBit := I2C.Write(SCL, $21)       ' Col Setting
    ackBit := I2C.Write(SCL, controlByte)
    ackBit := I2C.Write(SCL, 0)         ' Col Start#
    ackBit := I2C.Write(SCL, controlByte)
    ackBit := I2C.Write(SCL, 95)        ' Col End#
    ackBit := I2C.Write(SCL, controlByte)
    ackBit := I2C.Write(SCL, $22)       ' Page Setting
    ackBit := I2C.Write(SCL, controlByte)
    ackBit := I2C.Write(SCL, 0)         ' Page Start#
    ackBit := I2C.Write(SCL, controlByte)
    ackBit := I2C.Write(SCL, 1)         ' Page End#                         

  ackBit := 1
  repeat while ackBit
    ackBit := I2C.Write(SCL, controlByte)
    ackBit := I2C.Write(SCL, $A4)   ';//Disable Entire Display On

  ackBit := 1
  repeat while ackBit
    ackBit := I2C.Write(SCL, controlByte)
    ackBit := I2C.Write(SCL, $A1)   ';//--set segment re-map 96 to 1
    'ackBit := I2C.Write(SCL, $A0)   ';//--set segment re-map 0 to SEG0 (RESET)

  ackBit := 1
  repeat while ackBit
    ackBit := I2C.Write(SCL, controlByte)
    ackBit := I2C.Write(SCL, $C8)   ';//--Set COM Output Scan Direction 16 to 1

  ackBit := 1
  repeat while ackBit
    ackBit := I2C.Write(SCL, controlByte)
    ackBit := I2C.Write(SCL, $DA)   ';//--set com pins hardware configuration
    ackBit := I2C.Write(SCL, $80)
    ackBit := I2C.Write(SCL, $02)   'Sequential COM pin config
    'ackBit := I2C.Write(SCL, %100010)   'Enable COM Left/Right remap <- Didn't work
    

  ackBit := 1
  repeat while ackBit
    ackBit := I2C.Write(SCL, controlByte)
    ackBit := I2C.Write(SCL, $81)   ';//--set contrast control register
    ackBit := I2C.Write(SCL, controlByte)
    ackBit := I2C.Write(SCL, Contrast_level)

  ackBit := 1
  repeat while ackBit
    ackBit := I2C.Write(SCL, controlByte)
    ackBit := I2C.Write(SCL, $D9)   ';//--set pre-charge period
    ackBit := I2C.Write(SCL, controlByte)
    ackBit := I2C.Write(SCL, $22)

  ackBit := 1
  repeat while ackBit
    ackBit := I2C.Write(SCL, controlByte)
    ackBit := I2C.Write(SCL, $DB)   ';//--set vcomh
    ackBit := I2C.Write(SCL, controlByte)
    ackBit := I2C.Write(SCL, $49)   ';//--0.83*vref

  ackBit := 1
  repeat while ackBit
    ackBit := I2C.Write(SCL, controlByte)
    ackBit := I2C.Write(SCL, $A6)   ';//--set normal display


  ackBit := 1
  repeat while ackBit
    ackBit := I2C.Write(SCL, controlByte)
    ackBit := I2C.Write(SCL, $AF)   ';//--turn on oled panel

  I2C.Stop(SCL)

  return


PRI Pause(ms) | t
{{Delay program ms milliseconds}}

  t := cnt - 1088                                               ' sync with system counter
  repeat (ms #> 0)                                              ' delay must be > 0
    waitcnt(t += _MS_001)


DAT
MacTuxLin3    byte      $00, $00, $00, $00, $FC, $04, $0C, $F8, $80, $00, $00, $C0, $20, $18, $04, $FC,{
                        }$00, $00, $00, $00, $60, $60, $60, $60, $40, $40, $C0, $00, $00, $00, $00, $80,{
                        }$40, $40, $40, $40, $40, $00, $00, $0C, $0C, $0C, $0C, $FC, $0C, $0C, $0C, $0C,{
                        }$EC, $0C, $00, $00, $00, $00, $00, $E0, $00, $00, $00, $00, $20, $C0, $00, $00,{
                        }$80, $40, $20, $00, $00, $00, $FC, $00, $00, $00, $00, $00, $00, $00, $00, $00,{
                        }$EC, $0C, $00, $00, $E0, $80, $00, $40, $40, $40, $40, $C0, $00, $00, $00, $00,{
                        }$00, $00, $00, $3F, $00, $00, $00, $00, $07, $06, $01, $00, $00, $00, $3F, $00,{
                        }$00, $00, $00, $1E, $12, $12, $12, $13, $03, $3B, $0F, $00, $00, $00, $1F, $10,{
                        }$10, $10, $10, $10, $00, $00, $00, $00, $00, $00, $3E, $01, $00, $00, $00, $00,{
                        }$1F, $10, $10, $10, $10, $00, $08, $3F, $00, $00, $20, $10, $08, $04, $03, $03,{
                        }$08, $20, $00, $00, $00, $3F, $30, $30, $30, $30, $30, $30, $00, $00, $00, $3C,{
                        }$03, $00, $00, $00, $3F, $00, $00, $00, $00, $00, $00, $3F, $00, $00, $00, $00