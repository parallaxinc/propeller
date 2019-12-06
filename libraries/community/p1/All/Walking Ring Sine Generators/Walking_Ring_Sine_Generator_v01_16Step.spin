' "WALKING RING" Low Distortion Sine Wave Output - v0.1 using Spin
' (c) Tubular Controls June 2011.  MIT license, see end of DAT section
'
' DESCRIPTION:
'   This object uses Spin to produce a low distortion 2.33 kHz (@80Mhz) sine wave using pins P8..P14.
'   This walking ring has 8 stages, 7 outputs, and is clocked in 16 steps per 2.33kHz cycle
'   (The 8th output is not used so the sine 'dwells' at its peak and trough) 
'   Using ideal resistors, the first harmonics present are 15th (-24dB), 17th (-25dB), 31st(-30dB), 33rd(-30dB)...
'   This technique could be extended to use Video Generator's WAITVID for much higher Sine frequencies (1.2kHz..5MHz at 80Mhz clock)
'
' REFERENCE: CMOS Cookbook, by Don Lancaster.  May also be in the TTL Cookbook by same author.  
'
' CIRCUIT:
'   Each output pin P8..P14 connects to one end of a resistor.
'   The other end of all 7 resistors are joined together (sine output node).
'   Add a capacitor 10~20nF to ground for optional lowpass filtering.
'      P8 - 39kohm - sine output node.    Waveform: __~~~~~~~~______   (LSB)     ideal factor: 2.613xR
'      P9 - 36kohm - sine output node.    Waveform: ___~~~~~~~~_____             ideal factor: 2.414xR
'     P10 - 27kohm - sine output node.    Waveform: ____~~~~~~~~____             ideal factor: 1.848xR
'     P11 - 15kohm - sine output node.    Waveform: _____~~~~~~~~___             ideal factor: 1.000xR
'     P12 - 27kohm - sine output node.    Waveform: ______~~~~~~~~__             ideal factor: 1.848xR
'     P13 - 36kohm - sine output node.    Waveform: _______~~~~~~~~_             ideal factor: 2.414xR
'     P14 - 39kohm - sine output node.    Waveform: ________~~~~~~~~   (MSB)     ideal factor: 2.613xR

CON
  _clkmode      = xtal1 + pll16x                       ' use crystal x 16
  _xinfreq      = 5_000_000                            ' external xtal is 5 MHz

VAR
  byte Index                                           ' index counter tracks through 16 steps
             
PUB Main
  dira[14..8]~~                                         'reserve 7 pins as output                    
  repeat
    repeat Index from 0 to 15
      outa[14..8] := Buffer2[Index]

DAT
  Buffer2     byte      0,0,1,3,7,15,31,63,127,127,126,124,120,112,96,64


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