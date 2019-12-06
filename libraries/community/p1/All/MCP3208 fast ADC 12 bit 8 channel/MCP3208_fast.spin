''MCP3208_fast.spin
''
''Copyright (c) 2007 Jim Kuhlman
''
'' See end of file for terms of use.
''
''*****************************************************
''*  MCP3208 12-bit/8-channel ADC Driver              *
''*  Works w/indiv channel on chip rather than all 8  *
''*  Provides single sample or average of n samples   *
''*  Provides single mode only, no differential mode  *
''*  Does not provide DAC output like original code   *
''*****************************************************

'' rev 1.0   09-16-07 Fixed bug in start routine for delay value.

CON
  #1, _setup, _single, _average, _delay, _div, _adcready
     ' cmds for assy routine: 1=setup, 2=single adc sample, 3=average of n adc samples, etc.

VAR

  long  cog, delay

  long  cmd, chnl, nsamples, data[4]          '7 longs (3 longs, 8 words)

PUB start(dpin, cpin, spin, mode) : okay

'' Start driver - starts a cog
'' returns false if no cog available
'' may be called again to change settings
''
''   dpin  = pin connected to both DIN and DOUT on MCP3208
''   cpin  = pin connected to CLK on MCP3208
''   spin  = pin connected to CS  on MCP3208
''   mode not used, included for compatability with older program

  stop                          ' stop cog if running from before
  
  cmd := 0                      ' tell adc_read to wait for next command
  cog := cognew(@adc_read, @cmd) + 1  ' store adc_read and shared mem address
  waitcnt(clkfreq/4 + cnt)      'wait 1/4 sec for cog to start

  chnl := dpin                  ' initialize for call to _setup
  nsamples := cpin
  data[0] := spin
  data[1] := 0
  
  do_cmd(_setup, @chnl)         ' initialize assy routine for dpin, cpin and spin pins on MCP3208

  if clkfreq => 80_000_000      ' make it work for prop2 also
    delay := clkfreq/2_000_000  ' time delay for half cycle of 50KHz sample rate
  else                          ' set for 1MHz clock rate to chip
    delay := 40                 ' if clkfreq < 80,000,000 then set to 40
    
  do_cmd(_delay, @delay)        ' pass time delay parameter to assy routine

  return cog


PUB stop

'' Stop driver - frees a cog

  if cog
    cogstop(cog~ - 1)

    
PUB in(channel)

'' Read the current sample from an ADC channel (0..7)

  chnl := channel

  do_cmd(_single, @chnl)        ' get single sample from channel

  return data.word[channel]


PUB average(channel, n)

'' Average n samples from an ADC channel (0..7), n <= 16

  chnl := channel               ' set channel number in xfr array

  nsamples := n <# 16           ' limit # of samples to 16 max
  nsamples #>= 1                ' must be greater than zero
  
  do_cmd(_average, @chnl)       ' get average of n samples from specified channel

  return data.word[channel]

PUB div(divisor, dividend) : quotient

'' Divide 16 bit dividend (in long)
'' by 16 bit divisor (in long)
'' Return 16 bit quotient (in long)

  chnl := divisor
  nsamples := dividend

  do_cmd(_div, @chnl)

  quotient := nsamples

  
PRI do_cmd(adc_command, argptr)

  cmd := adc_command << 16 + argptr                 'write command and pointer to shared memory loc
  repeat while cmd                                  'wait for command to be cleared, signifying completion

  
DAT
''
''************************************
''* Assembly language MCP3208 driver *
''************************************

                        org
'************************************
adc_read                rdlong  t1,par          wz      ' wait for command
        if_z            jmp     #adc_read

                        movd    :arg,#arg0              
                        mov     t2,t1
                        mov     t3,#4                   ' get 4 arguments
                        
:arg                    rdlong  arg0,t2                 ' store in arg0, arg1, arg2, arg3
                        add     :arg, hex200            ' update destination addr for next loop
                        add     t2,#4                   ' point to next input arg
                        djnz    t3,#:arg

                        ror     t1,#16+2                ' lookup command address
                        add     t1,#jmptable
                        movs    :tabloc,t1
                        rol     t1,#2
                        shl     t1,#3
:tabloc                 mov     t2,0
                        shr     t2,t1
                        and     t2,#$FF
                        jmp     t2                      ' jump to command

'************************************
jmptable                byte    0                       '0 not used
                        byte    setup_                  '1 setup adc routine
                        byte    single_                 '2 single adc value
                        byte    average_                '3 average adc values
                        byte    delay_                  '4 delay for adc clock
                        byte    div_                    '5 divide 16 x 16 bits
                        byte    adcready                '6 loop for next instruction

'************************************
setup_                  mov     t1, arg0
                        call    #param                  'setup DIN/DOUT pin
                        mov     dmask,t2

                        mov     t1, arg1
                        call    #param                  'setup CLK pin
                        mov     cmask,t2

                        mov     t1, arg2
                        call    #param                  'setup CS pin
                        mov     smask,t2
                        
                        jmp     #adcready

'************************************
param                   mov     t2,#1                   'make pin mask in t2
                        shl     t2,t1
param_ret               ret
                        
'************************************
delay_                  mov     t4, arg0                'set up delay time for chip clock
                        shr     t4, #3                  ' divide it by 8 clock cycles/ 2 instr
                        sub     t4, #4                  ' adj for 1/2 cycle
                        mov     delayval, t4            ' store in delayval for delay routines
                        jmp     #adcready
                        
'************************************
div_                    mov     t1, arg0                ' move divisor  to t1
                        mov     t2, arg1                ' move dividend to t2
                        
                        call    #divide
                        
                        mov     t3, par                 ' shared mem ref to t3
                        add     t3, #8                  ' point to output
                        wrlong  t2, t3                  ' write quotient to nsamples
                        jmp     #adcready
                        
'************************************
single_                 mov     arg1, #1                'initialize arg1, not supplied with single_ call

'************************************
average_                mov     t3, arg1                'set for n sample average (or 1 if single sample)
                        or      dira,cmask              'set CLK line to output
                        or      dira,smask              'set CS  line to output

                        mov     command,#$18            'init command to 011000, start/single
                        add     command, arg0           'add in channel number to command bits
                        
                        mov     t2, #0                  'initialize data[channel] accumulator
                        
:bloop                  mov     stream,command          'set up for new sample
                        or      outa,smask              ' CS high
                        or      dira,dmask              ' make DIN/DOUT output
                        andn    outa,cmask              ' CLK MUST be low before CS enabled!!!
                        andn    outa,smask              ' CS low
                        nop                             ' wait 8 clock cycles for TSUCS              
                        nop
                        
                        mov     bits,#5                 'ready 20 bits (cs+1+diff+ch[3]+0+0+data[12])
:cloop                  test    stream,#$10     wc      'update DIN/DOUT
                        muxc    outa,dmask
                        andn    outa,cmask              'CLK low
                        call    #delay1                 ' adjust clock cycle time                        
                        rcl     stream,#1               ' shift out next bit
                        or      outa,cmask              'CLK high                        
                        call    #delay2                 ' adjust clock cycle time                        
                        djnz    bits,#:cloop

                        andn    dira,dmask              ' make DIN/DOUT input to get data
                        mov     bits,#14                'get the data 2-null plus 12 data
:dloop                  andn    outa,cmask              'CLK low                        
                        call    #delay1                 ' adjust clock cycle time                        
                        or      outa,cmask              'CLK high
                        test    dmask,ina       wc      'sample DIN/DOUT
                        rcl     stream,#1               ' store bit for output         
                        call    #delay2                 ' adjust clock cycle time                        
                        djnz    bits, #:dloop           'next data bit

                        and     stream,mask12           'trim sample
                        add     t2, stream              'accumulate sum in t2
                        djnz    t3, #:bloop             'more samples for average?

                        cmp     arg1, #1        wz      ' see if n > 1
        if_nz           mov     t1, arg1                ' set up for divide if needed, arg1 = number of samples, n
        if_nz           call    #divide                 ' divide t2 by t1 or sum/n -> t2

                        mov     t3, arg0                'load channel number, 0..7
                        shl     t3, #1                  'mult by 2 for word offset in data[ ]
                        add     t3, #12                 'add 12 for 3 long offset (cmd + chnl + nsamples)
                        mov     t1,par                  'reset sample pointer
                        add     t1, t3                  'add offset, t1 now points to data[channel]
                        wrword  t2,t1                   'write sample to data[channel]
                                                        'fall through to adcready and exit
'************************************
adcready                wrlong  zero,par                'zero command to tell caller we're done
                        jmp     #adc_read               'back to wait for another command

'************************************
delay1                  mov     t4, delayval            ' load delayval, clock cycles
                        nop                             ' adj to half cycle
                        nop
:tloop1                 nop
                        djnz    t4, #:tloop1            ' delay 1/2 uSec = 1/2 MCP3208 clk cycle
delay1_ret              ret

'************************************
delay2                  mov     t4, delayval            ' load delayval, clock cycles
:tloop2                 nop
                        djnz    t4, #:tloop2            ' delay 1/2 uSec = 1/2 MCP3208 clk cycle
delay2_ret              ret

'************************************
' Divide
'   in:         t1 = 16-bit divisor  in long
'               t2 = 16-bit dividend in long

'   out:        t2 = 16-bit quotient (in long), truncated

'   temp:       t3 = loop counter

divide                  shl     t1,#15                  'get divisor into t1[30..15]
                        mov     t3,#16                  'loop counter for 16 bits
                        
:loop                   cmpsub  t2,t1 wc                'if t1 =< t2 subtract it, quotient bit -> c bit
                        rcl     t2,#1                   'rotate c into quotient and shift dividend
                        djnz    t3,#:loop               'loop until done
                        
                        and     t2, hexFFFF             'mask quotient, drop the remainder in [31..16]
divide_ret              ret                             

'************************************
' Initialized data
'
hex200                  long    $200                    'constants
hexFFFF                 long    $FFFF
mask12                  long    $FFF
zero                    long    0

'************************************
' Uninitialized data
'
arg0                    res     1                       ' arguments passed from high-level
arg1                    res     1
arg2                    res     1
arg3                    res     1

dmask                   res     1                       ' MCP3208 pin masks
cmask                   res     1
smask                   res     1

t1                      res     1                       ' temps
t2                      res     1
t3                      res     1
t4                      res     1

dx                      res     1                       ' for atn routine
dy                      res     1

command                 res     1                       ' for 3208 routine
stream                  res     1
bits                    res     1
delayval                res     1

{ Terms of use:

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

}

