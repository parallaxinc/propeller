{{
////////////////////////////////////////////////////////////////////////////////////////////
//                  SHA-256.spin
// SHA-256 implementation in PASM

// Author: Mark Tillotson
// Updated: 2012-02-03
// Designed For: P8X32A
// Version: 1.0

// Provides Start,
//   Functions:

//   PUB Start

//   PUB Stop

//   PUB clearHash
//       reset state for new hash and wipe any values from last use

//   PUB addByte (b)
//         b is an 8-bit byte to append to the hash input - the hash is maintained
//         on the fly for you

//   PUB addByteVec (bv, size)
//         bv is address of a byte vector to append to the hash input
//         size is the number of bytes to process

//   PUB getByteCount
//       returns the number of bytes processed so far in this use of the hash function
//       (ie since calcHashXXX or Clear calls)

//   PUB calcHash (resvec)
//       calculate the hash value for the input so far (since last calcHashXXX or reset)
//       and write the 32 byte _binary_ digest to the resvec (a byte vector).  Automatically
//       then resets the state as by Clear

//   PUB calcHashHex(resvec)
//       as calcHash() but writes a 65 byte hex string (null terminated) to the resvec

//   PUB calcDoubleHash(resvec)
//       as calcHash() but calls the hash function on the output of the hash function,
//       ie calculates  SHA-256 (SHA-256 (input)).  Writes 32 byte binary digest

//   PUB calcDoubleHashHex(resvec)
//       as calcDoubleHash () but writes a 65 byte null-terminated hex digest string

// Note that there is currently no lock protocol

// See end of file for standard MIT licence / terms of use.

// Update History:

// v1.0 - Initial version 2012-02-03

////////////////////////////////////////////////////////////////////////////////////////////
}}

CON
  IDLE = 0
  OP_RESET = 1
  OP_PROC_BYTE = 2
  OP_PROC_BVEC = 3
  OP_FINAL = 4
  OP_FINAL_HEX = 5
  OP_LENGTH = 6


VAR
  long  cog
  long  args[3]


PUB Start
  args[0] := OP_RESET
  if cog == 0
    cog := cognew (@entry, @args) + 1
  if cog <> 0
    repeat until args[0] == 0
  result := cog-1

PUB Stop
  if cog <> 0
    cogstop (cog-1)
    cog := 0

PUB clearHash
  args[0] := OP_RESET
  repeat until args[0] == 0

PUB addByte(bb)
  args[1] := bb
  args[0] := OP_PROC_BYTE
  repeat until args[0] == 0

PUB addByteVec(bv, size)
  args[1] := bv
  args[2] := size
  args[0] := OP_PROC_BVEC
  repeat until args[0] == 0

PUB getByteCount
  args[0] := OP_LENGTH
  repeat until args[0] == 0
  result := args[1]

PUB calcHash(resvec)
  args[1] := resvec
  args[0] := OP_FINAL
  repeat until args[0] == 0

PUB calcHashHex(resvec)
  args[1] := resvec
  args[0] := OP_FINAL_HEX
  repeat until args[0] == 0

PUB calcDoubleHash(resvec)
  calcHash(resvec)
  addByteVec(resvec, 32)
  calcHash(resvec)

PUB calcDoubleHashHex(resvec)
  calcHash(resvec)
  addByteVec(resvec, 32)
  calcHashHex(resvec)


DAT

		ORG	0

entry		rdlong	op, par
		cmp	op, #0  wz
	if_z	jmp	#entry
                neg     duration, cnt

		cmp	op, #OP_PROC_BYTE  wz
	if_z	call	#proc_byte
		cmp	op, #OP_PROC_BVEC  wz
	if_z	call	#proc_vec
		cmp	op, #OP_FINAL  wz
		mov	hexflag, #0
	if_z	call	#finalize
		cmp	op, #OP_FINAL_HEX  wz
		mov	hexflag, #1
	if_z	call	#finalize
		cmp	op, #OP_RESET  wz
	if_z	call	#reset
		cmp	op, #OP_LENGTH  wz
	if_z	call	#get_len

:done
                add     duration, cnt
                mov     parm, par
                add     parm, #8
                wrlong  duration, parm
		mov	op, #0
		wrlong	op, par
		jmp	#entry

{ --------------------------------------------------- }

get_len         mov	parm, par
		add	parm, #4
		mov	length0, len_low
		shr	length0, #3
		add	length0, phase
		mov	length1, len_hi
		shl	length1, #29
		or	length0, length1
		wrlong  length0, parm
		add	parm, #4
		wrlong  len_hi, parm
get_len_ret	ret
		
{ --------------------------------------------------- }

reset		movd	:wrins, #W0   ' reset allows another run of the SHA-256 hash function 
		mov	count, #64    ' but also wipes _all_ state previous call
:wrins		mov	W0, #0
		add	:wrins, D1
		djnz	count, #:wrins

		mov	H0, Hval0
		mov	H1, Hval1
		mov	H2, Hval2
		mov	H3, Hval3
		mov	H4, Hval4
		mov	H5, Hval5
		mov	H6, Hval6
		mov	H7, Hval7

		mov	a, #0
		mov	b, #0
		mov	c, #0
		mov	d, #0
		mov	e, #0
		mov	f, #0
		mov	g, #0
		mov	h, #0

		mov	T1, #0
		mov	T2, #0
		mov	r, #0
		mov	t, #0
		mov	tt, #0
		mov	x, #0
		mov	byt, #0
		mov	wrd, #0
		
		mov	len_low, #0
		mov	len_hi,  #0
                mov     phase, #0
reset_ret	ret

{ --------------------------------------------------- }


finalize	mov	parm, par     ' param is the byte address for resultant hash digest
		add	parm, #4      ' (uses 32 bytes for binary, 65 bytes for hex)
		rdlong	resaddr, parm 
		call	#finish	      ' first process padding and final block
		
		movs	:getins, #H0  ' iterate the H0..H7 regs
		mov	count, #8

:getins		mov	wrd, H0
		add	:getins, #1
		mov	count2, #4
:loop
		rol	wrd, #8      ' inner loop 4 times shifting through the bytes
		cmp	hexflag, #0  wz  ' (in big-endian order)
	if_z	wrbyte  wrd, resaddr     ' either direct output for binary
	if_z	add	resaddr, #1
	if_nz	call	#writehex        ' or call to hex-digit subroutine
		djnz	count2, #:loop

		djnz	count, #:getins
                cmp     hexflag, #0  wz  ' if hex was output we zero-terminate the string
        if_nz   mov     wrd, #0
        if_nz   wrbyte  wrd, resaddr
		call	#reset
finalize_ret	ret

{ --------------------------------------------------- }

writehex	mov	byt, wrd       ' output a byte in hex at resaddr
		shr	byt, #4
		and	byt, #15
		call	#writedig
		mov	byt, wrd
		and	byt, #15
		call	#writedig
writehex_ret	ret


writedig	cmp	byt, #10  wz,wc ' output hex digit
	if_b	add	byt, #"0"
	if_ae	add	byt, #("a" - 10)
		wrbyte  byt, resaddr
		add	resaddr, #1
writedig_ret	ret


{ --------------------------------------------------- }

{ Here we know that 64 bytes have been shifted into the W0..W15 registers
  in big-endian order.  Run the schedule that fills the other 48 longs of block
}
block_sched	movd	:stins, #W16   ' all done with modified instructions
		movs	:ld1ins, #W14
		movs	:add1ins, #W9
		movs	:ld2ins, #W1
		movs	:add2ins, #W0
		mov	count, #48

:ld1ins		mov	x, W14       ' W(t-2)
		add	:ld1ins, #1
        	mov	r, x         ' little sigma1 operation
		shr	r, #10
		rol	r, #19
		xor	r, x
		ror	r, #2
		xor	r, x
		ror	r, #17
:add1ins	add	r, W9        ' add in W(t-7)
		add	:add1ins, #1
:ld2ins		mov	x, W1        ' W(t-15)
		add	:ld2ins, #1
		mov	t, x         ' little sigma0 operation
		shr	t, #3
		rol	t, #18
		xor	t, x
		ror	t, #11
		xor	t, x
		ror	t, #7
		add	r, t
:add2ins	add	r, W0         ' add in W(t-16)
		add	:add2ins, #1
:stins		mov	W16, r        ' finally store the new word
		add	:stins, D1
		djnz	count, #:ld1ins
block_sched_ret ret


{ --------------------------------------------------- }

{ Main block processing loop - loop 64 times updating state vars a,b,c,d,e,f,g,h
  from the block, eventually updating H0..H7
}
block_loop	mov	a, H0
		mov	b, H1
		mov	c, H2
		mov	d, H3
		mov	e, H4
		mov	f, H5
		mov	g, H6
		mov	h, H7

		movs	:kins, #K0
		movs	:wins, #W0
		mov	count, #64
:loop
		mov	T1, e     ' big sigma1 on e
		ror	T1, #14
		xor	T1, e
		ror	T1, #5
		xor	T1, e
		ror	T1, #6

		add	T1, h

		mov	t, f     ' Ch(e,f,g)
		and	t, e
		mov	tt, g
		andn	tt, e
		xor	t, tt

		add	T1, t
:kins		add	T1, K0
		add	:kins, #1
:wins		add	T1, W0
		add	:wins, #1

		mov	T2, a    ' big sigma0 on a
		ror	T2, #9
		xor	T2, a
		ror	T2, #11
		xor	T2, a
		ror	T2, #2

        	mov	t, a     ' Maj(a, b, c)
		and	t, b
		mov	tt, b
		and	tt, c
		xor	t, tt
		mov	tt, c
		and	tt, a
		xor	t, tt

		add	T2, t

		mov	h, g      ' cyclic permute and alter...
		mov	g, f
		mov	f, e
		mov	e, d
		add	e, T1
		mov	d, c
		mov	c, b
		mov	b, a
		mov	a, T1
		add	a, T2

		djnz    count, #:loop

		add	H0, a     ' finally update H0..H7
		add	H1, b
		add	H2, c
		add	H3, d
		add	H4, e
		add	H5, f
		add	H6, g
		add	H7, h
block_loop_ret	ret


{ --------------------------------------------------- }


proc_byte	mov	parm, par      ' param is byte
		add	parm, #4
		rdbyte	byt, parm
		call	#add_byte      ' so add it
proc_byte_ret	ret


{ --------------------------------------------------- }

proc_vec	mov	parm, par       ' params are address and byte-count
		add	parm, #4
		rdlong	byte_ptr, parm
		add	parm, #4
		rdlong	count2, parm
                cmp     count2, #0  wz  ' loop for count2 bytes
        if_z    jmp     #proc_vec_ret
:loop
		rdbyte	byt, byte_ptr   ' read byte from vector and process
		add	byte_ptr, #1
		call	#add_byte
		djnz	count2, #:loop
proc_vec_ret	ret


{ --------------------------------------------------- }

add_byte	and	byt, #$FF       ' ensure a byte
		mov	reg, phase
		shr	reg, #2	        ' wphase is word offset in block
		add	reg, #W0        ' address the W regs
		movs	:getins, reg	' setup the instructions
		movd	:setins, reg
:getins		mov	t, W0           ' update the word in the block
		shl	t, #8		' shift in the correct byte
		or	t, byt
:setins		mov	W0, t

                add     phase, #1       ' update counts now (len_low/hi only
		cmp	phase, #$40  wz ' advanced when block processed)
	if_nz	jmp	#add_byte_ret
                add	len_low, H200  wc
		addx	len_hi, #0
                mov     phase, #0
		call	#block_sched    ' two parts of block processing done now
		call	#block_loop
add_byte_ret	ret

{ --------------------------------------------------- }

finish          mov     length0, len_low ' record true length of message
                mov     length1, len_hi  ' before padding updates len_low/hi
                shl     phase, #3        ' phase is a byte count, times 8
                add     length0, phase   ' this cannot overflow as len_lo was multiple of 512
                shr     phase, #3
		mov	byt, #$80       ' add a one bit immediately after last input byte
:loop
		call	#add_byte
		mov	byt, #0
		cmp	phase, #$38  wz ' keep addings zeroes till at 56th byte in 64 byte block
	if_nz	jmp	#:loop

		mov	wrd, length1    ' write the 64bit length, bigendian
		call	#add_word
		mov	wrd, length0
		call	#add_word       ' will just have filled/processed a block
finish_ret	ret

{ --------------------------------------------------- }

add_word	rol	wrd, #8         ' big endian order of byte handling
		mov	byt, wrd
		call	#add_byte
                rol	wrd, #8
		mov	byt, wrd
		call	#add_byte
                rol	wrd, #8
		mov	byt, wrd
		call	#add_byte
                rol	wrd, #8
		mov	byt, wrd
		call	#add_byte
add_word_ret	ret


{ --------------------------------------------------- }


D1		long	1<<9
D1S1		long	(1<<9)+1
H200            long    $200

Hval0		long	$6A09E667
Hval1		long	$BB67AE85
Hval2		long	$3C6EF372
Hval3		long	$A54FF53A
Hval4		long	$510E527F
Hval5		long	$9B05688C
Hval6		long	$1F83D9AB
Hval7		long	$5BE0CD19


K0		long    $428A2F98, $71374491, $B5C0FBCF, $E9B5DBA5, $3956C25B, $59F111F1, $923F82A4, $AB1C5ED5
		long    $D807AA98, $12835B01, $243185BE, $550C7DC3, $72BE5D74, $80DEB1FE, $9BDC06A7, $C19BF174
		long    $E49B69C1, $EFBE4786, $0FC19DC6, $240CA1CC, $2DE92C6F, $4A7484AA, $5CB0A9DC, $76F988DA
		long    $983E5152, $A831C66D, $B00327C8, $BF597FC7, $C6E00BF3, $D5A79147, $06CA6351, $14292967
		long    $27B70A85, $2E1B2138, $4D2C6DFC, $53380D13, $650A7354, $766A0ABB, $81C2C92E, $92722C85
		long    $A2BFE8A1, $A81A664B, $C24B8B70, $C76C51A3, $D192E819, $D6990624, $F40E3585, $106AA070
		long 	$19A4C116, $1E376C08, $2748774C, $34B0BCB5, $391C0CB3, $4ED8AA4A, $5B9CCA4F, $682E6FF3
		long    $748F82EE, $78A5636F, $84C87814, $8CC70208, $90BEFFFA, $A4506CEB, $BEF9A3F7, $C67178F2



W0		res	1
W1		res	8
W9		res	5
W14		res	2
W16		res	48

a		res	1
b		res	1
c		res	1
d		res	1
e		res	1
f		res	1
g		res	1
h		res	1

H0		res	1
H1		res	1
H2		res	1
H3		res	1
H4		res	1
H5		res	1
H6		res	1
H7		res	1

op              res     1
parm            res     1
duration        res     1
t		res	1
tt              res     1
r               res     1
reg             res     1
x               res     1
T1		res	1
T2		res	1
count		res	1
count2		res	1
phase		res	1
wrd		res	1
byt		res	1
byte_ptr	res	1
resaddr         res     1
len_low		res	1
len_hi		res	1
length0         res     1
length1         res     1
hexflag         res     1

		FIT	$1F0

{{
////////////////////////////////////////////////////////////////////////////////////////////
//                                TERMS OF USE: MIT License
////////////////////////////////////////////////////////////////////////////////////////////
// Permission is hereby granted, free of charge, to any person obtaining a copy of this 
// software and associated documentation files (the "Software"), to deal in the Software 
// without restriction, including without limitation the rights to use, copy, modify, merge,
// publish, distribute, sublicense, and/or sell copies of the Software, and to permit 
// persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
// PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
// FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
// DEALINGS IN THE SOFTWARE.
////////////////////////////////////////////////////////////////////////////////////////////
}}
