'' Copyright (c) 2008 Philip C. Pilgrim
'' (See end of file for terms of use.)
''
''-----------[ Description ]----------------------------------------------------
''
'' This Propeller object provides up to eight leading-edge-aligned PWM channels
'' with resolution determined by a defined constant. The maximum PWM frequency
'' is the lesser of:
''
''    clkfreq / (13.5 * resolution) and 20.648881 / resolution MHz
''
'' The minimum PWM frequency is :
'' 
''    clkfreq / (40000 * resolution)
''
'' PWM output is generated using the Propeller's video generator in VGA mode. The
'' eight or fewer channels can be any subset of the pins in one of four
'' contiguous blocks: A0-A7, A8-A15, A16-A23, or A24-A31.
''
''-----------[ History ]--------------------------------------------------------
''
'' Version 1.1: 17 Jul 08: Fixed a couple bugs related to base pins > 0.
'' Version 1.2: 20 Jan 10: Fixed a bug relating to duty modes of 256 (i.e. full on).
''
''-----------[ Program ]--------------------------------------------------------

CON

  resolution    = 256           'The number of steps in the pulse widths. Must be an integer multiple of 4.
  nlongs        = resolution / 4

VAR

  long  fcb[5]
  long  pwmdata[nlongs + 1]
  long  pinmask
  long  previndex[8]
  byte  cogno, basepin

'-----------[ Public Methods ]-------------------------------------------------

PUB start(base, mask, freq)

' This method is used to setup the PWM driver and start its cog. If a driver had
' already been started, it will be stopped first. The arguments are as follows:
'
'     base: The base pin of the PWM output block. Must be 0, 8, 16, or 24.
'
'     mask: The enable mask for the eight pins in the block:
'
'               bit 0 = basepin + 0
'               bit 1 = basepin + 1
'               ...
'               bit 7 = basepin + 7
'
'           Set a bit to 1 to enable the corresponding pin for PWM ouput.
'
'     freq: The frequency in Hz for the PWM output.
'
' Returns true on success; false, if no cog is available or parameters exceed
' permissible limits.    

  if (cogno)
    stop
  freq *= resolution
  if (clkfreq =< 4000000 or freq > 20648881 or clkfreq  < freq * 135 / 10 or clkfreq / freq > 40000 or base <> base & %11000 or mask <> mask & $ff or resolution <> resolution & $7ffffffc)
    return false
  basepin := base      
  pinmask := mask << base
  longfill(@pwmdata, 0, nlongs)
  longfill(@previndex, 0, 8)
  fcb[0] := nlongs
  fcb[1] := freq
  fcb[2] := constant(1 << 29 | 1 << 28) | base << 6 | mask
  fcb[3] := pinmask
  fcb[4] := @pwmdata
  if (cogno := cognew(@pwm, @fcb) + 1)
    return true
  else
    return false

PUB stop

' This method is used to stop an already-started PWM driver. It returns true if
' a driver was running; false, otherwise.

  if (cogno)
    cogstop(cogno - 1)
    cogno~
    return true
  else
    return false

PUB duty(pinno, value) | vindex, pindex, i, mask, unmask

' This method defines a pin's duty cycle. It's arguments are:
'
'     pinno: The pin number of the PWM output to modify.
'
'     value: The new duty cycle (0 = 0% to resolution = 100%)
'
' Returns true on success; false, if pinno or value is invalid.

  if (1 << pinno & pinmask == 0 or value < 0 or value > resolution)
    return false
  pinno -= basepin
  mask := $01010101 << pinno
  unmask := !mask
  vindex := value >> 2
  pindex := previndex[pinno]
  if (vindex > pindex)
    repeat i from pindex to vindex - 1
      pwmdata[i] |= mask
  elseif (vindex < pindex)
    repeat i from pindex to vindex + 1
      pwmdata[i] &= unmask
  pwmdata[vindex] := pwmdata[vindex] & unmask | mask & ($ffffffff >> (31 - ((value & 3) << 3)) >> 1)
  previndex[pinno] := vindex
  return true

DAT

' PWM driver loaded into a separate cog. Cycles continuously through PWM data in hub RAM,
' using the video driver to output logic levels.

'-----------[ Initialization ]-------------------------------------------------

              org       0
              
pwm           rdlong    clkfrq,#0               'Read the current clock frequency (Hz).
              mov       ptr0,par                'Get beginning address of fcb in ptr0.
              rdlong    longs,ptr0              'Get the number of longs in pwm array.
              add       ptr0,#4
              rdlong    pllfrqh,ptr0            'Read the desired output pll frequency (Hz).
              add       ptr0,#4                 'Increment fcb index.
              mov       pllfrql,pllfrqh         'Divide output pll freq by 16 to get input pll freq w/ no divider.
              shr       pllfrqh,#4              '  64-bit result.
              shl       pllfrql,#28
              mov       plldiv,#0               'Initialize frequency divider for no division.
              
:frqalp       cmp       pllfrqh,_4000000 wc     'Is input pll freq at least 4MHz?
        if_nc jmp       #gotpllinp              '  Yes: Use it.

              shl       pllfrql,#1 wc           '  No:  Input pll freq *= 2.
              rcl       pllfrqh,#1
              add       plldiv,#1               '       Divider *= 2 also to keep output the same.
              jmp       #:frqalp                '       Back for another try.
              
gotpllinp     mov       ra,pllfrqh              'frqa := input pll freq * 2^32 / clkfrq
              mov       rb,pllfrql
              mov       rx,clkfrq
              call      #divabx                 'rb := ra:rb / rx
              mov       frqa,rb                 'Save frqa.

              sub       plldiv,#7 wc,wz         'Can all the division be done in counter?
 if_nz_and_nc jmp       #:needvscl                            

              neg       plldiv,plldiv           '  Yes: Compute the divider value.
              jmp       #:gotdiv

:needvscl     shl       vscl0,plldiv            '  No:  Shift VSCL value left by divider amount.
              mov       plldiv,#0               '       Set CTRA for maximum divider.
                            
:gotdiv       mov       vscl,vscl0              'Write computed value to VSCL.
              shl       plldiv,#23              'Position it for CTRA.
              or        plldiv,ctra0            'OR in the rest.
              mov       ctra,plldiv             'Write CTRA.
              rdlong    vcfg,ptr0               'Get VCFG from fcb.
              add       ptr0,#4
              rdlong    dira,ptr0               'Get DIRA from fcb.
              add       ptr0,#4
              rdlong    ptr0,ptr0               'Get address of pwmdata array in ptr0.

'-----------[ Main PWM Loop ]--------------------------------------------------

pwmlp         mov       ptr,ptr0                ' 4   Point back to beginning of pwmdata.
              mov       ctr,longs               ' 4   Initialize counter with no. of longs.
              
:nyblp        rdlong    pwmbits,ptr             '22   Read four "pixels" form pwmdata.
              add       ptr,#4                  ' 4   Point to next four.              
              waitvid   pwmbits,#%11_10_01_00   ' 6   Wait and "display".
              djnz      ctr,#:nyblp             ' 8   Back for next "pixel".
                            
              jmp       #pwmlp                  ' 4   Back for first "pixel".
                                                '---
                                                '52 clocks worst case, or 1.538 MHz through loop w/ 80 MHz clock.

'-----------[ Divide 64 / 32 = 32 ]--------------------------------------------

divabx        mov       cctr,#32 wc
:loop         rcl       rb,#1 wc
              rcl       ra,#1 wc
        if_c  sub       ra,rx
       if_nc  cmpsub    ra,rx wc
              djnz      cctr,#:loop
              rcl       rb,#1 wc
divabx_ret    ret

'-----------[ Predefined variables and constants ]-----------------------------

vscl0         long      1 << 12 | 4             'Initial VSCL w/ no division.
ctra0         long      %00001 << 26            'Initial CTRA w/ no PLL.
pwmbits       long      0                       '
_4000000      long      4000000                 'Minimum PLL input frequency.

'-----------[ Variables ]------------------------------------------------------

ptr0          res       1
ptr           res       1
ctr           res       1
ra            res       1
rb            res       1
rx            res       1
cctr          res       1
clkfrq        res       1
pllfrqh       res       1
pllfrql       res       1
plldiv        res       1
longs         res       1

''-----------[ TERMS OF USE ]---------------------------------------------------
''
'' Permission is hereby granted, free of charge, to any person obtaining a copy of
'' this software and associated documentation files (the "Software"), to deal in
'' the Software without restriction, including without limitation the rights to use,
'' copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
'' Software, and to permit persons to whom the Software is furnished to do so,
'' subject to the following conditions: 
''
'' The above copyright notice and this permission notice shall be included in all
'' copies or substantial portions of the Software. 
''
'' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
'' INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
'' PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
'' HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
'' OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
'' SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.