	.area text(rom,rel)
	.dbfile ..\..\..\..\..\..\DOCUME~1\Steve\MYDOCU~1\_Propeller_OBEX_\Ping\PingTest.c
	.dbfile C:\DOCUME~1\Steve\MYDOCU~1\_Propeller_OBEX_\Ping\PingTest.c
	.dbfunc e main _main fV
;           dist -> R4
;           time -> R4
;        pingpin -> R4
_main::
	sub HRSP,#8	
	.dbline -1
	.dbline 18
; /**
;  * @file PingTest.c
;  * Ping driver test application.
;  * Copyright (c) 2009, Steve Denson
;  * See end of file for MIT license terms.
;  */
; 
; #include <stdio.h>
; #include <propeller.h>
; #include "FdSerial.h"
; #include "ping.h"
; 
; /**
;  * start serial port
;  * print ping measurements
;  */
; void main(void)
; {
	.dbline 19
;     int time = 0;
	.dbline 20
;     int dist = 0;
	.dbline 21
;     int pingpin = 19;
	mov R4,#19	
	.dbline 23
; 
;     FdSerial_start(31,30,0,115200);
	mov R0,#31	
	mov R1,#30	
	mov R2,#0	
	@FLDCNST	
	.long 115200	
	mov R3,TEMP0	
	@FCALL	
	.long _FdSerial_start	
	.dbline 24
;     msleep(500); // wait for user console to start
	mov R0,#500	
	@FCALL	
	.long _msleep	
	rdlong PC,PC	
	.long L3	
L2:
	.dbline 26
; 
;     while(1) {
	.dbline 27
;         printf("\r\nPing Measurements ... ");
	@FLDCNST	
	.long L5	
	mov R15,TEMP0	
	mov TEMP5,HRSP	
	wrlong R15,HRSP	
	@FCALL	
	.long _printf	
	.dbline 28
;         printf("%d mm, ", ping_mm(pingpin));
	mov R0,R4	
	@FCALL	
	.long _ping_mm	
	mov R15,R0	
	@FLDCNST	
	.long L6	
	mov R14,TEMP0	
	mov TEMP5,HRSP	
	wrlong R14,HRSP	
	mov TEMP5,HRSP	
	add TEMP5,#4	
	wrlong R15,TEMP5	
	@FCALL	
	.long _printf	
	.dbline 29
;         printf("%d cm, ", ping_cm(pingpin));
	mov R0,R4	
	@FCALL	
	.long _ping_cm	
	mov R15,R0	
	@FLDCNST	
	.long L7	
	mov R14,TEMP0	
	mov TEMP5,HRSP	
	wrlong R14,HRSP	
	mov TEMP5,HRSP	
	add TEMP5,#4	
	wrlong R15,TEMP5	
	@FCALL	
	.long _printf	
	.dbline 30
;         printf("%d dm, ", ping_dm(pingpin));
	mov R0,R4	
	@FCALL	
	.long _ping_dm	
	mov R15,R0	
	@FLDCNST	
	.long L8	
	mov R14,TEMP0	
	mov TEMP5,HRSP	
	wrlong R14,HRSP	
	mov TEMP5,HRSP	
	add TEMP5,#4	
	wrlong R15,TEMP5	
	@FCALL	
	.long _printf	
	.dbline 31
;         printf("%d in, ", ping_inch(pingpin));
	mov R0,R4	
	@FCALL	
	.long _ping_inch	
	mov R15,R0	
	@FLDCNST	
	.long L9	
	mov R14,TEMP0	
	mov TEMP5,HRSP	
	wrlong R14,HRSP	
	mov TEMP5,HRSP	
	add TEMP5,#4	
	wrlong R15,TEMP5	
	@FCALL	
	.long _printf	
	.dbline 32
;         printf("%d ft", ping_foot(pingpin));
	mov R0,R4	
	@FCALL	
	.long _ping_foot	
	mov R15,R0	
	@FLDCNST	
	.long L10	
	mov R14,TEMP0	
	mov TEMP5,HRSP	
	wrlong R14,HRSP	
	mov TEMP5,HRSP	
	add TEMP5,#4	
	wrlong R15,TEMP5	
	@FCALL	
	.long _printf	
	.dbline 33
;         msleep(5);
	mov R0,#5	
	@FCALL	
	.long _msleep	
	.dbline 34
;     }
L3:
	.dbline 26
	rdlong PC,PC	
	.long L2	
L11:
	.dbline 36
; 
;     while(1);
L12:
	.dbline 36
	sub PC,#4	;Jump to L11
X0:
	.dbline -2
L1:
	add HRSP,#8	
	@FRET
	.dbline 0 ; func end
	.dbsym r dist 4 I
	.dbsym r time 4 I
	.dbsym r pingpin 4 I
	.dbend
	.dbfunc e putchar _putchar fI
;            val -> R4
_putchar::
	@FENTER	
	.long R4,0	
	mov R4,R0	
	.dbline -1
	.dbline 43
; }
; 
; /**
;  * define putchar for printf to use
;  */
; int putchar(char val)
; {
	.dbline 44
;     FdSerial_tx(val);
	mov R0,R4	
	and R0,MASKFF	
	@FCALL	
	.long _FdSerial_tx	
	.dbline 45
;     return 0;
	mov R0,#0	
	.dbline -2
L14:
	@FPOP	
	.long R4,0	
	@FRET
	.dbline 0 ; func end
	.dbsym r val 4 c
	.dbend
	.area lit(rom,rel)
L10:
	.byte 37,'d,32,'f,'t,0
L9:
	.byte 37,'d,32,'i,'n,44,32,0
L8:
	.byte 37,'d,32,'d,'m,44,32,0
L7:
	.byte 37,'d,32,'c,'m,44,32,0
L6:
	.byte 37,'d,32,'m,'m,44,32,0
L5:
	.byte 13,10,'P,'i,'n,'g,32,'M,'e,'a,'s,'u,'r,'e,'m,'e
	.byte 'n,'t,'s,32,46,46,46,32,0
