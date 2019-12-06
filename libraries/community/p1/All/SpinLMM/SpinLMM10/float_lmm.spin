'***************************************************************************************
' float_lmm
' Copyright (c) 2010 Dave Hein
' July 6, 2010
' See end of file for terms of use
'***************************************************************************************
' This program implements the basic floating point functions using SpinLMM.
' I was derived from the "Floating Point" object found in the OBEX.
'***************************************************************************************
OBJ
  lmm : "SpinLMM"

CON
  reg0       = lmm#reg0
  lmm_pc     = lmm#lmm_pc
  lmm_ret    = lmm#lmm_ret
  lmm_loop   = lmm#lmm_loop
  FJMP       = lmm#FJMP
  FCALL      = lmm#FCALL
  FRETX      = lmm#FRETX
  FCACHE     = lmm#FCACHE
  cache_addr = lmm#cache_addr
  dcurr      = lmm#dcurr

'-------------------- local variables -----------------------------------------
  t1         = lmm#reg1                                 ' temporary values
  t2         = lmm#reg2
  t4         = lmm#reg3

  fnumA      = lmm#reg16                                ' floating point A value
  flagA      = lmm#reg17
  expA       = lmm#reg18
  manA       = lmm#reg19

  fnumB      = lmm#reg20                                ' floating point B value
  flagB      = lmm#reg21
  expB       = lmm#reg22
  manB       = lmm#reg23

CON
  SignFlag      = $1
  ZeroFlag      = $2
  NaNFlag       = $8

PUB FAdd(a, b)
  result := lmm.run2(@_FAdd, a, b)

PUB FSub(a, b)
  result := lmm.run2(@_FSub, a, b)

PUB FMul(a, b)
  result := lmm.run2(@_FMul, a, b)

PUB FDiv(a, b)
  result := lmm.run2(@_FDiv, a, b)

PUB FFloat(a)
  result := lmm.run1(@_FFloat, a)

PUB FTrunc(a)
  result := lmm.run1(@_FTrunc, a)

PUB FRound(a)
  result := lmm.run1(@_FRound, a)

DAT
                        org     0

_Pop1                  sub      dcurr, #4
                       rdlong   fnumA, dcurr
                       mov      lmm_pc, lmm_ret

_Pop2                  sub      dcurr, #4
                       rdlong   fnumA, dcurr
                       sub      dcurr, #4
                       rdlong   fnumB, dcurr
                       mov      lmm_pc, lmm_ret

'------------------------------------------------------------------------------
' _FAdd    fnumA = fnumA + fNumB
' _FSub    fnumA = fnumA - fNumB
' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB, t1
'------------------------------------------------------------------------------

_FSub                   mov     t1, #1                  ' get $80000000
                        shl     t1, #31
                        add     lmm_pc, #4              ' skip next instruction
_FAdd                   mov     t1, #0
                        jmp     #FCALL                  ' get two parameters
                        long    @@@_Pop2
                        xor     fnumB, t1               ' negate B if FSub
                        jmp     #FCALL                  ' unpack two variables
                        long    @@@_Unpack2
          if_c_or_z     jmp     #FJMP                   ' check for NaN or B = 0
                        long    @@@_FAdd_ret

                        test    flagA, #SignFlag wz     ' negate A mantissa if negative
          if_nz         neg     manA, manA
                        test    flagB, #SignFlag wz     ' negate B mantissa if negative
          if_nz         neg     manB, manB

                        mov     t1, expA                ' align mantissas
                        sub     t1, expB
                        abs     t1, t1
                        max     t1, #31
                        cmps    expA, expB wz,wc
          if_nz_and_nc  sar     manB, t1
          if_nz_and_c   sar     manA, t1
          if_nz_and_c   mov     expA, expB        

                        add     manA, manB              ' add the two mantissas
                        cmps    manA, #0 wc, nr         ' set sign of result
          if_c          or      flagA, #SignFlag
          if_nc         andn    flagA, #SignFlag
                        abs     manA, manA              ' pack result and exit
                        jmp     #FCALL
                        long    @@@_Pack
_FAdd_ret               mov     reg0, fnumA
                        jmp     #FRETX

'------------------------------------------------------------------------------
' _FMul    fnumA = fnumA * fNumB
' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB, t1, t2
'------------------------------------------------------------------------------

_FMul                   jmp     #FCALL
                        long    @@@_Pop2
                        jmp     #FCALL                  ' unpack two variables
                        long    @@@_Unpack2
          if_c          jmp     #FJMP                   ' check for NaN
                        long    @@@_FMul_ret

                        xor     flagA, flagB            ' get sign of result
                        add     expA, expB              ' add exponents
                        mov     t1, #0                  ' t2 = upper 32 bits of manB
                        mov     t2, #32                 ' loop counter for multiply
                        shr     manB, #1 wc             ' get initial multiplier bit 
                        jmp     #FCACHE
                        org     cache_addr
multiply  if_c          add     t1, manA wc             ' 32x32 bit multiply
                        rcr     t1, #1 wc
                        rcr     manB, #1 wc
                        djnz    t2, #multiply
                        jmp     #lmm_loop
                        long    0

                        shl     t1, #3                  ' justify result and exit
                        mov     manA, t1
                        jmp     #FCALL
                        long    @@@_Pack
_FMul_ret               mov     reg0, fnumA
                        jmp     #FRETX

'------------------------------------------------------------------------------
' _FDiv    fnumA = fnumA / fNumB
' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB, t1, t2
'------------------------------------------------------------------------------

_FDiv                   jmp     #FCALL
                        long    @@@_Pop2
                        jmp     #FCALL                  ' unpack two variables
                        long    @@@_Unpack2
                        mov     t1, #1                   ' generate NaN
                        shl     t1, #31
                        sub     t1, #1
          if_c_or_z     mov     fnumA, t1               ' check for NaN or divide by 0
          if_c_or_z     jmp     #FJMP
                        long    @@@_FDiv_ret
        
                        xor     flagA, flagB            ' get sign of result
                        sub     expA, expB              ' subtract exponents
                        mov     t1, #0                  ' clear quotient
                        mov     t2, #30                 ' loop counter for divide

                        jmp     #FCACHE
                        org     cache_addr
divide                  shl     t1, #1                  ' divide the mantissas
                        cmps    manA, manB wz,wc
          if_z_or_nc    sub     manA, manB
          if_z_or_nc    add     t1, #1
                        shl     manA, #1
                        djnz    t2, #divide
                        jmp     #lmm_loop
                        long    0

                        mov     manA, t1                ' get result and exit
                        jmp     #FCALL
                        long    @@@_Pack
_FDiv_ret               mov     reg0, fnumA
                        jmp     #FRETX

'------------------------------------------------------------------------------
' _FFloat  fnumA = float(fnumA)
' changes: fnumA, flagA, expA, manA
'------------------------------------------------------------------------------

_FFloat                 jmp     #FCALL                  ' get one parameter
                        long    @@@_Pop1
                        mov     flagA, fnumA            ' get integer value
                        mov     fnumA, #0               ' set initial result to zero
                        abs     manA, flagA wz          ' get absolute value of integer
          if_z          jmp     #FRETX                  ' if zero, exit
                        shr     flagA, #31              ' set sign flag
                        mov     expA, #31               ' set initial value for exponent
normalize               shl     manA, #1 wc             ' normalize the mantissa
          if_nc         sub     expA, #1                ' adjust exponent
          if_nc         sub     lmm_pc, #12
                        rcr     manA, #1                ' justify mantissa
                        shr     manA, #2
                        jmp     #FCALL                  ' pack and exit
                        long    @@@_Pack
                        mov     reg0, fnumA
                        jmp     #FRETX

'------------------------------------------------------------------------------
' _FTrunc  fnumA = fix(fnumA)
' _FRound  fnumA = fix(round(fnumA))
' changes: fnumA, flagA, expA, manA, t1 
'------------------------------------------------------------------------------

_FTrunc                 mov     t1, #0                  ' set for no rounding
                        add     lmm_pc, #4              ' skip next instruction
_FRound                 mov     t1, #1                  ' set for rounding
                        jmp     #FCALL                  ' get one parameter
                        long    @@@_Pop1
                        jmp     #FCALL                  ' unpack floating point value
                        long    @@@_Unpack
          if_c          jmp     #FJMP                  ' check for NaN
                        long    @@@_FRound_ret
                        shl     manA, #2                ' left justify mantissa 
                        mov     fnumA, #0               ' initialize result to zero
                        neg     expA, expA              ' adjust for exponent value
                        add     expA, #30 wz
                        cmps    expA, #32 wc
          if_nc_or_z    jmp     #FJMP
                        long    @@@_FRound_ret
                        shr     manA, expA
                        add     manA, t1                ' round up 1/2 lsb
                        shr     manA, #1
                        test    flagA, #signFlag wz     ' check sign and exit
                        sumnz   fnumA, manA
_FRound_ret             mov     reg0, fnumA
                        jmp     #FRETX
                                  
'------------------------------------------------------------------------------
' input:   fnumA        32-bit floating point value
'          fnumB        32-bit floating point value 
' output:  flagA        fnumA flag bits (Nan, Infinity, Zero, Sign)
'          expA         fnumA exponent (no bias)
'          manA         fnumA mantissa (aligned to bit 29)
'          flagB        fnumB flag bits (Nan, Infinity, Zero, Sign)
'          expB         fnumB exponent (no bias)
'          manB         fnumB mantissa (aligned to bit 29)
'          C flag       set if fnumA or fnumB is NaN
'          Z flag       set if fnumB is zero
' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB, t1, t2
'------------------------------------------------------------------------------

_Unpack2                mov     t2, lmm_ret             ' Save the return address
                        mov     t1, fnumA               ' save A
                        mov     fnumA, fnumB            ' unpack B to A
                        jmp     #FCALL
                        long    @@@_Unpack
          if_c          jmp     #FJMP                   ' check for NaN
                        long    @@@_Unpack2_ret

                        mov     fnumB, fnumA            ' save B variables
                        mov     flagB, flagA
                        mov     expB, expA
                        mov     manB, manA

                        mov     fnumA, t1               ' unpack A
                        jmp     #FCALL
                        long    @@@_Unpack
                        cmp     manB, #0 wz             ' set Z flag
_Unpack2_ret            mov     lmm_pc, t2

'------------------------------------------------------------------------------
' input:   fnumA        32-bit floating point value 
' output:  flagA        fnumA flag bits (Nan, Infinity, Zero, Sign)
'          expA         fnumA exponent (no bias)
'          manA         fnumA mantissa (aligned to bit 29)
'          C flag       set if fnumA is NaN
'          Z flag       set if fnumA is zero
' changes: fnumA, flagA, expA, manA, t4
'------------------------------------------------------------------------------

_Unpack                 mov     flagA, fnumA            ' get sign
                        shr     flagA, #31
                        mov     manA, fnumA             ' get mantissa
                        mov     t4, #1
                        shl     t4, #23
                        sub     t4, #1
                        and     manA, t4                ' Mask23
                        mov     t4, #1
                        shl     t4, #29                 ' Bit29
                        mov     expA, fnumA             ' get exponent
                        shl     expA, #1
                        shr     expA, #24 wz
          if_z          jmp     #FJMP                   ' check for zero or subnormal
                        long    @@@zeroSubnormal
                        cmp     expA, #255 wz           ' check if finite
          if_nz         jmp     #FJMP
                        long    @@@finite
                        mov     fnumA, #1               ' no, then return NaN
                        shl     fnumA, #31
                        sub     fnumA, #1
                        mov     flagA, #NaNFlag
                        jmp     #FJMP
                        long    @@@exit2

zeroSubnormal           or      manA, expA wz,nr        ' check for zero
          if_nz         jmp     #FJMP
                        long    @@@subnorm
                        or      flagA, #ZeroFlag        ' yes, then set zero flag
                        neg     expA, #150              ' set exponent and exit
                        jmp     #FJMP
                        long    @@@exit2
                                 
subnorm                 shl     manA, #7                ' fix justification for subnormals
subnorm2                test    manA, t4 wz
          if_nz         jmp     #FJMP
                        long    @@@exit4
                        shl     manA, #1
                        sub     expA, #1
                        jmp     #FJMP
                        long    @@@subnorm2

finite                  shl     manA, #6                ' justify mantissa to bit 29
                        or      manA, t4                ' add leading one bit
                        
exit4                   sub     expA, #127              ' remove bias from exponent
exit2                   test    flagA, #NaNFlag wc      ' set C flag
                        cmp     manA, #0 wz             ' set Z flag
                        mov     lmm_pc, lmm_ret

'------------------------------------------------------------------------------
' input:   flagA        fnumA flag bits (Nan, Infinity, Zero, Sign)
'          expA         fnumA exponent (no bias)
'          manA         fnumA mantissa (aligned to bit 29)
' output:  fnumA        32-bit floating point value
' changes: fnumA, flagA, expA, manA, t4
'------------------------------------------------------------------------------

_Pack                   cmp     manA, #0 wz             ' check for zero                                        
          if_z          mov     expA, #0
          if_z          jmp     #FJMP
                        long    @@@exit3

                        neg     t4, #23                 ' Minus23
normalize1              shl     manA, #1 wc             ' normalize the mantissa
          if_nc         sub     expA, #1                ' adjust exponent
          if_nc         sub     lmm_pc, #12
                      
                        add     expA, #2                ' adjust exponent
                        add     manA, #$100 wc          ' round up by 1/2 lsb
          if_c          add     expA, #1

                        add     expA, #127              ' add bias to exponent
                        mins    expA, t4
                        maxs    expA, #255
 
                        cmps    expA, #1 wc             ' check for subnormals
          if_nc         jmp     #FJMP
                        long    @@@exit3

':subnormal
                        or      manA, #1                ' adjust mantissa
                        ror     manA, #1

                        neg     expA, expA
                        shr     manA, expA
                        mov     expA, #0                ' biased exponent = 0

exit3                   mov     fnumA, manA             ' bits 22:0 mantissa
                        shr     fnumA, #9
                        movi    fnumA, expA             ' bits 23:30 exponent
                        shl     flagA, #31
                        or      fnumA, flagA            ' bit 31 sign
                        mov     lmm_pc, lmm_ret

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
