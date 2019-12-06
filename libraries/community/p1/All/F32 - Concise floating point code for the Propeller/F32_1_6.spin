{{
        F32 - Concise floating point code for the Propeller

        Copyright (c) 2011 Jonathan "lonesock" Dummer

        Released under the MIT License (see the end of this file for details)      

        +--------------------------------------------------------------------------+
        | IEEE 754 compliant 32-bit floating point math routines for the Propeller |
        | Based on Float32 & Float32Full v1.5, by Cam Thompson                     |
        | Modified by Jonathan (lonesock) to try to fit all functionality into     |
        |              a single cog, and speed-up the routines where possible.     |
        +--------------------------------------------------------------------------+

        Features:

        * prop resources:       1 cog, 690 longs        (BST can remove unused Spin code, and the odds are
                                                        good that you won't need all the functionality [8^)

        * faster:               _Pack, Add, Sub, Sqr, Sin, Cos, Tan, Float, Exp*, Log*, Pow, Mul, Div

        * added funcs:          Exp2, Log2 (Spin calling code only, no cog bloat),
                                FMod, ATan, ATan2, ACos, ASin, Floor, Ceil (from Float32A),
                                FloatTrunc, FloatRound, UintTrunc (added code to the cog)

        * more accurate:        ATan, ATan2, ACos, ASin (now use CORDIC routines instead of a 5th
                                                        order polynomial approximation with sqrts)

        Still Needed / Desired:
        * MORE TESTING!! (hint hint [8^)
        * User-defined function mechanism (from Float32A)...does anyone use this?

        Ver          Date       Change Log:
        1.6     April 22, 2013  - working on the ATan2 code for the bug Duane Degn found (thanks!)
        1.5     April 27, 2012  - optimizations as suggested by kuroneko...THANKS!
                                   * "jmp label_ret" is faster than "jmp #label_ret", but only works for ret.
                                   * faster FCmp
                                - fixed offset table bug (Thanks ???)
        1.4     Jan  31, 2012   - fixed bug in LOG due to _Table_Interp not handling table address overflow. 0 longs free [8^(  {mods by Marty Lawson...THANKS!}
        1.3a    Aug   3, 2011   - added 'atof' - uses loops instead of Exp10 (which uses the log table in ROM, so can get errors there)
        1.3     Apr  28, 2011   - fixed a bug in FRound (max set's C is D<S...I wanted D<=S!  THANKS John Abshier!!)
        1.2a    Dec  15, 2010   - found that "repeat <newline> while x" is faster than "repeat while x" on a single line (smaller too!)
        1.2     Nov  27, 2010   - added dispatch table constants, and the Cmd_ptr & Call_ptr functions
        1.0     Nov  19, 2010   - adding comments, adjusted call method (sorry heater!)
        0.9     Sept 29, 2010   - fixed some comments, added UintTrunc, only 4 longs free [8^(
        0.8     Sept 28, 2010   - added FloatTrunc & FloatRound, converted to all ASCII with CRLF end of line.
        0.7     Sept 27, 2010   - faster interpolation, CORDIC faster (uses full table), Tan faster (reuses some cals from Sin in Cos) - 26 longs free
        0.6     Sept 24, 2010   - fixed the trig functions (had a bug in my table interpolation code)
        0.5     Sept 21, 2010   - faster multiply and divide - 26 longs free
        0.4     Sept 20, 2010   - added in all the functionality from Float32Full - 14 longs free
        0.3     Sept 15, 2010   - fixed race condition on startup, 111 longs free
        0.2     Sept 14, 2010   - fixed Exp*, sped up Exp*, Log*, Pow, Cos and Sin again
        0.1     Sept 13, 2010 PM- fixed Trunc and Round to now do the right thing for large integers. 83 longs available
        0.0     Sept 13, 2010 AM- new calling convention. 71 longs available in-Cog

USAGE:
  * call start first (starts a new cog)
  * use functions as expected
  * realize that you are storing the result into a regular long variable type (signed 4-byte integer), _encoded_as_a_float_!

Notes to self:
  * CORDIC using floats would be very slow
  * integer-only CORDIC isn't super accurate for tiny integers
    - not pre-rounding before performing bit shifts
    - SAR is used to handle negative numbers, but -1 >> 10 still = -1, instad of 0
  * for small values of x, sin(x) ~= x, and cos(x) = 1.
  * if x <= 0.0002, the approximations' error is < f32 resolution!

}}

CON
  ' the list of all the PASM functions' offsets in the dispatch table
  ' You probably only need this table can be used to call F32 routines from inside your own PASM code
  offAdd        = offGain * 0
  offSub        = offGain * 1
  offMul        = offGain * 2
  offDiv        = offGain * 3
  offFloat      = offGain * 4
  offTruncRound = offGain * 5
  offUintTrunc  = offGain * 6
  offSqr        = offGain * 7
  offCmp        = offGain * 8
  offSin        = offGain * 9
  offCos        = offGain * 10
  offTan        = offGain * 11
  offLog2       = offGain * 12
  offExp2       = offGain * 13
  offPow        = offGain * 14
  offFrac       = offGain * 15
  offMod        = offGain * 16
  offASinCos    = offGain * 17
  offATan2      = offGain * 18
  offCeil       = offGain * 19
  offFloor      = offGain * 20
  ' each entry is a long...4 bytes
  offGain       = 4
  
VAR

  long  f32_Cmd
  byte  cog
  
PUB start
{{
  Start start floating point engine in a new cog.
  Returns:     True (non-zero) if cog started, or False (0) if no cog is available.
}}
  stop
  f32_Cmd := 0
  return cog := cognew(@f32_entry, @f32_Cmd) + 1

PUB stop
{{
  Stop floating point engine and release the cog.
}}
  if cog
    cogstop(cog~ - 1)

PUB Cmd_ptr
{{
  return the Hub address of f32_Cmd, so other code can call F32 functions directly
}}
  return @f32_Cmd

PUB Call_ptr
{{
  return the Hub address of the dispatch table, so other code can call F32 functions directly
}}
  return @cmdCallTable

PUB atof( strptr ) : f | int, sign, dmag, mag, get_exp, b
  ' get all the digits as if this is an integer (but track the exponent)
  ' int := sign := dmag := mag := get_exp := 0
  longfill( @int, 0, 5 )
  repeat
    case b := byte[strptr++]
      "-": sign := $8000_0000
      "+": ' just ignore, but allow
      "0".."9":
           int := int*10 + b - "0"
           mag += dmag
      ".": dmag := -1
      other: ' either done, or about to do exponent
           if get_exp
             ' we just finished processing the exponent
             if sign
               int := -int
             mag += int
             quit
           else
             ' convert int to a (signed) float
             f := FFloat( int ) | sign
             ' should we continue?
             if (b == "E") or (b == "e")
               ' int := sign := dmag := 0
               longfill( @int, 0, 3 )
               get_exp := 1
             else
               quit
  ' Exp10 is the weak link...uses the Log table in P1 ROM
  'f := FMul( f, Exp10( FFloat( mag ) ) )
  ' use these loops for more precision (slower for large exponents, positive or negative)
  b := 0.1
  if mag > 0
    b := 10.0
  repeat ||mag
    f := FMul( f, b )

PUB FAdd(a, b)
{{
  Addition: result = a + b
  Parameters:
    a        32-bit floating point value
    b        32-bit floating point value
  Returns:   32-bit floating point value
}}
  result  := cmdFAdd
  f32_Cmd := @result
  repeat
  while f32_Cmd
          
PUB FSub(a, b)
{{
  Subtraction: result = a - b
  Parameters:
    a        32-bit floating point value
    b        32-bit floating point value
  Returns:   32-bit floating point value
}}
  result  := cmdFSub
  f32_Cmd := @result
  repeat
  while f32_Cmd
  
PUB FMul(a, b)
{{
  Multiplication: result = a * b
  Parameters:
    a        32-bit floating point value
    b        32-bit floating point value
  Returns:   32-bit floating point value
}}
  result  := cmdFMul
  f32_Cmd := @result
  repeat
  while f32_Cmd

PUB FDiv(a, b)
{{
  Division: result = a / b
  Parameters:
    a        32-bit floating point value
    b        32-bit floating point value
  Returns:   32-bit floating point value
}}
  result  := cmdFDiv
  f32_Cmd := @result
  repeat
  while f32_Cmd

PUB FFloat(n)
{{
  Convert integer to floating point.
  Parameters:
    n        32-bit integer value
  Returns:   32-bit floating point value
}}
  result  := cmdFFloat
  f32_Cmd := @result
  repeat
  while f32_Cmd

PUB UintTrunc(a)
{{
  Convert floating point to unsigned integer (with truncation).
  Parameters:
    a        32-bit floating point value
  Returns:   32-bit unsigned integer value
  (negative values are clamped to 0)
}}

  result  := cmdUintTrunc
  f32_Cmd := @result
  repeat
  while f32_Cmd

PUB FTrunc(a) | b
{{
  Convert floating point to integer (with truncation).
  Parameters:
    a        32-bit floating point value
    b        flag: 0 signifies truncation
  Returns:   32-bit integer value
}}
  b       := %000
  result  := cmdFTruncRound
  f32_Cmd := @result
  repeat
  while f32_Cmd

PUB FRound(a) | b
{{
  Convert floating point to integer (with rounding).
  Parameters:
    a        32-bit floating point value
    b        flag: 1 signifies rounding to the nearest integer
  Returns:   32-bit integer value
}}
  b       := %001
  result  := cmdFTruncRound
  f32_Cmd := @result
  repeat
  while f32_Cmd

PUB FloatTrunc(a) | b
{{
  Convert floating point to whole number (floating point, with truncation).
  Parameters:
    a        32-bit floating point value
    b        flag: 2 signifies floating point truncation
  Returns:   32-bit floating point value
}}
  b       := %010
  result  := cmdFTruncRound
  f32_Cmd := @result
  repeat
  while f32_Cmd

PUB FloatRound(a) | b
{{
  Convert floating point to whole number (floating point, with rounding).
  Parameters:
    a        32-bit floating point value
    b        flag: 3 signifies floating point rounding to the nearest whole number
  Returns:   32-bit floating point value
}}
  b       := %011
  result  := cmdFTruncRound
  f32_Cmd := @result
  repeat
  while f32_Cmd

PUB FSqr(a)
{{
  Square root.
  Parameters:
    a        32-bit floating point value
  Returns:   32-bit floating point value
}}
  result  := cmdFSqr
  f32_Cmd := @result
  repeat
  while f32_Cmd

PUB FCmp(a, b)
{{
  Floating point comparison.
  Parameters:
    a        32-bit floating point value
    b        32-bit floating point value
  Returns:   32-bit integer value
             -1 if a < b
              0 if a == b
              1 if a > b
}}
  result  := cmdFCmp
  f32_Cmd := @result
  repeat
  while f32_Cmd

PUB Sin(a)
{{
  Sine of an angle (radians).
  Parameters:
    a        32-bit floating point value (angle in radians)
  Returns:   32-bit floating point value
}}
  result  := cmdFSin
  f32_Cmd := @result
  repeat
  while f32_Cmd

PUB Cos(a)
{{
  Cosine of an angle (radians).
  Parameters:
    a        32-bit floating point value (angle in radians)
  Returns:   32-bit floating point value
}}
  result  := cmdFCos
  f32_Cmd := @result
  repeat
  while f32_Cmd

PUB Tan(a)
{{
  Tangent of an angle (radians).
  Parameters:
    a        32-bit floating point value (angle in radians)
  Returns:   32-bit floating point value
}}
  result  := cmdFTan
  f32_Cmd := @result
  repeat
  while f32_Cmd

PUB Log(a) | b
{{
  Logarithm, base e.
  Parameters:
    a        32-bit floating point value
    b        constant used to convert base 2 to base e
  Returns:   32-bit floating point value
}}
  b       := 1.442695041
  result  := cmdFLog2
  f32_Cmd := @result
  repeat
  while f32_Cmd

PUB Log2(a) | b
{{
  Logarithm, base 2.
  Parameters:
    a        32-bit floating point value
    b        0 is a flag to skip the base conversion (skips a multiplication by 1.0)
  Returns:   32-bit floating point value
}}
  b       := 0
  result  := cmdFLog2
  f32_Cmd := @result
  repeat
  while f32_Cmd

PUB Log10(a) | b
{{
  Logarithm, base 10.
  Parameters:
    a        32-bit floating point value
    b        constant used to convert base 2 to base 10
  Returns:   32-bit floating point value
}}
  b       := 3.321928095
  result  := cmdFLog2
  f32_Cmd := @result
  repeat
  while f32_Cmd

PUB Exp(a) | b
{{
  Exponential (e raised to the power a).
  Parameters:
    a        32-bit floating point value
    b        constant used to convert base 2 to base e
  Returns:   32-bit floating point value
}}
  b       := 1.442695041
  result  := cmdFExp2
  f32_Cmd := @result
  repeat
  while f32_Cmd

PUB Exp2(a) | b
{{
  Exponential (2 raised to the power a).
  Parameters:
    a        32-bit floating point value
    b        0 is a flag to skip the base conversion (skips a division by 1.0)
  Returns:   32-bit floating point value
}}
  b       := 0
  result  := cmdFExp2
  f32_Cmd := @result
  repeat
  while f32_Cmd

PUB Exp10(a) | b
{{
  Exponential (10 raised to the power a).
  Parameters:
    a        32-bit floating point value
    b        constant used to convert base 2 to base 10
  Returns:   32-bit floating point value
}}
  b       := 3.321928095
  result  := cmdFExp2
  f32_Cmd := @result
  repeat
  while f32_Cmd

PUB Pow(a, b)
{{
  Power (a to the power b).
  Parameters:
    a        32-bit floating point value
    b        32-bit floating point value  
  Returns:   32-bit floating point value
}}
  result  := cmdFPow
  f32_Cmd := @result
  repeat
  while f32_Cmd

PUB Frac(a)
{{
  Fraction (returns fractional part of a).
  Parameters:
    a        32-bit floating point value
  Returns:   32-bit floating point value
}}
  result  := cmdFFrac
  f32_Cmd := @result
  repeat
  while f32_Cmd

PUB FNeg(a)
{{
  Negate: result = -a.
  Parameters:
    a        32-bit floating point value
  Returns:   32-bit floating point value
}}
  return a ^ $8000_0000

PUB FAbs(a)
{{
  Absolute Value: result = |a|.
  Parameters:
    a        32-bit floating point value
  Returns:   32-bit floating point value
}}
  return a & $7FFF_FFFF
  
PUB Radians(a) | b
{{
  Convert degrees to radians
  Parameters:
    a        32-bit floating point value (angle in degrees)
    b        the conversion factor
  Returns:   32-bit floating point value (angle in radians)
}}
  b       := constant(pi / 180.0)
  result  := cmdFMul
  f32_Cmd := @result
  repeat
  while f32_Cmd

PUB Degrees(a) | b
{{
  Convert radians to degrees
  Parameters:
    a        32-bit floating point value (angle in radians)
    b        the conversion factor
  Returns:   32-bit floating point value (angle in degrees)
}}
  b       := constant(180.0 / pi)
  result  := cmdFMul
  f32_Cmd := @result
  repeat
  while f32_Cmd

PUB FMin(a, b)
{{
  Minimum: result = the minimum value a or b.
  Parameters:
    a        32-bit floating point value
    b        32-bit floating point value  
  Returns:   32-bit floating point value
}}
  result  := cmdFCmp
  f32_Cmd := @result
  repeat
  while f32_Cmd
  if result < 0
    return a
  return b
  
PUB FMax(a, b)
{{
  Maximum: result = the maximum value a or b.
  Parameters:
    a        32-bit floating point value
    b        32-bit floating point value  
  Returns:   32-bit floating point value
}}
  result  := cmdFCmp
  f32_Cmd := @result
  repeat
  while f32_Cmd
  if result < 0
    return b
  return a

PUB FMod(a, b)
{{
  Floating point remainder: result = the remainder of a / b.
  Parameters:
    a        32-bit floating point value
    b        32-bit floating point value  
  Returns:   32-bit floating point value
}}
  result  := cmdFMod
  f32_Cmd := @result
  repeat
  while f32_Cmd

PUB ASin(a) | b
{{
  Arc Sine of a (in radians).
  Parameters:
    a        32-bit floating point value (|a| must be < 1)
    b        1 is a flag signifying return the sine component
  Returns:   32-bit floating point value (angle in radians)
}}
  b       := 1
  result  := cmdASinCos
  f32_Cmd := @result
  repeat
  while f32_Cmd

PUB ACos(a) | b
{{
  Arc Cosine of a (in radians).
  Parameters:
    a        32-bit floating point value (|a| must be < 1)
    b        0 is a flag signifying return the cosine component
  Returns:   32-bit floating point value (angle in radians)
             if |a| > 1, NaN is returned
}}
  b       := 0
  result  := cmdASinCos
  f32_Cmd := @result
  repeat
  while f32_Cmd

PUB ATan(a) | b
{{
  Arc Tangent of a.
  Parameters:
    a        32-bit floating point value
    b        atan(a) = atan2(a,1.0)
  Returns:   32-bit floating point value (angle in radians)
}}
  b       := 1.0
  result  := cmdATan2
  f32_Cmd := @result
  repeat
  while f32_Cmd

PUB ATan2(a, b)
{{
  Arc Tangent of vector a, b (in radians, no division is performed, so b==0 is legal).
  Parameters:
    a        32-bit floating point value
    b        32-bit floating point value
  Returns:   32-bit floating point value (angle in radians)
}}
  result  := cmdATan2
  f32_Cmd := @result
  repeat
  while f32_Cmd

PUB Floor(a)
{{
  Calculate the floating point value of the nearest integer <= a.
  Parameters:
    a        32-bit floating point value
  Returns:   32-bit floating point value
}}
  result  := cmdFloor
  f32_Cmd := @result
  repeat
  while f32_Cmd

PUB Ceil(a)
{{
  Calculate the floating point value of the nearest integer >= a.
  Parameters:
    a        32-bit floating point value
  Returns:   32-bit floating point value
}}
  result  := cmdCeil
  f32_Cmd := @result
  repeat
  while f32_Cmd


CON
  SignFlag      = $1
  ZeroFlag      = $2
  NaNFlag       = $8


DAT

'----------------------------
' Assembly language routines
'----------------------------

'----------------------------
' Main control loop
'----------------------------
                        org     0                       ' (try to keep 2 or fewer instructions between rd/wrlong)
f32_entry               rdlong  ret_ptr, par wz         ' wait for command to be non-zero, and store it in the call location
              if_z      jmp     #f32_entry

                        rdlong  :execCmd, ret_ptr       ' get the pointer to the return value ("@result")
                        add     ret_ptr, #4

                        rdlong  fNumA, ret_ptr          ' fnumA is the long after "result"
                        add     ret_ptr, #4

                        rdlong  fNumB, ret_ptr          ' fnumB is the long after fnumA
                        sub     ret_ptr, #8

:execCmd                nop                             ' execute command, which was replaced by getCommand

:finishCmd              wrlong  fnumA, ret_ptr          ' store the result (2 longs before fnumB)
                        wrlong  outb, par               ' clear command status (outb is initialized to 0)
                        jmp     #f32_entry              ' wait for next command


'----------------------------
' addition and subtraction
' fnumA = fnumA +- fnumB
'----------------------------
_FSub                   xor     fnumB, Bit31            ' negate B
_FAdd                   call    #_Unpack2               ' unpack two variables
          if_c_or_z     jmp     _FAdd_ret              ' check for NaN or B = 0

                        test    flagA, #SignFlag wz     ' negate A mantissa if negative
          if_nz         neg     manA, manA
                        test    flagB, #SignFlag wz     ' negate B mantissa if negative
          if_nz         neg     manB, manB

                        mov     t1, expA                ' align mantissas
                        sub     t1, expB
                        abs     t1, t1          wc
                        max     t1, #31
              if_nc     sar     manB, t1
              if_c      sar     manA, t1
              if_c      mov     expA, expB

                        add     manA, manB              ' add the two mantissas
                        abs     manA, manA      wc      ' store the absolte value,
                        muxc    flagA, #SignFlag        ' and flag if it was negative

                        call    #_Pack                  ' pack result and exit
_FSub_ret
_FAdd_ret               ret      


'----------------------------
' multiplication
' fnumA *= fnumB
'----------------------------
_FMul                   call    #_Unpack2               ' unpack two variables
              if_c      jmp     _FMul_ret              ' check for NaN

                        xor     flagA, flagB            ' get sign of result
                        add     expA, expB              ' add exponents

                        '{ new method: 4 * (4 * 24 + 10) = 424 counts for this block,
                        ' worst case.  But, it is within the window of the calling Spin
                        ' repeat loop, so un-noticable.  And the best case scenario is
                        ' better.
                        neg     t1, manA                ' isolate the low bit of manA
                        and     t1, manA
                        neg     t2, manB                ' isolate the low bit of manB
                        and     t2, manB
                        cmp     t1, t2 wc               ' who has the greater low bit?  After reversal, this will go to 0 faster.
              if_c      mov     t1, manA wz             ' if t1 is 0, we'll just skip through everything              '
              if_nc     mov     t1, manB wz             ' ditto, only t1 is manB
              if_nc     mov     manB, manA              ' and in this case we wanted manA to be the multiplier mask

                        mov     manA, #0                ' manA is my new accumulator
                        rev     manB, #32-30            ' start by right aligning the reverse of the B mantissa

:multiply     if_nz     shr     manB, #1 wc,wz          ' get multiplier bit, and take note if we hit 0 (skip if t1 was already 0!)
              if_c      add     manA, t1                ' if the bit was set, add in the multiplicand
                        shr     t1, #1                  ' adjust my increment value's bit alignment
              if_nz     jmp     #:multiply              ' go back for more
                        '}

                        { standard method: 404 counts for this block
                        mov     t1, #0                  ' t1 is my accumulator
                        mov     t2, #24                 ' loop counter for multiply (only do the bits needed...23 + implied 1)
                        shr     manB, #6                ' start by right aligning the B mantissa

:multiply               shr     t1, #1                  ' shift the previous accumulation down by 1
                        shr     manB, #1 wc             ' get multiplier bit
              if_c      add     t1, manA                ' if the bit was set, add in the multiplicand
                        djnz    t2, #:multiply          ' go back for more
                        mov     manA, t1                ' yes, that's my final answer.
                        '}

                        call    #_Pack
_FMul_ret               ret


'----------------------------
' division
' fnumA /= fnumB
'----------------------------
_FDiv                   call    #_Unpack2               ' unpack two variables
          if_c_or_z     mov     fnumA, NaN              ' check for NaN or divide by 0
          if_c_or_z     jmp     _FDiv_ret
        
                        xor     flagA, flagB            ' get sign of result
                        sub     expA, expB              ' subtract exponents

                        ' slightly faster division, using 26 passes instead of 30
                        mov     t1, #0                  ' clear quotient
                        mov     t2, #26                 ' loop counter for divide (need 24, plus 2 for rounding)

:divide                 ' divide the mantissas
                        cmpsub  manA, manB      wc
                        rcl     t1, #1
                        shl     manA, #1
                        djnz    t2, #:divide
                        shl     t1, #4                  ' align the result (we did 26 instead of 30 iterations)

                        mov     manA, t1                ' get result and exit
                        call    #_Pack

_FDiv_ret               ret

'------------------------------------------------------------------------------
' fnumA = float(fnumA)
'------------------------------------------------------------------------------
_FFloat                 abs     manA, fnumA     wc,wz   ' get |integer value|
              if_z      jmp     _FFloat_ret            ' if zero, exit
                        muxc    flagA, #SignFlag        ' depending on the integer's sign
                        mov     expA, #29               ' set my exponent
                        call    #_Pack                  ' pack and exit
_FFloat_ret             ret

'------------------------------------------------------------------------------
' rounding and truncation
' fnumB controls the output format:
'       %00 = integer, truncate
'       %01 = integer, round
'       %10 = float, truncate
'       %11 = float, round
'------------------------------------------------------------------------------
_FTruncRound            mov     t1, fnumA               ' grab a copy of the input
                        call    #_Unpack                ' unpack floating point value

                        ' Are we going for float or integer?
                        cmpsub  fnumB, #%10     wc      ' clear bit 1 and set the C flag if it was a 1
                        rcl     t2, #1
                        and     t2, #1          wz      ' Z now signified integer output

                        shl     manA, #2                ' left justify mantissa
                        sub     expA, #30               ' our target exponent is 30
                        abs     expA, expA      wc      ' adjust for exponent sign, and track if it was negative
                          
              if_z_and_nc mov   manA, NaN               ' integer output, and it's too large for us to handle
              if_z_and_nc jmp   #:check_sign
              
              if_nz_and_nc mov  fnumA, t1                ' float output, and we're already all integer
              if_nz_and_nc jmp  _FTruncRound_ret
                        
                        ' well, I need to kill off some bits, so let's do it
                        cmp     expA, #32       wc      ' DO set the C flag here...I want to know if expA =< 31, aka < 32
                        max     expA, #31               ' DON'T set the C flag here...max sets C if D<S
                        shr     manA, expA
              if_c      add     manA, fnumB             ' round up 1/2 lsb if desired, and if it isn't supposed to be 0! (if expA was > 31)
                        shr     manA, #1

              if_z      jmp     #:check_sign            ' integer output?

                        mov     expA, #29
                        call    #_Pack
                        jmp     _FTruncRound_ret

:check_sign             test    flagA, #signFlag wz     ' check sign and exit
                        negnz   fnumA, manA

_FTruncRound_ret        ret


'------------------------------------------------------------------------------
' truncation to unsigned integer
' fnumA = unsigned int(fnumA), clamped to 0
'------------------------------------------------------------------------------
_UintTrunc              call    #_Unpack
                        mov     fnumA, #0
                        test    flagA, #SignFlag wc
              if_c_or_z jmp     _UintTrunc_ret         ' if the input number was negative or zero, we're done
                        shl     manA, #2                ' left justify mantissa
                        sub     expA, #31               ' our target exponent is 31
                        abs     expA, expA      wc,wz
              if_a      neg     fnumA, #1               ' if we needed to shift left, we're already maxed out
              if_be     cmp     expA, #32       wc      ' otherwise, if we need to shift right by more than 31, the answer is 0
              if_c      shr     manA, expA              ' OK, shift it down
              if_c      mov     fnumA, manA
_UintTrunc_ret          ret

                                  
'------------------------------------------------------------------------------
' square root
' fnumA = sqrt(fnumA)
'------------------------------------------------------------------------------
_FSqr                   call    #_Unpack                 ' unpack floating point value
          if_c_or_z     jmp     _FSqr_ret               ' check for NaN or zero
                        test    flagA, #signFlag wz      ' check for negative
          if_nz         mov     fnumA, NaN               ' yes, then return NaN                       
          if_nz         jmp     _FSqr_ret

                        sar     expA, #1 wc             ' if odd exponent, shift mantissa
          if_c          shl     manA, #1
                        add     expA, #1
                        mov     t2, #29

                        mov     fnumA, #0               ' set initial result to zero
:sqrt                   ' what is the delta root^2 if we add in this bit?
                        mov     t3, fnumA
                        shl     t3, #2
                        add     t3, #1
                        shl     t3, t2
                        ' is the remainder >= delta?
                        cmpsub  manA, t3        wc
                        rcl     fnumA, #1
                        shl     manA, #1
                        djnz    t2, #:sqrt
                        
                        mov     manA, fnumA             ' store new mantissa value and exit
                        call    #_Pack
_FSqr_ret               ret


'------------------------------------------------------------------------------
' compare fnumA , fnumB
' fnumA =
'       1 if fnumA > fnumB
'       -1 if fnumA < fnumB
'       0 if fnumA = fnumB
'------------------------------------------------------------------------------
_FCmp                   mov     t1, fnumA               ' if both values...
                        and     t1, fnumB               '  are negative...
                        shl     t1, #1 wc               ' (bit 31 high)...
                        negc    t1, #1                  ' then the comparison will be reversed
                        cmps    fnumA, fnumB wc,wz      ' do the signed comparison, save result in flags C Z
              if_z      mov     t1, #0
                        or      fnumA, fnumB            ' +0 == -0, so compare for both being 0...
                        andn    fnumA, Bit31 wz         ' ignoring bit 31, will be 0 if both fA and fB were zero
              if_nz     negc    fnumA, t1               ' if it's not zero
_FCmp_ret               ret


'------------------------------------------------------------------------------
' new table lookup code
' Inputs
' t1 = 31-bit number: 1-bit 0, then 11-bits real, then 20-bits fraction (allows the sine table to use the top bit)
' t2 = table base address
' Outputs
' t1 = 30-bit interpolated number
'------------------------------------------------------------------------------
_Table_Interp           ' store the fractional part
                        mov     t4, t1                  ' will store reversed so a SAR will shift the value and get a bit
                        rev     t4, #12                 ' ignore the top 12 bits, and reverse the rest
                        ' align the input number to get the table offset, multiplied by 2
                        shr     t1, #19
                        test    t2, SineTable    wc      'C = 1 if we're doing a SINE table lookup.  added to fix LOG and SIN
                        add     t2, t1
                        ' read the 2 intermediate values, and scale them for interpolation
                        rdword  t1, t2
                        shl     t1, #14
                        
                        add     t2, #2
                        
                        test    t2, TableMask   wz      'table address has overflowed.  added to fix LOG          
        if_z_and_nc     mov     t2, Bit16               'fix table value unless we're doing the SINE table.  added to fix LOG            
        if_nz_or_c      rdword  t2, t2                  'else, look up the correct value.  conditional added to fix LOG
                        shl     t2, #14
                        ' interpolate
                        sub     t2, t1                  ' change from 2 points to delta
                        movs    t2, t4                  ' make the low 9 bits the multiplier (reversed)
                        mov     t3, #9                  ' do 9 steps
:interp                 sar     t2, #1          wc      ' divide the delta by 2, and get the MSB multiplier bit
              if_c      add     t1, t2                  ' if the multiplier bit was 1, add in the shifter delta
                        djnz    t3, #:interp            ' keep going, 9 times around
                        ' done, and the answer is in t1, bit 29 aligned
_Table_Interp_ret       ret


'------------------------------------------------------------------------------
' sine and cosine
' fnumA = sin(fnumA) for sine
' fnumA = sin(fnumA+pi/2) for cosine
' note: resume tan allows reuse of the angle scaling when calling
' both sine and cosine of the same angle.
'------------------------------------------------------------------------------
OneOver2Pi              long    1.0 / (2.0 * pi)        ' I need this constant to get the fractional angle

_Cos                    mov     t4, bit29               ' adjust sine to cosine at the last possible minute by adding 90 degrees
                        andn    fnumA, bit31            ' nuke the sign bit
                        jmp     #_SinCos_cont

_Sin                    mov     t4, #0                  ' just sine, and keep my sign bit

_SinCos_cont            mov     fnumB, OneOver2Pi
                        call    #_FMul                  ' rescale angle from [0..2pi] to [0..1]

                        ' now, work with the raw value
                        call    #_Unpack

                        ' get the whole and fractional bits
                        add     expA, #2                ' bias the exponent by 3 so the resulting data will be 31-bit aligned
                        abs     expA, expA      wc      ' was the exponent positive or negative?
                        max     expA, #31               ' limit to 31, otherwise we do weird wrapping things
              if_c      shr     manA, expA              ' -exp: shift right to bring down to 1.0
              if_nc     shl     manA, expA              ' +exp: shift left to throw away the high bits

                        mov     t6, manA                ' store the address in case Tan needs it

                        add     manA, t4                ' adjust for cosine?

_resume_Tan             test    manA, bit29     wz
                        negnz   t1, manA
                        shl     t1, #2

                        mov     t2, SineTable
                        call    #_Table_Interp

                        ' rebuild the number
                        test    manA, bit30     wz      ' check if we're in quadrant 3 or 4
                        abs     manA, t1                ' move my number into the mantissa
                        shr     manA, #16               ' but the table went to $FFFF, so scale up a bit to
                        addabs  manA, t1                ' get to &10000
              if_nz     xor     flagA, #SignFlag        ' invert my sign bit, if the mantissa would have been negative (quad 3 or 4)
                        neg     expA, #1                ' exponent is -1
                        call    #_Pack

_resume_Tan_ret
_Cos_ret
_Sin_ret                ret


'------------------------------------------------------------------------------
' tangent
' fnumA = tan(fnumA) = sin(fnumA) / cos(fnumA)
'------------------------------------------------------------------------------
_Tan                    call    #_Sin
                        mov     t7, fnumA
                        ' skip the angle normalizing, much faster
                        mov     manA, t6                ' was manA for Sine
                        add     manA, bit29             ' add in 90 degrees
                        call    #_resume_Tan            ' go back and recompute the float
                        mov     fnumB, fnumA            ' move Cosine into fnumB
                        mov     fnumA, t7               ' move Sine into fnumA
                        call    #_FDiv                  ' divide
_Tan_ret                ret


'------------------------------------------------------------------------------
' log2
' fnumA = log2(fnumA)
' may be divided by fnumB to change bases
'------------------------------------------------------------------------------
_Log2                   call    #_Unpack                ' unpack variable
          if_nz_and_nc  test    flagA, #SignFlag wc     ' if NaN or <= 0, return NaN
          if_z_or_c     jmp     #:exitNaN

                        mov     t1, manA
                        shl     t1, #3
                        shr     t1, #1
                        mov     t2, LogTable
                        call    #_Table_Interp
                        ' store the interpolated table lookup
                        mov     manA, t1
                        shr     manA, #5                  ' clear the top 7 bits (already 2 free
                        ' process the exponent
                        abs     expA, expA      wc
                        muxc    flagA, #SignFlag
                        ' recombine exponent into the mantissa
                        shl     expA, #25
                        negc    manA, manA
                        add     manA, expA
                        mov     expA, #4
                        ' make it a floating point number
                        call    #_Pack
                        ' convert the base
                        cmp     fnumB, #0    wz         ' check that my divisor isn't 0 (which flags that we're doing log2)
              if_nz     call    #_FDiv                  ' convert the base (unless fnumB was 0)
                        jmp     _Log2_ret

:exitNaN                mov     fnumA, NaN              ' return NaN
_Log2_ret               ret

'------------------------------------------------------------------------------
' exp2
' fnumA = 2 ** fnumA
' may be multiplied by fnumB to change bases
'------------------------------------------------------------------------------
                        ' 1st off, convert the base
_Exp2                   cmp     fnumB, #0       wz
              if_nz     call    #_FMul

                        call    #_Unpack
                        shl     manA, #2                ' left justify mantissa
                        mov     t1, expA                ' copy the local exponent

                        '        OK, get the whole number
                        sub     t1, #30                 ' our target exponent is 31
                        abs     expA, t1      wc        ' adjust for exponent sign, and track if it was negative
              if_c      jmp     #:cont_Exp2

                        ' handle this case depending on the sign
                        test    flagA, #signFlag wz
              if_z      mov     fnumA, NaN              ' nope, was positive, bail with NaN (happens to be the largest positive integer)
              if_nz     mov     fnumA, #0
                        jmp     _Exp2_ret

:cont_Exp2              mov     t2, manA
                        max     expA, #31
                        shr     t2, expA
                        shr     t2, #1
                        mov     expA, t2

                        ' get the fractional part
                        add     t1, #31
                        abs     t2, t1          wc
              if_c      shr     manA, t2
              if_nc     shl     manA, t2

                        ' do the table lookup
                        mov     t1, manA
                        shr     t1, #1
                        mov     t2, ALogTable
                        call    #_Table_Interp

                        ' store a copy of the sign
                        mov     t6, flagA

                        ' combine
                        mov     manA, t1
                        or      manA, bit30
                        sub     expA, #1
                        mov     flagA, #0

                        call    #_Pack

                        test    t6, #signFlag wz        ' check sign and store this back in the exponent
              if_z      jmp     _Exp2_ret
                        mov     fnumB, fnumA            ' yes, then invert
                        mov     fnumA, One
                        call    #_FDiv

_Exp2_ret               ret


'------------------------------------------------------------------------------
' power
' fnumA = fnumA raised to power fnumB
'------------------------------------------------------------------------------
_Pow                    mov     t7, fnumA wc            ' save sign of result
          if_nc         jmp     #:pow3                  ' check if negative base

                        mov     fnumA, fnumB            ' check exponent
                        call    #_Unpack
                        mov     fnumA, t7               ' restore base
          if_z          jmp     #:pow2                  ' check for exponent = 0
          
                        test    expA, Bit31 wz          ' if exponent < 0, return NaN
          if_nz         jmp     #:pow1

                        max     expA, #23               ' check if exponent = integer
                        shl     manA, expA    
                        and     manA, Mask29 wz, nr                         
          if_z          jmp     #:pow2                  ' yes, then check if odd
          
:pow1                   mov     fnumA, NaN              ' return NaN
                        jmp     _Pow_ret

:pow2                   test    manA, Bit29 wz          ' if odd, then negate result
          if_z          andn    t7, Bit31

:pow3                   andn    fnumA, Bit31            ' get |fnumA|
                        mov     t6, fnumB               ' save power
                        call    #_Log2                  ' get log of base
                        mov     fnumB, t6               ' multiply by power
                        call    #_FMul
                        call    #_Exp2                  ' get result      

                        test    t7, Bit31 wz            ' check for negative
          if_nz         xor     fnumA, Bit31
_Pow_ret                ret


'------------------------------------------------------------------------------
' fraction
' fnumA = fractional part of fnumA
'------------------------------------------------------------------------------
_Frac                   call    #_Unpack                ' get fraction
                        test    expA, Bit31 wz          ' check for exp < 0 or NaN
          if_c_or_nz    jmp     #:exit
                        max     expA, #23               ' remove the integer
                        shl     manA, expA    
                        and     manA, Mask29
                        mov     expA, #0                ' return fraction

:exit                   call    #_Pack
                        andn    fnumA, Bit31
_Frac_ret               ret


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
' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB, t1
'------------------------------------------------------------------------------
_Unpack2                mov     t1, fnumA               ' save A
                        mov     fnumA, fnumB            ' unpack B to A
                        call    #_Unpack
          if_c          jmp     _Unpack2_ret           ' check for NaN

                        mov     fnumB, fnumA            ' save B variables
                        mov     flagB, flagA
                        mov     expB, expA
                        mov     manB, manA

                        mov     fnumA, t1               ' unpack A
                        call    #_Unpack
                        cmp     manB, #0 wz             ' set Z flag                      
_Unpack2_ret            ret


'------------------------------------------------------------------------------
' input:   fnumA        32-bit floating point value 
' output:  flagA        fnumA flag bits (Nan, Infinity, Zero, Sign)
'          expA         fnumA exponent (no bias)
'          manA         fnumA mantissa (aligned to bit 29)
'          C flag       set if fnumA is NaN
'          Z flag       set if fnumA is zero
' changes: fnumA, flagA, expA, manA
'------------------------------------------------------------------------------
_Unpack                 mov     flagA, fnumA            ' get sign
                        shr     flagA, #31
                        mov     manA, fnumA             ' get mantissa
                        and     manA, Mask23
                        mov     expA, fnumA             ' get exponent
                        shl     expA, #1
                        shr     expA, #24 wz
          if_z          jmp     #:zeroSubnormal         ' check for zero or subnormal
                        cmp     expA, #255 wz           ' check if finite
          if_nz         jmp     #:finite
                        mov     fnumA, NaN              ' no, then return NaN
                        mov     flagA, #NaNFlag
                        jmp     #:exit2        

:zeroSubnormal          or      manA, expA wz,nr        ' check for zero
          if_nz         jmp     #:subnorm
                        or      flagA, #ZeroFlag        ' yes, then set zero flag
                        neg     expA, #150              ' set exponent and exit
                        jmp     #:exit2
                                 
:subnorm                shl     manA, #7                ' fix justification for subnormals  
:subnorm2               test    manA, Bit29 wz
          if_nz         jmp     #:exit1
                        shl     manA, #1
                        sub     expA, #1
                        jmp     #:subnorm2

:finite                 shl     manA, #6                ' justify mantissa to bit 29
                        or      manA, Bit29             ' add leading one bit
                        
:exit1                  sub     expA, #127              ' remove bias from exponent
:exit2                  test    flagA, #NaNFlag wc      ' set C flag
                        cmp     manA, #0 wz             ' set Z flag
_Unpack_ret             ret       


'------------------------------------------------------------------------------
' input:   flagA        fnumA flag bits (Nan, Infinity, Zero, Sign)
'          expA         fnumA exponent (no bias)
'          manA         fnumA mantissa (aligned to bit 29)
' output:  fnumA        32-bit floating point value
' changes: fnumA, flagA, expA, manA 
'------------------------------------------------------------------------------
_Pack                   cmp     manA, #0 wz             ' check for zero                                        
          if_z          mov     expA, #0
          if_z          jmp     #:exit1

                        sub     expA, #380              ' take us out of the danger range for djnz
:normalize              shl     manA, #1 wc             ' normalize the mantissa
          if_nc         djnz    expA, #:normalize       ' adjust exponent and jump

                        add     manA, #$100 wc          ' round up by 1/2 lsb

                        addx    expA, #(380 + 127 + 2)  ' add bias to exponent, account for rounding (in flag C, above)
                        mins    expA, Minus23
                        maxs    expA, #255

                        abs     expA, expA wc,wz        ' check for subnormals, and get the abs in case it is
          if_a          jmp     #:exit1

:subnormal              or      manA, #1                ' adjust mantissa
                        ror     manA, #1

                        shr     manA, expA
                        mov     expA, #0                ' biased exponent = 0

:exit1                  mov     fnumA, manA             ' bits 22:0 mantissa
                        shr     fnumA, #9
                        movi    fnumA, expA             ' bits 23:30 exponent
                        shl     flagA, #31
                        or      fnumA, flagA            ' bit 31 sign            
_Pack_ret               ret


'------------------------------------------------------------------------------
' modulo
' fnumA = fnumA mod fnumB
'------------------------------------------------------------------------------
_FMod                   mov     t4, fnumA               ' save fnumA
                        mov     t5, fnumB               ' save fnumB
                        call    #_FDiv                  ' a - float(fix(a/b)) * b
                        mov     fnumB, #0
                        call    #_FTruncRound
                        call    #_FFloat
                        mov     fnumB, t5
                        call    #_FMul
                        or      fnumA, Bit31
                        mov     fnumB, t4
                        andn    fnumB, Bit31
                        call    #_FAdd
                        test    t4, Bit31 wz            ' if a < 0, set sign
          if_nz         or      fnumA, Bit31
_FMod_ret               ret


'------------------------------------------------------------------------------
' arctan2
' fnumA = atan2( fnumA, fnumB )
' note: y = fnumA, x = fnumB: same as C++, opposite of Excel!
'------------------------------------------------------------------------------
_ATan2                  call    #_Unpack2               ' OK, start with the basics
                        mov     fnumA, #0               ' clear my accumulator
                        ' which is the larger exponent?
                        sub     expA, expB
                        abs     expA, expA      wc

                        ' decrease my resolution...I could get some overflow without this!
                        ' Thanks, Duane Degn!!
                        shr     manA, #1
                        shr     manB, #1

                        ' make the exponents equal
              if_c      shr     manA, expA
              if_nc     shr     manB, expA

                        ' correct signs based on the Quadrant
                        test    flagA, #SignFlag wc
                        test    flagB, #SignFlag wz
              if_z_eq_c neg     manA, manA
              if_nz     sumc    fnumA, CORDIC_Pi

                        ' do the CORDIC thing
                        mov     t1, #0
                        mov     t2, #25                 ' 20 gets you the same error range as the original, 29 is best, 25 is a nice compromise
                        movs    :load_C_table, #CORDIC_Angles

:CORDIC                 ' do the actual CORDIC thing
                        mov     t3, manA        wc      ' mark whether our Y component is negative or not
                        sar     t3, t1
                        mov     t4, manB
                        sar     t4, t1
                        sumc    manB, t3                ' C determines the direction of the rotation
                        sumnc   manA, t4        wz      ' (be ready to short-circuit as soon as the Y component is 0)
:load_C_table           sumc    fnumA, 0-0
                        ' update all my counters (including the code ones)
                        add     :load_C_table, #1
                        add     t1, #1
                        ' go back for more?
                        djnz    t2, #:CORDIC

                        ' convert to a float
                        mov     expA, #1
                        abs     manA, fnumA     wc
                        muxc    flagA, #SignFlag
                        call    #_Pack

_ATan2_ret              ret

CORDIC_Pi               long    $3243f6a8       ' Pi in 30 bits (otherwise we can overflow)
' The CORDIC angle table...binary 30-bit representation of atan(2^-i)
CORDIC_Angles           long $c90fdaa, $76b19c1, $3eb6ebf, $1fd5ba9, $ffaadd
                        long $7ff556, $3ffeaa, $1fffd5, $ffffa, $7ffff
                        long $3ffff, $20000, $10000, $8000, $4000
                        long $2000, $1000, $800, $400, $200
                        long $100, $80, $40, $20, $10
                        'long $8, $4, $2, $1


'------------------------------------------------------------------------------
' arcsine or arccosine
' fnumA = asin or acos(fnumA)
' asin( x ) = atan2( x, sqrt( 1 - x*x ) )
' acos( x ) = atan2( sqrt( 1 - x*x ), x )
'------------------------------------------------------------------------------
_ASinCos                ' grab a copy of both operands
                        mov     t5, fnumA
                        mov     t6, fnumB
                        ' square fnumA
                        mov     fnumB, fnumA
                        call    #_FMul
                        mov     fnumB, fnumA
                        mov     fnumA, One
                        call    #_FSub
                        '       quick error check
                        test    fnumA, bit31    wc
              if_c      mov     fnumA, NaN
              if_c      jmp     _ASinCos_ret
                        ' carry on
                        call    #_FSqr
                        ' check if this is sine or cosine (determines which goes into fnumA and fnumB)
                        mov     t6, t6          wz
              if_z      mov     fnumB, t5
              if_nz     mov     fnumB, fnumA
              if_nz     mov     fnumA, t5
                        call    #_ATan2
_ASinCos_ret            ret


'------------------------------------------------------------------------------
' _Floor fnumA = floor(fnumA)
' _Ceil fnumA = ceil(fnumA)
'------------------------------------------------------------------------------
_Ceil                   mov     t6, #1                  ' set adjustment value
                        jmp     #floor2
                        
_Floor                  neg     t6, #1                  ' set adjustment value

floor2                  call    #_Unpack                ' unpack variable
          if_c          jmp     _Floor_ret             ' check for NaN
                        cmps     expA, #23 wc, wz       ' check for no fraction
          if_nc         jmp     _Floor_ret

                        mov     t4, fnumA               ' get integer value
                        mov     fnumB, #0
                        call    #_FTruncRound
                        mov     t5, fnumA
                        xor     fnumA, t6
                        test    fnumA, Bit31 wz
          if_nz         jmp     #:exit

                        mov     fnumA, t4               ' get fraction  
                        call    #_Frac

                        or      fnumA, fnumA wz
          if_nz         add     t5, t6                  ' if non-zero, then adjust

:exit                   mov     fnumA, t5               ' convert integer to float 
                        call    #_FFloat                '}                
_Ceil_ret
_Floor_ret              ret


'-------------------- constant values -----------------------------------------

One                     long    1.0
NaN                     long    $7FFF_FFFF
Minus23                 long    -23
Mask23                  long    $007F_FFFF
Mask29                  long    $1FFF_FFFF
TableMask               long    $0FFE           'added to fix LOG
Bit16                   long    $0001_0000       'added to fix LOG
Bit29                   long    $2000_0000
Bit30                   long    $4000_0000
Bit31                   long    $8000_0000
LogTable                long    $C000
ALogTable               long    $D000
SineTable               long    $E000

'-------------------- initialized variables -----------------------------------

'-------------------- local variables -----------------------------------------

ret_ptr                 res     1
t1                      res     1
t2                      res     1
t3                      res     1
t4                      res     1
t5                      res     1
t6                      res     1
t7                      res     1

fnumA                   res     1               ' floating point A value
flagA                   res     1
expA                    res     1
manA                    res     1

fnumB                   res     1               ' floating point B value
flagB                   res     1
expB                    res     1
manB                    res     1

fit 496 ' A cog has 496 longs available, the last 16 (to make it up to 512) are register shadows.

' command dispatch table: must be compiled along with PASM code in
' Cog RAM to know the addresses, but does not neet to fit in it.
cmdCallTable
cmdFAdd                 call    #_FAdd
cmdFSub                 call    #_FSub
cmdFMul                 call    #_FMul
cmdFDiv                 call    #_FDiv
cmdFFloat               call    #_FFloat
cmdFTruncRound          call    #_FTruncRound
cmdUintTrunc            call    #_UintTrunc
cmdFSqr                 call    #_FSqr
cmdFCmp                 call    #_FCmp
cmdFSin                 call    #_Sin
cmdFCos                 call    #_Cos
cmdFTan                 call    #_Tan
cmdFLog2                call    #_Log2
cmdFExp2                call    #_Exp2
cmdFPow                 call    #_Pow
cmdFFrac                call    #_Frac
cmdFMod                 call    #_FMod
cmdASinCos              call    #_ASinCos
cmdATan2                call    #_ATan2
cmdCeil                 call    #_Ceil
cmdFloor                call    #_Floor

{{


+------------------------------------------------------------------------------------------------------------------------------+
|                                                   TERMS OF USE: MIT License                                                  |                                                            
+------------------------------------------------------------------------------------------------------------------------------+
|Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    | 
|files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    |
|modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software|
|is furnished to do so, subject to the following conditions:                                                                   |
|                                                                                                                              |
|The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.|
|                                                                                                                              |
|THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          |
|WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         |
|COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   |
|ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         |
+------------------------------------------------------------------------------------------------------------------------------+
}}