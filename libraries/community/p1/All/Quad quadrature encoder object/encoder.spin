{{
////////////////////////////////////////////////////////////////////////////////////////////
//                  encoder.spin
//
//  Quadrature encoder library for 1 to 4 channels of A-B encoder, using a single cog
//  and not relying on hardware counters, but using WAITPNE to activate on each change on any
//  channel, then polling for which have changed. 

//  This minimizes power consumption for the cog, and using a single cog for all
//  4 channels minimizes the number of cogs required. (The scheme can be extended to more
//  channels at the expense of throughput-per-channel)

//  The way the changes are sensed maintains correct counts so long as the frequency 
//  doesn't exceed a maximum limit - every transition sensed is accounted for.

//  Error detection is employed - when both A and B signals change from one cycle to
//  the next that channel has received more than one transition in a cycle, which is too
//  fast to account for, so an error counter for that channel is incremented to provide
//  feedback.

//  On an 80MHz Prop. the main cycle of the cog takes about between 1us and 4us
//  (depending on how many channels are actively changing at once), giving upto 250k
//  pulses-per-second for a single channel, 62k pulses-per-second for 4 channels together.
//  There are 4 counts per pulse in quadrature, so the max count rates are 1M counts/sec
//  for one channel, 250k counts/sec for four channels together (approximately, not finalized)

// Author: Mark Tillotson
// Updated: 2014-03-20
// Designed For: P8X32A
// Version: 1.0

// Provides Start, Stop, count, errorCount, getCounters, getErrorCounters

//   PUB  Start (pins)
//      starts up an encoder cog monitoring upto 4 AB quadrature channels.

//      "pins" is an array of 8 bytes, being AB pin numbers for upto 4 encoder channels,
//        first channel AB are indices 0 and 1, next 2 and 3 etc
//        unused channels must have the bytes set to $FF.
//        Swapping the A and B pin values will reverse the sense of counting, note.


//   PUB  Stop
//      kills the cog, if one is active

//   PUB  count (channel)
//      return current encoder count (long) for channel given (0 .. 3)
//      counts start at zero

//   PUB  errorCount (channel)
//      return current encoder error count (long) for channel given (0 .. 3)
//      error counts start at zero

//   PUB  getCounters
//      return the address of the counter array for direct access

//   PUB  getErrorCounters
//      return the address of the error counter array for direct access

/

// See end of file for standard MIT licence / terms of use.

// Update History:

// v1.0 - Initial version 2014-03-20

////////////////////////////////////////////////////////////////////////////////////////////
}}



CON
  NCHANS = 4

VAR
  long   cog

  long   pinvec [(NCHANS+1)/2]	  ' two longs with pin numbers encoded in them
  long   counters [NCHANS]      ' counters
  long	 errcounters [NCHANS]   ' error counters

PUB  Start (pins) | chan
  Stop                    ' ensure sane state
  pinvec [0] := byte [pins] [0] | (byte [pins] [1] << 8) | (byte [pins] [2] << 16) | (byte [pins] [3] << 24)
  pinvec [1] := byte [pins] [4] | (byte [pins] [5] << 8) | (byte [pins] [6] << 16) | (byte [pins] [7] << 24)
  repeat chan from 0 to NCHANS-1   ' setup counters
    counters [chan] := 0
    errcounters [chan] := 0
  cog := 1 + cognew (@entry, @pinvec)   ' fire up cog

PUB  Stop                 ' kill cog if active
  if cog <> 0
    cogstop (cog-1)
    cog := 0

PUB  count (channel)
  return counters [channel]

PUB  errorCount (channel)
  return errcounters [channel]

PUB  getCounters
  return @counters

PUB  getErrorCounters
  return @errcounters

DAT

		ORG	0
entry
		mov	parm, PAR

		call	#init_pins	' init_pins returns zero ABmask for null entry (Apin == $FF)
		mov	enc0_masklow, Amask
		mov	enc0_mask, ABmask
		mov	mask, enc0_mask ' mask is union of all active channel inputs

		call	#init_pins      ' channel 1
		mov	enc1_masklow, Amask
		mov	enc1_mask, ABmask
		or	mask, enc1_mask

		call	#init_pins      ' channel 2
		mov	enc2_masklow, Amask
		mov	enc2_mask, ABmask
		or	mask, enc2_mask

		call	#init_pins      ' channel 3
		mov	enc3_masklow, Amask
		mov	enc3_mask, ABmask
		or	mask, enc3_mask

		mov	enc0_addr, parm  ' get the counter addresses
		add	parm, #4
		mov	enc1_addr, parm
		add	parm, #4
		mov	enc2_addr, parm
		add	parm, #4
		mov	enc3_addr, parm
		add	parm, #4

		mov	err0_addr, parm  ' and for error addresses
		add	parm, #4
		mov	err1_addr, parm
		add	parm, #4
		mov	err2_addr, parm
		add	parm, #4
		mov	err3_addr, parm

                mov     state, INA	' initialize state
                and     state, mask
		jmp	#enc_loop       ' and run the loop

{{ --------------------- init_pins --------------------- }}

init_pins
		rdbyte	Apin, parm
		add	parm, #1
		rdbyte	Bpin, parm
		add	parm, #1

		cmp	Apin, #$FF  wz	' if A pin is FF, then ignore this entry
	if_e	mov	ABmask, #0
	if_e	jmp	#init_pins_ret

		mov	Amask, #1
		shl	Amask, Apin
		mov	ABmask, #1
		shl	ABmask, Bpin
		or	ABmask, Amask
init_pins_ret	ret

		
{{ --------------------- enc_loop --------------------- }}

enc_loop
		WAITPNE state, mask		' wait for change on any monitored pins
		mov	newstate, INA		' get latest state and calculate changes
		and	newstate, mask
		mov	change, state
		xor	change, newstate

		test	change, enc0_mask  wc, wz  ' carry set if odd number of bits set in mask, ie 01 or 10
	if_z	jmp	#:next1
	if_nc	add	error0, #1		' nz, nc means both bits changed, error case
	if_nc	wrlong	error0, err0_addr
	if_nc	jmp	#:next1

		test	newstate, enc0_mask  wc	   ' if changed to 00 or 11
	if_nc	xor	change, enc0_mask          ' then change is flipped from 01 <-> 10
		test	change, enc0_masklow  wz   ' which reverses sense of this test.
	if_nz	add	count0, #1
	if_z	sub	count0, #1
		wrlong	count0, enc0_addr

:next1
		test	change, enc1_mask  wc, wz  ' again for channel 1
	if_z	jmp	#:next2
	if_nc	add	error1, #1		' nz, nc means both bits changed, error case
	if_nc	wrlong	error1, err1_addr
	if_nc	jmp	#:next2

		test	newstate, enc1_mask  wc
	if_nc	xor	change, enc1_mask
		test	change, enc1_masklow  wz
	if_nz	add	count1, #1
	if_z	sub	count1, #1
		wrlong	count1, enc1_addr

:next2
		test	change, enc2_mask  wc, wz  ' again for channel 2
	if_z	jmp	#:next3
	if_nc	add	error2, #1		' nz, nc means both bits changed, error case
	if_nc	wrlong	error2, err2_addr
	if_nc	jmp	#:next3

		test	newstate, enc2_mask  wc
	if_nc	xor	change, enc2_mask
		test	change, enc2_masklow  wz
	if_nz	add	count2, #1
	if_z	sub	count2, #1
		wrlong	count2, enc2_addr

:next3
		test	change, enc3_mask  wc, wz  ' again for channel 3
	if_z	jmp	#:done
	if_nc	add	error3, #1		' nz, nc means both bits changed, error case
	if_nc	wrlong	error3, err3_addr
	if_nc	jmp	#:done

		test	newstate, enc3_mask  wc
	if_nc	xor	change, enc3_mask
		test	change, enc3_masklow  wz
	if_nz	add	count3, #1
	if_z	sub	count3, #1
		wrlong	count3, enc3_addr

:done
		mov	state, newstate		' update state ready for the go-around.
		jmp	#enc_loop

{{ --------------------- ASM variables --------------------- }}

count0		long	0    	       ' local counters - note we don't read ever, only write, and start at zero
count1		long	0
count2		long	0
count3		long	0

error0		long	0	       ' local error counters, again we only write these to hub.
error1		long	0
error2		long	0
error3		long	0

parm            res     1

mask		res	1	       ' mask for all active channel pins

Apin		res	1              ' variables for init_pins
Bpin		res	1
Amask		res	1
ABmask		res	1

state           res     1	       ' state for main WAITPNE loop
newstate        res     1
change          res     1

enc0_addr	res	1	       ' counter addresses
enc1_addr	res	1
enc2_addr	res	1
enc3_addr 	res	1

err0_addr	res	1
err1_addr	res	1
err2_addr	res	1
err3_addr 	res	1

enc0_mask	res	1	       ' masks per channel, union of masks for pins A and B
enc1_mask	res	1
enc2_mask	res	1
enc3_mask	res	1
enc0_masklow	res	1              ' masks for direction test, just pin A
enc1_masklow	res	1
enc2_masklow	res	1
enc3_masklow	res	1


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
