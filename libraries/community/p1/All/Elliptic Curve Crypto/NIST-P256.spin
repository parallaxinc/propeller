{{ NIST-P256.spin }}
CON

  Nwords  = 8
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
    cog := 1+cognew (@p256, @args)
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

'Curve P-256
' prime = ffffffff 00000001 00000000 00000000 00000000 ffffffff ffffffff ffffffff
' order = ffffffff 00000000 ffffffff ffffffff bce6faad a7179e84 f3b9cac2 fc632551
' seed  =                            c49d3608 86e70493 6a6678e1 139d26b7 819f7e90
' hashout
'     c = 7efba166 2985be94 03cb055c 75d4f7e0 ce8d84a9 c5114abc af317768 0104fa0d
'     b = 5ac635d8 aa3a93e7 b3ebbd55 769886bc 651d06b0 cc53b0f6 3bce3c3e 27d2604b
'    Gx = 6b17d1f2 e12c4247 f8bce6e5 63a440f2 77037d81 2deb33a0 f4a13945 d898c296
'    Gy = 4fe342e2 fe1a7f9b 8ee7eb4a 7c0f9e16 2bce3357 6b315ece cbb64068 37bf51f5

primedata      long $ffffffff, $00000001, $00000000, $00000000, $00000000, $ffffffff, $ffffffff, $ffffffff
ndata          long $ffffffff, $00000000, $ffffffff, $ffffffff, $bce6faad, $a7179e84, $f3b9cac2, $fc632551
bdata          long $5ac635d8, $aa3a93e7, $b3ebbd55, $769886bc, $651d06b0, $cc53b0f6, $3bce3c3e, $27d2604b
xdata          long $6b17d1f2, $e12c4247, $f8bce6e5, $63a440f2, $77037d81, $2deb33a0, $f4a13945, $d898c296
ydata          long $4fe342e2, $fe1a7f9b, $8ee7eb4a, $7c0f9e16, $2bce3357, $6b315ece, $cbb64068, $37bf51f5


                ORG     0

p256            rdlong  op, par
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
        if_z    call    #add_p256

                cmp     op, #OP_SUB  wz
        if_z    call    #sub_p256

                cmp     op, #OP_MULT  wz
        if_z    call    #multiply

                cmp     op, #OP_HALVE  wz
        if_z    call    #halve_p256

                cmp     op, #OP_SETPRIME  wz
        if_z    call    #set_prime

                cmp     op, #OP_COMPARE  wz
        if_z    call    #compare

                cmp     op, #OP_SETSMALL  wz
        if_z    call    #set_small

                cmp     op, #OP_SIZE  wz
        if_nz   jmp     #:done
                mov     count, #8   ' word count
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


read_a          rdlong  a0, a
                add     a, #4
                rdlong  a1, a
                add     a, #4
                rdlong  a2, a
                add     a, #4
                rdlong  a3, a
                add     a, #4
                rdlong  a4, a
                add     a, #4
                rdlong  a5, a
                add     a, #4
                rdlong  a6, a
                add     a, #4
                rdlong  a7, a
read_a_ret      ret

read_b          rdlong  b0, b
                add     b, #4
                rdlong  b1, b
                add     b, #4
                rdlong  b2, b
                add     b, #4
                rdlong  b3, b
                add     b, #4
                rdlong  b4, b
                add     b, #4
                rdlong  b5, b
                add     b, #4
                rdlong  b6, b
                add     b, #4
                rdlong  b7, b
read_b_ret      ret


read_r          rdlong  r0, r
                add     r, #4
                rdlong  r1, r
                add     r, #4
                rdlong  r2, r
                add     r, #4
                rdlong  r3, r
                add     r, #4
                rdlong  r4, r
                add     r, #4
                rdlong  r5, r
                add     r, #4
                rdlong  r6, r
                add     r, #4
                rdlong  r7, r
                sub     r, #28  ' rp will be needed again
read_r_ret      ret


write_r
                wrlong  r0, r
                add     r, #4
                wrlong  r1, r
                add     r, #4
                wrlong  r2, r
                add     r, #4
                wrlong  r3, r
                add     r, #4
                wrlong  r4, r
                add     r, #4
                wrlong  r5, r
                add     r, #4
                wrlong  r6, r
                add     r, #4
                wrlong  r7, r
                sub     r, #28
write_r_ret     ret



{{ ---------------------------------- multiply --------------------------------- }}

multiply        call    #mult_p256
                call    #normal_p256
		call	#write_r
multiply_ret    ret

{{ ---------------------------------- mult_p256 --------------------------------- }}

mult_p256       call    #read_a
                call    #read_b
		
		movd	:clrins, #r0
		mov	count, #16
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
		mov	count1, #4
:loop1
		movs	:blins, #b0
		movs	:bhins, #b1
		mov	count2, #4
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

		sub	:r0ins, D6
		sub	:r1ins, D6
		sub	:r2ins, D6
		sub	:r3ins, D6
		sub	:rninit, #6

		add	:alins, #2
		add	:ahins, #2

		djnz	count1, #:loop1
mult_p256_ret   ret


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


{{ ---------------------------------- normal_p256 --------------------------------- }}

normal_p256     mov     rc, #0   
		mov	count, #2
:loop
		add	r3, r11  wc
		addx	r4, r12  wc
		addx	r5, r13  wc
		addx	r6, r14  wc
		addx	r7, r15  wc
		addx	rc, #0         ' do again

		add	r3, r12  wc
		addx	r4, r13  wc
		addx	r5, r14  wc
		addx    r6, r15  wc
		addx	r7, #0  wc
		addx	rc, #0         ' do again

		djnz	count, #:loop

		add	r0, r8  wc
		addx	r1, r9  wc
		addx	r2, r10  wc
		addx	r3, #0  wc
		addx	r4, #0  wc
		addx	r5, #0  wc
		addx	r6, r14  wc
		addx	r7, r15  wc
		addx	rc, #0

		add	r0, r9  wc
		addx	r1, r10  wc
		addx	r2, r11  wc
		addx	r3, r13  wc
		addx	r4, r14  wc
		addx	r5, r15  wc
		addx	r6, r13  wc
		addx	r7, r8  wc
		addx	rc, #0

		sub	r0, r11  wc
		subx	r1, r12  wc
		subx	r2, r13  wc
		subx	r3, #0  wc
		subx	r4, #0  wc
		subx	r5, #0  wc
		subx	r6, r8  wc
		subx	r7, r10  wc
		subx	rc, #0

		sub	r0, r12  wc
		subx	r1, r13  wc
		subx	r2, r14  wc
		subx	r3, r15  wc
		subx	r4, #0  wc
		subx	r5, #0  wc
		subx	r6, r9  wc
		subx	r7, r11  wc
		subx	rc, #0

		sub	r0, r13  wc
		subx	r1, r14  wc
		subx	r2, r15  wc
		subx	r3, r8  wc
		subx	r4, r9  wc
		subx	r5, r10  wc
		subx	r6, #0  wc
		subx	r7, r12  wc
		subx	rc, #0

		sub	r0, r14  wc
		subx	r1, r15  wc
		subx	r2, #0  wc
		subx	r3, r9  wc
		subx	r4, r10  wc
		subx	r5, r11  wc
		subx	r6, #0  wc
		subx	r7, r13  wc
		subx	rc, #0

		call	#norm_small
normal_p256_ret ret


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



norm_check	cmp	r7, minus1  wc,wz
	if_b	jmp	#norm_check_ret
		cmp	r6, #1  wc,wz
	if_b	jmp	#norm_check_ret
	if_a	jmp	#:correct
		cmp	r5, #0  wc,wz
	if_a	jmp	#:correct
		cmp	r4, #0  wc,wz
	if_a	jmp	#:correct
		cmp	r3, #0  wc,wz
	if_a	jmp	#:correct
		cmp	r2, minus1  wc,wz
	if_b	jmp	#norm_check_ret
		cmp	r1, minus1  wc,wz
	if_b	jmp	#norm_check_ret
		cmp	r0, minus1  wc,wz
	if_b	jmp	#norm_check_ret
:correct	mov	hh, #1
		call	#sub_mult_p
norm_check_ret  ret		



sub_mult_p	sub	r3, hh  wc
		subx	r4, #0  wc
		subx	r5, #0	wc
		subx	r6, hh	wc
		subx	r7, #0	wc
		subx	rc, hh
		add	r0, hh  wc
		addx	r1, #0  wc
		addx	r2, #0  wc
		addx	r3, #0  wc
		addx	r4, #0  wc
		addx	r5, #0  wc
		addx	r6, #0  wc
		addx	r7, hh  wc
		addx	rc, #0
sub_mult_p_ret  ret



add_mult_p	add	r3, hh  wc
		addx	r4, #0  wc
		addx	r5, #0	wc
		addx	r6, hh	wc
		addx	r7, #0	wc
		addx	rc, hh
		sub	r0, hh  wc
		subx	r1, #0  wc
		subx	r2, #0  wc
		subx	r3, #0  wc
		subx	r4, #0  wc
		subx	r5, #0  wc
		subx	r6, #0  wc
		subx	r7, hh  wc
		subx	rc, #0
add_mult_p_ret	ret


{{ ---------------------------------- add_p256 --------------------------------- }}

read_a_to_r     rdlong  r0, a
                add     a, #4
                rdlong  r1, a
                add     a, #4
                rdlong  r2, a
                add     a, #4
                rdlong  r3, a
                add     a, #4
                rdlong  r4, a
                add     a, #4
                rdlong  r5, a
                add     a, #4
                rdlong  r6, a
                add     a, #4
                rdlong  r7, a
read_a_to_r_ret ret

add_p256	call	#read_a_to_r
		call	#read_b
		add	r0, b0  wc
		addx	r1, b1  wc
		addx	r2, b2  wc
		addx	r3, b3  wc
		addx	r4, b4  wc
		addx	r5, b5  wc
		addx	r6, b6  wc
		addx	r7, b7  wc
		mov	rc, #0
		addx	rc, #0
		call	#norm_small
		call	#write_r
add_p256_ret	ret

{{ ---------------------------------- sub_p256 --------------------------------- }}

sub_p256	call	#read_a_to_r
		call	#read_b
		sub	r0, b0  wc
		subx	r1, b1  wc
		subx	r2, b2  wc
		subx	r3, b3  wc
		subx	r4, b4  wc
		subx	r5, b5  wc
		subx	r6, b6  wc
		subx	r7, b7  wc
		mov	rc, #0
		subx	rc, #0
		call	#norm_small
		call	#write_r
sub_p256_ret	ret



{{ ---------------------------------- halve_p256 --------------------------------- }}

halve_p256      call    #read_r
                test    r0, #1  wc     ' check LSB, only one that can't be halved by right shift alone
        if_nc   jmp     #:skipadd
		add	r3, #1  wc     ' add in p+1 before right shift, (p+1)>>1 is 1/2, carry bit set
		addx	r4, #0  wc
		addx	r5, #0  wc
		addx	r6, #1  wc
		addx	r7, minus1  wc
:skipadd        rcr     r7, #1  wc
                rcr     r6, #1  wc
                rcr     r5, #1  wc
                rcr     r4, #1  wc
                rcr     r3, #1  wc
                rcr     r2, #1  wc
                rcr     r1, #1  wc
                rcr     r0, #1         
                call    #write_r
halve_p256_ret  ret


copy          mov       count, #8
:loop         rdlong    hh, a
              add       a, #4
              wrlong    hh, r
              add       r, #4
              djnz      count, #:loop
copy_ret      ret




set_small     wrlong    a, r
              mov       count, #7
:loop         add       r, #4
              wrlong    zero, r
              djnz      count, #:loop
set_small_ret ret


set_prime     mov	count, #3
:loop1	      
	      wrlong	minus1, r
	      add	r, #4
	      djnz	count, #:loop1
	      mov	count, #3
:loop2	      
	      wrlong	zero, r
	      add	r, #4
	      djnz	count, #:loop2
	      wrlong	one, r
	      add	r, #4
	      wrlong	minus1, r
set_prime_ret ret



compare       xor       hh, hh  wz,wc
              mov       count, #8
              add       a, #28
              add       b, #32
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



minus1          long    $FFFFFFFF
one		long	1
zero		long	0

D1              long    1<<9
D2		long	2<<9
D6		long	6<<9

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
rc              res     1


a0              res     1
a1              res     1
a2              res     1
a3              res     1
a4              res     1
a5              res     1
a6              res     1
a7              res     1


b0              res     1
b1              res     1
b2              res     1
b3              res     1
b4              res     1
b5              res     1
b6              res     1
b7              res     1




aal             res     1
aah             res     1
bbl             res     1
bbh             res     1
rr0		res	1
rr1		res	1
rr2		res	1
rr3		res	1

                FIT     $1F0

