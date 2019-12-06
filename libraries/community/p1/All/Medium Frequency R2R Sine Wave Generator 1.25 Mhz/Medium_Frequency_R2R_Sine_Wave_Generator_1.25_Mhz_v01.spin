' Medium Frequency R2R Sine Wave Generator 1.25MHz - v0.1 using PASM
' (c) Tubular Controls June 2011.  MIT license, see end of DAT section
'
' DESCRIPTION:
'   This object generates a Medium Frequency Sine Wave using a "DDS precalculation" technique.
'   The cosine wave has N=16 steps, each step takes 4CLK for a max sine output of 1.25MHz@80MHz (1.56MHz@100MHz CLK)

'   This technique can easily be adapted for other values of N => 3, including odd values.
'   N=8 should still give a reasonably good sine wave at up to 3MHz (using 100MHz clock) 

'   The secret is to offset the steps by half a step in the time domain,
'     eg for N=16, don't use 0,22.5,45 degrees but 11.25, 33.75, 56.25 degrees etc
'   such that two successive samples near the peak have the same output value.
'   Then instead of outputting the second identical sample, JMP to the start of the loop and repeat.
'   The JMP and Output (MOV OUTA, SampleValue) both use 4 CLKs.

' CIRCUIT:
'   Bourns 4614X-R2R-103 - 10k/20k, 14 pin, 12 resistor network on P0...P11. 
'   P0 is LSB, P11 is MSB. Dot is output end, other end to Vss. 
'   Note: Suspect this would be more robust (better sine waves) with a network with lower R than 10k tested here.   

CON
  _clkmode      = xtal1 + pll16x                'use crystal x 16
  _xinfreq      = 5_000_000                     'external xtal is 5 MHz

PUB Main
  cognew(@cogstart, 0)                          'start a PASM cog

DAT
cogstart        MOV     DIRA,  #511             'make lower 9 bits an output (P0..8)
                MOVD    DIRA,  #7               'and next 3 bits also an output (12b total for Bourns 4612X-R2R-103)
loop            MOV     OUTA,  sample1          'output first value of cosine on pins P0..11
                MOV     OUTA,  sample2
                MOV     OUTA,  sample3
                MOV     OUTA,  sample4
                MOV     OUTA,  sample5
                MOV     OUTA,  sample6
                MOV     OUTA,  sample7          
                MOV     OUTA,  sample8
                MOV     OUTA,  sample9
                MOV     OUTA,  sample10
                MOV     OUTA,  sample11
                MOV     OUTA,  sample12
                MOV     OUTA,  sample13
                MOV     OUTA,  sample14
                MOV     OUTA,  sample15         '... output 15th value of cosine
                JMP     #loop                   'during the jump hold same value (effectively a sample16=sample15=4057
                                                'Total loop uses 64 clocks (1.25 MHz sine @ 80 MHz)

'**** Precalculated sine wave data for 12 bit R2R ladder, eg Bourns 4614X-R2R-103
sample1         LONG    3751                    '=2048+2048*cos(33.75 degrees)
sample2         LONG    3186                    '=2048+2048*cos(56.25 degrees)
sample3         LONG    2448                    '=2048+2048*cos(78.75 ... every 360/16=22.5 degrees apart
sample4         LONG    1648
sample5         LONG    910 
sample6         LONG    345
sample7         LONG    39                      'samples 7 and 8 (at trough of cosine) are identical if N even 
sample8         LONG    39
sample9         LONG    345 
sample10        LONG    910
sample11        LONG    1648
sample12        LONG    2448
sample13        LONG    3186
sample14        LONG    3751
sample15        LONG    4057                    '=2048+2048*cos(348.75 degrees)
' phantom s16           4057                    is held while jumping. S15(@348.75degrees) and S16(@11.25degrees)
'                                    are identical always, since they are equidistant from the peak of cosine at 0 degrees             '


{
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
}