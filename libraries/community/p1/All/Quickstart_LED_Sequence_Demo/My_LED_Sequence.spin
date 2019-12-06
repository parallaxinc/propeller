{{


        ######################################################################################################## 
        ########################################################################################################
        ********************************        LED SEQUENCE: BIT by BIT        ********************************
        ********************************        By Justin A. McGillivary        ********************************
        ********************************        Date: September 30th, 2013      ********************************
        ********************************                 Revision B             ********************************
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


CON
  _CLKMODE = XTAL1 + PLL16X
  _XINFREQ = 5_000_000

  left  = 23
  right = 16

VAR
  long StackA[32]
  long StackB[32]
  long StackC[32]
  long StackD[32]
  long StackE[32]
  
PUB main | X

  X := 1

  cognew  (Alternating    ,       @StackA)
  cognew  (Out_In         ,       @StackB)
  cognew  (On_Off         ,       @StackC)
  cognew  (LtoR           ,       @StackD)
  cognew  (RtoL           ,       @StackE)
                                              
  dira[23..16]~~
  
  REPEAT                                                ' Set up infinite loop
  
  
    REPEAT X FROM 0 TO 3                                            ' Repeat this PORTION 3 times
    
           
      REPEAT X FROM 0 TO 5                                          ' Repeat this pattern 5 times                    
             Alternating
             
      REPEAT X FROM 0 TO 5                                          ' Repeat this pattern 5 times
             Out_In
             
      REPEAT X FROM 0 TO 5                                          ' Repeat this pattern 5 times 
             On_Off
             
      REPEAT X FROM 0 TO 3                                          ' Repeat this pattern 3 times
             LtoR
              
      REPEAT X FROM 0 TO 3                                          ' Repeat this pattern 3 times
             RtoL 
        
PUB Alternating
  
  'REPEAT                                               
      
        outa[left..right] := %10101010                  ' ALTERNATING
        waitcnt(clkfreq/4 + cnt)
        !outa[left..right]
        waitcnt(clkfreq/4 + cnt)


PUB Out_In

  'REPEAT                                                
      
        outa[left..right] := %00000000                  ' OUTSIDE to INSIDE
        waitcnt(clkfreq/4 + cnt)
        outa[left..right] := %10000001
        waitcnt(clkfreq/4 + cnt)
        outa[left..right] := %11000011
        waitcnt(clkfreq/4 + cnt)
        outa[left..right] := %11100111
        waitcnt(clkfreq/4 + cnt)
        outa[left..right] := %11111111
        waitcnt(clkfreq/4 + cnt)


PUB On_Off

  'REPEAT
  
        outa[left..right] := %00001111                  ' 4 ON/OFF
        waitcnt(clkfreq/4 + cnt)
        outa[left..right] <<= 4
        waitcnt(clkfreq/4 + cnt)  


PUB LtoR

  'REPEAT
  
        outa[left..right] := %10000000                  ' LEFT to RIGHT
        waitcnt(clkfreq/4 + cnt)
        outa[left..right] := %11000000
        waitcnt(clkfreq/4 + cnt)
        outa[left..right] := %11100000
        waitcnt(clkfreq/4 + cnt)
        outa[left..right] := %11110000
        waitcnt(clkfreq/4 + cnt)
        outa[left..right] := %11111000
        waitcnt(clkfreq/4 + cnt)
        outa[left..right] := %11111100
        waitcnt(clkfreq/4 + cnt)
        outa[left..right] := %11111110
        waitcnt(clkfreq/4 + cnt)
        outa[left..right] := %11111111
        waitcnt(clkfreq/4 + cnt)


PUB RtoL

  'REPEAT
  
        outa[left..right] := %00000001                   ' RIGHT TO LEFT
        waitcnt(clkfreq/4 + cnt)
        outa[left..right] := %00000011
        waitcnt(clkfreq/4 + cnt)
        outa[left..right] := %00000111
        waitcnt(clkfreq/4 + cnt)
        outa[left..right] := %00001111
        waitcnt(clkfreq/4 + cnt)
        outa[left..right] := %00011111
        waitcnt(clkfreq/4 + cnt)
        outa[left..right] := %00111111
        waitcnt(clkfreq/4 + cnt)
        outa[left..right] := %01111111
        waitcnt(clkfreq/4 + cnt)
        outa[left..right] := %11111111


CON   
' END OF LINE