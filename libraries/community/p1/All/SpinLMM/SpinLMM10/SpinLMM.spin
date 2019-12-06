'***************************************************************************************
' SpinLMM Interpreter  Version 1.0
' Copyright (c) 2010 Dave Hein, Tim Moore, Ray Rodrick (Cluso99)
' Contributors: Bill Henning, Steve Denson (jazzed), Terry Hitt (Bean)
' Permission granted by Chip Gracey for inclusion of portions of the Spin interpreter
' July 7, 2010
' See end of file for terms of use
'***************************************************************************************
' This object patches the LMM PASM interpreter into a running Spin interpreter.  It uses
' the locations that provide the sqrt, strsize, strcomp, coginit and lock functions.
' These functions continue to be supported as LMM PASM routines.
'
' When the start method is called a temporary LMM PASM interpreter is loaded at locations
' $1E0 to $1E4 and $1E6.  This is then executed by using the lookup instruction.
' The temporary LMM interpreter runs a LMM PASM program that writes the permanet LMM
' interpreter.  It then restores the original values in the $1EX locations and continues
' normal execution.
'
' A "run" method is provided to evoke the LMM interpreter.  The location of the LMM PASM
' program is passed to it, as well as a parameter.  It returns the result from the LMM
' PASM program.
'
' The FJMP, FCALL and FCACHE psuedo-ops are provided.
'
' Dave Hein, July 1, 2010
'
' Tim Moore
'
'       Add icall - indirect call via a jump table
'       Changed lmm to only pop 1 parameter
'       Change order of items so initialization code is together so it can be used
'
' Version 0.9, July 6, 2010
'
'       Renumbered reg0 through reg15 to reg8 through reg23
'       Added reg0 through reg7 aliases for x, y, a, t1, t2, op, op2 and adr
'       Changed indirect address register from t1 to reg7
'       Added run3 and run4 methods
'       Added MIT license
'
' Version 1.0, July 7, 2010
'
'***************************************************************************************
CON
  ' Addresses within the Spin interpreter
  x           = $000
  y           = $001
  a           = $002
  t1          = $003
  t2          = $004
  op          = $005
  op2         = $006
  adr         = $007
  loop        = $008
  pushz       = $044
  notx        = $0CD
  mtst2       = $12C
  maskpar     = $138
  push        = $158
  range_ret   = $1E4
  masklong    = $1E5
  lsb         = $1E8
  pcurr       = $1EE
  dcurr       = $1EF

  ' SpinLMM pseudo-ops and special registers
  fret        = $008
  fcache      = $064
  fcall       = $06C
  icall       = $06E
  ijmp        = $06F
  lmm_ret     = $072
  cache_addr  = $0A4
  fjmp        = $152
  lmm_loop    = $153
  lmm_pc      = $157
  fretx       = $158

  ' SpinLMM registers that alias x, y, a, t1, t2, op, op2 and addr
  reg0        = $000
  reg1        = $001
  reg2        = $002
  reg3        = $003
  reg4        = $004
  reg5        = $005
  reg6        = $006
  reg7        = $007

  ' SpinLMM registers that overlap the cache_addr area
  reg8        = $0A4
  reg9        = $0A5
  reg10       = $0A6
  reg11       = $0A7
  reg12       = $0A8
  reg13       = $0A9
  reg14       = $0AA
  reg15       = $0AB
  reg16       = $0AC
  reg17       = $0AD
  reg18       = $0AE
  reg19       = $0AF
  reg20       = $0B0
  reg21       = $0B1
  reg22       = $0B2
  reg23       = $0B3

' Execute the LMM PASM program pointed to by "code".
PUB run0(code)
  result := bytecode($64, $3C)

PUB run1(code, parm1)
  result := bytecode($68, $64, $3C)

PUB run2(code, parm1, parm2)
  result := bytecode($6C, $68, $64, $3C)

PUB run3(code, parm1, parm2, parm3)
  result := bytecode($70, $6C, $68, $64, $3C)

PUB run4(code, parm1, parm2, parm3, parm4)
  result := bytecode($74, $70, $6C, $68, $64, $3C)

' Patch the LMM intepreter into the Spin interpreter
PUB start
  Install(boot_loop, boot_loop[1], boot_loop[2], boot_loop[3], boot_loop[4])

' Load temporary LMM interpreter into locations $1E0, $1E1, $1E2, $1E3 and $1E6.
' Call lookup to run the LMM interpreter, which is replaced by a permanent intepreter
' at the sqrt/boolean not location.
PUB Install(xa, xb, xc, xd, xe)
  bytecode($64, $3F, $A0)
  bytecode($68, $3F, $A1)
  bytecode($6C, $3F, $A2)
  bytecode($70, $3F, $A3)
  bytecode($74, $3F, $A6)
  lookup(1:1..3)

PUB GetInit
  return @install_lmm_interp

'***************************************************************************************
'**** LMM PASM Code for patching the intepreter and providing sqrt, strsize and strcomp
'***************************************************************************************
DAT
'***************************************************************************************
' Square Root and Boolean Not LMM PASM code
'***************************************************************************************
muny3b                  mov     x,#0
        if_nz           jmp     #FJMP                   '!W
                        long    @@@boolnot

'Chip's smaller version: masksqrt = $40000000 gets used directly and rotated all the way back to orig. value
'math_F8                 mov     x,#0                    'reset root
                        mov     reg23,#1
                        shl     reg23,#30
                        jmp     #fcache
                        org     cache_addr
msqr                    or      x,reg23                 'set trial bit
                        cmpsub  y,x             wc      'subtract root from input if fits
                        sumnc   x,reg23                 'cancel trial bit, set root bit if fit
                        shr     x,#1                    'shift root down
                        ror     reg23,#2        wc      'shift mask down (wraps on last iteration)
        if_nc           jmp     #msqr
                        jmp     #push
                        long    0

boolnot                 cmp     x,y             wc      'boolean not
                        muxnc   x,masklong
                        jmp     #push

'***************************************************************************************
'        pop, run, strsize, strcomp
'***************************************************************************************
j5b     if_z            sub     dcurr,#4                'if pop/strsize, pop count/string
        if_z            rdlong  x,dcurr
        if_nc_and_z     sub     dcurr,x                 'if pop, subtract count from dcurr

        if_nc_and_nz    mov     lsb,pcurr               'if run, save pcurr and set to $FFFC
        if_nc_and_nz    mov     pcurr,maskpar

        if_nc           jmp     #loop                   'if pop/run, loop

        if_z            rdlong  lmm_pc, lmm_pc          'if strsize jump
                        long    @@@j5d

                        sub     dcurr,#4                'if strcomp, pop stringa/stringb
                        rdlong  y,dcurr
                        sub     dcurr,#4
                        rdlong  x,dcurr
                        rdbyte t1, x
                        add     x, #1
                        jmp     #fcache
                        org     cache_addr
j5c                     rdbyte  t2, y           wz
                        add     y, #1
                        sub     t2, t1
                        rdbyte  t1, x
                        add     x, #1
        if_nz           tjz     t2, #j5c
                        jmp     #mtst2
                        long    0

j5d                     mov     a,x
                        jmp     #fcache
                        org     cache_addr
j5e                     rdbyte  t1,a            wz
                        add     a,#1
        if_nz           jmp     #j5e
                        sub     x,a
                        jmp     #notx
                        long    0

'***************************************************************************************
' coginit, locknew, lockset, lockclr
'***************************************************************************************
jAb
jBb     if_c            rdlong  lmm_pc, lmm_pc          'lockclr/lockset?
                        long    @@@jA_lock

        if_z            sub     dcurr,#4                'coginit, pop parameters
        if_z            rdlong  a,dcurr
        if_z            sub     dcurr,#4                'coginit, pop parameters
        if_z            rdlong  y,dcurr
        if_z            sub     dcurr,#4
        if_z            rdlong  x,dcurr
        if_z            and     a,maskpar               'assemble fields
        if_z            shl     a,#16
        if_z            and     y,maskpar
        if_z            shl     y,#2
        if_z            or      y,a
        if_z            max     x,#8
        if_z            or      x,y
        if_z            coginit x               wc,wr

        if_nz           locknew x               wc      'locknew

        if_c            neg     x,#1                    '-1 if c, else 0..7
                        rdlong  lmm_pc, lmm_pc
                        long    @@@jA_push

jA_lock                 sub     dcurr,#4                'lockclr/lockset, pop id
                        rdlong  x,dcurr

        if_z            lockset x               wc      'clr/set lock
        if_nz           lockclr x               wc

                        muxc    x,masklong              '-1 if c, else 0


jA_push                 test    op,#%100        wz      'push result?
                        jmp     #pushz

'***************************************************************************************
' LMM PASM Code for patching the intepreter
'***************************************************************************************
                        org     0
install_lmm_interp      muxnz   reg8, #1                ' Save the zero flag

                        ' Copy full LMM intepreter into sqrt/not space
                        ' This code executes from the boot LMM interpreter
                        rdlong  reg12, boot_pc
                        long    @@@muny3a
                        mov     reg13, #$14A
                        mov     reg11, #13
                        mov     reg10, boot_pc
                        rdlong  boot_pc, boot_pc
                        long    @@@HubToCog

                        ' Patch the $3C to $3F command handler at $0D6
                        rdlong  lmm_pc, boot_pc
                        long    @@@jF
                        rdlong  $0D6, lmm_pc

                        ' Patch the pop, run, strsize and strcomp area
                        rdlong  reg12, boot_pc
                        long    @@@j5a
                        mov     reg13, #$062
                        mov     reg11, #16
                        mov     reg10, boot_pc
                        rdlong  boot_pc, boot_pc
                        long    @@@HubToCog

                        ' Patch the coginit, locknew, lockset, lockclr area
                        rdlong  lmm_pc, boot_pc
                        long    @@@jAa
                        rdlong  $0A1, lmm_pc
                        add     lmm_pc, #4
                        rdlong  $0A2, lmm_pc
                        add     lmm_pc, #4
                        rdlong  $0A3, lmm_pc

                        ' Switch control to the permanent LMM interpreter
                        rdlong  lmm_pc, boot_pc
                        long    @@@restore
                        jmp     #lmm_loop

                        ' Restore $1E0 to $1E3 and $1E6 to original values
restore                 rdlong  boot_pc, lmm_pc
                        long    @@@original_code
                        rdlong  $1E0, boot_pc
                        add     boot_pc, #4
                        rdlong  $1E1, boot_pc
                        add     boot_pc, #4
                        rdlong  $1E2, boot_pc
                        add     boot_pc, #4
                        rdlong  $1E3, boot_pc
                        add     boot_pc, #4
                        rdlong  $1E6, boot_pc

                        ' jump to $1E0 to resume normal execution
                        test    reg8, #1           wz   ' Restore the zero flag
                        jmp     #$1E0

                        ' Copy Hub RAM to Cog registers
                        ' reg10 contains the return address minus 8
                        ' reg11 contains the count
                        ' reg12 contains the hub address
                        ' reg13 contains the cog address
'***************************************************************************************
' This LMM PASM routine copies hub RAM to cog registers
'***************************************************************************************
HubToCog                mov     reg9, boot_pc           ' Get address of next long
                        add     reg9, #16               ' Get address of rdlong instrucntion
                        rdlong  reg9, reg9
                        movd    reg9, reg13             ' Move reg13 to hub destination
HubToCog1               wrlong  reg9, boot_pc           ' Save updated instruction in next long
                        rdlong  $000, reg12             ' Copy hub long to cog register
                        add     reg12, #4               ' Increment hub address
                        add     reg9, #$100             ' Increment the cog destination address
                        add     reg9, #$100
                        sub     reg11, #1          wz   ' Decrement count
         if_nz          sub     boot_pc, #28            ' Jump back 6 longs to HubToCog1
                        add     reg10, #8               ' Bump return address to correct point
                        mov     boot_pc, reg10          ' Return

                        '54 longs so far
'*************************************************************************************
'**** PASM code that is patched into the Spin interpreter
'*************************************************************************************
' Temporary boot LMM PASM Interpreter at $1E0
                        org     $1E0
boot_loop
                        rdlong  boot_instr, boot_pc     ' Get the instruction
                        add     boot_pc, #4             ' Increment the PC
boot_instr              nop                             ' Execute the instruction
                        jmp     #boot_loop              ' Return to the beginning of the loop
                        org     $1E6
boot_pc                 long    @@@install_lmm_interp   ' Program Counter

' Original Spin Interpreter code at Locations $1E0 to $1E3, and #1E6
                        org     $1E0
original_code
        if_c            xor     y,a
        if_c            xor     a,y
                        cmps    x,y             wc
        if_nc           cmps    a,x             wc
                        org     $1E6
                        long    $80000000

' Entry point for the $3C to $3F opcodes.  Jump instruction to the LMM interpreter
                        org     $0D6
jF                      jmp     #lmm_inter

' Permanent LMM PASM Interpreter that uses the pop, run, strsize and strcomp space
                        org     $062
j5a                     mov     lmm_pc, j5a+3
                        jmp     #lmm_loop
fcache_                 movd    fcache1, #fcache0
                        long    @@@j5b
fcache1                 rdlong  fcache0, lmm_pc wz
                        add     fcache1, #$100
                        add     fcache1, #$100
                        add     lmm_pc, #4
          if_nz         jmp     #fcache1
                        jmp     #fcache0
fcall_                  mov     lmm_retaddr, lmm_pc
                        jmp     #fjmp_
lmm_icall               mov     lmm_retaddr, lmm_pc     ' Save the return address, call via a jump table
lmm_ijmp                rdlong  lmm_pc, lmm_pc          ' jmp via a jump table
                        add     lmm_pc, reg7            ' reg7 contains start of table
                        jmp     #fjmp_
lmm_retaddr             long    0

' Permanent LMM PASM Interpreter that uses the coginit, locknew, lockset, lockclr
                        org     $0A1
jAa                     mov     lmm_pc, jAa+2
                        jmp     #lmm_loop
                        long    @@@jAb
fcache0                 res     16


' Permanent LMM PASM Interpreter that uses the square root and boolean not space
                        org     $14A
muny3a                  mov     lmm_pc, sqrt_addr       ' Load address for the LMM PASM routine
                        jmp     #lmm_loop
sqrt_addr               long    @@@muny3b

lmm_inter if_c_or_nz    rdbyte  x,pcurr                 ' Execute instruction replaced by jmp
          if_c_or_nz    jmp     #jF+1                   ' Jump back if opcode is not $3C
                        call    #popx                   ' Get LMM PASM address
                        mov     lmm_pc, x               ' Load address in the program counter
                        jmp     #lmm_loop

fjmp_                   rdlong  lmm_pc, lmm_pc          ' Perform jump by loading next long into PC

lmm_loop_               rdlong  instr, lmm_pc           ' Get the instruction
                        add     lmm_pc, #4              ' Increment the PC to next long address
instr                   nop                             ' Execute the instruction
                        jmp     #lmm_loop               ' Return to the beginning of the LMM loop

lmm_pc_                 long    0                       ' LMM Program Counter

                        '45 + 54 = 99longs
'***************************************************************************************
                        org     $1D8
popayx                  res     1                       ' Need to define popyx and poxyx_ret
                        org     $1DA
popyx                   res     1                       ' Need to define popyx and poxyx_ret
                        org     $1DC
popx                    res     1                       ' Need to define popyx and poxyx_ret
                        org     $1DE
popayx_ret
popx_ret
popyx_ret               res     1                       ' popyx_ret doesn't work if defined in CON

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
