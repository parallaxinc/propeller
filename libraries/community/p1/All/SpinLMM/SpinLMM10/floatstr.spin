'******************************************************************************
' Floating Point I/O Routines
' Author: Dave Hein
' Copyright (c) 2010
' See end of file for terms of use.
'******************************************************************************
' This is a modified version of the cfloatstr object that is contained in
' in CLIB 1.01 found in the OBEX.
'******************************************************************************
{
  These routines are used by the C library to perform formatted floating point
  I/O.  The two output routines, putfloate and putfloatf write to string.

  Input formatting is performed by the strtofloat routine.  It uses a pointer
  to a string pointer and returns the resulting floating point value.

  If floating point I/O is not required for an application this file can be
  removed by deleting the references to the object and the three routines in
  clib.spin.
}

'******************************************************************************  
' Floating Point Routines
'******************************************************************************
PUB putfloate(str, x, width, digits) | man, exp10, signbit
{{
  Convert the floating point value in x to a string of characters in scientific
  notation in str.  digits determines the number of fractional digits used and
  width determines the minimum length of the output string.  Leading blanks are
  added to achieve the minimum width.
 }} 
  if (digits < 0)
    digits := 6
  signbit := tofloat10(x, @man, @exp10)
  exp10 += round10(digits + 1, @man) + digits
  width -= 5 + signbit - (digits <> 0)
  repeat while (width-- > digits)
    byte[str++] := " "
  if (signbit)
    byte[str++] := "-"
  str := utoa10(man, str, 1)
  byte[str++] := "e"
  if (exp10 => 0)
    byte[str++] := "+"
  else
    byte[str++] := "-"
    exp10 := -exp10
  if (exp10 < 10)
    byte[str++] := "0"
  str := utoa10(exp10, str, -1)
  byte[str] := 0
  return str

PUB putfloatf(str, x, width, digits) | lead0, trail0, man, exp10, signbit, digits0
{{
  Convert the floating point value in x to a string of character in standard
  notation in str.  digits determines the number of fractional digits used and
  width determines the minimum length of the output string.  Leading blanks are
  added to achieve the minimum width.
}}
  if (digits < 0)
    digits := 6
  signbit := tofloat10(x, @man, @exp10)
  digits0 := numdigits(man, @lead0) + exp10
  if (digits0 > 0)
    width -= digits0
  digits0 += digits
  if (digits0 > 8)
    digits0 := 8
  exp10 += round10(digits0, @man) + digits0 - 1
  if (digits0 < 0)
    digits0 := 0
  elseif (digits0 == 0 and man == 1 and digits > 0)
    digits0 := 1
  lead0 := digits - digits0
  trail0 := digits - digits0 + exp10 + 1
  width -= signbit + digits - (lead0 => 0) + 1
  repeat while (width-- > 0)
    byte[str++] := " "
  if (signbit)
    byte[str++] := "-"
  if (lead0 => 0)
    byte[str++] := "0"
  if (lead0 > 0)
    byte[str++] := "."
  repeat while (lead0-- > 0)
    byte[str++] := "0"
  if (digits0 > 0)
    str := utoa10(man, str, exp10 + 1)
  exp10 -= digits0 - 1
  repeat while (trail0-- > 0)
    if (exp10-- == 0)
      byte[str++] := "."
    byte[str++] := "0"
  byte[str] := 0
  return str

PUB strtofloat(str) | value, exp10, exp10a, signbit, mode, char, esignbit
{{
  Convert the string of characters pointer to by "pstr" into a floating point
  value.  The input can be in either standard or scientific notation.  Leading
  blanks are ignored.  The string pointed to by "pstr" is updated to the last
  character postioned that caused processing to be completed.
}}
  esignbit := 0
  mode := 0
  value := 0
  exp10 := 0
  exp10a := 0
  signbit := 0
  repeat
    char := byte[str++]      
    if (char == 0)
      quit
    case mode
      0:
        case char
          "0".."9": value := char - "0"
          "-" : signbit := 1
          " " : next
          "+": mode := 1
          other:quit
        mode := 1
      1 :
        case char
          "0".."9":
            if (value =< 200_000_000)
              value := (value * 10) + char  - "0"
            else
               exp10++
          ".": mode := 2
          "e", "E": mode := 3
          other: quit
      2:
        case char
          "0".."9":
            if (value =< 200_000_000)
              value := (value * 10) + char  - "0"
              exp10--
          "e", "E": mode := 3
          other: quit
      3:
        case char
          "0".."9": exp10a := char - "0"
          "-" : esignbit := 1
          "+": mode := 4
          other:quit
        mode := 4
      4:
        case char
          "0".."9":exp10a := (exp10a * 10) + char - "0"
          other: quit
  if (esignbit)
    exp10 -= exp10a
  else
    exp10 += exp10a
  return fromfloat10(value, exp10, signbit)

DAT
{{

________________________
  These tables of scalers are used to scale a floating point number by a ratio of a
  power of 10 versus a power of 2.
}}
''SCALE1         10/16      100/128    1000/1024   10^6/2^20  10^12/2^40  10^24/2^80
  scale1 long 1342177280, 1677721600, 2097152000, 2048000000, 1953125000, 1776356839
''SCALE2          8/10       64/100     512/1000   2^19/10^6  2^39/10^12  2^79/10^24
  scale2 long 1717986918, 1374389535, 1099511628, 1125899907, 1180591621, 1298074215
  nbits1 byte 4, 7, 10, 20, 40, 80
  nbits2 byte 3, 6,  9, 19, 39, 79
  ndecs  byte 1, 2,  3,  6, 12, 24

PRI floatloop(man, pexp0, pexp1, step0, step1, scale, pexp2, step2) | i
{{
  This private routine reduces the value of exp0 toward 0 while increasing the value
  of exp1.  This is done in a successive approximation method using the scaling
  table passed in "scale".  This routine is used here to convert between a mantissa
  times a power of 2 or 10 to a mantissa times a power of 10 or 2.
}}
  repeat i from 5 to 0
    if (long[pexp0] => byte[step0][i])
      man := (man ** long[scale][i]) << 1
      long[pexp0] -= byte[step0][i]
      long[pexp1] += byte[step1][i]
      if ((man & $40000000) == 0)
        man <<= 1
        long[pexp2] -= step2
  return man

PRI tofloat10(value, pman, pexp10) | exp2, exp10, man
{{
  This private routine converts from a mantissa times a power of 2 to a mantissa
  times a power of 10.
}}'***************************************************************************************
' SpinLMM Demo
' Copyright (c) 2010 Dave Hein
' July 6, 2010
' See end of file for terms of use
'***************************************************************************************
' This program demostrates the use of SpinLMM with serial I/O and floating point
' operations.
'***************************************************************************************

  result := value >> 31
  exp2 := ((value >> 23) & 255) - 157
  man := ((value & $007fffff) | $00800000) << 7
  exp10 := 0
  if (exp2 =< 0)
    exp2 := -exp2
    man := floatloop(man, @exp2, @exp10, @nbits1, @ndecs, @scale1, @exp2, -1)
    man >>= exp2
    exp10 := -exp10
  else
    exp2 += 2
    man := floatloop(man, @exp2, @exp10, @nbits2, @ndecs, @scale2, @exp2,  1)
    man >>= 2 - exp2
  long[pman] := man
  long[pexp10] := exp10
  
PRI fromfloat10(man, exp10, signbit) | exp2
{{
  This private routine converts from a mantissa times a power of 10 to a mantissa
  times a power of two.
}}
  if (man == 0)
    return 0
  exp2 := 0
  repeat while(man & $40000000) == 0
    man <<= 1
    exp2--
  if (exp10 =< 0)
    exp10 := -exp10
    exp2 := -exp2
    man := floatloop(man, @exp10, @exp2, @ndecs, @nbits2, @scale2, @exp2, -1)
    exp2 := -exp2
  else
    man := floatloop(man, @exp10, @exp2, @ndecs, @nbits1, @scale1, @exp2, 1)
  repeat while(man & $ff000000)
    man >>= 1
    exp2++
  return (signbit << 31) | ((exp2 + 150) << 23) | (man & $007fffff)

PRI numdigits(man, pdiv) : numdig | divisor
{{
  This routine determines the number of decimal digits in the number in man.
}}
  numdig := 10
  divisor := 1000000000
  repeat while (divisor > man)
    numdig--
    divisor /= 10
  long[pdiv] := divisor

PRI round10(digits, pman) : exp10 | numdig, divisor, rounder, man
{{
  This routine round the number poiinted to by pman to the number of decimal
  digits specified by "digits".
}}
  man := long[pman]
  exp10 := numdigits(man, @divisor) - digits
  if (digits < 0)'***************************************************************************************
' SpinLMM Demo
' Copyright (c) 2010 Dave Hein
' July 6, 2010
' See end of file for terms of use
'***************************************************************************************
' This program demostrates the use of SpinLMM with serial I/O and floating point
' operations.
'***************************************************************************************

    man := 0
  elseif (digits == 0)
    if (man / divisor => 5)
      man := 1
      exp10++
  elseif (exp10 > 0)
    rounder := 1
    repeat exp10
      rounder *= 10
    man :=(man + (rounder >> 1)) / rounder
    divisor /= rounder
    if (man / divisor > 9)
      man /= 10
      exp10++
  elseif (exp10 < 0)
    repeat 0-exp10
      man *= 10
  long[pman] := man

PRI utoa10(number, str, point) | divisor, temp
{{
  This routine converts the value in "number" to a string of decimal characters
  in "str".  A decimal point is added after the character position specified by
  the value in "point".
}}
  if (number == 0)
    byte[str++] := "0"
    byte[str] := 0
    return str
  divisor := 1_000_000_000
  repeat while (divisor > number)
    divisor /= 10
  repeat while (divisor > 0)
    if (point-- == 0)
      byte[str++] := "."
    temp := number / divisor
    byte[str++] := temp + "0"
    number -= temp * divisor
    divisor /= 10
  byte[str] := 0
  return str

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
