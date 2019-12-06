'***************************************************************************************
' HalfDuplexSerial
' Copyright (c) 2010 Dave Hein
' July 6, 2010
' See end of file for terms of use
'***************************************************************************************
' This object implements a half-duplex serial port.  It is implemented in Spin and
'  LMM PASM.  The lmm.start method must be called before calling this object.
'
' The dbprintf method provide formatted output.  The dbprint0 to dbprintf6 methods are
' used depending on how many parameters are passed.
'***************************************************************************************
OBJ
  lmm : "SpinLMM"

CON
  ' LMM PASM constants
  reg0   = lmm#reg0
  reg1   = lmm#reg1
  reg2   = lmm#reg2
  reg3   = lmm#reg3
  reg4   = lmm#reg4
  fjmp   = lmm#fjmp
  fretx  = lmm#fretx
  lmm_pc = lmm#lmm_pc
  dcurr  = lmm#dcurr

' Run the txbyte LMM program to transmit a single byte at 57,600 baud
PUB tx(value)
  lmm.run1(@txbyte, value)

DAT                     org     0
txbyte                  mov     reg3, #1               ' Create P30 bitmask
                        shl     reg3, #30
                        or      outa, reg3             ' Set P30 high
                        or      dira, reg3             ' Set P30 for output
                        sub     dcurr, #4              ' Read byte off the stack
                        rdlong  reg0, dcurr
                        or      reg0, #$100            ' Add start and stop bits to byte
                        shl     reg0, #2
                        or      reg0, #1
                        mov     reg4, #11               ' Set count for 11 bits
                        mov     reg1, #174              ' Initialize for 460,800 baud
                        shl     reg1, #3                ' Reduce to 57,600 baud
                        mov     reg2, reg1              ' Initialize wait count
                        add     reg2, cnt
txbyte1                 shr     reg0, #1     wc         ' Output a bit to P30
                        muxc    outa, reg3
                        waitcnt reg2, reg1              ' Wait one bit time
                        djnz    reg4, #FJMP
                        long    @@@txbyte1
                        jmp     #FRETX                  ' Return

' Run the rxbyte LMM program to read a single byte at 57,600 baud
PUB rx
  result := lmm.run0(@rxbyte)

DAT                     org     0
rxbyte                  mov     reg3, #1                ' Create P31 bit mask
                        shl     reg3, #31
                        andn    dira, reg3              ' Set P31 for input
                        mov     reg4, #10               ' Set count for 10 bits
                        mov     reg1, #174              ' Initialize for 460,800 baud
                        shl     reg1, #3                ' Reduce to 57,600 baud
                        mov     reg2, reg1              ' Initialize for one-half bit time
                        shr     reg2, #1
rxbyte1                 test    reg3, ina       wc      ' Wait for start bit
           if_c         sub     lmm_pc, #8
                        add     reg2, cnt               ' Add CNT to one-half bit time
rxbyte2                 waitcnt reg2, reg1              ' Wait to sample bit
                        test    reg3, ina         wc
                        rcr     reg0, #1                ' Shift bit into MSB
                        djnz    reg4, #FJMP
                        long    @@@rxbyte2
                        shr     reg0, #23               ' Right justify
                        and     reg0, #$FF              ' Remove stop bit
                        jmp     #FRETX                  ' Return byte

' Convert a string of hex digits to a number
PUB strtohex(ptr)
  repeat 8
    case byte[ptr]
      "0".."9": result := (result << 4) + byte[ptr++] - "0"
      "a".."f": result := (result << 4) + byte[ptr++] - "a" + 10
      "A".."F": result := (result << 4) + byte[ptr++] - "A" + 10
      other: quit

' Convert a string of hex digits to a number
PUB strtodec(ptr)
  repeat
    case byte[ptr]
      "0".."9": result := (result * 10) + byte[ptr++] - "0"
      other: quit

' Read a string from the serial port and echo each character received
PUB getstr(ptr, num) | i, value
  repeat i from 0 to num - 2
    byte[ptr][i] := value := rx
    tx(value)
    if value == 13
      quit
  byte[ptr][i] := 0

' Transmit a string out the serial port
PUB str(ptr)
  repeat while byte[ptr]
    tx(byte[ptr++])

' Convert a number to hex characters and transmit out the serial port
PUB hex(value, digits)
'' Print a hexadecimal number
  value <<= (8 - digits) << 2
  repeat digits
    tx(lookupz((value <-= 4) & $F : "0".."9", "A".."F"))

PUB dec(value) | i
'' Print a decimal number
  if (value < 0)
    tx("-")
    if (value == NEGX)
      tx("2")
      value += 2_000_000_000
    value := -value

  i := 1_000_000_000
  repeat while (i > value and i > 1)
    i /= 10
  repeat while (i > 0)
    tx(value/i + "0")
    value //= i
    i /= 10

PUB bin(value, digits)
'' Print a binary number
  value <<= 32 - digits
  repeat digits
    tx((value <-= 1) & 1 + "0")

PUB dbprintf0(fmtstr)
  dbprintf(fmtstr, @fmtstr)

PUB dbprintf1(fmtstr, arg1)
  dbprintf(fmtstr, @arg1)

PUB dbprintf2(fmtstr, arg1, arg2)
  dbprintf(fmtstr, @arg1)

PUB dbprintf3(fmtstr, arg1, arg2, arg3)
  dbprintf(fmtstr, @arg1)

PUB dbprintf4(fmtstr, arg1, arg2, arg3, arg4)
  dbprintf(fmtstr, @arg1)

PUB dbprintf5(fmtstr, arg1, arg2, arg3, arg4, arg5)
  dbprintf(fmtstr, @arg1)

PUB dbprintf6(fmtstr, arg1, arg2, arg3, arg4, arg5, arg6)
  dbprintf(fmtstr, @arg1)

PUB dbprintf(fmtstr, arglist) | arg, val, digits
  arg := long[arglist]
  arglist += 4
  repeat while (val := byte[fmtstr++])
    if (val == "%")
      digits := 0
      repeat
        case (val := byte[fmtstr++])
          "d" : dec(arg)
          "x" :
            ifnot digits
              digits := 8
            hex(arg, digits)
          "b" :
            ifnot digits
              digits := 32
            bin(arg, digits)
          "s" : str(arg)
          "0".."9":
             digits := (digits * 10) + val - "0"
             next
          0  : return
          other: tx(val)
        quit
      arg := long[arglist]
      arglist += 4
    elseif (val == "\")
      case (val := byte[fmtstr++])
        "n"  : tx(13)
        0    : return
        other: tx(val)
    else
      tx(val)

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
