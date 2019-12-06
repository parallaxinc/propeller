{{ NIST-P192.spin }}
CON

  Nwords  = 6
  Nbuffer = 2 * Nwords
  Nbytes  = 4 * Nbuffer


  ' specific to a particular NIST prime field:
  IDLE        = 0
  OP_ADD      = 1   ' r := a + b
  OP_SUB      = 2   ' r := a - b
  OP_MULT     = 3   ' r := a * b
  OP_HALVE    = 4   ' r := r/2
  OP_SETPRIME = 6   ' r := p
  OP_SIZE     = 15  ' return the word size and workspace

  ' generic field operations can be done if Nwords is known:
'  OP_ISZERO   = 20
'  OP_ISONE    = 21
'  OP_ISEVEN   = 22
  OP_COMPARE  = 23
  OP_SETSMALL = 24
  OP_INVERSE  = 25

  ' generic ECC operations
  OP_ISINF     = 26
  OP_DOUBJAC   = 27
  OP_ADDAFF    = 28
  OP_ENSUREAFF = 29
  OP_MULTPOINT1= 30
  OP_MULTPOINT = 31
  OP_SETINF    = 32
  OP_CHECKCURVE = 33   ' verify 4a^3 = -27b^2
  OP_CHECKP    = 34    ' check y^2 = x^3 +ax +b
  OP_CHECKV    = 35    ' check  0 <= v < p
  OP_CHECKR    = 36    ' check  0 < r < n
  OP_SETP      = 37    ' set (xx,yy), and check
  OP_RESETP    = 38    ' reset (xx,yy) to curve default

  OP_SETUP     = 99
  OP_NOP       = 100



VAR
  long args[5]

  long prime [Nwords]
'  long abuf [Nwords]

  long Xbuf [Nwords]
  long Ybuf [Nwords]
  long Zbuf [Nwords]
  long xxbuf [Nwords]
  long yybuf [Nwords]
  long zzbuf [Nwords]
  long t1buf [Nwords]
  long t2buf [Nwords]
  long t3buf [Nwords]
  long t4buf [Nwords]
  long ubuf [Nwords]
  long vbuf [Nwords]
  long x1buf [Nwords]
  long x2buf [Nwords]
  long bbuf [Nwords]
  long nbuf [Nwords]
  long xorig [Nwords]
  long yorig [Nwords]

  long i
  long j
  long k
  long vv

  long comp

  long cog

PUB start | tmp
  repeat i from 0 to Nwords-1
    tmp := Nwords-i-1
    xxbuf [tmp] := xdata[i]
    xorig [tmp] := xdata[i]
    yybuf [tmp] := ydata[i]
    yorig [tmp] := ydata[i]
    bbuf  [tmp] := bdata[i]
    nbuf  [tmp] := ndata[i]
  setZP
  worksp := @Xbuf
  if cog == 0
    args[0] := OP_SIZE
    cog := 1+cognew (@p192, @args)
    repeat until args[0] == 0
  result := @args


PUB stop
  if cog <> 0
    cogstop (cog-1)


PUB setZP
  repeat i from 0 to Nwords-1
    Xbuf[i] := xxbuf[i]
    Ybuf[i] := yybuf[i]
    Zbuf[i] := 0
  Zbuf[0] := 1



DAT


' y^2 = x^3 - 3x + b
' prime =  ffffffff ffffffff ffffffff fffffffe ffffffff ffffffff
' order =  ffffffff ffffffff ffffffff 99def836 146bc9b1 b4d22831
' seed  =           3045ae6f c8422f64 ed579528 d38120ea e12196d5
' hash c = 3099d2bb bfcb2538 542dcd5f b078b6ef 5f3d6fe2 c745de65
'      b = 64210519 e59c80e7 0fa7e9ab 72243049 feb8deec c146b9b1
' b^2.c = -27
'      x = 188da80e b03090f6 7cbf20eb 43a18800 f4ff0afd 82ff1012
'      y = 07192b95 ffc8da78 631011ed 6b24cdd5 73f977a1 1e794811

primedata      long $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFE, $FFFFFFFF, $FFFFFFFF
ndata          long $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $99DEF836, $146BC9B1, $B4D22831
bdata          long $64210519, $E59C80E7, $0FA7E9AB, $72243049, $FEB8DEEC, $C146B9B1
xdata          long $188DA80E, $B03090F6, $7CBF20EB, $43A18800, $F4FF0AFD, $82FF1012
ydata          long $07192B95, $FFC8DA78, $631011ED, $6B24CDD5, $73F977A1, $1E794811


                org     0

p192            rdlong  op, par
parse           mov     parm, par
                add     parm, #4
                rdlong  rp, parm
                add     parm, #4
                rdlong  a, parm
                add     parm, #4
                rdlong  b, parm
                sub     parm, #8

                neg     duration, cnt

                cmp     op, #OP_ADD  wz
        if_z    call    #add_p192

                cmp     op, #OP_SUB  wz
        if_z    call    #sub_p192

                cmp     op, #OP_MULT  wz
        if_z    call    #multiply

                cmp     op, #OP_HALVE  wz
        if_z    call    #halve_p192

                cmp     op, #OP_SETPRIME  wz
        if_z    call    #set_prime
{
                cmp     op, #OP_COMPARE  wz
        if_z    call    #compare

                cmp     op, #OP_SETSMALL  wz
        if_z    call    #set_small
}
                cmp     op, #OP_SIZE  wz
        if_nz   jmp     #:done
                mov     count, #6   ' word count
                wrlong  count, parm
                add     parm, #4
                wrlong  worksp, parm

:done
                add     duration, cnt

                add     parm, #4
                wrlong  duration, parm
                mov     op, #0
                wrlong  op, par
:wait
                rdlong  op, par
                cmp     op, #0  wz
        if_z    jmp     #:wait
                jmp     #parse



{{ ------------------- helpers for multiply matrix ------------------ }}


read_a          rdlong  a0l, a
                add     a, #4
                rdlong  a0h, a
                add     a, #4
                rdlong  a1l, a
                add     a, #4
                rdlong  a1h, a
                add     a, #4
                rdlong  a2l, a
                add     a, #4
                rdlong  a2h, a
read_a_ret      ret

read_b          rdlong  b0l, b
                add     b, #4
                rdlong  b0h, b
                add     b, #4
                rdlong  b1l, b
                add     b, #4
                rdlong  b1h, b
                add     b, #4
                rdlong  b2l, b
                add     b, #4
                rdlong  b2h, b
read_b_ret      ret


read_r          rdlong  r0l, rp
                add     rp, #4
                rdlong  r0h, rp
                add     rp, #4
                rdlong  r1l, rp
                add     rp, #4
                rdlong  r1h, rp
                add     rp, #4
                rdlong  r2l, rp
                add     rp, #4
                rdlong  r2h, rp
                sub     rp, #20  ' rp will be needed again
read_r_ret      ret


write_r
                wrlong  r0l, rp
                add     rp, #4
                wrlong  r0h, rp
                add     rp, #4
                wrlong  r1l, rp
                add     rp, #4
                wrlong  r1h, rp
                add     rp, #4
                wrlong  r2l, rp
                add     rp, #4
                wrlong  r2h, rp
                sub     rp, #20
write_r_ret     ret



{{ ---------------------------------- OLD mult_p192 --------------------------------- }}

multiply        call    #mult_p192
                call    #normal_p192
multiply_ret    ret

{{ ---------------------------------- mult_p192 --------------------------------- }}

mult_p192       call    #read_a
                call    #read_b


                ' 00
                mov     aal, a0l
                mov     aah, a0h
                mov     bbl, b0l
                mov     bbh, b0h
                call    #mult64x64
                mov     r0l, rr0
                mov     r0h, rr1
                mov     r1l, rr2
                mov     r1h, rr3
                ' 11
                mov     aal, a1l
                mov     aah, a1h
                mov     bbl, b1l
                mov     bbh, b1h
                call    #mult64x64
                mov     r2l, rr0
                mov     r2h, rr1
                mov     r3l, rr2
                mov     r3h, rr3

                ' 22
                mov     aal, a2l
                mov     aah, a2h
                mov     bbl, b2l
                mov     bbh, b2h
                call    #mult64x64
                mov     r4l, rr0
                mov     r4h, rr1
                mov     r5l, rr2
                mov     r5h, rr3

                ' 01 and 10
                mov     aal, a0l
                mov     aah, a0h
                add     aal, a1l  wc
                addx    aah, a1h  wc
                muxc    aac, #1
                mov     bbl, b1l
                mov     bbh, b1h
                add     bbl, b0l  wc
                addx    bbh, b0h  wc
                muxc    bbc, #1
                call    #mult65x65
                sub     rr0, r0l  wc
                subx    rr1, r0h  wc
                subx    rr2, r1l  wc
                subx    rr3, r1h  wc
                subx    rr4, #0
                sub     rr0, r2l  wc
                subx    rr1, r2h  wc
                subx    rr2, r3l  wc
                subx    rr3, r3h  wc
                subx    rr4, #0
                mov     pp0, rr0
                mov     pp1, rr1
                mov     pp2, rr2
                mov     pp3, rr3
                mov     pp4, rr4

                ' 12 and 21
                mov     aal, a1l
                mov     aah, a1h
                add     aal, a2l  wc
                addx    aah, a2h  wc
                muxc    aac, #1
                mov     bbl, b2l
                mov     bbh, b2h
                add     bbl, b1l  wc
                addx    bbh, b1h  wc
                muxc    bbc, #1
                call    #mult65x65
                sub     rr0, r2l  wc
                subx    rr1, r2h  wc
                subx    rr2, r3l  wc
                subx    rr3, r3h  wc
                subx    rr4, #0
                sub     rr0, r4l  wc
                subx    rr1, r4h  wc
                subx    rr2, r5l  wc
                subx    rr3, r5h  wc
                subx    rr4, #0
                mov     qq0, rr0
                mov     qq1, rr1
                mov     qq2, rr2
                mov     qq3, rr3
                mov     qq4, rr4

                ' 02 and 20
                mov     aal, a0l
                mov     aah, a0h
                add     aal, a2l  wc
                addx    aah, a2h  wc
                muxc    aac, #1
                mov     bbl, b2l
                mov     bbh, b2h
                add     bbl, b0l  wc
                addx    bbh, b0h  wc
                muxc    bbc, #1
                call    #mult65x65
                sub     rr0, r0l  wc
                subx    rr1, r0h  wc
                subx    rr2, r1l  wc
                subx    rr3, r1h  wc
                subx    rr4, #0
                sub     rr0, r4l  wc
                subx    rr1, r4h  wc
                subx    rr2, r5l  wc
                subx    rr3, r5h  wc
                subx    rr4, #0

                add     r2l, rr0  wc
                addx    r2h, rr1  wc
                addx    r3l, rr2  wc
                addx    r3h, rr3  wc
                addx    r4l, rr4  wc
                addx    r4h, #0  wc
                addx    r5l, #0  wc
                addx    r5h, #0

                add     r3l, qq0  wc
                addx    r3h, qq1  wc
                addx    r4l, qq2  wc
                addx    r4h, qq3  wc
                addx    r5l, qq4  wc
                addx    r5h, #0

                add     r1l, pp0  wc
                addx    r1h, pp1  wc
                addx    r2l, pp2  wc
                addx    r2h, pp3  wc
                addx    r3l, pp4  wc
                addx    r3h, #0  wc
                addx    r4l, #0  wc
                addx    r4h, #0  wc
                addx    r5l, #0  wc
                addx    r5h, #0

mult_p192_ret  ret


{{ ---------------------------------- mult65x65 --------------------------------- }}

                ' aac and bbc are top bits (regs are 0 or 1)
mult65x65       call    #mult64x64
                mov     rr4, #0
                test    aac, #1  wz  ' if a carried then add b * 2^64
        if_nz   add     rr2, bbl  wc
        if_nz   addx    rr3, bbh  wc
        if_nz   muxc    rr4, #1
                test    bbc, #1  wz  ' if b carried then add a * 2^64
        if_nz   add     rr2, aal  wc
        if_nz   addx    rr3, aah  wc
        if_nz   addx    rr4, #0
                and     aac, bbc     ' if both carried add 2^128
                add     rr4, aac
mult65x65_ret   ret


{{ ---------------------------------- mult64x64 --------------------------------- }}

mult64x64       mov     rr1, #0
                xor     rr0, rr0  wc  ' clear carry
                mov     count, #32
                mov     rr2, bbh
                mov     rr3, bbl

:loop1          shl     rr0, #1  wc
                rcl     rr1, #1  wc
                rcl     rr2, #1  wc
        if_nc   jmp     #:skip1
                add     rr0, aal  wc
                addx    rr1, aah  wc
                addx    rr2, #0
:skip1          djnz    count, #:loop1

                mov     count, #32

:loop2          shl     rr0, #1  wc
                rcl     rr1, #1  wc
                rcl     rr2, #1  wc
                rcl     rr3, #1  wc
        if_nc   jmp     #:skip2
                add     rr0, aal  wc
                addx    rr1, aah  wc
                addx    rr2, #0  wc
                addx    rr3, #0
:skip2          djnz    count, #:loop2

mult64x64_ret   ret


{{ ---------------------------------- normal_p192 --------------------------------- }}

normal_p192     mov     hh, #0   ' inter-word carry

                add     r0l, r3l  wc
                addx    hh, #0
                add     r0l, r5l  wc
                addx    hh, #0

                add     r0h, hh  wc
                mov     hh, #0
                addx    hh, #0
                add     r0h, r3h  wc
                addx    hh, #0
                add     r0h, r5h  wc
                addx    hh, #0

                add     r1l, hh  wc
                mov     hh, #0
                addx    hh, #0
                add     r1l, r3l  wc
                addx    hh, #0
                add     r1l, r4l  wc
                addx    hh, #0
                add     r1l, r5l  wc
                addx    hh, #0

                add     r1h, hh  wc
                mov     hh, #0
                addx    hh, #0
                add     r1h, r3h  wc
                addx    hh, #0
                add     r1h, r4h  wc
                addx    hh, #0
                add     r1h, r5h  wc
                addx    hh, #0

                add     r2l, hh  wc
                mov     hh, #0
                addx    hh, #0
                add     r2l, r4l  wc
                addx    hh, #0
                add     r2l, r5l  wc
                addx    hh, #0

                add     r2h, hh  wc
                mov     hh, #0
                addx    hh, #0
                add     r2h, r4h  wc
                addx    hh, #0
                add     r2h, r5h  wc
                addx    hh, #0

                cmp     hh, #0  wz    ' any overflow from 6'th word?
        if_z    jmp     #:last_check
                                      ' add back to words 0, 2
                call    #add_hh_2n_p

                ' if carry then must be small result, so after correction no last check needed
        if_c    jmp     #:correct

:last_check     ' if large value, could be equal or greater than the prime, so test for it.
                mov     hh, #1
                call    #add_hh_2n_p
        if_nc   call    #sub_2n_p
                jmp     #:write_back

:correct        mov     hh, #1
                call    #add_hh_2n_p

:write_back     call    #write_r
normal_p192_ret ret

add_hh_2n_p     add     r0l, hh  wc ' add hh*(2^192-p)
                addx    r0h, #0  wc
                addx    r1l, hh  wc
                addx    r1h, #0  wc
                addx    r2l, #0  wc
                addx    r2h, #0  wc
add_hh_2n_p_ret ret

sub_2n_p        sub     r0l, #1  wc
                subx    r0h, #0  wc
                subx    r1l, #1  wc
                subx    r1h, #0  wc
                subx    r2l, #0  wc
                subx    r2h, #0  wc
sub_2n_p_ret    ret

{{ ---------------------------------- add_p192 --------------------------------- }}

add_p192        call    #read_a_to_r
                call    #read_b
                add     r0l, b0l  wc
                addx    r0h, b0h  wc
                addx    r1l, b1l  wc
                addx    r1h, b1h  wc
                addx    r2l, b2l  wc
                addx    r2h, b2h  wc
                muxc    cc, #1     ' record if operation overflowed
                mov     hh, #1
                call    #add_hh_2n_p ' add 2^192-p
                test    cc, #1  wz
     if_nz_or_c jmp     #:done

                call    #sub_2n_p
:done
                call    #write_r
add_p192_ret    ret

read_a_to_r     rdlong  r0l, a
                add     a, #4
                rdlong  r0h, a
                add     a, #4
                rdlong  r1l, a
                add     a, #4
                rdlong  r1h, a
                add     a, #4
                rdlong  r2l, a
                add     a, #4
                rdlong  r2h, a
read_a_to_r_ret ret

{{ ---------------------------------- sub_p192 --------------------------------- }}


sub_p192        call    #read_a_to_r
                call    #read_b
                sub     r0l, b0l  wc
                subx    r0h, b0h  wc
                subx    r1l, b1l  wc
                subx    r1h, b1h  wc
                subx    r2l, b2l  wc
                subx    r2h, b2h  wc
        if_c    call    #sub_2n_p
                call    #write_r
sub_p192_ret    ret

{{ ---------------------------------- halve_p192 --------------------------------- }}

halve_p192      call    #read_r
                test    r0l, #1  wc     ' check LSB, only one that can't be halved by right shift alone
        if_nc   jmp     #:skipadd
                add     r1l, minus1  wc ' add in p+1 before right shift, (p+1)>>1 is 1/2
                addx    r1h, minus1  wc
                addx    r2l, minus1  wc
                addx    r2h, minus1  wc ' top bit of addition is shifted back at the top of result
:skipadd        rcr     r2h, #1  wc
                rcr     r2l, #1  wc
                rcr     r1h, #1  wc
                rcr     r1l, #1  wc
                rcr     r0h, #1  wc
                rcr     r0l, #1         
                call    #write_r
halve_p192_ret  ret

{
copy          mov       count, #6
:loop         rdlong    hh, a
              add       a, #4
              wrlong    hh, rp
              add       rp, #4
              djnz      count, #:loop
copy_ret      ret
}

set_reg       mov       count, #5
:loop         add       rp, #4
              wrlong    hh, rp
              djnz      count, #:loop
              sub       rp, #12
set_reg_ret   ret


set_small     wrlong    a, rp
              mov       hh, #0
              call      #set_reg
set_small_ret ret


set_prime     mov       hh, minus1
              wrlong    hh, rp
              call      #set_reg
              wrlong    minus2, rp
set_prime_ret ret


{
compare       xor       hh, hh  wz,wc
              mov       count, #6
              add       a, #20
              add       b, #20
:loop         rdlong    a0l, a
              sub       a, #4
              rdlong    b0l, b
              sub       b, #4
              cmp       a0l, b0l  wc,wz
        if_e  djnz      count, #:loop
:done   if_b  mov       hh, minus1
        if_a  mov       hh, #1
              wrlong    hh, rp
compare_ret   ret
}


minus1          long    $FFFFFFFF
minus2          long    $FFFFFFFE
H80000000       long    $80000000
H7FFFFFFF       long    $7FFFFFFF
D1              long    1<<9
aac             long    0
bbc             long    0
worksp          long    0

parm            res     1
duration        res     1
op              res     1
aa              res     1
count           res     1
cc              res     1

a               res     1
b               res     1

rp              res     1
r0l             res     1
r0h             res     1
r1l             res     1
r1h             res     1
r2l             res     1
r2h             res     1
r3l             res     1
r3h             res     1
r4l             res     1
r4h             res     1
r5l             res     1
r5h             res     1
hh              res     1

a0l             res     1
a0h             res     1
a1l             res     1
a1h             res     1
a2l             res     1
a2h             res     1

b0l             res     1
b0h             res     1
b1l             res     1
b1h             res     1
b2l             res     1
b2h             res     1

rr0             res     1
rr1             res     1
rr2             res     1
rr3             res     1
rr4             res     1
pp0             res     1
pp1             res     1
pp2             res     1
pp3             res     1
pp4             res     1
qq0             res     1
qq1             res     1
qq2             res     1
qq3             res     1
qq4             res     1

aal             res     1
aah             res     1
bbl             res     1
bbh             res     1

u               res     1
v               res     1
x1              res     1
x2              res     1
rtmp            res     1
btmp            res     1

                fit     $1F0

