'' =================================================================================================
''
''   File....... jm_freqin.spin
''   Purpose.... 
''   Author..... Jon "JonnyMac" McPhalen (aka Jon Williams)
''               Copyright (c) 2009 Jon McPhalen
''               -- see below for terms of use
''   E-mail..... jon@jonmcphalen.com
''   Started.... 09 JUL 2009 
''   Updated.... 10 JUL 2009
''
'' =================================================================================================

{{

  This object uses ctra and ctrb of its own cog to measure the period of an intput waveform.
  The period is measured in clock ticks; this value can be divided into the Propeller clock
  frequecy to determine the frequency of the input waveform.  In application the period is
  divided into 10x the clock frequency to increase the resolution to 0.1Hz; this is espeically
  helpful for low frequencies.  Estimated range is 0.5Hz to ~40MHz (using 80MHz clkfreq).

  The counters are setup such that ctra measures the high phase of the input and ctrb measures
  low phase.  Measuring each phase independently allows the input waveform to be asymmetric.

  In order to prevent a loss of signal from causing an eroneous value from the .freq() method
  the fcCyles value is cleared after a valid frequency is calculated; this means that you
  should not call this method at a rate faster than the expected input frequency.  

}}


var

  long  cog

  long  fcPin                                                   ' frequency counter pin
  long  fcCycles                                                ' frequency counter cycles


pub init(p) : okay

'' Start frequency counter on pin p
'' -- valid input pins are 0..27

  if p < 28                                                     ' protect rx, tx, i2c
    fcPin := p
    fcCycles := 0
    okay := cog := cognew(@frcntr, @fcPin) + 1
  else
    okay := false


pub cleanup

'' Stop frequency counter cog if running

  if cog
    cogstop(cog~ - 1)


pub period

'' Returns period of input waveform

  return fcCycles 
  

pub freq | p, f

'' Converts input period to frequency
'' -- returns frequency in 0.1Hz units (1Hz = 10 units)
'' -- should not be called faster than expected minimum input frequency

  p := period
  if p
    f := clkfreq * 10 / p                                       ' calculate frequency
    fcCycles := 0                                               ' clear for loss of input
  else
    f := 0

  return f
    

dat

                        org     0

frcntr                  mov     tmp1, par                       ' start of structure
                        rdlong  tmp2, tmp1                      ' get pin#

                        mov     ctra, POS_DETECT                ' ctra measures high phase
                        add     ctra, tmp2
                        mov     frqa, #1
                        
                        mov     ctrb, NEG_DETECT                ' ctrb measures low phase
                        add     ctrb, tmp2
                        mov     frqb, #1
                        
                        mov     mask, #1                        ' create pin mask
                        shl     mask, tmp2
                        andn    dira, mask                      ' input in this cog

                        add     tmp1, #4
                        mov     cyclepntr, tmp1                 ' save address of hub storage

restart                 waitpne mask, mask                      ' wait for 0 phase
                        mov     phsa, #0                        ' clear high phase counter
       
highphase               waitpeq mask, mask                      ' wait for pin == 1
                        mov     phsb, #0                        ' clear low phase counter
                                                
lowphase                waitpne mask, mask                      ' wait for pin == 0
                        mov     cycles, phsa                    ' capture high phase cycles

endcycle                waitpeq mask, mask                      ' let low phase finish
                        add     cycles, phsb                    ' add low phase cycles
                        wrlong  cycles, cyclepntr               ' update hub

                        jmp     #restart

' --------------------------------------------------------------------------------------------------

POS_DETECT              long    %01000 << 26 
NEG_DETECT              long    %01100 << 26

tmp1                    res     1
tmp2                    res     1

mask                    res     1                               ' mask for frequency input pin
cyclepntr               res     1                               ' hub address of cycle count
cycles                  res     1                               ' cycles in input period

                        fit     492
                        

dat

{{

  Copyright (c) 2009 Jon McPhalen (aka Jon Williams)

  Permission is hereby granted, free of charge, to any person obtaining a copy of this
  software and associated documentation files (the "Software"), to deal in the Software
  without restriction, including without limitation the rights to use, copy, modify,
  merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to the following
  conditions:

  The above copyright notice and this permission notice shall be included in all copies
  or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
  PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
  OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 

}}                   