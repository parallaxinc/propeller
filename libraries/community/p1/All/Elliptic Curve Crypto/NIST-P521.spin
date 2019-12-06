{{ p521.spin }}
CON
  MERSENNE_BITS = 521

  NW = (MERSENNE_BITS+31)/32   ' actually 17 longs
  NB = NW*4                    ' number bytes
  Nt = NB-4                    ' address offset to top word
  NWW = 2*NW   ' twice as long (extra guard word for normalization)
  NBB = NWW*4
  NTT = NBB-4

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


  NARGS = 7


VAR
  long Xbuf[NW]
  long Ybuf[NW]
  long Zbuf[NW]
  long xxbuf[NW]
  long yybuf[NW]
  long zzbuf[NW]
  long t1buf[NW]
  long t2buf[NW]
  long t3buf[NW]
  long t4buf[NW]
  long ubuf[NW]
  long vbuf[NW]
  long x1buf[NW]
  long x2buf[NW]
  long bbuf[NW]
  long nbuf[NW]
  long xorig [NW]
  long yorig [NW]

  long tbuf[NWW]    ' these should be contiguous buffers

  long i
  long cog

  long args[NARGS]

PUB start | tmp
  repeat i from 0 to NW-1
    tmp := NW-i-1
    xxbuf [tmp] := xdata[i]
    xorig [tmp] := xdata[i]
    yybuf [tmp] := ydata[i]
    yorig [tmp] := ydata[i]
    bbuf  [tmp] := bdata[i]
    nbuf  [tmp] := ndata[i]
  setZP

  if cog == 0
    args[0] := 0       ' completion flag, non-zero on finished, zero triggers cog
    args[6] := @Xbuf   ' workspace address (Xbuf..tBuf)
    ' initialize and set cog waiting for instructions:
    args[4] := OP_NOP
    cog := 1+cognew (@p521, @args)
    if cog <> 0
      repeat until args[0] == 0
  result := @args


PUB stop
  if cog <> 0
    cogstop (cog-1)
    cog := 0


PUB setZP
  repeat i from 0 to Nw-1
    Xbuf[i] := xxbuf[i]
    Ybuf[i] := yybuf[i]
    Zbuf[i] := 0
  Zbuf[0] := 1




DAT

{{ Data }}
' Curve P-521
' prime = 1ff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff
' order = 1ff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff fffffffa 51868783 bf2f966b 7fcc0148 f709a5d0 3bb5c9b8 899c47ae bb6fb71e 91386409
' seed =    d09e8800 291cb853 96cc6717 393284aa a0da64ba
'     c = 0b4 8bfa5f42 0a349495 39d2bdfc 264eeeeb 077688e4 4fbf0ad8 f6d0edb3 7bd6b533 28100051 8e19f1b9 ffbe0fe9 ed8a3c22 00b8f875 e523868c 70c1e5bf 55bad637
'     b = 051 953eb961 8e1c9a1f 929a21a0 b68540ee a2da725b 99b315f3 b8b48991 8ef109e1 56193951 ec7e937b 1652c0bd 3bb1bf07 3573df88 3d2c34f1 ef451fd4 6b503f00
'     x = 0c6 858e06b7 0404e9cd 9e3ecb66 2395b442 9c648139 053fb521 f828af60 6b4d3dba a14b5e77 efe75928 fe1dc127 a2ffa8de 3348b3c1 856a429b f97e7e31 c2e5bd66
'     y = 118 39296a78 9a3bc004 5c8a5fb4 2c7d1bd9 98f54449 579b4468 17afbd17 273e662c 97ee7299 5ef42640 c550b901 3fad0761 353c7086 a272c240 88be9476 9fd16650
primedata     long      $1ff
              long $ffffffff, $ffffffff, $ffffffff, $ffffffff, $ffffffff, $ffffffff, $ffffffff, $ffffffff
              long $ffffffff, $ffffffff, $ffffffff, $ffffffff, $ffffffff, $ffffffff, $ffffffff, $ffffffff

ndata         long      $1ff
              long $ffffffff, $ffffffff, $ffffffff, $ffffffff, $ffffffff, $ffffffff, $ffffffff, $fffffffa
              long $51868783, $bf2f966b, $7fcc0148, $f709a5d0, $3bb5c9b8, $899c47ae, $bb6fb71e, $91386409

bdata         long      $051
              long $953eb961, $8e1c9a1f, $929a21a0, $b68540ee, $a2da725b, $99b315f3, $b8b48991, $8ef109e1
              long $56193951, $ec7e937b, $1652c0bd, $3bb1bf07, $3573df88, $3d2c34f1, $ef451fd4, $6b503f00

xdata         long      $0c6
              long $858e06b7, $0404e9cd, $9e3ecb66, $2395b442, $9c648139, $053fb521, $f828af60, $6b4d3dba
              long $a14b5e77, $efe75928, $fe1dc127, $a2ffa8de, $3348b3c1, $856a429b, $f97e7e31, $c2e5bd66

ydata         long      $118
              long $39296a78, $9a3bc004, $5c8a5fb4, $2c7d1bd9, $98f54449, $579b4468, $17afbd17, $273e662c
              long $97ee7299, $5ef42640, $c550b901, $3fad0761, $353c7086, $a272c240, $88be9476, $9fd16650



{{ Cog Assembly Code }}

              org       0                 'Begin at Cog RAM addr 0

p521          mov       parm, par         ' don't change par so valid for next operation
              add       parm, #24

              rdlong    workspace, parm    ' args[6] is workspace, setup on first call only
              add       parm, #4
              mov       script_arr, parm   ' args[7]  points to scripts array

              add       X, workspace
              add       Y, workspace
              add       Z, workspace
              add       xx, workspace
              add       yy, workspace
              add       zz, workspace
              add       t1, workspace
              add       t2, workspace
              add       t3, workspace
              add       t4, workspace
              add       u, workspace
              add       v, workspace
              add       x1, workspace
              add       x2, workspace
              add       bcoeff, workspace
              add       ncoeff, workspace
              add       origx, workspace
              add       origy, workspace
              add       tempbuf, workspace
              mov       op, #0
              wrlong    op, par
waiting
              rdlong    op, par
              cmp       op, #0  wz
        if_z  jmp       #waiting

reentry       mov       parm, par      ' par points to params, args[0] is flag
              add       parm, #4
              rdlong    r, parm        ' r = args[1]
              add       parm, #4
              rdlong    a, parm        ' a = args[2]
              add       parm, #4
              rdlong    b, parm        ' b = args[3]
              sub       parm, #8

              neg       duration, cnt  ' record -begin

              cmp       op, #OP_ADD  wz
        if_z  mov       addflag, #1
        if_z  call      #addd

              cmp       op, #OP_SUB  wz
        if_z  mov       addflag, #0
        if_z  call      #subtract

              cmp       op, #OP_MULT  wz
        if_z  call      #mult

              cmp       op, #OP_HALVE  wz
        if_z  call      #halve_into

              cmp       op, #OP_SETPRIME  wz
        if_z  call      #set_prime
{
              cmp       op, #OP_SETSMALL  wz
        if_z  call      #set_small
}
              cmp       op, #OP_SIZE  wz
        if_nz jmp       #cogreturn
              mov       r, #Nw        ' size in words
              wrlong    r, parm
              add       parm, #4
              wrlong    X, parm       ' workspace address

cogreturn     add       duration, cnt
              add       parm, #4
              wrlong    duration, parm
              mov       op, #0
              wrlong    op, par
              jmp       #waiting



{{ normal_big: normalize r after multiply, sub the top 521 bits onto lower 521 bits }}
normal_big    mov       p, r 
              mov       q, r    ' normalize buffer at r
              add       p, #Nt
              mov       counter, #(Nw)
              xor       aa, aa  wc  ' clear carry flag

:loop         rdlong    al, p     ' get reads and writes spaced out nicely for hub syncing
              mov       aa, al
              and       aa, topbits ' clear top part of top word for later in loop
              wrlong    aa, p
:loopn        add       p, #4
              rdlong    aa, p
              shr       al, #9
              shl       aa, #23
              rdlong    bb, q
              or        aa, al
              addx      aa, bb  wc
              wrlong    aa, q
              add       q, #4
              rdlong    al, p
              djnz      counter, #:loop

              and       aa, toptopbits
              sub       q, #4
              wrlong    aa, q
              jmp       #:done
{
              rdlong    al, p
              shr       al, #9
              rdlong    bb, q
              and       bb, topbits
              addx      al, bb
              wrlong    al, q
              }
:done
              call      #normal_small   ' from r
normal_big_ret ret


{{ noraml_small: normalize a value (r) that might be >= prime (but less than 2*prime) }}

normal_small  mov       q, r
              add       q, #Nt
              rdlong    aa, q
              cmp       aa, topbits  wc,wz
        if_c  jmp       #normal_small_ret    ' smaller, then less than prime
        if_nz jmp       #subprime            ' larger, must reduce
:loop         sub       q, #4                ' might be equal to prime
              cmp       q, r  wc
        if_c  jmp       #subprime            ' if get to end and still all ones, must reduce
              rdlong    aa, q
              cmp       aa, minus1 wz        ' if any word not all ones, value is OK
        if_z  jmp       #:loop
normal_small_ret ret



subprime      sub       r, #4
              mov       counter, #Nw
              xor       aa, aa  wc   ' clear carry

:subloop      add       r, #4        ' 32 cycles per loop
              rdlong    aa, r
              subx      aa, minus1  wc
              wrlong    aa, r
              djnz      counter, #:subloop

              and       aa, topbits  ' fix top word
              wrlong    aa, r              ' leave r corrupted, note, but going to return anyway
              jmp       #normal_small_ret  ' assume never more than 2p-1

{{ Adding, subtracting modulo the prime - note the use of addflag }}

{
double        mov       b, a
              jmp       #addd
double_into   mov       b, r
}
sub_into
add_into      mov       a, r
subtract
addd          mov       counter, #(Nw-1) ' about 11us
              andn      aa, aa  wc      ' clear carry ???
              test      addflag, #1  wz ' set zero flag if subtraction (addflag zero)

:loop         rdlong    bb, b           ' 48 cycles round loop
        if_z  xor       bb, minus1      ' invert if subtracting (addflag = 0)
              add       b, #4
              rdlong    aa, a 
              add       a, #4
              addx      aa, bb  wc
              wrlong    aa, r
              add       r, #4
              djnz      counter, #:loop

              rdlong    bb, b
        if_z  xor       bb, minus1      ' invert if subtracting (addflag = 0)
        if_z  and       bb, topbits
              rdlong    aa, a
              addx      aa, bb
              wrlong    aa, r
              sub       r, #Nt
              call      #normal_small
double_ret
double_into_ret
sub_into_ret
add_into_ret
subtract_ret
addd_ret      ret


{{ multiplication modulo the prime }}

rawmult       mov       endp, a       ' about 3.75ms  (270 Hz)
              add       endp, #NT
              mov       counter, #NWW
              mov       aa, #0
:loop         wrlong    aa, r
              add       r, #4
              djnz      counter, #:loop
              sub       r, #NBB

:loop1        rdlong    aa, a
              mov       endq, b
              rdlong    bb, b
              add       endq, #NT

:loop2        rdlong    rrl, r   ' about 13us per loop
              add       r, #4
              rdlong    rrh, r
              call      #multadd64  ' aa * bb + rr -> rr, cout
              wrlong    rrh, r
              sub       r, #4
              wrlong    rrl, r
              add       r, #4

              cmp       cout, #0  wz
        if_z  jmp       #:skip

              mov       rrr, r
:carryloop    add       rrr, #4    ' carry propagation loop
              rdlong    aa, rrr
              add       aa, cout  wc
        if_c  mov       cout, #1
              wrlong    aa, rrr
        if_c  jmp       #:carryloop

:skip         rdlong    aa, a        ' done early to avoid stalls
              cmp       b, endq  wz
              add       b, #4
              rdlong    bb, b        ' done early to avoid stalls
        if_nz jmp       #:loop2

              sub       r, #NT
              sub       b, #(NT+4)

              cmp       a, endp  wz
              add       a, #4
        if_nz jmp       #:loop1

rawmult_ret   ret


{ multu64, inputs aa, bb,  inouts rrl, rrh, outputs cout }
{
multadd64     mov       counter, #32    ' about 11.5us
              mov       ah, #0
              mov       cout, #0

:loop         shr       bb, #1  wc
        if_nc jmp       #:skip
              add       rrl, aa  wc
              addx      rrh, ah  wc
              addx      cout, #0
:skip         shl       aa, #1  wc
              rcl       ah, #1
              djnz      counter, #:loop
multadd64_ret ret
}
multadd64     mov	counter, #4
	      mov       rrrh, bb
	      mov	rrrl, #0
:loop
	      shl	rrrl, #1  wc
	      rcl	rrrh, #1  wc
	if_c  add	rrrl, aa  wc
	      addx	rrrh, #0
	      shl	rrrl, #1  wc
	      rcl	rrrh, #1  wc
	if_c  add	rrrl, aa  wc
	      addx	rrrh, #0
	      shl	rrrl, #1  wc
	      rcl	rrrh, #1  wc
	if_c  add	rrrl, aa  wc
	      addx	rrrh, #0
	      shl	rrrl, #1  wc
	      rcl	rrrh, #1  wc
	if_c  add	rrrl, aa  wc
	      addx	rrrh, #0
	      shl	rrrl, #1  wc
	      rcl	rrrh, #1  wc
	if_c  add	rrrl, aa  wc
	      addx	rrrh, #0
	      shl	rrrl, #1  wc
	      rcl	rrrh, #1  wc
	if_c  add	rrrl, aa  wc
	      addx	rrrh, #0
	      shl	rrrl, #1  wc
	      rcl	rrrh, #1  wc
	if_c  add	rrrl, aa  wc
	      addx	rrrh, #0
	      shl	rrrl, #1  wc
	      rcl	rrrh, #1  wc
	if_c  add	rrrl, aa  wc
	      addx	rrrh, #0

	      djnz	counter, #:loop

	      add	rrl, rrrl  wc
	      addx	rrh, rrrh  wc
              mov       cout, #0
	      addx	cout, #0
multadd64_ret ret

{{ divide by two - bit rotate right }}

halve_into    mov       p, r
              add       p, #Nt
              rdlong    aa, r
              and       aa, #1
              shl       aa, #8
              rdlong    bb, p
              shr       bb, #1  wc
              add       bb, aa
              wrlong    bb, p
              sub       p, #4
              mov       counter, #(Nw-1)
:loop         rdlong    bb, p
              rcr       bb, #1  wc
              wrlong    bb, p
              sub       p, #4
              djnz      counter, #:loop
halve_into_ret ret


{{ wrap around multiply to handle the long result buffer via tempbuf }}

mult          mov       tres, r         ' save result place
              mov       r, tempbuf      ' use double length temp buffer for multiply
              call      #rawmult
              mov       r, tempbuf
              call      #normal_big
              mov       a, tempbuf
              mov       r, tres
              call      #copy
mult_ret      ret


{{ copy one number to another }}

copy          mov       counter, #Nw
              sub       r, #4

:loop         rdlong    aa, a
              add       a, #4
              add       r, #4
              wrlong    aa, r
              djnz      counter, #:loop

copy_ret      ret


{{ set to a small int value (low word in a) }}
{
set_small     mov       counter, #(Nw-1)
              wrlong    a, r
              mov       a, #0
:loop         add       r, #4
              wrlong    a, r
              djnz      counter, #:loop
set_small_ret ret
}

{{ set value to the prime - used in modular inverse }}

set_prime     mov       counter, #(Nw-1)
:loop         wrlong    minus1, r
              add       r, #4
              djnz      counter, #:loop
              wrlong    topbits, r
set_prime_ret ret




minus1        long      $FFFFFFFF
topbits       long      $1FF
toptopbits    long      $3FFFF



' The arguments - these must be contiguous block
' values start off as offsets, during init we add on base address
X             long      0     ' 0
Y             long      NB    ' 1
Z             long      2*NB  ' 2
xx            long      3*NB  ' 3
yy            long      4*NB  ' 4
zz            long      5*NB  ' 5
t1            long      6*NB  ' 6
t2            long      7*NB  ' 7
t3            long      8*NB  ' 8
t4            long      9*NB  ' 9
u             long      10*NB ' A
v             long      11*NB ' B
x1            long      12*NB ' C
x2            long      13*NB ' D
bcoeff        long      14*NB
ncoeff        long      15*NB
origx         long      16*NB
origy         long      17*NB
tempbuf       long      18*NB ' 10

workspace     res       1
parm          res       1
duration      res       1

script_arr    res       1

counter       res       1

dd            res       1
tres          res       1

p             res       1
endp          res       1
q             res       1
endq          res       1

a             res       1
aa            res       1
ah            res       1
al            res       1
b             res       1
bb            res       1
r             res       1
rr            res       1

rrh           res       1
rrl           res       1
rrrh          res       1
rrrl          res       1
rrr           res       1
cout          res       1
op            res       1

addflag       res       1
script        res       1
arg           res       1


wrd           res       1
bcount        res       1
wcount        res       1
N             res       1

              fit       $1F0


