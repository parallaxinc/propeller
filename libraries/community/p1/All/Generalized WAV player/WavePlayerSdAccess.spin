'  10-bit WAV Player V4.1, plays mono and stereo, 8 and 16-bit PCM WAV files
'  from SD card and alows for general sd access while not playing.
'  Copyright 2009 David Sloan  
'  See end of file for terms of use.

' V4.1
' fixed issue with driver continuing to run through buffer after wave had finished
obj                        
  sd  : "fsrw"
  wbuf: "wave_asm"
  wdec: "wav_decoder"

var    
  long pBuffer
  long BufferLen
  long pStack
  byte backCog

pub start(sdPin, RightPin, LeftPin, BufferAddress, BufferLength)
  sd.mount(sdPin)
  pBuffer := BufferAddress
  BufferLen := BufferLength
  wbuf.start(RightPin, LeftPin, BufferAddress, BufferLength)
  pStack := -1
  backCog := 9

pub setStack(StackAddress)
  'nessesary for using background methods (stack lengths of 50 longs have worked in trials)
  pStack := StackAddress

pub pflush
  if (active == 3)
    abort(@ERROR_WAV_Playing)
  return sd.pflush

pub pclose
  if (active == 3)
    abort(@ERROR_WAV_Playing)
  active := 0
  return sd.pclose

pub popen(s, mode) 
  if (active == 3)
    abort(@ERROR_WAV_Playing)
  if (mode == "r")
    active := 1
  elseif (mode == "w" or mode == "a")
    active := 2
  else
    active := 0
  return sd.popen(s,mode)

pub pread(ubuf, count)       
  readfunc
  return sd.pread(ubuf, count)
  
pub pgetc
  readfunc
  return sd.pgetc
  
pub pwrite(ubuf, count)
  writefunc
  return sd.pwrite(ubuf, count)
  
pub pputc(c)
  writefunc
  return sd.pputc(c)
  
Pub SDStr(ptr)
  writefunc
  sd.SDStr(ptr)
  
PUB SDdec(value)
  writefunc
  sd.SDdec(value)
  
PUB SDhex(value, digits)
  writefunc
  sd.SDhex(value, digits)
  
PUB SDbin(value, digits)
  writefunc
  sd.SDbin(value, digits)
  
pub opendir    
  return sd.opendir
  
pub nextfile(fbuf)
  return sd.nextfile(fbuf)

pub playWave(s) | i
  if (active == 3)
    abort(@ERROR_WAV_Playing)
  active := 3
  
  i := sd.popen(s, "r")
  if (i == -1)  
    sd.pclose
    active := 0
    abort(@ERROR_NO_WAV)

  openwav 

  i := wdec.DataLen
  sd.pread(pBuffer, minimum(i, bufferLen))
  i -= bufferLen
  wbuf.play         
  repeat while i > 0
    wbuf.waitBufFillBegining(0) 
    sd.pread(pBuffer, minimum(bufferLen/2,i))
    i -= bufferLen/2
    if i < 0
      i -= bufferLen/2
      next
    wbuf.waitBufFillEnd(0)
    sd.pread(PBuffer + bufferLen/2, minimum(bufferLen/2,i))
    i -= bufferLen/2
  i := BufferLen - 1 + i
  if (i < bufferLen/2)
    wbuf.waitBufFillEnd(0)
  wbuf.stopWav(i) 
  
  sd.pclose
  active := 0
  backCog := 9

pub playbgWave(s)
  if (pStack == -1)
    abort(@ERROR_NO_Stack)
  if (active == 3)
    abort(@ERROR_WAV_Playing) 
  backCog := cognew(playwave(s), pStack)

pub togglebgPause
'will pause main function if called by second proc
  if (wbuf.ispaused)
    wbuf.unpause
  else
    wbuf.pause

pub stopbgWave
  wbuf.stopWav(0)
  if (backCog <> 9)
    cogstop(backCog)
    sd.pclose
    active := 0

pub bgisPlaying
  return backCog <> 9

pri readfunc  
  if (active == 3)
    abort(@ERROR_WAV_Playing)
  elseif (active == 2)
    abort(@ERROR_F_Write)
  elseif (active == 0)
    abort(@ERROR_Open_F)

pri writefunc              
  if (active == 3)
    abort(@ERROR_WAV_Playing)
  elseif (active == 1)
    abort(@ERROR_F_Read)
  elseif (active == 0)
    abort(@ERROR_Open_F)
  
pri minimum(i,j)
  if (i<j)
    return i
  else
    return j

pri openwav | i
  wdec.new
  i := wdec.requestlength
  repeat while i <> 0
    if (sd.pread(pBuffer, i) =< 0)
      sd.pclose
      abort(@ERROR_eoWAV)
    wdec.bytesin(pBuffer)
    i := wdec.requestLength
    
  if (wdec.WavFormat <> wdec.FORMAT_PCM) 
    sd.pclose
    abort(@ERROR_Format) 
  wbuf.setChannels(wdec.Channels)
  wbuf.setsamplePeriod(clkfreq / wdec.SampleRate)
  if wdec.BitsPerSample < 9
    wbuf.setSampleWidth(8)
  else
    wbuf.setSampleWidth(16)
dat

active                  byte    0       '0-inactive, 1-read, 2-write, 3-wav
ERROR_WAV_Playing       byte    "Wave currently playing",0
ERROR_NO_WAV            byte    "Wave file does not exist",0
ERROR_Format            byte    "Unrecognized wave format",0
ERROR_eoWAV             byte    "End of wav reached or read error",0
ERROR_NO_Stack          byte    "No stack initialized",0
ERROR_F_Write           byte    "File open for writing",0
ERROR_F_Read            byte    "File open for reading",0
ERROR_Open_F            byte    "No open file",0

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