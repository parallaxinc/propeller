CON
'***************************************
'  Hardware related settings
'***************************************
  _clkmode = xtal1 + pll16x                             'Use the PLL to multiple the external clock by 16
  _xinfreq = 5_000_000                                  'An external clock of 5MHz. is used (80MHz. operation)


'***************************************
'  I/O Definitions
'***************************************

  _gsclk     = 16             'gsclk
  _xlat      = 17             'xlat
  _blank     = 18             'blank
  _sin       = 19             'sin
  _sclk      = 20             'sclk
  _vprg      = 21             'vprg

'***************************************
'  Other Definitions
'***************************************
  _baseOffset = 0               'Number of TLC channels to skip, you probably want to leave this at zero.



OBJ

  TLC           : "TLC5940_Driver"


PUB MAIN | i

  TLC.Start(_sclk, _sin, _xlat, _gsclk, _blank, _vprg, _baseOffset)
  TLC.SetAllChannels(0)
  TLC.Update
  TLC.SetAllDC(63)

  'Walk through each channel
  repeat
    repeat i from 0 to 48
      TLC.SetChannel(i-1, 0)
      TLC.SetChannel(i, 4095)
      TLC.Update
      Pause(100)



PRI Pause(Duration)
'' Pause execution in milliseconds.
'' Duration = number of milliseconds to delay

  waitcnt(((clkfreq / 1_000 * Duration)) + cnt)

'*************************************** 
{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │ │                                                                                                                              │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}
