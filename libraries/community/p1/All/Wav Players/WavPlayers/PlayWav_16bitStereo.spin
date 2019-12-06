'  ASM WAV Player Ver. 1b  (Plays only stereo, 16-bit PCM WAV files from SD card)
'  Copyright 2007 Raymond Allen  See end of file for terms of use.  
'  Settings for Demo Board Audio Output:  Right Pin# = 10, Left Pin# = 11   , VGA base=Pin16, TV base=Pin12
'  Rev.B:  21Dec07 Fixed pin assignment bug.  



CON _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000       '80 MHz

    buffSize = 100

VAR long parameter1  'to pass @buff1 to ASM
    long parameter2  'to pass @buff2 to ASM
    long parameter3  'to pass sample rate to ASM
    long parameter4  'to pass #samples to ASM
    long buff1[buffSize]
    long buff2[buffSize]
    byte Header[44]
    
OBJ
    SD  : "FSRW"
    text : "vga_text"    'For NTSC TV Video: Comment out this line...
    'text : "tv_text"    'and un-comment this line  (need to change pin parameter for text.start(pin) command below too).

PUB Main|n,i,j, SampleRate,Samples
  'Play a WAV File
  'Start up the status display...
  text.start(16)    'Start the VGA/TV text driver (uses another cog)
                    'The parameter (16) is the base pin used by demo and proto boards for VGA output
                    'Change (16) to (12) when using "tv_text" driver with demo board as it uses pin#12 for video                    
  text.str(STRING("Starting Up",13))

  'open the WAV file  (NOTE:  Only plays stereo, 16-bit PCM WAV Files !!!!!!!!!!!!!)
  'access SD card 
  i:=sd.mount(0)
  if (i<>0)
    repeat

  text.str(STRING("SD Card Mounted",13))     

  'open file
  'i:=sd.popen(string("test6.wav"), "r")                '   <---------  Change .wav filename here !!!!!!!!!!!!!!         
  i:=sd.popen(string("test7.wav"), "r")                '   <---------  Change .wav filename here !!!!!!!!!!!!!!
  if (i<>0)
    repeat

  'ignoring much file header (so you better have the format right!)    stereo, 16-bit PCM WAV Files !!!!!!!!!!!!!!!!
  'See here for header format:  http://ccrma.stanford.edu/CCRMA/Courses/422/projects/WaveFormat/
  i:=sd.pread(@Header, 44) 'read data words to input stereo buffer
  'Get sample rate from header
  SampleRate:=Header[27]<<24+Header[26]<<16+Header[25]<<8+Header[24]
  text.dec(SampleRate)
  text.out(13)
  'get # samples from header
  Samples:=Header[43]<<24+Header[42]<<16+Header[41]<<8+Header[40]
  Samples:=Samples>>2
  text.dec(Samples)
  text.out(13)
    

  'Start ASM player in a new cog
  text.str(STRING("Running ASM Player",13))    
  parameter1:=@buff1[0]
  parameter2:=@buff2[0]
  parameter3:=CLKFREQ/SampleRate  '#clocks between samples'1814'for 44100ksps,  5000 'for 16ksps
  parameter4:=Samples
  COGNEW(@ASMWAV,@parameter1)
 
  'Keep filling buffers until end of file
  ' note:  using alternating buffers to keep data always at the ready...
  n:=buffSize-1
  j:=buffsize*4   'number of bytes to read
  repeat while (j==buffsize*4)  'repeat until end of file
    if (buff1[n]==0)
      j:=sd.pread(@buff1, buffSize*4) 'read data words to input stereo buffer   

    if (buff2[n]==0)
      j:=sd.pread(@buff2, buffSize*4) 'read data words to input stereo buffer  

  'must have reached the end of the file, so close it
  sd.pclose

  repeat
  'shut down here

 
DAT
  ORG 0
ASMWAV
'load input parameters from hub to cog given address in par
        movd    :par,#pData1             
        mov     x,par
        mov     y,#4  'input 4 parameters
:par    rdlong  0,x
        add     :par,dlsb
        add     x,#4
        djnz    y,#:par

setup
        'setup output pins
        MOV DMaskR,#1
        ROL DMaskR,OPinR
        OR DIRA, DMaskR
        MOV DMaskL,#1
        ROL DMaskL,OPinL
        OR DIRA, DMaskL
        'setup counters
        OR CountModeR,OPinR
        MOV CTRA,CountModeR
        OR CountModeL,OPinL
        MOV CTRB,CountModeL
        'Wait for SPIN to fill table
        MOV WaitCount, CNT
        ADD WaitCount,BigWait
        WAITCNT WaitCount,#0
        'setup loop table
        MOV LoopCount,SizeBuff  
        'ROR LoopCount,#1    'for stereo
        MOV pData,pData1
        MOV nTable,#1
        'setup loop counter
        MOV WaitCount, CNT
        ADD WaitCount,dRate


MainLoop
        SUB nSamples,#1
        CMP nSamples,#0 wz
        IF_Z JMP #Done
        waitcnt WaitCount,dRate

        RDLONG Right,pData
        ADD Right,twos      'Going to cheat a bit with the LSBs here...  Probably shoud fix this!    
        MOV FRQA,Right
        ROL Right,#16       '16 LSBs are left channel...
        MOV FRQB,Right
        WRLONG Zero,pData
        ADD pData,#4

        'loop
        DJNZ LoopCount,#MainLoop
        
        MOV LoopCount,SizeBuff        
        'switch table       ?
        CMP nTable,#1 wz
        IF_Z JMP #SwitchToTable2
SwitchToTable1
        MOV nTable,#1
        MOV pData,pData1
        JMP #MainLoop
SwitchToTable2
        MOV nTable,#2
        MOV pData,pData2
        JMP #MainLoop
        
                
Done
         'now stop
        COGID thisCog
        COGSTOP thisCog          

'Working variables
thisCog long 0
x       long 0
y       long 0
dlsb    long    1 << 9
BigWait long 100000
twos    long $8000_8000
        
'Loop parameters
nTable  long 0
WaitCount long 0
pData   long 0
LoopCount long 0
SizeBuff long buffsize
'Left    long 0
Right   long 0
Zero    long 0          

'setup parameters
DMaskR  long 0 'right output mask
OPinR   long 10 'right channel output pin #                        '   <---------  Change Right pin# here !!!!!!!!!!!!!!    
DMaskL  long 0 'left output mask 
OPinL   long 11 'left channel output pin #                         '   <---------  Change Left pin# here !!!!!!!!!!!!!!    
CountModeR long %00011000_00000000_00000000_00000000
CountModeL long %00011000_00000000_00000000_00000000


'input parameters
pData1   long 0 'Address of first data table        
pData2   long 0 'Address of second data table
dRate    long 5000  'clocks between samples
nSamples long 2000


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