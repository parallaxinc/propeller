'' =================================================================================================
''
''   File....... VMA203_PAB_demoMRX5Buttons.spin
''   Primary Purpose..... Demonstrate operation KeyPad buttons on VMA203 
''   Seconday Purpose.... Demonstrate operation of ADC on PAB
''                        Demonstrate display of strings on VMA203 LCD      
''   Hardware used : Valleman VMA203 & Parallax Activity Board
' Current Version
' TESTED OK
' Started........2016-01-03
' Copyright (c) 2016  MIROX Corporation
' Edited by: Miro Kefurt
' 2016-09-26
' Version 1.5   2016-01-03     Uses Parallax PST for data display
' Version 1.6   2016-09-26     Add New Line between chanel print outs
' Version 2.0   2018-08-24     Add Buttons PRI for Velleman VMA203, change update speed to 200ms
' Version 2.2   2018-08-24      Tested OK PAB WX and VMA203 = Uses Parallax PST for data display
' Version A     2018-08-25      Use VMA203 LCD for display (replaces PST)
''
'' =================================================================================================    

CON { timing }
  
  _xinfreq = 5_000_000                                          ' use 5MHz External crystal
  _clkmode = xtal1 + pll16x                                     ' 5MHz * PLL16 = 80MHz Clock Frequency

CON { io pins }

  ADC_CS  = 21                                                  ' adc connections
  ADC_SCL = 20                                                  ' adc connections
  ADC_DO  = 19                                                  ' adc connections
  ADC_DI  = 18                                                  ' adc connections
  
OBJ

  adc  : "jm_adc124s021MRX"                      ' Original modified by Miro Kefurt
  LCD  : "LCD_16x2_4Bit-VMA203H"                 ' Original modified by Miro Kefurt

PUB main | ch, counts 

  setup                               ' start objects             

  LCD.CLEAR                                     ' Clears display 
  
                 '1234567890123456
  LCD.STR(STRING("  VMA203 Demo"))               ' Print String
  LCD.MOVE(2,2)                                  ' Move Cursor to Position 2 Line 2
  LCD.STR(STRING("by Miro Kefurt"))              ' Print String  
  waitcnt(clkfreq*4 + cnt)                       ' Rest 4 seconds 
  LCD.CLEAR                                      ' Clears display 
  LCD.STR(string(" BUTTON STATUS :"))            ' Print String 
  ch := 0                                        ' Set ADC channel to 0
  
  repeat
                                            
      counts := adc.read(ch)                     ' read adc (ch) channel
      
      buttons (counts)
      
      waitcnt(clkfreq/10 + cnt)                  ' Rest 1/10 seconds 
    

PUB setup
'   waitcnt(Delay + cnt)               '  Wait for Delay cycles   
'' Setup objects and I/O Ports used by main cog

  adc.start(ADC_CS, ADC_SCL, ADC_DI, ADC_DO)     ' connect to adc

  LCD.START                                      ' Start LCD Object   

  waitcnt(clkfreq + cnt)                         ' Rest 1 second                         ' let everything load 

PRI buttons (count)

    LCD.MOVE(5,2)                                 ' Move Cursor to Position 2 Line 2
    
    if  count > 4000
                      '1234567890123456
          LCD.STR(string("  NONE  "))                     ' Print String 
    if  count < 40
          LCD.STR(string("  RIGHT "))
    if  (count > 300) AND (count < 450)
          LCD.STR(string("   UP   "))
    if  (count > 1000) AND (count < 1100)
          LCD.STR(string("  DOWN  "))
    if  (count > 1600) AND (count < 1700)
          LCD.STR(string("  LEFT  "))
    if  (count > 2500) AND (count < 2600)
          LCD.STR(string(" SELECT "))    
    
    
DAT { license }

{{

  Terms of Use: MIT License

  Permission is hereby granted, free of charge, to any person obtaining a copy of this
  software and associated documentation files (the "Software"), to deal in the Software
  without restriction, including without limitation the rights to use, copy, modify,
  merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to the following
  conditions:

  The above copyright notice and this permission notice shall be included in all copies
  or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
  PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
  OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

}}