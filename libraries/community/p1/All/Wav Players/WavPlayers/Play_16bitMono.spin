'  SPIN WAV Player Ver. 1a  (Plays only mono WAV at 16ksps)
'  Copyright 2007 Raymond Allen   See end of file for terms of use.    
'  Settings for Demo Board Audio Output:  Right Pin# = 10, Left Pin# = 11   , VGA base=Pin16, TV base=Pin12


CON _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000       '80 MHz

    buffSize = 256

VAR long parameter
    long buff1[buffSize]
    long buff2[buffSize]
    long stack1[100]
    word MonoData[buffSize]
    
OBJ
    text : "vga_text"    'For NTSC TV Video: Comment out this line...
    'text : "tv_text"    'and un-comment this line  (need to change pin parameter for text.start(pin) command below too).
    SD  : "FSRW"
    num : "numbers"

PUB Main|n,i,j
  'Play a WAV File

  'Start up the status display...
  text.start(16)    'Start the VGA/TV text driver (uses another cog)
                    'The parameter (16) is the base pin used by demo and proto boards for VGA output
                    'Change (16) to (12) when using "tv_text" driver with demo board as it uses pin#12 for video                    
  text.str(STRING("Starting Up",13))

  'open the WAV file  (NOTE:  Only plays mono, 16000 ksps PCM WAV Files !!!!!!!!!!!!!)
  'access SD card 
  i:=sd.mount(0)
  if (i==0)
    text.str(STRING("SD Card Mounted",13))
  else
    text.str(STRING("SD Card Mount Failed",13))
    repeat

  'open file
  'i:=sd.popen(string("test1.wav"), "r")                '   <---------  Change .wav filename here !!!!!!!!!!!!!!         
  'i:=sd.popen(string("test2.wav"), "r")                '   <---------  Change .wav filename here !!!!!!!!!!!!!!
  'i:=sd.popen(string("test3.wav"), "r")                '   <---------  Change .wav filename here !!!!!!!!!!!!!!
  i:=sd.popen(string("test4.wav"), "r")                '   <---------  Change .wav filename here !!!!!!!!!!!!!!      
  text.str(STRING("Opening: "))
  text.str(num.toStr(i,num#dec))
  text.out(13)

  'ignore the file header (so you better have the format right!)
  'See here for header format:  http://ccrma.stanford.edu/CCRMA/Courses/422/projects/WaveFormat/
  i:=sd.pread(@MonoData, 44) 'read data words to input stereo buffer
  text.str(STRING("Header Read ",13))


  'Start the player in a new cog
  COGNEW(Player(10, 11),@stack1)      'Play runs in a seperate COG (because SPIN is a bit slow!!)
  text.str(STRING("Playing...",13))


  'Keep filling buffers until end of file
  ' note:  using alternating buffers to keep data always at the ready...
  n:=buffSize-1
  j:=buffsize*2
  repeat while (j==buffsize*2)  'repeat until end of file
    if (buff1[n]==0)
      j:=sd.pread(@MonoData, buffSize*2) 'read data words to input stereo buffer   
      'fill table 1
      repeat i from 0 to n
         buff1[i]:=($8000+MonoData[i])<<16
    if (buff2[n]==0)
      j:=sd.pread(@MonoData, buffSize*2) 'read data words to input stereo buffer  
      'fill table 1
      repeat i from 0 to n
         buff2[i]:=($8000+MonoData[i])<<16


  'must have reached the end of the file, so close it
  text.str(STRING("Closing: "))  
  sd.pclose
  
  'shut down here

PUB Player(PinR, PinL)|n,i,nextCnt,j
  'Play the wav data using counter modules
  'although just mono, using both counters to play the same thing on both left and right pins

  'Set pins to output mode
  DIRA[PinR]~~                              'Set Right Pin to output
  DIRA[PinL]~~                              'Set Left Pin to output

  'Set up the counters
  CTRA:= %00110 << 26 + 0<<9 + PinR         'NCO/PWM Single-Ended APIN=Pin (BPIN=0 always 0)
  CTRB:= %00110 << 26 + 0<<9 + PinL         'NCO/PWM Single-Ended APIN=Pin (BPIN=0 always 0)   

  'Get ready for fast loop  
  n--
  i:=0
  j:=true
  NextCnt:=cnt+1005000

    'Play loop
    'This loop updates the counter with the new desired output level
    'Alternates between buff1 and buff2 so main program can keep buffers full
    repeat 
      repeat i from 0 to buffSize-1
        NextCnt+=5000   ' need this to be 5000 for 16KSPS   @ 80 MHz
        waitcnt(NextCnt)
        if (j)
          FRQA:=buff1[i]~
          FRQB:=FRQA
        else
          FRQA:=buff2[i]~
          FRQB:=FRQA  
      NOT j
       
 

{{
                            TERMS OF USE: MIT License

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
}}

