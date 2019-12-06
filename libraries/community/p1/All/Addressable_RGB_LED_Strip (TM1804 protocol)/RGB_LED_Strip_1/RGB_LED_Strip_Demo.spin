'' RGB_LED_Demo
'' by Gavin T. Garner
'' University of Virginia
'' April 20, 2012
{  This program demonstrates how to use my RGB_LED_Strip object and shows how to call its methods.}

CON                          
  _xinfreq=6_250_000          'The system clock is set at 100MHz (you need at least a 20MHz system clock)
  _clkmode=xtal1+pll16x       '(I have been overclocking my Propeller chips with impunity for years!^)    

  TotalLEDs=60   '<---set the maximum number of LEDs you wish to control (eg. 30 for 1m strip, 60 for 2m
                 '    strip, 120 for two 2m strips wired in series, etc.) Code has been tested up to 4m
OBJ
  rgb : "RGB_LED_Strip"           'Include RGB_LED_Strip object and call it "rgb" for short

PUB Demo | i, j, x, maxAddress
  rgb.start(0,TotalLEDs)          'Start up RGB LED driver on a new cog, set data pin to be P0,   
                                  ' and specify that there are 60 LEDs in the strip (2 meters)
  maxAddress:=TotalLEDs-1         'LED addresses start with zero so 59 will be the maximum address

  rgb.AllOff                      'You can turn off all of the LEDs at once
 
                                  'ROYGBIV Rainbow demo
  rgb.LED(0,rgb#red)              'You can set a specific LED address to a predefined color         
  rgb.LED(1,rgb#orange)           ' Note that you can access predefined constants from within my
  rgb.LED(2,rgb#yellow)           ' RGB_LED_Strip object using the "rgb" alias and # sign
  rgb.LED(3,rgb#green)
  rgb.LED(4,rgb#blue)
  rgb.LED(5,rgb#indigo)
  rgb.LED(6,rgb#violet)
  waitcnt(clkfreq+cnt)
                                  'You can also set the 8-bit RGB color values manually
  rgb.LED(7,255<<16)              'Set color to red=255 (green=blue=0) 
  rgb.LED(8,255<<8)               'Set color to green=255 (red=blue=0)
  rgb.LED(9,255)                  'Set color to blue=255 (green=0 blue=0)
  waitcnt(clkfreq+cnt)
  rgb.LED(10,255<<16+255<<8+255)  'Set color to red=255 green=255 blue=255 (white)
  rgb.LED(11,$FF_FF_FF)           'Or use hexadecimal* red=$FF green=$FF blue=$FF (white)                        
  rgb.LED(12,%11111111_11111111_11111111) 'Or 24-bit binary* where %11111111=255(white)
  rgb.LED(13,16777215)            'Or one big decimal number*
  waitcnt(clkfreq+cnt)            '*Note that these are are cruel and unusual forms of punishment
  
             '   R   G   B         You can also set each color component individually
  rgb.LEDRGB(14,255,255,255)      'Set color to red=255 green=255 blue=255 (white) 
  rgb.LEDRGB(15,255,0,0)          'Set color to red=255 green=0 blue=0 (red) 
  rgb.LEDRGB(16,0,255,0)          'Set color to red=0 green=255 blue=0 (green)
  rgb.LEDRGB(17,0,0,255)          'Set color to red=0 green=0 blue=255 (blue)
  rgb.LEDRGB(18,255,255,0)        'Set color to red=255 green=255 blue=0 (yellow)
  rgb.LEDRGB(19,255,0,255)        'Set color to red=255 green=0 blue=255 (magenta)
  rgb.LEDRGB(20,127,255,212)      'Set color to red=127 green=255 blue=212 (aquamarine)
  waitcnt(clkfreq+cnt)
  
  rgb.SetSection(21,maxAddress,255)'You can set sections of the strip's LEDs to one color at once
  waitcnt(clkfreq+cnt)
  
  rgb.SetAllColors(rgb#red)       'You can set all of the strip's LEDs to one color at once
  waitcnt(clkfreq/2+cnt)
  rgb.SetAllColors(rgb#green)
  waitcnt(clkfreq/2+cnt)
  rgb.SetAllColors(rgb#blue)
  waitcnt(clkfreq/2+cnt)
                                  'Now you are ready to start making fancy patterns...
  rgb.AllOff                                
  x:=3
  repeat j from 100 to 300 step 100                              
    repeat i from 0 to maxAddress-x
      rgb.SetSection(i,i+3,rgb#blue)    
      waitcnt(clkfreq/j+cnt)
      rgb.SetSection(0,maxAddress-x,rgb#off)
    x:=x+3
    repeat i from 0 to maxAddress-x
      rgb.SetSection(i,i+3,rgb#red)
      waitcnt(clkfreq/j+cnt)
      rgb.SetSection(0,maxAddress-x,rgb#off) 
    x:=x+3  
    repeat i from 0 to maxAddress-x
      rgb.SetSection(i,i+3,rgb#green)
      waitcnt(clkfreq/j+cnt)
      rgb.SetSection(0,maxAddress-x,rgb#off) 
    x:=x+3
  repeat i from maxAddress-x to maxAddress step 3
    rgb.SetSection(i,i+3,rgb#off)
    waitcnt(clkfreq/10+cnt)
  
  repeat i from maxAddress to 0
    rgb.LED(i,rgb#white)    
    waitcnt(clkfreq/20+cnt)
  repeat i from 0 to maxAddress-1
    rgb.LED(i,rgb#red)    
    waitcnt(clkfreq/50+cnt)
  repeat i from maxAddress to 0
    rgb.LED(i,rgb#green)    
    waitcnt(clkfreq/50+cnt)
  repeat i from 0 to maxAddress/2
    rgb.LED(i,rgb#blue)    
    waitcnt(clkfreq/50+cnt)

  x:=255                                'Flip-flop pattern
  repeat 3
    repeat i from 0 to maxAddress/2  
      rgb.LED(maxAddress/2+i,x)
      rgb.LED(maxAddress/2-i,x)     
      waitcnt(clkfreq/50+cnt) 
    repeat i from 0 to maxAddress/2
      rgb.LED(i,rgb#off)
      rgb.LED(maxAddress-i,rgb#off)   
      waitcnt(clkfreq/50+cnt)
    x:=x<<8                             'Shift x from blue to green then red
 
  repeat i from 0 to maxAddress/2-1     
    rgb.LED(maxAddress/2-1-i,rgb#white)
    rgb.LED(maxAddress/2-1+i,rgb#white)   
    waitcnt(clkfreq/50+cnt)
  
  repeat i from 10 to 100               'Lightning strobe effect
    rgb.SetAllColors(rgb#white)    
    waitcnt(clkfreq/i+cnt)        
    rgb.AllOff                    
    waitcnt(clkfreq/i+cnt)

  repeat 3
    repeat i from 255 to 0 step 5         'Fade off
      rgb.SetAllColors(i<<16+i<<8+i)
      waitcnt(clkfreq/50+cnt)
    repeat i from 0 to 255 step 5         'Fade on
      rgb.SetAllColors(i<<16+i<<8+i)
      waitcnt(clkfreq/50+cnt)

  repeat j from 50 to 4000 step 50      'Random-color, ping-pong pattern
    rgb.Random(0)
    repeat i from 0 to maxAddress 
      x:=rgb.GetColor(i)                'You can retrieve the color value of any LED
      rgb.LED(i+1,x)
      waitcnt(clkfreq/j+cnt)
    rgb.Random(maxAddress)              'There's no earthly way of knowing which direction they are going
    repeat i from maxAddress to 1       '      ...There's no knowing where they're rowing... 
      x:=rgb.GetColor(i)                'The danger must be growing cause the rowers keep on rowing       
      rgb.LED(i-1,x)                    'And they're certainly not showing any sign that they are slowing!
      waitcnt(clkfreq/j+cnt)            '   (If you are the lest bit epileptic, stop this demo now!) 
     
  repeat                                'Nice, infinite, peacefully-pulsing, random pattern 
    x:=?cnt>>24                         'This last portion of code was developed by two of my students:                                     
    repeat j from 0 to 255 step 5       '      Taylor Hammelman and Ankit Javia  
      repeat  i from 0 to maxAddress step 2    '            Enjoy!                 
        rgb.LEDRGB(i,x,255-x,j)
        rgb.LEDRGB(i+1,x,255-x,255-j)
      waitcnt(clkfreq/30+cnt)
    
{Copyright (c) 2012 Gavin Garner, University of Virginia                                                                              
MIT License: Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated             
documentation files (the "Software"), to deal in the Software without restriction, including without limitation the                   
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit                
persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and               
this permission notice shall be included in all copies or substantial portions of the Software. The software is provided              
as is, without warranty of any kind, express or implied, including but not limited to the warrenties of noninfringement.              
In no event shall the author or copyright holder be liable for any claim, damages or other liablility, out of or in                   
connection with the software or the use or other dealings in the software.}            