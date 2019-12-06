/**
 * @file ping_asm.s
 * Ping clocks ASM implementation.
 * Copyright (c) 2009, Steve Denson
 * See end of file for MIT license terms.
 */

	.area text(rom,rel)		// let assembler know we're code

/* ----------------------------------------
 * long ping_clocks(int pin) - same as ping_clockc API function signature
 * Measure ping distance in clock ticks.
 *
 * LMM assembly version of ping_clocks.
 * Affects R0,R1,R2,R3
 * @param pin variable is passed to function in R0
 * @return result in R0
 */
_ping_clocks::
    mov     R1,     #1		// one pin one bit
    shl     R1,     R0      // make pin mask #1 shl by pin number
    mov     R2,     #400    // set pulse delay 400*12.5ns = 5us @ 80MHz
    or      OUTA,   R1      // make sure bit is high
    or      DIRA,   R1      // set bit to output
    add     R2,     cnt     // add cnt to delay for waitcnt target
    waitcnt R2,     R2      // wait 10us pulse at 80MHz - wider for slower clk
    andn    OUTA,   R1      // make sure bit is low
    andn    DIRA,   R1      // clear bit to input
    waitpeq R1,     R1      // wait for ping return pulse to start high
    mov     R2,     cnt     // bit high now
    waitpne R1,     R1      // wait for ping return pulse finish low
    mov     R3,     cnt     // bit low now ... pulsewidth = R6-R5 * clk period
    sub     R3,     R2      // diff between R6, R5 ... caller deals with carry
    shr     R3,     #1      // number of clock ticks passed one way
    mov     R0,     R3      // return result in R0
	@FRET

/*
+------------------------------------------------------------------------------------------------------------------------------+
¦                                                   TERMS OF USE: MIT License                                                  ¦                                                            
+------------------------------------------------------------------------------------------------------------------------------¦
¦Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    ¦ 
¦files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    ¦
¦modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software¦
¦is furnished to do so, subject to the following conditions:                                                                   ¦
¦                                                                                                                              ¦
¦The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.¦
¦                                                                                                                              ¦
¦THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          ¦
¦WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         ¦
¦COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   ¦
¦ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         ¦
+------------------------------------------------------------------------------------------------------------------------------+
*/