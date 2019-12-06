{{
  
        ######################################################################################################## 
        ########################################################################################################
        ********************************      Counter_Sequences.SPIN            ********************************
        ********************************      By Justin A. McGillivary          ********************************
        ********************************      Date: October 30th, 2013          ********************************
        ********************************      Revision A                        ********************************
        ######################################################################################################## 
        ########################################################################################################

}}


CON
  _CLKMODE = XTAL1 + PLL16X                             ' set clkfreq to XTAL1 x 16
  _XINFREQ = 5_000_000                                  ' XTAL1 is 5_000_000 Hz x 16 = 80_000_000 Hz

  left          = 16                                    ' constant for pin #16 @ AllTogetherNow
  right         = 23                                    ' constant for pin #23 @ AllTogetherNow

  left2         = 16                                    ' constant for pin #16 @ chunk
  right2        = 19                                    ' constant for pin #19 @ chunk

  left3         = 20                                    ' constant for pin #20 @ chunk2
  right3        = 23                                    ' constant for pin #23 @ chunk2

  left4         = 18                                    ' constant for pin #18 @ chunk3
  right4        = 21                                    ' constant for pin #21 @ chunk3

  
VAR
  byte begin[5]                                         ' create 5 bytes named begin
  byte end[5]                                           ' create 5 bytes named end
  long Stack[32]                                        ' cog workspace
  long Stack2[32]                                       ' cog workspace

  
PUB main

  begin := %0000_0000                                   ' set byte begin = 0 (%0000_0000)
  end   := %1111_1111                                   ' set byte end   = 255 (%1111_1111)
              
  dira[left..right]~~                                   ' establish/set direction of pins as outputs

  cognew(AllTogetherNow, @Stack)                        ' start a new cog for AllTogetherNow
  cognew(chunks, @Stack2)                               ' start a new cog for chunks

{{
        ' Only run "chunks" or "AllTogetherNow"
        ' while one is on and the other is off.
        ' So if "chunks" is on, comment the line
        ' "AllTogetherNow" so as not to cause
        ' any unwanted errors. (done by default)
}}
         
repeat                                                  ' cycle loop
   
  chunks                                                ' call method chunks
  'AllTogetherNow                                       ' call method AllTogetherNow


PUB AllTogetherNow | routine

{{
        ' This PUB will make all 8 LEDs count from 0 to 255.
        ' The LEDs output the number in binary by lighting up
        ' the coresponding LED/s. Ex: counter is at #24,
        ' so in binary this is %00011000...
        ' The following LEDs will turn on from MSB to LSB...
        ' Pin #16..#17..#18..#19..#20..#21..#22..#23
        '     _OFF _OFF _OFF _ON  _ON  _OFF _OFF _OFF
        '      0    0    0    1    1    0    0    0
}}

  routine := outa[begin[1]..end[1]]                     ' make routine the outputs
  
repeat                                                  ' cycle loop
    
  repeat routine from begin[2] to end[2]  step 1        ' run counter loop from 0 to 255
   
      waitcnt(CLKFREQ/12 + cnt)                         ' wait for output
      outa[left..right]++                               ' increment/decrement outa to count in forward/reverse, respectively

    
PUB chunks | chunk, chunk2, chunk3

{{
        ' This PUB will make 4 LEDs at a time count from 0 to 127
        ' Starting at pins #16 - #19, then pins #20 - #23, and
        ' finally from pins #18-#21. So the Outsides and the Inside,
        ' hence the name, 'chunks'. Because the bits and the counter
        ' is broken into chunks for 3 seperate sequences.
}}

  begin[3] := 16                                        ' from pin #16
  end[3] := 19                                          ' to pin   #19 (4 pins)
  
  begin[4] := 20                                        ' from pin #20
  end[4]   := 23                                        ' to pin   #23 (4 pins)
  
  chunk  := outa[begin[3]..end[3]]                      ' chunk  = pins #16 - #19 (4 pins)
  chunk2 := outa[begin[4]..end[4]]                      ' chunk2 = pins #20 - #23 (4 pins)
  chunk3 := outa[begin[5]..end[5]]                      ' chunk3 = pins #18 - #21 (4 pins)
  
repeat                                                  ' cycle loop

    repeat chunk from %0000 to %1111 step 1             ' run this count-to loop [0-127]
     
        waitcnt(CLKFREQ/12 + cnt)                       ' wait for output                          
        outa[left2..right2]++                           ' output the counter in binary to each pin: 1 = 0000_0001 etc.
                                                                                                  'bits 7^^^_^^^0
    repeat chunk2 from %0000 to %1111 step 1            ' run this count-down loop [127-0]
     
        waitcnt(CLKFREQ/12 + cnt)                       ' wait for output
        outa[left3..right3]++                           ' output the counter in binary to each pin: 7 = 0000_0111 etc.
                                                                                                  'bits 7^^^_^^^0
    repeat chunk3 from %0000 to %1111 step 1            ' run this count-to loop

        waitcnt(CLKFREQ/12 + cnt)                       ' wait for output
        outa[left4..right4]++                           ' output the counter in binary to each pin: 7 = 0000_0111 etc.
                                                                                                  'bits 7^^^_^^^0



CON
{{
Uploaded in accordance with the Parallax Object Exchange (OBEX) Terms & Conditions. 
All Rights Reserved. May not be redistributed or sold without Owner's Consent. (Named above)
}}                                                                                                                           