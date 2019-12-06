{{ NIST-P384.spin }}
CON

  Nwords  = 12
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

  OP_SETUP     = 99
  OP_NOP       = 100



VAR
  long args[5]

  long prime [Nwords]
  long abuf [Nwords]

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
    cog := 1+cognew (@p384, @args)
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

' Curve P-384
' prime = ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff fffffffe ffffffff 00000000 00000000 ffffffff
' order = ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff c7634d81 f4372ddf 581a0db2 48b0a77a ecec196a ccc52973
' seed  =                                                                a335926a a319a27a 1d00896a 6773a482 7acdac73
'     c = 79d1e655 f868f02f ff48dcde e14151dd b80643c1 406d0ca1 0dfe6fc5 2009540a 495e8042 ea5f744f 6e184667 cc722483
'     b = b3312fa7 e23ee7e4 988e056b e3f82d19 181d9c6e fe814112 0314088f 5013875a c656398d 8a2ed19d 2a85c8ed d3ec2aef
'     x = aa87ca22 be8b0537 8eb1c71e f320ad74 6e1d3b62 8ba79b98 59f741e0 82542a38 5502f25d bf55296c 3a545e38 72760ab7
'     y = 3617de4a 96262c6f 5d9e98bf 9292dc29 f8f41dbd 289a147c e9da3113 b5f0b8c0 0a60b1ce 1d7e819d 7a431d7c 90ea0e5f

primedata       long    $ffffffff, $ffffffff, $ffffffff, $ffffffff, $ffffffff, $ffffffff
	        long    $ffffffff, $fffffffe, $ffffffff, $00000000, $00000000, $ffffffff
ndata           long    $ffffffff, $ffffffff, $ffffffff, $ffffffff, $ffffffff, $ffffffff
                long    $c7634d81, $f4372ddf, $581a0db2, $48b0a77a, $ecec196a, $ccc52973
bdata           long    $b3312fa7, $e23ee7e4, $988e056b, $e3f82d19, $181d9c6e, $fe814112
	        long    $0314088f, $5013875a, $c656398d, $8a2ed19d, $2a85c8ed, $d3ec2aef
xdata           long    $aa87ca22, $be8b0537, $8eb1c71e, $f320ad74, $6e1d3b62, $8ba79b98
	        long    $59f741e0, $82542a38, $5502f25d, $bf55296c, $3a545e38, $72760ab7
ydata           long    $3617de4a, $96262c6f, $5d9e98bf, $9292dc29, $f8f41dbd, $289a147c
	        long    $e9da3113, $b5f0b8c0, $0a60b1ce, $1d7e819d, $7a431d7c, $90ea0e5f


                ORG     0

p384            rdlong  op, par
parse           mov     parm, par
                add     parm, #4
                rdlong  r, parm
                add     parm, #4
                rdlong  a, parm
                add     parm, #4
                rdlong  b, parm
                sub     parm, #8

                neg     duration, cnt

                cmp     op, #OP_ADD  wz
        if_z    call    #add_p384

                cmp     op, #OP_SUB  wz
        if_z    call    #sub_p384

                cmp     op, #OP_MULT  wz
        if_z    call    #multiply

                cmp     op, #OP_HALVE  wz
        if_z    call    #halve_p384

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
                mov     count, #12   ' word count
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


read_a          movd    :rdains, #a0
		mov	count, #12
:loop
:rdains         rdlong  a0, a
		add	:rdains, D1
                add     a, #4
		djnz	count, #:loop
read_a_ret      ret


read_b          movd    :rdbins, #b0
		mov	count, #12
:loop
:rdbins         rdlong  b0, b
		add	:rdbins, D1
                add     b, #4
		djnz	count, #:loop
read_b_ret      ret


read_r          movd    :rdrins, #r0
		mov	count, #12
:loop
:rdrins         rdlong  r0, r
		add	:rdrins, D1
                add     r, #4
		djnz	count, #:loop
		sub	r, #48
read_r_ret      ret



write_r		movd	:wrins, #r0
		mov	count, #12
:loop
:wrins          wrlong  r0, r
		add	:wrins, D1
                add     r, #4
		djnz	count, #:loop
                sub     r, #48
write_r_ret     ret



{{ ---------------------------------- multiply --------------------------------- }}

multiply        call    #mult_p384
                call    #normal_p384
		call	#write_r
multiply_ret    ret

{{ ---------------------------------- mult_p384 --------------------------------- }}

mult_p384       call    #read_a
                call    #read_b
		
		movd	:clrins, #r0
		mov	count, #24
:clrins		mov	r0, #0
		add	:clrins, D1
		djnz	count, #:clrins

		movs	:alins, #a0
		movs	:ahins, #a1
		movd	:r0ins, #r0
		movd	:r1ins, #r1
		movd	:r2ins, #r2
		movd	:r3ins, #r3
		movs	:rninit, #r4
		mov	count1, #6
:loop1
		movs	:blins, #b0
		movs	:bhins, #b1
		mov	count2, #6
:loop2
:alins		mov	aal, a0
:ahins		mov	aah, a1

:blins		mov	bbl, b0
		add	:blins, #2
:bhins		mov	bbh, b1
		add	:bhins, #2

		call	#mult64x64

:r0ins		add	r0, rr0  wc
		add	:r0ins, D2
:r1ins		addx	r1, rr1  wc
		add	:r1ins, D2
:r2ins		addx	r2, rr2  wc
		add	:r2ins, D2
:r3ins		addx	r3, rr3  wc
		add	:r3ins, D2
:rninit		movd	:rnins, #r4
		add	:rninit, #2

	if_nc	jmp	#:skip
:rnins		addx	r4, #0  wc
		add	:rnins, D1
	if_c	jmp	#:rnins
:skip
		djnz	count2, #:loop2

		sub	:r0ins, D10
		sub	:r1ins, D10
		sub	:r2ins, D10
		sub	:r3ins, D10
		sub	:rninit, #10

		add	:alins, #2
		add	:ahins, #2

		djnz	count1, #:loop1
mult_p384_ret   ret


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


{{ ---------------------------------- normal_p384 --------------------------------- }}

cyclic_add_12	mov     count, #12
		xor	hh, hh  wc
cyclic_add
addxins 	addx	r0, r12  wc
		add	addxins, D1S1
		djnz	count, #addxins
cyclic_add_12_ret
cyclic_add_ret  ret


cyclic_sub
subxins 	subx	r0, r12  wc
		add	subxins, D1S1
		djnz	count, #subxins
cyclic_sub_ret  ret


sub_last7	subx	r5, #0  wc
		subx	r6, #0  wc
		subx	r7, #0  wc
		subx	r8, #0  wc
		subx	r9, #0  wc
		subx	r10, #0  wc
		subx	r11, #0  wc
		subx	rc, #0
sub_last7_ret   ret


add_last4	addx	r8, #0	wc
		addx	r9, #0	wc
		addx	r10, #0	wc
		addx	r11, #0	wc
		addx	rc, #0
add_last4_ret   ret


normal_p384     mov     rc, #0   
		mov	count, #2
:loop
		add	r4, r21  wc
		addx	r5, r22  wc
		addx	r6, r23  wc
		addx	r7, #0	wc
		call	#add_last4
		djnz	count, #:loop

		movs	addxins, #r12
		movd	addxins, #r0
		call	#cyclic_add_12
		addx	rc, #0

		add	r0, r21  wc
		addx	r1, r22  wc
		addx	r2, r23  wc
		movs	addxins, #r12
		movd	addxins, #r3
		mov	count, #9
		call    #cyclic_add
		addx	rc, #0

		add	r1, r23  wc
		addx	r2, #0  wc
		addx	r3, r20  wc
                movs    addxins, #r12
                movd    addxins, #r4
                mov     count, #8
                call    #cyclic_add
		addx	rc, #0

		add	r4, r20	 wc
		addx	r5, r21  wc
		addx	r6, r22  wc
		addx	r7, r23  wc
		call	#add_last4

		add	r0, r20  wc
		addx	r1, #0  wc
		addx	r2, #0  wc
		addx	r3, r21	 wc
		addx	r4, r22	 wc
		addx	r5, r23	 wc
		addx	r6, #0	wc
		addx	r7, #0	wc
		call	#add_last4

		sub	r0, r23  wc
		movs	subxins, #r12
		movd	subxins, #r1
		mov	count, #11
		call	#cyclic_sub
		subx	rc, #0

		sub	r1, r20  wc
		subx	r2, r21  wc
		subx	r3, r22  wc
		subx	r4, r23  wc
		call	#sub_last7

		sub	r3, r23  wc
		subx	r4, r23  wc
		call	#sub_last7

		call	#norm_small
normal_p384_ret ret


norm_small      cmps	rc, #0  wc,wz
	if_a	jmp	#:too_large
	if_b	jmp	#:too_small
		' might be just higher than prime
:check_and_ret
		call	#norm_check
		jmp	#norm_small_ret
:too_large
		mov	hh, rc
		call	#sub_mult_p
		cmps	rc, #0  wc,wz
	if_a	jmp	#:too_large
		jmp	#:check_and_ret	
:too_small	
		neg	hh, rc
		call	#add_mult_p
		cmps	rc, #0  wc,wz
	if_b	jmp	#:too_small
norm_small_ret	ret



norm_check	cmp	r11, minus1  wz   ' first test quick, most likely case
	if_nz	jmp	#norm_check_ret
		mov	hh, r10
		and	hh, r9
		and	hh, r8
		and	hh, r7
		and	hh, r6
		and	hh, r5
		cmp	hh, minus1  wz
	if_nz	jmp	#norm_check_ret
		cmp	r4, minus2  wc,wz
	if_b	jmp	#norm_check_ret
	if_a	jmp	#:correct
		cmp	r3, minus1  wc,wz
	if_b	jmp	#norm_check_ret
		mov	hh, r2
		or	hh, r1  wz
	if_nz	jmp	#:correct
		cmp	r0, minus1  wc,wz
	if_b	jmp	#norm_check_ret
:correct	mov	hh, #1
		call	#sub_mult_p
norm_check_ret  ret		



add_chunk	addx    r5, #0  wc
		addx	r6, #0  wc
		addx	r7, #0  wc
		addx	r8, #0  wc
		addx	r9, #0  wc
		addx	r10, #0  wc
		addx	r11, #0  wc
add_chunk_ret   ret

sub_chunk	subx	r5, #0  wc
		subx	r6, #0  wc
		subx	r7, #0  wc
		subx	r8, #0  wc
		subx	r9, #0  wc
		subx	r10, #0  wc
		subx	r11, #0  wc
sub_chunk_ret   ret


sub_mult_p	sub	r1, hh  wc
		subx	r2, #0  wc
		subx    r3, #0  wc
		subx	r4, #0  wc
		call	#sub_chunk
		subx	rc, hh
		add	r0, hh  wc
		addx	r1, #0  wc
		addx	r2, #0  wc
		addx	r3, hh  wc
		addx	r4, hh  wc
		call	#add_chunk
		addx	rc, #0
sub_mult_p_ret  ret



add_mult_p	add	r1, hh  wc
		addx	r2, #0  wc
		addx    r3, #0  wc
		addx	r4, #0  wc
		call	#add_chunk
		addx	rc, hh
		sub	r0, hh  wc
		subx	r1, #0  wc
		subx	r2, #0  wc
		subx	r3, hh  wc
		subx	r4, hh  wc
		call	#sub_chunk
		subx	rc, #0
add_mult_p_ret	ret


{{ ---------------------------------- add_p384 --------------------------------- }}

read_a_to_r	movd    :rdins, #r0
		mov	count, #12
:loop
:rdins          rdlong  r0, a
		add	:rdins, D1
		add	a, #4
		djnz	count, #:loop
read_a_to_r_ret ret

add_loop	add     r0, b0  wc
		movs	:addxins, #b1
		movd	:addxins, #r1
		mov	count, #11
:loop
:addxins	addx	r1, b1  wc
		add	:addxins, D1S1
		djnz	count, #:loop
add_loop_ret    ret


add_p384	call	#read_a_to_r
		call	#read_b
		'call	#add_loop

                add     r0, b0  wc
                addx    r1, b1  wc
                addx    r2, b2  wc
                addx    r3, b3  wc
                addx    r4, b4  wc
                addx    r5, b5  wc
                addx    r6, b6  wc
                addx    r7, b7  wc
                addx    r8, b8  wc
                addx    r9, b9  wc
                addx    r10, b10  wc
                addx    r11, b11  wc

		mov	rc, #0
		addx	rc, #0
		call	#norm_small
		call	#write_r
add_p384_ret	ret

{{ ---------------------------------- sub_p384 --------------------------------- }}
{
sub_loop	sub     r0, b0  wc
		movs	:subxins, #b1
		movd	:subxins, #r1
		mov	count, #11
:loop
:subxins	subx	r1, b1  wc
		add	:subxins, D1S1
		djnz	count, #:loop
sub_loop_ret    ret
}

sub_p384	call	#read_a_to_r
		call	#read_b
		'call	#sub_loop
                sub     r0, b0  wc
                subx    r1, b1  wc
                subx    r2, b2  wc
                subx    r3, b3  wc
                subx    r4, b4  wc
                subx    r5, b5  wc
                subx    r6, b6  wc
                subx    r7, b7  wc
                subx    r8, b8  wc
                subx    r9, b9  wc
                subx    r10, b10  wc
                subx    r11, b11  wc

		mov	rc, #0
		subx	rc, #0
		call	#norm_small
		call	#write_r
sub_p384_ret	ret



{{ ---------------------------------- halve_p384 --------------------------------- }}

halve_p384      call    #read_r
                test    r0, #1  wc     ' check LSB, only one that can't be halved by right shift alone
        if_nc   jmp     #:skipadd
		add	r1, #1  wc     ' add in p+1 before right shift, (p+1)>>1 is 1/2, carry bit set
		addx	r2, #0  wc
		addx	r3, minus1  wc
		addx	r4, minus2  wc
		addx	r5, minus1  wc
		addx	r6, minus1  wc
		addx	r7, minus1  wc
		addx	r8, minus1  wc
		addx	r9, minus1  wc
		addx	r10, minus1  wc
		addx	r11, minus1  wc
:skipadd        rcr     r11, #1  wc
                rcr     r10, #1  wc
                rcr     r9, #1  wc
                rcr     r8, #1  wc
                rcr     r7, #1  wc
                rcr     r6, #1  wc
                rcr     r5, #1  wc
                rcr     r4, #1  wc
                rcr     r3, #1  wc
                rcr     r2, #1  wc
                rcr     r1, #1  wc
                rcr     r0, #1         
                call    #write_r
halve_p384_ret  ret

{

copy          mov       count, #12
:loop         rdlong    hh, a
              add       a, #4
              wrlong    hh, r
              add       r, #4
              djnz      count, #:loop
copy_ret      ret

}

{
set_small     wrlong    a, r
              mov       count, #11
:loop         add       r, #4
              wrlong    zero, r
              djnz      count, #:loop
set_small_ret ret
}

set_prime     wrlong	minus1, r
	      add	r, #4
	      wrlong	zero, r
	      add	r, #4
	      wrlong	zero, r
	      add	r, #4
	      wrlong	minus1, r
	      add	r, #4
	      wrlong	minus2, r
	      add	r, #4
	      mov	count, #7
:loop
	      wrlong	minus1, r
	      add	r, #4
	      djnz	count, #:loop
set_prime_ret ret


{
compare       xor       hh, hh  wz,wc
              mov       count, #12
              add       a, #44
              add       b, #48
:loop         rdlong    a0, a
              sub       a, #4
              sub       b, #4
              rdlong    b0, b
              cmp       a0, b0  wc,wz
        if_e  djnz      count, #:loop
:done   if_b  mov       hh, minus1
        if_a  mov       hh, one
              wrlong    hh, r
compare_ret   ret
}


minus1          long    $FFFFFFFF
minus2          long    $FFFFFFFE
one		long	1
zero		long	0

D1              long    1<<9
D2		long	2<<9
D10		long	10<<9
D1S1		long	(1<<9)+1

aac             long    0
bbc             long    0
worksp          long    0

parm            res     1
duration        res     1	
op              res     1
aa              res     1
count           res     1
count1          res     1
count2          res     1
cc              res     1
hh              res     1

a               res     1
b               res     1
r               res     1

r0              res     1
r1              res     1
r2              res     1
r3              res     1
r4              res     1
r5              res     1
r6              res     1
r7              res     1
r8              res     1
r9              res     1
r10             res     1
r11             res     1
r12             res     1
r13             res     1
r14             res     1
r15             res     1
r16             res     1
r17             res     1
r18             res     1
r19             res     1
r20             res     1
r21             res     1
r22             res     1
r23             res     1
rc              res     1


a0              res     1
a1              res     1
a2              res     1
a3              res     1
a4              res     1
a5              res     1
a6              res     1
a7              res     1
a8              res     1
a9              res     1
a10             res     1
a11             res     1


b0              res     1
b1              res     1
b2              res     1
b3              res     1
b4              res     1
b5              res     1
b6              res     1
b7              res     1
b8              res     1
b9              res     1
b10             res     1
b11             res     1




aal             res     1
aah             res     1
bbl             res     1
bbh             res     1
rr0		res	1
rr1		res	1
rr2		res	1
rr3		res	1

                FIT     $1F0

