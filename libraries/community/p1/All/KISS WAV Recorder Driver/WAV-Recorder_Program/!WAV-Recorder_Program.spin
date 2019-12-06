{{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// WAV-Recorder Program
//
// Author: Kwabena W. Agyeman
// Updated: 7/11/2011
// Designed For: P8X32A
// Version: 1.0
//
// Copyright (c) 2011 Kwabena W. Agyeman
// See end of file for terms of use.
//
// Update History:
//
// v1.0 - Original release - 7/11/2011.
//
// Records a WAV file from a sigma-delta ADC at any sample rate. The WAV file is specified by its file path name string that
// can be found in the code below. The WAV recorder must actually finish recording the WAV file before power is toggled or the
// SD/MMC card is removed - otherwise file corruption will occur and the WAV file will be unreadable. To stop the recording
// process toggle the "stop pin" in the CON section below and the "stop light" in the CON section below will light indicating
// that the recorder has stopped and that it is now safe to remove the SD/MMC card and to play the WAV file back. The default
// setup uses the serial terminal to stop the recording process. Send any stream of characters to stop the recorder.
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
  _cdpin = -1 ' -1 if unused.
  _wppin = -1 ' -1 if unused.

  _rtcres1 = -1 ' -1 always.
  _rtcres2 = -1 ' -1 always.
  _rtcres3 = -1 ' -1 always.

  _inpin = 8 ' Sigma delta ADC in pin.    
  _feedbackpin = 9 ' Sigma delta ADC out pin.

  _rate = 22_050 ' Default sample rate.

  _stoplight = 23 ' Lights when WAV recorder is stopped or not recording.  
  _stoppin = 31 ' Toggle to stop WAV recorder.

OBJ 

  adc: "WAV-Recorder_ADCEngine.spin"
  fat: "SD-MMC_FATEngine.spin"

VAR long spinRecorderStack[100]

PUB demo

  adc.FATEngineStart(_dopin, _clkpin, _dipin, _cspin, _wppin, _cdpin, _rtcres1, _rtcres2, _rtcres3)
  adc.ADCEngineStart(_inpin, _feedbackpin, _rate) ' Never fails - no need to check return value.

  cognew(spinRecorder, @spinRecorderStack) ' Startup separate process.

  waitcnt(clkfreq + cnt) ' Wait a bit.

  result := ina[_stoppin] ' Wait until pin is toggled.

  repeat until(result <> ina[_stoppin])

  adc.stopRecordingWAVFile ' Stop WAV recorder.

PUB spinRecorder ' Records a WAV file over and over again. You must delete the old file for the new one to be recorded.

  adc.startRecordingWAVFile(string("FOLDER/WAV.WAV"))

  outa[_stoplight] := dira[_stoplight] := true

  repeat ' Keep alive to keep light alive.

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