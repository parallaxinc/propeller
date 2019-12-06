{{ ecc.spin }}
CON

  MAX_SIZE = 17


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
  OP_RESETP    = 38

  OP_SETUP     = 99
  OP_NOP       = 100



VAR
  long  dur

  long  args[5]   ' our args

  long  cog
  long  worksp

PUB start(fieldargs)
  fargs := fieldargs
  script_aff1 := @aff_script_1
  script_aff2 := @aff_script_2
  script_doub := @double_script
  script_red := @reduce_script
  script_chk_cur := @chk_cur_script
  script_chk_p := @chk_p_script


  args[1] := fargs
  args[0] := OP_SETUP
  cog := 1+cognew (@entry, @args)
  repeat until args[0] == 0    ' start our cog

  ' call OP_SIZE again for Spin, since cog has private copies of this state now.
  long[fargs][0] := OP_SIZE
  repeat until long[fargs][0] == 0
  Nwords := long[fargs][1]
  worksp := long[fargs][2]
  Nbytes := 4 * Nwords
  args[4] := cog-1
  result := @args

PUB stop
  if cog <> 0
    cogstop (cog-1)

PUB size
  result := Nwords

PUB workspace
  result := worksp

PRI call_cog_full (oper, dest, arga, argb)
  args[1] := dest
  args[2] := arga
  args[3] := argb
  result := call_cog (oper)

PRI call_cog (oper)
  args[0] := oper
  repeat until args[0] == 0
  result := args[1]

PUB ensure
  call_cog (OP_ENSUREAFF)

PUB double
  call_cog (OP_DOUBJAC)

PUB addaff
  call_cog (OP_ADDAFF)

PUB isinfinite
  result := call_cog (OP_ISINF)

PUB pointmul1 (wrd)
  call_cog_full (OP_MULTPOINT1, 0, wrd, 0)

PUB pointmul (val)
  call_cog_full (OP_MULTPOINT, 0, val, 0)

PUB setinfinite
  call_cog (OP_SETINF)

PUB checkcurve
  result := call_cog (OP_CHECKCURVE)

PUB checkV(val)
  result := call_cog_full (OP_CHECKV, 0, val, 0)

PUB checkR(val)
  result := call_cog_full (OP_CHECKR, 0, val, 0)

PUB checkP
  result := call_cog (OP_CHECKP)

PUB setP (newx, newy)
  result := call_cog_full (OP_SETP, 0, newx, newy)

PUB resetP
  result := call_cog (OP_RESETP)



DAT

aff_script_1    word    $3622, $3762, $3663, $3774, $2660, $2771, 0

aff_script_2    word    $3226, $3866, $3986, $3880, $1688, $3077, $2006, $2009
                word    $2880, $3887, $3991, $2189, 0

double_script   word    $3622, $2706, $1660, $3776, $1877, $1778, $1111, $3221
                word    $3111, $3810, $3111, $41AA, $3077, $1688, $2006, $2680
                word    $3667, $2161, 0

reduce_script   word    $3522, $3225, $3005, $3112, 0

chk_cur_script  word    $17EE, $177E, $3777, $1677, $1667, 0

chk_p_script    word    $3644, $3733, $3737, $1833, $1838, $2778, $177E, 0

	        ORG     0

entry	        rdlong  op, par
parse           mov	parm, par
		add	parm, #4
		rdlong	r, parm
		add     parm, #4
		rdlong	a, parm
		add	parm, #4
		rdlong	b, parm
                sub     parm, #8     ' position for setting result

                neg     duration, cnt

                ' Finite field operations
                cmp     op, #OP_COMPARE  wz   '  r  :=  sign (a - b)
          if_nz jmp     #:skip_comp
                call    #compare
                jmp     #:done
:skip_comp
                cmp     op, #OP_INVERSE  wz   '  r  :=  r^-1
          if_nz jmp     #:skip_inv
                call    #invert
                jmp     #:done
:skip_inv
                ' Elliptic curve ops, Q is jacobi point (X:Y:Z), P is affine (xx,yy)
                cmp     op, #OP_ISINF  wz   '  r  :=  (Q == Inf)
          if_nz jmp     #:skip_isinf
                call    #isinf
                jmp     #:done
:skip_isinf
                cmp     op, #OP_SETINF  wz  '  Q := Inf
          if_nz jmp     #:skip_setinf
                call    #setinf
                jmp     #:done
:skip_setinf
		cmp     op, #OP_DOUBJAC  wz '   Q := Q+Q
	  if_nz jmp     #:skip_doub
                call	#double_jacobi
                jmp     #:done
:skip_doub
	  	cmp     op, #OP_ADDAFF  wz  '   Q := Q+P
	  if_nz jmp     #:skip_addaff
                call	#add_affine
                jmp     #:done
:skip_addaff
	  	cmp     op, #OP_ENSUREAFF  wz  '  P := (X/Z^2, Y/Z^3, 1)
	  if_nz jmp     #:skip_ensure
                call	#ensure_affine
                jmp     #:done
:skip_ensure
	  	cmp     op, #OP_MULTPOINT1  wz  '  Q := a.Q   (a is 32 bit int)
	  if_nz jmp     #:skip_mulp1
                call	#multpoint1
                jmp     #:done
:skip_mulp1
	  	cmp     op, #OP_MULTPOINT  wz   '  Q := a.Q   (a is integer in the finite field)
	  if_nz jmp     #:skip_mulp
                call	#multpoint
                jmp     #:done
:skip_mulp
                cmp     op, #OP_CHECKCURVE  wz
          if_nz jmp     #:skip_checkcurve
                call    #check_curve
                jmp     #:done
:skip_checkcurve
                cmp     op, #OP_CHECKV  wz
          if_nz jmp     #:skip_checkv
                call    #check_v
                jmp     #:done
:skip_checkv
                cmp     op, #OP_CHECKR  wz
          if_nz jmp     #:skip_checkr
                call    #check_rand
                jmp     #:done
:skip_checkr
                cmp     op, #OP_CHECKP  wz
          if_nz jmp     #:skip_checkp
                call    #check_p
                jmp     #:done
:skip_checkp
                cmp     op, #OP_SETP  wz
          if_nz jmp     #:skip_setp
                call    #set_p
                jmp     #:done
:skip_setp
                cmp     op, #OP_RESETP  wz
          if_nz jmp     #:skip_resetp
                call    #reset_p
                jmp     #:done
:skip_resetp
	  	cmp     op, #OP_SETUP  wz   '  Q := a.Q   (a is integer in the finite field)
	  if_nz jmp     #:done

                mov     fargs, r                ' setup fargs ready for calling field cog
                mov     opc, #OP_SIZE           ' OP_SIZE gets wordsize, workspace
                call    #fieldop1
                add     fargs, #4
                rdlong  Nwords, fargs           ' get the Nwords
                mov     Nbytes, Nwords
                shl     Nbytes, #2
                add     fargs, #4
                rdlong  X, fargs                ' get workspace
                sub     fargs, #8               ' restore fargs for next call

                mov     Y, X                    ' setup all variables to workspace
                add     Y, Nbytes
                mov     Z, Y
                add     Z, Nbytes
                mov     xx, Z
                add     xx, Nbytes
                mov     yy, xx
                add     yy, Nbytes
                mov     zz, yy
                add     zz, Nbytes
                mov     t1, zz
                add     t1, Nbytes
                mov     t2, t1
                add     t2, Nbytes
                mov     t3, t2
                add     t3, Nbytes
                mov     t4, t3
                add     t4, Nbytes
                mov     u, t4
                add     u, Nbytes
                mov     v, u
                add     v, Nbytes
                mov     x1, v
                add     x1, Nbytes
                mov     x2, x1
                add     x2, Nbytes
                mov     bcoeff, x2
                add     bcoeff, Nbytes
                mov     ncoeff, bcoeff
                add     ncoeff, Nbytes
                mov     xorig, ncoeff
                add     xorig, Nbytes
                mov     yorig, xorig
                add     yorig, Nbytes

:done
                add     duration, cnt

                add     parm, #4
                wrlong  duration, parm
                mov     op, #0
		wrlong  op, par
:wait           rdlong  op, par
                cmp     op, #0  wz
        if_z    jmp     #:wait
                jmp     #parse



fieldop1
                add     fargs, #4
                jmp     #fieldop_comm
fieldop
                add     fargs, #12
                wrlong  b, fargs
                sub     fargs, #4
                wrlong  a, fargs
                sub     fargs, #4
fieldop_comm
                wrlong  r, fargs
                sub     fargs, #4
                wrlong  opc, fargs  ' set opcode
:loop
                rdlong  opc, fargs  ' wait till done
                cmp     opc, #0  wz
         if_nz  jmp     #:loop
fieldop1_ret
fieldop_ret     ret


iseven          rdlong  t, a
                test    t, #1  wz
iseven_ret      ret


iszero          mov     hh, #0
                jmp     #issmall
isone           mov     hh, #1
issmall         mov     count, Nwords
:loop           rdlong  t, a
                cmp     t, hh  wz
        if_nz   jmp     #iszero_ret
                add     a, #4
                mov     hh, #0
                djnz    count, #:loop
issmall_ret
isone_ret
iszero_ret      ret


copy		mov	count, Nwords
:loop		rdlong	t, a
		add	a, #4
		wrlong  t, r
		add	r, #4
		djnz	count, #:loop
copy_ret	ret


set_small       mov     count, Nwords
                sub     count, #1
                wrlong  a, r
                add     r, #4
                mov     a, #0
:loop
                wrlong  a, r
                add     r, #4
                djnz    count, #:loop
set_small_ret   ret


double_jacobi   mov	a, Z     ' implicit parameters X, Y, Z
	        call	#iszero
	  if_z  jmp	#double_jacobi_ret ' Z = 0 means infinity

                mov     script, script_doub
                call    #exec_script

double_jacobi_ret ret


ensure_jac      mov     a, xx
                mov     r, X
                call    #copy
                mov     a, yy
                mov     r, Y
                call    #copy
                mov     a, #1
                mov     r, Z
                call    #set_small
ensure_jac_ret  ret


add_affine      mov     a, Z    ' not testing the affine point for infinity
                call    #iszero
          if_nz jmp     #add_affine2
                call    #ensure_jac
                jmp     #add_affine_ret

add_affine2     mov     script, script_aff1
                call    #exec_script

                mov     a, t1
                call    #iszero
          if_nz jmp     #:normal
                mov     a, t2
                call    #iszero
          if_nz jmp     #:set_inf
                call    #double_jacobi
                jmp     #add_affine_ret

:set_inf        call    #setinf
                jmp     #add_affine_ret

:normal         mov     script, script_aff2
                call    #exec_script

add_affine_ret ret




isinf           mov     a, Z
                call    #iszero
                mov     r, #0
        if_z    mov     r, #1  ' return true if Z zero
                wrlong  r, parm
isinf_ret       ret



setinf		mov	a, #1
		mov	r, X
		call	#set_small
     		mov	a, #1
		mov	r, Y
		call	#set_small
                mov     a, #0
                mov     r, Z
                call    #set_small
setinf_ret      ret



ensure_affine mov       a, Z
              call      #isone
        if_z  jmp       #ensure_affine_ret

              mov       r, Z
              call      #invert

              mov       script, script_red
              call      #exec_script

              mov       a, #1
              mov       r, Z
              call      #set_small

ensure_affine_ret ret



compare       call      #comp_guts
        if_b  mov       hh, minus1
        if_a  mov       hh, #1
              wrlong    hh, parm
compare_ret   ret


comp_guts     add       a, Nbytes
              sub       a, #4
              add       b, Nbytes
	      xor       hh, hh  wz,wc
              mov	count, Nwords
:loop
              rdlong    aa, a
              sub       a, #4
              sub       b, #4
              rdlong    bb, b
              cmp       aa, bb  wc,wz
        if_e  djnz      count, #:loop
comp_guts_ret ret



invert        mov       dd, r   ' remember destination
              mov       a, #1
              mov       r, x1
              call      #set_small

              mov       a, dd
              mov       r, u
              call      #copy

              mov       r, v
              mov       opc, #OP_SETPRIME
	      call	#fieldop1

              mov       a, #0
              mov       r, x2
              call      #set_small

:loop         mov       a, u
              call      #isone
        if_z  jmp       #:end1
              mov       a, v
              call      #isone
        if_z  jmp       #:end2

:while1       mov       a, u
              call      #iseven
        if_nz jmp       #:while2
              mov       r, u
              mov	opc, #OP_HALVE
	      call	#fieldop1

              mov       r, x1
              mov	opc, #OP_HALVE
	      call	#fieldop1

              jmp       #:while1

:while2       mov       a, v
              call      #iseven
        if_nz jmp       #:less_test

              mov       r, v
              mov	opc, #OP_HALVE
	      call	#fieldop1

              mov       r, x2
              mov	opc, #OP_HALVE
	      call	#fieldop1

              jmp       #:while2

:less_test    mov       a, u
              mov       b, v
              call      #comp_guts
        if_b  jmp       #:else

              mov       b, v
	      mov	a, u
              mov       r, u
              mov       opc, #OP_SUB
	      call	#fieldop

              mov       b, x2
	      mov	a, x1
              mov       r, x1
              mov       opc, #OP_SUB
	      call	#fieldop

              jmp       #:loop

:else         mov       b, u
	      mov	a, v
              mov       r, v
              mov       opc, #OP_SUB
	      call	#fieldop

              mov       b, x1
	      mov	a, x2
              mov       r, x2
              mov       opc, #OP_SUB
	      call	#fieldop

              jmp       #:loop

:end1         mov       a, x1
              mov       r, dd
              jmp       #:skip
:end2         mov       a, x2
              mov       r, dd
:skip         call      #copy
invert_ret    ret


multpoint1    mov     bcount, #32
              mov     w, a
:loop
              call    #double_jacobi
              shl     w, #1  wc
        if_c  call    #add_affine
              djnz    bcount, #:loop
multpoint1_ret ret


multpoint     mov     n, a
              add     n, Nbytes
              mov     wcount, Nwords
              call    #setinf
:loop
              sub     n, #4
              rdlong  a, n
              call    #multpoint1
              djnz    wcount, #:loop
multpoint_ret ret

{ check the values of b, x, y are consistent }
check_curve   mov     script, script_chk_cur  ' t3 := b, t1 = 27b^2
              call    #exec_script
              mov     a, t3
              call    #check_v
        if_z  jmp     #:fail
              mov     a, #108
              mov     r, t2
              call    #set_small             ' t2 = -4a^3
              mov     a, t1
              mov     b, t2
              call    #compare
        if_z  jmp     #:fail
:succeed      mov     hh, #1
              jmp     #:retval
:fail         mov     hh, #0
:retval       wrlong  hh, parm
check_curve_ret ret

{ check a value is in range 0 .. prime-1 }

check_v       mov     r, t1
              mov     opc, #OP_SETPRIME
	      call    #fieldop1
              mov     b, t1
              call    #compare
              cmps    hh, #0  wz,wc
        if_ae mov     hh, #0
        if_b  mov     hh, #1
              cmp     hh, #0  wz   ' set Z flag for internal calls
              wrlong  hh, parm
check_v_ret   ret

check_rand    mov     b, a   ' temp copy
              call    #iszero
        if_z  mov     hh, #0
        if_z  jmp     #:retval
              mov     a, b    ' compare r to N
              mov     b, ncoeff
              call    #compare
              cmps    hh, #0  wz,wc
        if_ae mov     hh, #0
        if_b  mov     hh, #1
:retval
              wrlong  hh, parm
check_rand_ret ret


check_p       mov     a, xx
              call    #check_v
        if_z  jmp     #:fail
              mov     a, yy
              call    #check_v
        if_z  jmp     #:fail
              mov     script, script_chk_p ' t1 = y^2, t2 = x^3 - 3x + b
              call    #exec_script
              mov     a, t1
              mov     b, t2
              call    #compare
        if_nz jmp     #:fail
              mov     hh, #1
              jmp     #:retval
:fail         mov     hh, #0
:retval       wrlong  hh, parm
check_p_ret   ret



set_p         mov     r, xx   ' xx <- a
              call    #copy
              mov     a, b
              mov     r, yy   ' yy <- b
              call    #copy
              call    #check_p
set_p_ret     ret


reset_p       mov     a, xorig
              mov     r, xx
              call    #copy
              mov     a, yorig
              mov     r, yy
              call    #copy
              call    #check_p
reset_p_ret   ret




exec_script
:sloop        rdword  opc, script
              add     script, #2
              cmp     opc, #0  wz
        if_z  jmp     #exec_script_ret

	      add     fargs, #12
              call    #getarg     ' b
              call    #getarg     ' a
              call    #getarg     ' r
              wrlong  opc, fargs  ' set opcode
:wait_loop
              rdlong  opc, fargs  ' wait till done
              cmp     opc, #0  wz
       if_nz  jmp     #:wait_loop
              jmp     #:sloop
exec_script_ret  ret


getarg        mov     arg, opc
              and     arg, #$F    ' got rightmost arg number
              add     arg, #X     ' add X's cog address
              movd    wr_ins, arg ' overwrite instruction with correct register spec
              shr     opc, #4
wr_ins        wrlong  X, fargs
              sub     fargs, #4
getarg_ret    ret



minus1          long    $FFFFFFFF

script_aff1	long    @aff_script_1   ' bug in address calc?
script_aff2	long    @aff_script_2
script_doub	long    @double_script
script_red	long    @reduce_script
script_chk_cur  long    @chk_cur_script
script_chk_p    long    @chk_p_script

fargs		long	0  ' parameters to be setup from Spin
Nwords		long    0
Nbytes		long    0
X		long	0  ' 0  variable indices for scripts
Y		long	0
Z		long	0
xx		long	0  ' 3
yy		long	0
zz		long	0
t1		long	0  ' 6
t2		long	0
t3		long	0
t4		long	0
u		long	0  ' A
v		long	0  ' B
x1		long	0  ' C
x2		long	0  ' D
bcoeff		long    0  ' E
ncoeff		long    0  ' F
xorig           long    0
yorig           long    0

op              long    0

parm            res     1
r               res     1
a               res     1
b               res     1
duration        res     1
opc             res     1
arg             res     1
t               res     1
aa              res     1
bb              res     1
dd              res     1
hh              res     1
count           res     1
bcount          res     1
wcount          res     1
w               res     1
n               res     1
script          res     1

              FIT     $1F0

