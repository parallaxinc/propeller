{{


        ######################################################################################################## 
        ########################################################################################################
        ********************************        LED SEQUENCE: BIT by BIT        ********************************
        ********************************        By Justin A. McGillivary        ********************************
        ********************************        Date: September 30th, 2013      ********************************
        ######################################################################################################## 
        ########################################################################################################

        
                                                        - OVERVIEW -
 
- This program demonstrates, bit by bit, an LED sequence for the Propeller P8X32A QuickStart Board (Rev.A 40000).
- Here is a demonstration of how to control an LED sequence by turning off/on bits in some given order for effect.
- This code, while some might consider 'sloppy' is easy to understand and grasp. By looking at each line of code with a "%" prefix,
  which indicates the LED(s) to be lit in Binary (ex. %10101010), it is easy to visualise what is taking place.
- There is also a display of how to incorporate a system of repeats to generate a sequence of events. The infinite loop cycles the entire
  program while each "portion" is repeated a set number of times. Within these sets are the patterns to execute. The sequence of LEDs being
  lit can be changed by adjusting the repeat counts for each repeating loop.

  So what is taking place/actually happening?

- We'll start by looking at the intial REPEAT loop. Since this has no whole number associated with it, it cycles forever. Each additional
  repeat is a PORTION or a PATTERN. The patterns make up the portions, and they repeat individually, while the portions repeat the patterns
  and make up the guts of the program. In the first pattern the LEDs will cycle with ODD/EVEN pins by turning every other bit on, or off,
  and vice verse. The second pattern turns on the LEDs from the outside bits to the inside bits, e.g pins 23/16 to 22/17 to 21/18 to 20/19.
  The next pattern turns 4 bits on, shifts them left, and repeats. So while 4 bits are on, 4 are off, and it alternates. The fourth pattern
  turns individual bits on or off in a left to right then right to left order. If you notice the binary symbol, "%" you can clearly see how
  the pattern unfolds.

- Try changing any of the code to see how it affects the patterns!


        $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
        $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$                                                                                                                        
        $$$$$$$$$$$$$$$$$$$$$$       This program is uploaded in accordance with                       $$$$$$$$$$$$$$$$$$$$$$
        $$$$$$$$$$$$$$$$$$$$$$       Parallax's Terms & Conditions on the Object Exchange.             $$$$$$$$$$$$$$$$$$$$$$
        $$$$$$$$$$$$$$$$$$$$$$       Please refer to  http://obex.parallax.com/  for more details.     $$$$$$$$$$$$$$$$$$$$$$
        $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$                        
        $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

        
}}

PUB main                                                
  dira[23..16] := %11111111
  repeat                                                ' Set up infinite loop
  
    repeat 3                                            ' Repeat this PORTION 3 times
    
      repeat 5                                          ' Repeat this pattern 5 times
      
        outa[23..16] := %10101010                       ' ALTERNATING
        waitcnt(clkfreq/4 + cnt)
        !outa[23..16]
        waitcnt(clkfreq/4 + cnt)
                                                        
      repeat 3                                          ' Repeat this pattern 5 times
      
        outa[23..16] := %00000000                       ' OUTSIDE to INSIDE
        waitcnt(clkfreq/4 + cnt)
        outa[23..16] := %10000001
        waitcnt(clkfreq/4 + cnt)
        outa[23..16] := %11000011
        waitcnt(clkfreq/4 + cnt)
        outa[23..16] := %11100111
        waitcnt(clkfreq/4 + cnt)
        outa[23..16] := %11111111
        waitcnt(clkfreq/4 + cnt)
          
      repeat 5                                          ' Repeat this pattern 5 times
      
        outa[23..16] := %00001111                       ' 4 ON/OFF
        waitcnt(clkfreq/4 + cnt)
        outa[23..16] <<= 4
        waitcnt(clkfreq/4 + cnt)                        
    
      repeat 3                                          ' Repeat this pattern 5 times
      
        outa[23..16] := %10000000                       ' LEFT to RIGHT
        waitcnt(clkfreq/4 + cnt)
        outa[23..16] := %11000000
        waitcnt(clkfreq/4 + cnt)
        outa[23..16] := %11100000
        waitcnt(clkfreq/4 + cnt)
        outa[23..16] := %11110000
        waitcnt(clkfreq/4 + cnt)
        outa[23..16] := %11111000
        waitcnt(clkfreq/4 + cnt)
        outa[23..16] := %11111100
        waitcnt(clkfreq/4 + cnt)
        outa[23..16] := %11111110
        waitcnt(clkfreq/4 + cnt)
        outa[23..16] := %11111111
        waitcnt(clkfreq/4 + cnt)
        outa[23..16] := %00000001                        ' RIGHT TO LEFT
        waitcnt(clkfreq/4 + cnt)
        outa[23..16] := %00000011
        waitcnt(clkfreq/4 + cnt)
        outa[23..16] := %00000111
        waitcnt(clkfreq/4 + cnt)
        outa[23..16] := %00001111
        waitcnt(clkfreq/4 + cnt)
        outa[23..16] := %00011111
        waitcnt(clkfreq/4 + cnt)
        outa[23..16] := %00111111
        waitcnt(clkfreq/4 + cnt)
        outa[23..16] := %01111111
        waitcnt(clkfreq/4 + cnt)
        outa[23..16] := %11111111
        
' END OF LINE