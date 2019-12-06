'***************************************************************************************
' SpinLMM Demo
' Copyright (c) 2010 Dave Hein
' July 6, 2010
' See end of file for terms of use
'***************************************************************************************
' This program demostrates the use of SpinLMM with serial I/O and floating point
' operations.
'***************************************************************************************
CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

OBJ
  lmm : "SpinLMM"
  ser : "HalfDuplexSerial"
  f   : "float_lmm"
  fstr: "floatstr"

PUB main | temp, instr[20], tokens[3], temp1, temp2, outstr[20], cycles

  waitcnt(clkfreq+cnt)

  lmm.start

  help

  repeat
    ser.dbprintf0(string("\nEnter Command: "))
    ser.getstr(@instr, 80)
    tokenize(@instr, @tokens)
    if strcomp(tokens[0], string("float"))
      temp := ser.strtodec(tokens[1])
      cycles := cnt
      temp1 := f.FFloat(temp)
      cycles := cnt - cycles
      fstr.PutFloatE(@outstr, temp1, -1, -1)
      ser.dbprintf2(string("float(%d) = %s\n"), temp, @outstr)
    elseif strcomp(tokens[0], string("round"))
      temp := fstr.strtofloat(tokens[1])
      cycles := cnt
      temp1 := f.FRound(temp)
      cycles := cnt - cycles
      ser.dbprintf2(string("round(%s) = %d\n"), tokens[1], temp1)
    elseif strcomp(tokens[0], string("trunc"))
      temp := fstr.strtofloat(tokens[1])
      cycles := cnt
      temp1 := f.FTrunc(temp)
      cycles := cnt - cycles
      ser.dbprintf2(string("trunc(%s) = %d\n"), tokens[1], temp1)
    elseif strcomp(tokens[0], string("add"))
      temp := fstr.strtofloat(tokens[1])
      temp1 := fstr.strtofloat(tokens[2])
      cycles := cnt
      f.FAdd(temp, temp1)
      cycles := cnt - cycles
      fstr.PutFloatE(@outstr, f.FAdd(temp, temp1), -1, -1)
      ser.dbprintf3(string("add(%s, %s) = %s\n"), tokens[1], tokens[2], @outstr)
    elseif strcomp(tokens[0], string("sub"))
      temp := fstr.strtofloat(tokens[1])
      temp1 := fstr.strtofloat(tokens[2])
      cycles := cnt
      f.FSub(temp, temp1)
      cycles := cnt - cycles
      fstr.PutFloatE(@outstr, f.FSub(temp, temp1), -1, -1)
      ser.dbprintf3(string("sub(%s, %s) = %s\n"), tokens[1], tokens[2], @outstr)
    elseif strcomp(tokens[0], string("mul"))
      temp := fstr.strtofloat(tokens[1])
      temp1 := fstr.strtofloat(tokens[2])
      cycles := cnt
      f.FMul(temp, temp1)
      cycles := cnt - cycles
      fstr.PutFloatE(@outstr, f.FMul(temp, temp1), -1, -1)
      ser.dbprintf3(string("mul(%s, %s) = %s\n"), tokens[1], tokens[2], @outstr)
    elseif strcomp(tokens[0], string("div"))
      temp := fstr.strtofloat(tokens[1])
      temp1 := fstr.strtofloat(tokens[2])
      cycles := cnt
      f.FDiv(temp, temp1)
      cycles := cnt - cycles
      fstr.PutFloatE(@outstr, f.FDiv(temp, temp1), -1, -1)
      ser.dbprintf3(string("div(%s, %s) = %s\n"), tokens[1], tokens[2], @outstr)
    else
      Help
      next

    ser.dbprintf1(string("%d cycles\n"), cycles)


PUB Help
  ser.dbprintf0(string("\nCommands\n"))
  ser.dbprintf0(string("--------\n"))
  ser.dbprintf0(string("float inum\n"))
  ser.dbprintf0(string("round fnum\n"))
  ser.dbprintf0(string("trunc fnum\n"))
  ser.dbprintf0(string("add fnum fnum\n"))
  ser.dbprintf0(string("sub fnum fnum\n"))
  ser.dbprintf0(string("mul fnum fnum\n"))
  ser.dbprintf0(string("div fnum fnum\n"))

PUB tokenize(ptr, ptokens)
   repeat 3
     ptr := SkipChar(ptr, " ")
     long[ptokens] := ptr
     ptokens += 4
     ptr := FindChar(ptr, " ")
     if byte[ptr]
       byte[ptr++] := 0

PUB SkipChar(ptr, char)
  repeat while byte[ptr]
    if byte[ptr] <> char
      quit
    ptr++
  result := ptr

PUB FindChar(ptr, char)
  repeat while byte[ptr]
    if byte[ptr] == char
      quit
    ptr++
  result := ptr

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
