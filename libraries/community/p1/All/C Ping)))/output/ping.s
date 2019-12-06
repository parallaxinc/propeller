	.area text(rom,rel)
	.dbfile ..\..\..\..\..\..\DOCUME~1\Steve\MYDOCU~1\_Propeller_OBEX_\Ping\ping.c
	.dbfile C:\DOCUME~1\Steve\MYDOCU~1\_Propeller_OBEX_\Ping\ping.c
	.dbfunc e ping_clockc _ping_clockc fL
;             t1 -> R6
;             t0 -> R4
;           mask -> R5
;            pin -> R7
_ping_clockc::
	@FENTER	
	.long R4,R5,R6,R7,R15,0	
	mov R7,R0	
	.dbline -1
	.dbline 16
; /**
;  * @file ping.c
;  * Ping driver implementation. See ping.h for API descriptions.
;  * Distance functions return rounded one-way distances.
;  * Copyright (c) 2009, Steve Denson
;  * See end of file for MIT license terms.
;  */
; #include <propeller.h>
; #include "ping.h"
; 
; /*
;  * Measure ping distance in clock ticks.
;  * See header for API description.
;  */
; long ping_clockc(int pin)
; {
	.dbline 18
;     long t0,t1;
;     int mask = 1 << pin;
	mov R5,#1	
	shl R5,R7	
	.dbline 19
;     asm("or outa, %mask");      // make sure bit is high
	or outa, R5
	.dbline 20
;     asm("or dira, %mask");      // set bit to output
	or dira, R5
	.dbline 21
;     msleep(1);                  // send 1ms pulse ... minimum pw = 2.0us
	mov R0,#1	
	@FCALL	
	.long _msleep	
	.dbline 22
;     asm("andn outa, %mask");    // make sure bit is low
	andn outa, R5
	.dbline 23
;     asm("andn dira, %mask");    // clear bit to input
	andn dira, R5
	.dbline 24
;     asm("waitpeq %mask, %mask");
	waitpeq R5, R5
	.dbline 25
;     asm("mov %t0, cnt");        // bit high now
	mov R4, cnt
	.dbline 26
;     asm("waitpne %mask, %mask");
	waitpne R5, R5
	.dbline 27
;     asm("mov %t1, cnt");        // bit low now
	mov R6, cnt
	.dbline 28
;     return (t1-t0)>>1;          // number of clock ticks passed one way
	mov R15,R6	
	sub R15,R4	
	mov R0,R15	
	sar R0,#1	
	.dbline -2
L1:
	@FPOP	
	.long R15,R7,R6,R5,R4,0	
	@FRET
	.dbline 0 ; func end
	.dbsym r t1 6 L
	.dbsym r t0 4 L
	.dbsym r mask 5 I
	.dbsym r pin 7 I
	.dbend
	.dbfunc s ping_convert _ping_convert fL
;         clkdiv -> R6
;         clocks -> R4
;             rc -> R4
;          units -> R5
;            pin -> R4
_ping_convert:
	@FENTER	
	.long R4,R5,R6,R15,0	
	mov R4,R0	
	mov R5,R1	
	.dbline -1
	.dbline 35
; }
; 
; /*
;  * private conversion function
;  */
; static long ping_convert(int pin, long units)
; {
	.dbline 38
;     long rc;
; 	long clocks;
;     long clkdiv  = (CLKFREQ/PING_CLK_PER_CONST);
	@FLDCNST	
	.long 1000000	
	mov R1,TEMP0	
	rdlong R0,#0	
	@FDIV32S	
	mov R15,R0	
	mov R6,R0	
	.dbline 40
; 
; 	clocks = ping_clocks(pin);	// use asm version
	mov R0,R4	
	@FCALL	
	.long _ping_clocks	
	mov R4,R0	
	.dbline 42
; 	//clocks = ping_clockc(pin); // use c version
; 	rc = clocks/clkdiv;
	mov R1,R6	
	mov R0,R4	
	@FDIV32S	
	.dbline 43
;     rc = rc*units/PING_CLK_PER_CONST;
	mov R1,R5	
	@FMUL32	
	mov R15,R0	
	@FLDCNST	
	.long 1000000	
	mov R1,TEMP0	
	mov R0,R15	
	@FDIV32S	
	mov R15,R0	
	mov R4,R0	
	.dbline 44
;     return rc;
	mov R0,R15	
	.dbline -2
L2:
	@FPOP	
	.long R15,R6,R5,R4,0	
	@FRET
	.dbline 0 ; func end
	.dbsym r clkdiv 6 L
	.dbsym r clocks 4 L
	.dbsym r rc 4 L
	.dbsym r units 5 L
	.dbsym r pin 4 I
	.dbend
	.dbfunc e ping_mm _ping_mm fL
;            pin -> R4
_ping_mm::
	@FENTER	
	.long R4,R15,0	
	mov R4,R0	
	.dbline -1
	.dbline 52
; }
; 
; /*
;  * Measure ping distance in milli-meters.
;  * See header for API description.
;  */
; long ping_mm(int pin)
; {
	.dbline 53
;     return ping_convert(pin, PING_SOS_MM_PER_SEC); 
	mov R0,R4	
	@FLDCNST	
	.long 340290	
	mov R1,TEMP0	
	@FCALL	
	.long _ping_convert	
	mov R15,R0	
	.dbline -2
L3:
	@FPOP	
	.long R15,R4,0	
	@FRET
	.dbline 0 ; func end
	.dbsym r pin 4 I
	.dbend
	.dbfunc e ping_cm _ping_cm fL
;            pin -> R4
_ping_cm::
	@FENTER	
	.long R4,R15,0	
	mov R4,R0	
	.dbline -1
	.dbline 61
; }
; 
; /*
;  * Measure ping distance in centi-meters.
;  * See header for API description.
;  */
; long ping_cm(int pin)
; {
	.dbline 62
;     return ping_convert(pin, PING_SOS_CM_PER_SEC); 
	mov R0,R4	
	@FLDCNST	
	.long 34029	
	mov R1,TEMP0	
	@FCALL	
	.long _ping_convert	
	mov R15,R0	
	.dbline -2
L4:
	@FPOP	
	.long R15,R4,0	
	@FRET
	.dbline 0 ; func end
	.dbsym r pin 4 I
	.dbend
	.dbfunc e ping_dm _ping_dm fL
;            pin -> R4
_ping_dm::
	@FENTER	
	.long R4,R15,0	
	mov R4,R0	
	.dbline -1
	.dbline 70
; }
; 
; /*
;  * Measure ping distance in deci-meters.
;  * See header for API description.
;  */
; long ping_dm(int pin)
; {
	.dbline 71
;     return ping_convert(pin, PING_SOS_DM_PER_SEC); 
	mov R0,R4	
	@FLDCNST	
	.long 3403	
	mov R1,TEMP0	
	@FCALL	
	.long _ping_convert	
	mov R15,R0	
	.dbline -2
L5:
	@FPOP	
	.long R15,R4,0	
	@FRET
	.dbline 0 ; func end
	.dbsym r pin 4 I
	.dbend
	.dbfunc e ping_inch _ping_inch fL
;            pin -> R4
_ping_inch::
	@FENTER	
	.long R4,R15,0	
	mov R4,R0	
	.dbline -1
	.dbline 79
; }
; 
; /*
;  * Measure ping distance in inches.
;  * See header for API description.
;  */
; long ping_inch(int pin)
; {
	.dbline 80
;     return ping_convert(pin, PING_SOS_IN_PER_SEC); 
	mov R0,R4	
	@FLDCNST	
	.long 13397	
	mov R1,TEMP0	
	@FCALL	
	.long _ping_convert	
	mov R15,R0	
	.dbline -2
L6:
	@FPOP	
	.long R15,R4,0	
	@FRET
	.dbline 0 ; func end
	.dbsym r pin 4 I
	.dbend
	.dbfunc e ping_foot _ping_foot fL
;            pin -> R4
_ping_foot::
	@FENTER	
	.long R4,R15,0	
	mov R4,R0	
	.dbline -1
	.dbline 88
; }
; 
; /*
;  * Measure ping distance in feet.
;  * See header for API description.
;  */
; long ping_foot(int pin)
; {
	.dbline 89
;     return ping_convert(pin, PING_SOS_FT_PER_SEC); 
	mov R0,R4	
	@FLDCNST	
	.long 1116	
	mov R1,TEMP0	
	@FCALL	
	.long _ping_convert	
	mov R15,R0	
	.dbline -2
L7:
	@FPOP	
	.long R15,R4,0	
	@FRET
	.dbline 0 ; func end
	.dbsym r pin 4 I
	.dbend
