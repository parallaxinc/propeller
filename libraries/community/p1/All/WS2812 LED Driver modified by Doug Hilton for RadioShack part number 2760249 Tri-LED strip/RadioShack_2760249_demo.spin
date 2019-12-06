'' =================================================================================================
''
''   File....... jm_ws2812_demo.spin
''   Purpose.... WS2812/B demonstration program
''   Author..... Jon "JonnyMac" McPhalen
''               Copyright (c) 2014 Jon McPhalen
''               -- see below for terms of use
''   E-mail..... jon@jonmcphalen.com
''   Started.... 
''   Updated.... 24 SEP 2014
''   Modified... 22 DEC 2014 - Doug Hilton for RadioShack p/n 2760249 Tri-LED strip
''
'' =================================================================================================


con { timing }

  _clkmode = xtal1 + pll16x                                     ' 16x required for WS2812                              
  _xinfreq = 5_000_000                                          ' use 5MHz crystal

  CLK_FREQ = ((_clkmode - xtal1) >> 6) * _xinfreq               ' system freq as a constant
  MS_001   = CLK_FREQ / 1_000                                   ' ticks in 1ms
  US_001   = CLK_FREQ / 1_000_000                               ' ticks in 1us


con { io pins }

  RX1  = 31                                                     ' programming / terminal
  TX1  = 30
  
  SDA  = 29                                                     ' eeprom / i2c
  SCL  = 28

  LEDS = 14                                                     ' LED tx pin

  'RadioShack 2760249 Tri-LED strip (all values +- 150 ns)    Doug Hilton  
  T0H = 780       '780 ns        short time
  T1H = 1550      '1550 ns       long time
  T0L = T1H       '1800 ns
  T1L = T0H       '700 ns

con

  STRIP_LEN = 10                                                ' Number of logical (not physical) LED's in the strip
            
  
obj

  strip : "RadioShack_2760249.spin"                             ' WS2812 LED driver


var


dat

  Chakras  long strip#VIOLET,strip#INDIGO,strip#BLUE,strip#GREEN,strip#YELLOW
           long strip#ORANGE,strip#RED,strip#REALWHITE,strip#CYAN,strip#MAGENTA
           long strip#BLACK,strip#BLACK,strip#BLACK,strip#BLACK,strip#BLACK

pub main | pos

  'strip.start_b(LEDS, STRIP_LEN)                                ' start led driver
  strip.startx(LEDS, STRIP_LEN, T0H, T0L, T1H, T1L)              ' start led driver (Doug Hilton)
  strip.off

  repeat
  
    repeat 3
      color_chase(@Chakras, STRIP_LEN, 200)
      pause(20)
    
    repeat 3
      repeat pos from 0 to 255
        strip.set_all(strip.wheelx(pos, 64))                      ' 1/4 brightness
        pause(20)

    repeat 3
      repeat pos from 0 to STRIP_LEN-1
        strip.set(pos, strip#RED)
        pause(100)
      repeat pos from STRIP_LEN-1 to 0
        strip.set(pos, strip#BLACK)
        pause(100)
      pause(100)
            
    repeat 3
      repeat pos from 0 to STRIP_LEN-1
        strip.set(pos, strip#GREEN)
        pause(100)
      repeat pos from 0 to STRIP_LEN-1
        strip.set(pos, strip#BLACK)
        pause(100)
      pause(100)
            
    repeat 3
      repeat pos from 0 to STRIP_LEN-1
        strip.set(pos, strip#BLUE)
        pause(100)
      strip.off
      pause(100)      

pub color_chase(p_colors, len, ms) | base, idx, ch

'' Performs color chase
  repeat base from 1 to len                                     ' do all colors in table
    idx := base -1                                              ' start at base
    repeat ch from 0 to len - 1                                 ' loop through connected leds
      strip.set(ch, long[p_colors][idx])                        ' update channel color
      if (++idx == len)                                         ' past end of list?
        idx := 0                                                ' yes, reset   
    pause(ms)                                                   ' set movement speed   
   
con

  ' Routines ported from C code by Phil Burgess (www.paintyourdragon.com)


pub color_wipe(rgb, ms) | ch

'' Sequentially fills strip with color rgb
'' -- ms is delay between pixels, in milliseconds

  repeat ch from 0 to strip.num_pixels-1 
    strip.set(ch, rgb)
    pause(ms)


pub rainbow(ms) | pos, ch

  repeat pos from 0 to 255
    repeat ch from 0 to strip.num_pixels-1
      strip.set(ch, strip.wheel((pos + ch) & $FF))
    pause(ms)
    

pub rainbow_cycle(ms) | pos, ch 

  repeat pos from 0 to (255 * 5)
    repeat ch from 0 to strip.num_pixels-1
      strip.set(ch, strip.wheel(((ch * 256 / strip.num_pixels) + pos) & $FF))
    pause(ms)
    

con

  { ------------- }
  {  B A S I C S  }
  { ------------- }


pub pause(ms) | t

'' Delay program in milliseconds

  if (ms < 1)                                                   ' delay must be > 0
    return
  else
    t := cnt - 1776                                             ' sync with system counter
    repeat ms                                                   ' run delay
      waitcnt(t += MS_001)
    

pub high(pin)

'' Makes pin output and high

  outa[pin] := 1
  dira[pin] := 1


pub low(pin)

'' Makes pin output and low

  outa[pin] := 0
  dira[pin] := 1


pub toggle(pin)

'' Toggles pin state

  !outa[pin]
  dira[pin] := 1


pub input(pin)

'' Makes pin input and returns current state

  dira[pin] := 0

  return ina[pin]
 

dat { license }

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