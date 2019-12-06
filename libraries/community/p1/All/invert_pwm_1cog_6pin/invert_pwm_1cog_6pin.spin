{{
////////////////////////////////////////////////////////////////////////////////////////////
//                  invert_pwm_1cog_6pin.spin

// three-phase inverter PWM driver - uses only 1 cog to provide phase-correct
// three-phase PWM on 6 pins.  The PWM values are offset around the constant OFFSET
// with maximum variation of +/- (HALF_PERIOD - deadtime)

// The output frequency is fixed at Mclk / 3440 currently.  This is 23.255kHz for 80MHz mclk.

// Successive edges move opposite directions leading to symmetrical pulses:

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

//  With drive == OFFSET the outputs are square waves, the mark/space ratio increases
//  >50% in the high pin outputs on drive values > OFFSET, decreases <50% on
//  values < OFFSET.  The low pins are in antiphase with programmable deadtime.

//  inputs:
//
//  pwm.start6 (st, Ulo, Uhi, Vlo, Vhi, Wlo, Whi, dt, addr)
//
//     st = start time, a CNT value to synchronize startup

//     Ulo .. Whi = pin numbers for U, V, W  low and high driver signals

//     dt  = deadtime in units of 4 cycles, typically 50ns.

//     addr = address of array of 3 longs that drive U, V and W channels, these values
//            can vary from  OFFSET - HALF_PERIOD + deadtime
//            to             OFFSET + HALF_PERIOD - deadtime
//           exceeding this range can cause waitcnt lockout.


// Author: Mark Tillotson
// Updated: 2014-08-05
// Designed For: P8X32A
// Version: 1.00

////////////////////////////////////////////////////////////////////////////////////////////
}}

CON
  HALF_PERIOD = 192 	       ' instructions per half-period
  PERIOD = 2*HALF_PERIOD       ' instructions per period
  DELAYCOUNT = PERIOD*4 + 184  ' cycles delay per period, multiple of 16
  OFFSET = $100                ' offset for pwm values

VAR
  long  starttime
  long  values_addr

  long  cog



PUB  start (st, ul, uh, vl, vh, wl, wh, dt, values) | i
  stop

  time := st    ' synchronization time
  repeat i from 1 to 63
    if i & 1
      long [@pwm][i] |= 1 << uh
    if i & 2
      long [@pwm][i] |= 1 << vh
    if i & 4
      long [@pwm][i] |= 1 << wh
    if i & 8
      long [@pwm][i] |= 1 << ul
    if i & $10
      long [@pwm][i] |= 1 << vl
    if i & $20
      long [@pwm][i] |= 1 << wl
  uaddr := values
  vaddr := values+4
  waddr := values+8
  deadtime := dt

  cog := 1 + cognew (@pwm, 0)


PUB  stop | i
  if (cog <> 0)
    cogstop (cog-1)
    cog := 0



DAT

                ORG     0

pwm             jmp     #setup     ' this instruction overwritten with 0

                long      0,0,0,0,0,0,0    ' the pin mask table, 6 bit index
                long    0,0,0,0,0,0,0,0    ' returns pin mask for those pins
                long    0,0,0,0,0,0,0,0    ' whose bits are present.
                long    0,0,0,0,0,0,0,0    ' apart from zeroeth entry this is setup
                long    0,0,0,0,0,0,0,0    ' in start()
                long    0,0,0,0,0,0,0,0
                long    0,0,0,0,0,0,0,0
                long    0,0,0,0,0,0,0,0
{{ note the bits represent pins thus:
$01 = u high
$02 = v high
$04 = w high
$08 = u low
$10 = v low
$20 = w low
}}

{ ------------------------------------------- }

                ' table is centred about $100, made as large as possible
                ' the source fields are modified by XOR to select an entry from
                ' pin mask table, zeroth entry being the default, null value (0).
                ' this allows arbitrary timing to 4-cycle granularity of all 6 pins

table           xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'10
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'20
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'30
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'40
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'50
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'60
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'70
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'80
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'90
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'100
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'110
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'120
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'130
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'140
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'150
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'160
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'170
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'180
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'190
                xor     OUTA, 0-0
                xor     OUTA, 0-0
midpoint        xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'200
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'210
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'220
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'230
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'240
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'250
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'260
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'270
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'280
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'290
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'300
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'310
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'320
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'330
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'340
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'350
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'360
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'370
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'380
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
                xor     OUTA, 0-0
'384
                xor     OUTA, 0-0

                ' table tail-calls modify to save a few instructions
modify
uins         	xor	0-0, #1    ' modifies entries in the table to change which entries in
vins		xor	0-0, #2    ' pin mask table to use
wins		xor	0-0, #4
ulins         	xor	0-0, #8    ' calling modify twice repairs the damage
vlins		xor	0-0, #$10
wlins		xor	0-0, #$20
modify_ret
table_ret       ret

{ ------------------------------------------- }

setup           mov     0, #0     ' repair the pin mask table
		or	DIRA, %111_111  ' mask table entry with all pins set
                or      OUTA, %111_000  ' mask table with all low pins set

loop            cmp     0, 0   wc  ' clear carry
                call    #onephase
                cmp     0, 1  wc  ' set carry
                call    #onephase
		jmp	#loop

{ ------------------------------------------- }

onephase 	WAITCNT time, delay ' synchronize at start and each time round.

		rdlong	u, uaddr    ' u,v,w are the duty cycle values centred about OFFSET
		negc    u, u        ' alternately negated for symmetric PWM waveform
	        movd    uins, u     ' setup entries in the modify routine for high pins
		rdlong	v, vaddr
		negc    v, v
		movd    vins, v
		rdlong	w, waddr
		negc    w, w
                movd    wins, w

                sub     u, deadtime ' deadtime offset for low pin timing
                sub     v, deadtime
                sub     w, deadtime
                neg     deadtime, deadtime  ' deadtime leads or lags alternately
                movd    ulins, u    ' setup entries in the modify table for low pins
                movd    vlins, v
                movd    wlins, w

                call    #modify
		call 	#table
onephase_ret    ret


{ ----------------------------------------------- }

delay		long    DELAYCOUNT
uaddr           long    0
vaddr           long    0
waddr           long    0
deadtime        long    3
time            long    0

u               res     1
v               res     1
w               res     1

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
