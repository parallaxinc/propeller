{{
////////////////////////////////////////////////////////////////////////////////////////////
//                  inverter_pwm.spin

// three-phase inverter PWM driver - uses 3 synchronized cogs to provide phase-correct
// PWM driven by signed values.

// The output frequency is 1/2*period, the control value is read and used every period
// and successive edges move opposite directions leading to symmetrical pulses:

//   --------------+                     +---------------
//                 +---------------------+                 Ulo
//                  +-------------------+
//   ---------------+                   +----------------  Uhi

//   -----------+                           +------------ 
//              +---------------------------+              Vlo
//               +-------------------------+
//   ------------+                         +-------------  Vhi

//   ----------------+                 +-----------------
//                   +-----------------+                   Wlo
//                    +---------------+
//   -----------------+               +------------------  Whi
//   |                        |                         |  2 periods

//  With zero drive the outputs are square waves, the mark/space ratio increases
//  >50% in the high pin outputs on positive drive values, decreases <50% on
//  negative values.  The low pins are in antiphase with some deadtime.

//  inputs:
//
//  pwm.start6 (st, hp, Ulo, Uhi, Vlo, Vhi, Wlo, Whi, addr, ed)
//
//     st = start time, a CNT value to synchronize startup
//     hp = half_period, in clock cycles, for instance in 80MHz system hp=1000 gives 20kHz
//     Ulo .. Whi = pin numbers for U, V, W  low and high driver signals
//     addr = address of array of 3 longs that drive U, V and W channels, these values
//            can vary from a bit above -half_period to just below +half_period
//            allow a slack of 32 cycles at least to avoid CNT lockout.
//     ed = extra dead time - set to non-zero to get 250ns rather than 100ns deadtime

//  pwm.start3 (st, hp, Uhi, Vhi, Whi, addr)
//     same but only one pin per channel, and dead-time is not meaningful.

// Author: Mark Tillotson
// Updated: 2014-08-03
// Designed For: P8X32A
// Version: 1.00

////////////////////////////////////////////////////////////////////////////////////////////
}}

CON
  COGdelay = 10000 ' time to setup a cog and for it to run a bit
VAR
  long  starttime
  long  half_period
  long  pin_spec
  long  extra_dead
  long  del_addr

  long  cog[3]



PUB  start6 (st, hp, Ulo, Uhi, Vlo, Vhi, Wlo, Whi, addr, ed)  ' 6 pins
  stop

  starttime   := st
  half_period := hp
  pin_spec    := Ulo | Uhi << 6
  del_addr    := addr
  extra_dead  := ed

  cog[0] := 1 + cognew (@pwm, @starttime)
  waitcnt (CNT + COGdelay)

  pin_spec    := Vlo | Vhi << 6
  del_addr    := addr+4
  cog[1] := 1 + cognew (@pwm, @starttime)
  waitcnt (CNT + COGdelay)

  pin_spec    := Wlo | Whi << 6
  del_addr    := addr+8
  cog[2] := 1 + cognew (@pwm, @starttime)


PUB  start3 (st, hp, Uhi, Vhi, Whi, addr)  ' 3 pin only
  start6 (st, hp, Uhi, Uhi, Vhi, Vhi, Whi, Whi, addr, false)  ' no need for deadtime

  

PUB  stop | i
  repeat i from 0 to 2
    if (cog[i] <> 0)
      cogstop (cog[i]-1)
      cog[i] := 0

DAT

                ORG     0 

pwm             mov     parm, PAR        ' read parameters
		rdlong  time, parm
                add     parm, #4
		rdlong  half, parm
		add 	parm, #4
                rdlong  pins, parm
                add     parm, #4
		rdlong  deadtime, parm
		add	parm, #4
		rdlong	delta_addr, parm

                mov     lmask, #1	' calculate pin masks
                mov     hmask, #1
                mov     pin, pins
                and     pin, #$3F
                shl     lmask, pin
                shr     pins, #6
                mov     pin, pins
                and     pin, #$3F
                shl     hmask, pin

		cmp	lmask, hmask  wz
	if_z	mov	lmask, #0         ' if pins the same only use high pin


		or	DIRA, hmask	  ' set pin drive
                or      DIRA, lmask

		cmp	deadtime, #0  wz   ' chose short or long deadtime routine
	if_nz	jmp	#longdead

{ ----------------------------------------------- }

		' version with minimum deadtime, 100ns
shortdead	WAITCNT time, half
		rdlong	delta, delta_addr
		sub	time, delta

		WAITCNT time, delta
                andn    OUTA, lmask
		add	time, half
		or	OUTA, hmask

		WAITCNT time, half
		rdlong	delta, delta_addr
		add	time, delta

		WAITCNT time, half
		andn	OUTA, hmask
		sub	time, delta
                or      OUTA, lmask

		jmp	#shortdead


{ ----------------------------------------------- }

		' large deadtime, 250ns or so
longdead        or      OUTA, lmask

		WAITCNT time, half
		rdlong	delta, delta_addr
		sub	time, delta

		WAITCNT time, delta
                andn    OUTA, lmask
		add	time, half
                nop
              	nop
              	nop
		or	OUTA, hmask

		WAITCNT time, half
		rdlong	delta, delta_addr
		add	time, delta

		WAITCNT time, half
		andn	OUTA, hmask
		sub	time, delta
                nop
		nop
		jmp	#longdead


{ ----------------------------------------------- }


parm		res	1
pins            res     1
pin             res     1
hmask           res     1
lmask           res     1
time		res	1
delta_addr	res	1
half		res	1
delta		res	1
deadtime	res	1

                FIT     $1F0



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
