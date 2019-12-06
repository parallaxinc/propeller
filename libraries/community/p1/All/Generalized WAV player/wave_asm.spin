'  10-bit PCM driver, plays from mono and stereo, 8 and 16-bit PCM buffers.
'  Copyright 2009 David Sloan  
'  See end of file for terms of use.

con
  waitload = 8_000
var
  byte cog      
  byte Rpin, Lpin
  byte Mode
  byte chans      
  long position
  long fpos
  long storefpos
  long samplePer
  long passPars[7]
  long bufLen        

pub start(RightPin, LeftPin, BufferPointer, BufferLength)
  if (running == 1)
    cogstop(cog)
  Rpin := RightPin
  Lpin := Leftpin    
  position := -1
  bufLen := fpos := BufferLength  
     
  passpars[0] := @Rpin
  passpars[1] := @chans
  passpars[2] := @Mode
  passpars[3] := BufferPointer
  passpars[4] := @position
  passpars[5] := @fpos
  passpars[6] := @samplePer
  cog := cognew(@bufferedAudio, @passpars)
  waitcnt(cnt + waitload)
  if (position == -1)
    abort(-1)
  running := 1
  fpos := 0

pub play
  position := 0
  position := 0
  paused := 0
  fpos := BufLen
   
pub waitBufFillBegining(timeout) | j, t
  j := bufLen/2
  t := timeout + cnt
  repeat while position < j
    if (t - cnt =< 0) and (timeout > 0)
      abort(-1)

pub waitBufFillEnd(timeout) | j, t
  j := bufLen/2
  t := timeout + cnt
  repeat while position => j
    if (t - cnt =< 0) and (timeout > 0)
      abort(-1)

pub setPins(RightPin, LeftPin)
  Rpin := RightPin
  Lpin := LeftPin

pub setSampleWidth(sampleWidth)
  Mode := sampleWidth

pub setChannels(Channels)
  chans := channels

pub setSamplePeriod(SamplePeriod)
  samplePer := SamplePeriod

pub RightP
  return Rpin

pub LeftP
  return Lpin

pub SampWidth
  return Mode

pub NumChans
  return chans

pub SampPeriod
  return samplePer

pub stopWav(bufpos)
  if bufpos => bufLen
    bufpos := bufLen-1
  fpos := bufpos

pub stopPlayer
  if (running == 1)
    running := 0
    cogstop(cog)

pub ispaused
  return paused == 1

pub pause
  storefpos := fpos
  paused := 1
  fpos := 0

pub unpause
  paused := 0
  fpos := storefpos

  
DAT
org 0
              'retrieve parameters
bufferedAudio mov       tP1, par
              rdlong    tP2, tP1
              add       tP1, #4
              rdbyte    pinR, tP2
              add       tP2, #1
              rdbyte    pinL, tP2
              rdlong    pChan, tP1
              add       tP1, #4
              rdlong    pMode, tP1
              add       tP1, #4
              rdlong    pbuff, tP1   
              add       tP1, #4
              rdlong    Ppos, tP1      
              add       tP1, #4
              rdlong    Pfpos, tP1 
              rdlong    buffLen, Pfpos 
              add       tP1, #4
              rdlong    pSampP, tP1  

              'set up pins
              mov       tVal, #1
              shl       tVal, pinR
              or        dira, tVal
              mov       tVal, #1
              shl       tVal, pinL
              or        dira, tVal

              
              'set ctr state
              mov       ctra, ctrval
              movs      ctra, pinR
              mov       frqa, #1       'set counter to increment 1 each cycle
              mov       ctrb, ctrval
              movs      ctrb, pinL
              mov       frqb, #1
              
              'set up wait
              mov       time, cnt      'record current time
              add       time, period   'establish next period
              mov       lsamp, cnt     'establish last sample change

              'signal done loading
              mov       Cpos, #0
              wrlong    Cpos, Ppos

              'main loop
loop          'get mode (sample width)
              rdbyte    vMode, pMode
              cmp       vMode, b8               wz,wc
        if_be mov       inc, #1
        if_a  mov       inc, #2
              'get number of channels
              rdbyte    vChan, pChan
              mov       tP1, vChan
              mov       tval, #0
incLoop       add       tval, inc
              sub       tP1, #1                 wz,wc
        if_a  jmp       #incLoop
              mov       inc, tval
              'get finalPosition
              rdlong    vfpos, pfpos   
              'get sample period
              rdlong    vsampP, pSampP
              'get current position
              rdlong    Cpos, Ppos
              'check for period passing
              mov       tval, cnt
              sub       tval, lsamp
              cmp       tval, vsampP            wz,wc
                        '-increment current position
        if_b  jmp       #samePer
              mov       lsamp, cnt   
              cmp       Cpos, vfpos             wz,wc
        if_ae jmp       #samePer
        'if_ae call      #clear_buffer
              add       Cpos, inc  
              mov       tval, bufflen
              sub       tval, inc
              cmp       Cpos, tval              wz,wc
        if_a  mov       Cpos, #0
                        'write current position
              wrlong    Cpos, Ppos 
samePer       'get bytes from buffer
              cmp       vMode, b8               wz,wc
              mov       tP1, pbuff
              add       tP1, Cpos
              rdbyte    pinR, tP1
        if_a  add       tP1, #1
        if_a  rdbyte    tval, tP1
        if_a  shl       tval, #8
        if_a  add       pinR, tval
              mov       tP2, tP1
              add       tP2, #1
        if_a  sub       tP1, #1
              cmp       vChan, #1               wz,wc
        if_a  mov       tP1, tP2               
              rdbyte    pinL, tP1
              cmp       vMode, b8               wz,wc 
        if_a  add       tP1, #1
        if_a  rdbyte    tval, tP1
        if_a  shl       tval, #8
        if_a  add       pinL, tval 
              'adjust to output
        if_be shl       pinR, #2
        if_be shl       pinL, #2
        
        if_a  shl       pinR, #16
        if_a  sub       pinR, maxneg
        if_a  shr       pinR, #22
        if_a  shl       pinL, #16
        if_a  sub       pinL, maxneg
        if_a  shr       pinL, #22
        
nxt           waitcnt   time, period     'wait until next period
              'Set next duty cycle
              neg       phsa, pinR  
              neg       phsb, pinL  
              jmp       #loop            'loop for next cycle

clear_buffer
              mov       temp, Pbuff
              mov       templen, Pbuff
              add       templen, bufflen
cntnu         wrlong    zero, temp
              add       temp, #4
              cmp       temp, bufflen           wc, wr
        if_b  jmp       #cntnu
                   

clear_buffer_ret        ret

'Initialized Values      
ctrval        long %00100 << 26 + 0  
period        long 1024               '~78kHz period (_clkfreq / period)  
Cpos          long 0
maxNeg        long $80_00_00_00
b8            long 8
b16           long 16
zero          long 0

'Non-initialized Values
temp          res 1
templen
time          res 1
nextSP        res 1
tP1           res 1
tP2           res 1
tVal          res 1
pinR          res 1
pinL          res 1
pChan         res 1
vChan         res 1
Pbuff         res 1
Ppos          res 1  
Pfpos         res 1
Vfpos         res 1
pMode         res 1
vMode         res 1
pSampP        res 1
vsampP        res 1
lsamp         res 1
buffLen       res 1
inc           res 1

running       byte      0
paused        byte      0

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