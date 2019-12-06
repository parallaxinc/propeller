{{P8X32A_QuickStart_LED_Fun.spin

P8X32A QuickStart board fun LED patterns,
by Rick Nungester 8/23/13.

This short Spin program generates interesting
patterns on the board's 8 LEDs.  The patterns
repeat after about 1.7 minutes.

Program Overview:

A 32-bit linear feedback shift register (LFSR)
with taps at bits 30 and 31 and initial seed
value 1 produces a repeating cycle of 1023
states:

Next bit #0 = these 2 bits XOR'd together.
vv
00000000000000000000000000000001 seed
00000000000000000000000000000010 next state
00000000000000000000000000000100 next state
... (27 states skipped)
01000000000000000000000000000000
10000000000000000000000000000001
00000000000000000000000000000011
00000000000000000000000000000110
00000000000000000000000000001100
... (988 states skipped)
00000000000000000000000000000001 back to seed

Bits 0 to 7 of the above values are mapped
to the board's LEDs, with 1 indicating "LED On".
LFSRs are also used to generate pseudo-random
numbers.  Other visually interesting tap sets
with seed = 1:

 0, 31 : 32-bit FSR, similar to above but order reversed
14, 15 : 16-bit FSR, 255 states, similar to above
28, 31 : 32-bit FSR, 1,409,286,123 states (~4.5 year repeat)
 6,  7 : 8-bit FSR, 63 states, see all bits 
}}

CON

  seed         =  1  ' initial FSR state
  tap0         = 30  ' FSR bit number of 1st XOR feedback tap
  tap1         = 31  ' FSR bit number of 2nd XOR feedback tap
  leftLED      = 16  ' Port A bit number of the left LED
  rightLED     = 23  ' Port A bit number of the right LED
  delay = 1_200_000  ' ~100 ms (default RCFAST ~12 MHz clock)

VAR

  long fsr  ' 32-bit (or less) feedback shift register


PUB go

  dira[rightLED..leftLED]~~  ' set the LEDs as outputs
  fsr := seed
  repeat
    outa[rightLED..leftLED] := fsr  ' make LS to MS bit left to right on the board
    waitcnt(delay + cnt)  ' "cnt" on the right (see "waitcnt" in spin reference) 
    fsr := (fsr << 1) | (((fsr & (|< tap0)) >> tap0) ^ ((fsr & (|< tap1)) >> tap1))