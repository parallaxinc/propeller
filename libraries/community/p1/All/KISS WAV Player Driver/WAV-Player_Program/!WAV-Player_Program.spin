{{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// WAV-Player Program
//
// Author: Kwabena W. Agyeman
// Updated: 7/20/2011
// Designed For: P8X32A
// Version: 1.2
//
// Copyright (c) 2011 Kwabena W. Agyeman
// See end of file for terms of use.
//
// Update History:
//
// v1.0 - Original release - 7/6/2011.
// v1.1 - Tested with updated driver - 7/18/2011.
// v1.2 - Added support for dither mode - 7/20/2011.
//
// Plays a WAV file over and over again at different sample rates. The WAV file is specified by its file path name string that
// can be found in the code below. The WAV-Player program can play any standard WAV file. E.g. 16/8-Bit 16000/22050/44100-Hz.
//
// Nyamekye,
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}}

CON

  _clkmode = xtal1 + pll16x ' The clkfreq is 80MHz.
  _xinfreq = 5_000_000 ' Demo board compatible.

  _dopin = 0
  _clkpin = 1
  _dipin = 2
  _cspin = 3
  _cdpin = 4 ' -1 if unused.
  _wppin = 5 ' -1 if unused.

  _rtcres1 = -1 ' -1 always.
  _rtcres2 = -1 ' -1 always.
  _rtcres3 = -1 ' -1 always.

  _lpin = 11 ' -1 if unused.
  _rpin = 10 ' -1 if unused.

  _volume = 10 ' Default volume.

  _ditherEnable = true ' "true" or "false" please.
  _ditherLevel = 4 ' 0 = Most Dither ... 31 = Least Dither.
  
OBJ dac: "WAV-Player_DACEngine.spin"

VAR long spinPlayerStack[100]

PUB demo

  dac.FATEngineStart(_dopin, _clkpin, _dipin, _cspin, _wppin, _cdpin, _rtcres1, _rtcres2, _rtcres3)
  dac.DACEngineStart(constant(_lpin | (not(not(_ditherEnable)))), constant(_rpin | (not(not(_ditherEnable)))), _volume)

  ' Above Never fail - no need to check return value.    
  
  if(_ditherEnable)
    dac.DACDitherEngineStart(_lpin, _rpin, _ditherLevel) ' Never fails - no need to check return value.
  
  cognew(spinPlayer, @spinPlayerStack) ' Startup separate process.

  repeat ' Repeat forever.
    repeat until(dac.wavePlayerState) ' Wait until start.
    
    repeat until(dac.fileSamplePosition > (dac.fileSampleNumber / 3)) ' Wait until 1/3rds in.
    dac.fileSampleRateSetup((dac.fileSampleRate * 4) / 3) ' Sample rate set to 4/3rds the original.

    repeat until(dac.fileSamplePosition > ((dac.fileSampleNumber / 3) * 2)) ' Wait until 2/3rds in.
    dac.fileSampleRateSetup((dac.fileSampleRate * 3) / 4) ' Sample rate set to 3/4ths the original.

    repeat while(dac.wavePlayerState) ' Wait until stop. 

PUB spinPlayer ' Plays a WAV file over and over again.

  repeat ' Forever
    dac.playWAVFile(string("WAV.wav")) ' Supports WAV files up to ~2GB.

{{

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                  TERMS OF USE: MIT License
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
// Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}}