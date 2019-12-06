'******************************************************************************
' Spin Method Pointer Object
' Version 1.1
' Copyright (c) 2010 - 2014 Dave Hein
' See end of file for terms of use.
'******************************************************************************
{{
  This object implements method pointers.  A method pointer points to an array
  of two longs that contains the object base address, variable base address, stack
  variable size and starting address of a method.  The contents of the method
  struct can be set up with SetMethodPtr if the object and method numbers are known.
  Otherwise, SetMethodPtrEx can be used by placing a dummy call to the target method
  immediately after the call to SetMethodPtrEx as follows:

    if SetMethodPtrEx(@methodstruct)
      sample.Example(0, 0, 0)

  SetMethodPtrEx always returns a value of zero, so the following function call will
  not be performed.

  The target method can be called with the method pointer by calling CallMethodN
  where "N" is the number of parameters passed to the target method.  As an example,
  sample.Example would be called with CallMethod3(parm1, parm2, parm3, @methodstruct).

  The method pointer can be used to implement a callback technique by passing the method
  pointer as a parameter.  The method pointer is not limited to methods that are compiled
  and linked with a program.  It could be used call methods that are stored in the DAT area
  or downloaded from a disk file.  In this case, it would be the responsiblity of the
  calling program to properly set up the elements of the method struct.
}}

pub Initialize | methodstruct[2]
{{
  This method calls the CallMethod routines to intialize them.  It should be called only once
  at the beginning of a program.  methodstruct is set up for a dummy routine in case this
  method is called more than once.
}}
  SetMethodPtr(@methodstruct, 0, 2) ' Initialize methodstruct for dummy routine
  CallMethod0(@methodstruct)
  CallMethod1(0, @methodstruct)
  CallMethod2(0, 0, @methodstruct)
  CallMethod3(0, 0, 0, @methodstruct)
  CallMethod4(0, 0, 0, 0, @methodstruct)
  CallMethod5(0, 0, 0, 0, 0, @methodstruct)

pub Dummy

pub SetMethodPtr(methodptr, objnum, methnum) | pbase, vbase, doffset, pcurr, dbase, index
{{
  This method sets up the method struct using the object number and method number that are
  passed as arguments.  The object and variable base addresses are extracted from the calling
  frame on the stack.  If the object number is zero the method's starting address and
  stack variable size is extracted from the caller's method table based on the method
  number.  If the object number is not zero the object and variable bases are adjusted by
  the offsets in the caller's method table, and the starting address and stack varible size
  are extractd from the method table of the reference object.
}} 
  dbase := @result                    ' Get current dbase
  pbase := word[dbase][-4] & $fffc    ' Get caller's pbase
  vbase := word[dbase][-3]            ' Get caller's vbase
  if objnum                           ' If non-zero object number update pbase and vbase from new object
    index := (objnum << 1)            ' Word index is two times object number
    vbase += word[pbase][index + 1]   ' Add object's var offset to vbase
    pbase += word[pbase][index]       ' Add object offset to pbase
  index := (methnum << 1)             ' Word index is two times method number
  pcurr := word[pbase][index] + pbase ' Get method's absolute starting address
  doffset := word[pbase][index + 1]   ' Get method's stack variable space size
  word[methodptr]    := pcurr         ' Save method's starting address in method pointer
  word[methodptr][1] := vbase         ' Save vbase in method pointer
  word[methodptr][2] := doffset       ' Save stack variable space size in method pointer 
  word[methodptr][3] := pbase         ' Save pbase in method pointer

pub SetMethodPtrEx(methodptr) | objnum, methnum, pbase, vbase, doffset, pcurr, dbase, index, addr, opcode
{{
  This object sets up the method struct based on the object number and method number used
  in the method call that immediatly follows the call to this method.  It assumes that this
  method was called as follows:

    if SetMethodPtrEx(@methodstruct)
      sample.Example(0, 0, 0)

  SetMethodPtrEx always return a value of zero, so the subsequent method call will not
  be perform.  It examines the opcodes in the caller's code to extract the object number
  and method number.  Object arrays can be used, but the index must be a constant value.
}}
  dbase := @result                    ' Get current dbase
  addr := word[dbase][-1]             ' Get the return address
  addr += 3                           ' Skip jz, addr and ldfrm
  index := 0                          ' Initialize the object array index to zero
  repeat                              ' Search for call, callobj or callobjx
    opcode := byte[addr++]
    if opcode == $05                  ' call
      objnum~                         ' Clear object number
      methnum := byte[addr]           ' Get method number
      quit
    if opcode == $06                  ' callobj
      objnum := byte[addr++]          ' Get object number
      methnum := byte[addr]           ' Get method number
      quit
    if opcode == $07                  ' callobjx
      objnum := byte[addr++] + index  ' Get object number and add index
      methnum := byte[addr]           ' Get method number
      quit
    if opcode == $36                  ' Check for load constant 1 op
      index := 1                      
    elseif opcode == $37              ' Check for load packed constant op
      opcode := byte[addr++]
      index := 2 << opcode & $1f
      if opcode & $20
        index--
      if opcode & $40
        !index
    elseif opcode == $38               ' Check for load constant byte op
      index := byte[addr++]
  pbase := word[dbase][-4] & $fffc    ' Get caller's pbase
  vbase := word[dbase][-3]            ' Get caller's vbase
  if objnum                           ' If non-zero object number update pbase and vbase from new object
    index := (objnum << 1)            ' Word index is two times object number
    vbase += word[pbase][index + 1]   ' Add object's var offset to vbase
    pbase += word[pbase][index]       ' Add object offset to pbase
  index := (methnum << 1)             ' Word index is two times method number
  pcurr := word[pbase][index] + pbase ' Get method's absolute address
  doffset := word[pbase][index + 1]   ' Get method's stack variable space size
  word[methodptr]    := pcurr         ' Save method's starting address in method pointer
  word[methodptr][1] := vbase         ' Save vbase in method pointer
  word[methodptr][2] := doffset       ' Save stack variable space size in method pointer 
  word[methodptr][3] := pbase         ' Save pbase in method pointer

pub CallMethod0(methodptr) | dbase
{{
  This method uses the method pointer to set up the object base addres, the variable
  base address and the stack pointer.  It then jumps to the method's starting address.
  The taget method has no additional calling parameters.
}}
  dbase := @result
  outb := word[methodptr][3]              ' Set pbase
  outb := word[methodptr][1]              ' Set vbase
  outb := word[methodptr][2] + 4 + dbase  ' Set stack offset
  outb := word[methodptr]                 ' Jump to method by setting pcurr
  WriteOps

pub CallMethod1(arg1, methodptr) | dbase
{{
  This method uses the method pointer to set up the object base addres, the variable
  base address and the stack pointer.  It then jumps to the method's starting address.
  The taget method has one calling parameter.
}}
  dbase := @result
  outb := word[methodptr][3]              ' Set pbase
  outb := word[methodptr][1]              ' Set vbase
  outb := word[methodptr][2] + 8 + dbase  ' Set stack offset
  outb := word[methodptr]                 ' Jump to method by setting pcurr
  WriteOps

pub CallMethod2(arg1, arg2, methodptr) | dbase
{{
  This method uses the method pointer to set up the object base addres, the variable
  base address and the stack pointer.  It then jumps to the method's starting address.
  The taget method has two calling parameters.
}}
  dbase := @result
  outb := word[methodptr][3]              ' Set pbase
  outb := word[methodptr][1]              ' Set vbase
  outb := word[methodptr][2] + 12 + dbase ' Set stack offset
  outb := word[methodptr]                 ' Jump to method by setting pcurr
  WriteOps

pub CallMethod3(arg1, arg2, arg3, methodptr) | dbase
{{
  This method uses the method pointer to set up the object base addres, the variable
  base address and the stack pointer.  It then jumps to the method's starting address.
  The taget method has three calling parameters.
}}
  dbase := @result
  outb := word[methodptr][3]              ' Set pbase
  outb := word[methodptr][1]              ' Set vbase
  outb := word[methodptr][2] + 16 + dbase ' Set stack offset
  outb := word[methodptr]                 ' Jump to method by setting pcurr
  WriteOps
  
pub CallMethod4(arg1, arg2, arg3, arg4, methodptr) | dbase
{{
  This method uses the method pointer to set up the object base addres, the variable
  base address and the stack pointer.  It then jumps to the method's starting address.
  The taget method has four calling parameters.
}}
  dbase := @result
  outb := word[methodptr][3]              ' Set pbase
  outb := word[methodptr][1]              ' Set vbase
  outb := word[methodptr][2] + 20 + dbase ' Set stack offset
  outb := word[methodptr]                 ' Jump to method by setting pcurr
  WriteOps

pub CallMethod5(arg1, arg2, arg3, arg4, arg5, methodptr) | dbase
{{
  This method uses the method pointer to set up the object base addres, the variable
  base address and the stack pointer.  It then jumps to the method's starting address.
  The taget method has five calling parameters.
}}
  dbase := @result
  outb := word[methodptr][3]              ' Set pbase
  outb := word[methodptr][1]              ' Set vbase
  outb := word[methodptr][2] + 24 + dbase ' Set stack offset
  outb := word[methodptr]                 ' Jump to method by setting pcurr
  WriteOps

pub WriteOps | addr
{{
  This routine writes the register address for pbase, vbase, dcurr and pcurr into the
  code of the calling routine.  It requires that these register addresses are used
  at the precise offsets that are used.
}}
  addr := word[@result][-1]  ' Get return address
  byte[addr-24] := $ab       ' $1eb - pbase
  byte[addr-19] := $ac       ' $1ec - vbase
  byte[addr-8]  := $af       ' $1ef - dcurr
  byte[addr-4]  := $ae       ' $1ee - pcurr

{{
+--------------------------------------------------------------------
|  TERMS OF USE: MIT License
+--------------------------------------------------------------------
Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files
(the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge,
publish, distribute, sublicense, and/or sell copies of the Software,
and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
+------------------------------------------------------------------
}}