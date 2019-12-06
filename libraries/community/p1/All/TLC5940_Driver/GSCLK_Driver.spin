''**************************************
''
''  GSCLK Driver Ver. 00.1
''
''  Timothy D. Swieter, E.I.
''  www.brilldea.com
''
''  Copyright (c) 2008 Timothy D. Swieter, E.I.
''  See end of file for terms of use. 
''
''  Updated: May 17, 2008
''
''Description:
''This program runs in its own cog and handles
''the GSCLK and the BLANK outputs for the TLC5940.
''GSCLK counts to 4095 and then rests.  There is also
''options for holding the lights off (blank high) and
''for pausing the GSCLK.
''
''reference:
''      tlc5940.pdf (Datasheet for chip)
''      Parallax Forums (discussion regarding TLC5940)
''
''TO DO:
''      add control interface for pausing the count
''      add control interface to force blank high
''
''Revision Notes:
'' 0.1 Initial release
'' --- Update object to include MIT License
''     Made the document prettier and added comments
''
''**************************************
CON
'***************************************

'***************************************
'  System Definitions      
'***************************************

  _OUTPUT       = 1             'Sets pin to output in DIRA register
  _INPUT        = 0             'Sets pin to input in DIRA register  
  _HIGH         = 1             'High=ON=1=3.3v DC
  _ON           = 1
  _LOW          = 0             'Low=OFF=0=0v DC
  _OFF          = 0
  _ENABLE       = 1             'Enable (turn on) function/mode
  _DISABLE      = 0             'Disable (turn off) function/mode

'***************************************
VAR               'Variables to be located here
'***************************************

  'Processor
  long cog                      'Cog flag/ID

  'Data for assembly program
  long GSCLKpin                 'pin of the clock function
  long BLANKpin                 'pin of the blank function

'***************************************
PUB start(_gsclk, _blank) : okay
'***************************************
'' Start GSCLK driver - setup I/O pins, initiate variables, starts a cog
'' returns cog ID (1-8) if good or 0 if no good

  'Qualify that the pins
  if lookdown(_gsclk: 31..0)
    if lookdown(_blank: 31..0)

      'Assign the I/O passed over
      GSCLKpin := _gsclk
      BLANKpin := _blank

      'Start a cog with assembly routine
      okay:= cog:= cognew(@Entry, @GSCLKpin) + 1        'Returns 0-8 depending on success/failure

'***************************************
PUB Stop
'***************************************
'' Stops GSCLK driver - frees a cog

  if cog                                                'Is cog non-zero?
    cogstop(cog~ - 1)                                   'Yes, stop the cog and then make value zero

'***************************************
DAT
'***************************************
' Assembly language GSCLK Driver
'
        org
'
'Start of routine
Entry         mov t0, par                       'Load address of parameter list into t1 (par contains address)

              rdlong gspin, t0                  'Read value of GSCLKpin into gspin
              mov gsmask, #1                    'Load mask with a 1        
              shl gsmask, gspin                 'Create mask for the proper I/O pin by shifting

              add t0, #4                        'Increament address pointer by four bytes
              rdlong blpin, t0                  'Read value of BLANKpin into blmask
              mov blmask, #1                    'Load mask with a 1        
              shl blmask, blpin                 'Create mask for the proper I/O pin by shifting

              mov t1, #0
              or t1, gsmask                     'Create a composite mask for both pins
              or t1, blmask                     '
              mov dira, t1                      'Set gspin & blpin to output

:Loop         mov t1, count                     'Load up the counter

:Toggle       mov outa, gsmask                  'Set the gspin high 
              mov outa, #0                      'Set the gspin low
              djnz t1, #:Toggle                 'Toggle the pin again, if counter is not expired

              mov outa, blmask                  'Set the blpin high
              mov outa, #0                      'Set the blpin low
              jmp #:Loop                        'Do it all again - over and over

'Initialized Data
count         long 4095                         '12 bit PWM counting

'Uninitialized Data
t0            res 1                             'temp0
t1            res 1                             'temp1
gspin         res 1                             'pin number for gsclk
blpin         res 1                             'pin number for blank
gsmask        res 1                             'mask for gsclk I/O pin
blmask        res 1                             'mask for blank I/O pin

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
