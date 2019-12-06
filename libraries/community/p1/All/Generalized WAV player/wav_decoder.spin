'  Wave Decoder V1.1
'  Object used for retreiving data from wav files 
'  Copyright 2009 David Sloan  
'  See end of file for terms of use.

con
   WAVE_FORMAT_PCM = $0001
   WAVE_FORMAT_IEEE_FLOAT = $0003
   WAVE_FORMAT_ALAW = $0006
   WAVE_FORMAT_MULAW = $0007
   WAVE_FORMAT_EXTENSIBLE = $fffe
   
var
  byte RIFF_Tag[4]
  long RIFF_Size
  
  byte WAV_ID[4]
  byte WAV_ckid[4]
  long WAV_cksize
  word WAV_FormatTag
  word WAV_nChannels
  long WAV_nSampPerSec
  long WAV_nAvgBytesPerSec
  word WAV_nBlockAlign
  word WAV_wBitsPerSample

  byte DATA_Tag[4]
  long DATA_size

pub new
  pos := 0
  datfound := -1

pub bytesin(Pbt) | i
  if (pos == 0 and datfound == -1)
    cpBytes(@RIFF_Tag, pbt, 4)     
    if (!strncmp(@RIFF_Tag, @ckid_RIFF, 4))
      abort(@ERROR_BadRIFF)
    RIFF_Size := getLong(pbt+4)

    cpBytes(@WAV_ID, pbt+8, 4)       
    if (!strncmp(@WAV_ID, @ckid_WAVE, 4))
      abort(@ERROR_BadWAVE)            
    cpBytes(@WAV_ckid, pbt+12, 4)
    if (!strncmp(@WAV_ckid, @ckid_fmt, 4))
      abort(@ERROR_Badfmt)
    WAV_cksize := getLong(pbt+16)                                                 
    pos := requestlength
    
  elseif (pos == 20 and datfound == -1)
    WAV_FormatTag := getWord(pbt)
    if (WAV_FormatTag <> WAVE_FORMAT_PCM and WAV_FormatTag <> WAVE_FORMAT_IEEE_FLOAT and WAV_FormatTag <> WAVE_FORMAT_ALAW and WAV_FormatTag <> WAVE_FORMAT_MULAW and WAV_FormatTag <> WAVE_FORMAT_EXTENSIBLE)
      abort(@ERROR_unrecognizedFormat)
    WAV_nChannels := getWord(pbt+2)
    WAV_nSampPerSec :=  getLong(pbt+4)
    WAV_nAvgBytesPerSec := getLong(pbt+8)
    WAV_nBlockAlign := getWord(pbt+12)
    WAV_wBitsPerSample := getWord(pbt+14)
    pos += requestlength
    
  elseif (pos > 20 and datfound => -1)
    cpBytes(@DATA_Tag, pbt, 4)    
    DATA_size := getLong(pbt+4)
    if (strncmp(@DATA_Tag, @ckid_data, 4))
      datfound := -2
      pos := 0
    else
      datfound := DATA_Size
    
pub requestlength
if (pos == 0 and datfound == -1)
  return 20
elseif (pos == 20 and datfound == -1)
  return WAV_cksize
elseif (pos > 20 and datfound == -1)
  return 8
elseif (datfound => 0)
  return datfound
else
  return 0

pub WavFormat
  return WAV_FormatTag

pub Channels
  return WAV_nChannels

pub SampleRate
  return WAV_nSampPerSec

pub BitsPerSample
  return WAV_wBitsPerSample

pub DataLen
  return DATA_size

pub FORMAT_PCM
  return WAVE_FORMAT_PCM
pub FORMAT_IEEE_FLOAT
  return WAVE_FORMAT_IEEE_FLOAT
pub FORMAT_ALAW
  return WAVE_FORMAT_ALAW
pub FORMAT_MULAW
  return WAVE_FORMAT_MULAW
pub FORMAT_EXTENSIBLE
  return WAVE_FORMAT_EXTENSIBLE 

pri strncmp(s1,s2,maxLen) | i
  i := 0
  repeat while i < maxLen
    if byte[s1 + i] == 0 or byte[s2 + i] == 0
      return true
    if byte[s1 + i] <> byte[s2 + i]
      return false
    i += 1
  return true

pri getWord(pt)
  return byte[pt] + byte[pt+1]<<8

pri getLong(pt)
  return byte[pt] + byte[pt+1]<<8 + byte[pt+2]<<16 + byte[pt+3]<<24

pri cpBytes(tofill, pfrom, len)|i
  repeat i from 0 to len - 1
    byte[tofill + i] := byte[pfrom + i]
   
dat

pos                             long            0
datfound                        long            -1
ERROR_BadRIFF                   byte            "Bad RIFF Header",0
ERROR_BadWAVE                   byte            "Bad WAVE Header",0
ERROR_Badfmt                    byte            "fmt not found in WAVE chunk",0
ERROR_unrecognizedFormat        byte            "Unrecognized WAVE Format",0

ckid_RIFF                       byte            "RIFF",0
ckid_WAVE                       byte            "WAVE",0
ckid_fmt                        byte            "fmt ",0
ckid_data                       byte            "data",0

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