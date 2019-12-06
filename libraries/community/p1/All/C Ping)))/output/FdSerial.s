	.area text(rom,rel)
	.dbfile ..\..\..\..\..\..\DOCUME~1\Steve\MYDOCU~1\_Propeller_OBEX_\Ping\FdSerial.c
	.area data(ram,rel)
	.dbfile ..\..\..\..\..\..\DOCUME~1\Steve\MYDOCU~1\_Propeller_OBEX_\Ping\FdSerial.c
	.align	4
_FdSerial_Array::
	.long -1598248464
	.long -2130925552
	.long 146582100
	.long -1594052095
	.long 750563925
	.long -2130925564
	.long 146582100
	.long -1594049023
	.long 750566997
	.long -2130925564
	.long 146583124
	.long -2130925564
	.long 146583636
	.long -2130925564
	.long 146584660
	.long -1598242726
	.long -2130919408
	.long 1652338180
	.long 1635560962
	.long 1755048031
	.long 1756097631
	.long -1594046413
	.long 1555872868
	.long 1652338177
	.long 1631368178
	.long 1550057494
	.long -1594050551
	.long -1598244264
	.long 687651329
	.long -2135114767
	.long -2135115176
	.long 1555872868
	.long -1598248867
	.long -2068010511
	.long -1048795136
	.long 1548484639
	.long 1631368178
	.long 821868033
	.long -453199842
	.long 687650327
	.long 1627174655
	.long 1652338177
	.long 1825879807
	.long 146582512
	.long -2135119270
	.long 3978837
	.long -2068010406
	.long -2130925055
	.long 1627171343
	.long 138193904
	.long 1551630358
	.long 1555875934
	.long -1598248464
	.long -2130925560
	.long 146582100
	.long -2130925564
	.long 146582612
	.long -2042844586
	.long 1550319667
	.long -2135118752
	.long 12370518
	.long -2068009888
	.long -2130924543
	.long 1627171855
	.long 138194004
	.long 1761395456
	.long 754762242
	.long 1761395201
	.long -1594047477
	.long -1598240783
	.long 1652338180
	.long 1635560962
	.long 1826669057
	.long 704430593
	.long 1890314335
	.long 1956113503
	.long -2135112104
	.long 1555875934
	.long -1598248861
	.long -2068010511
	.long -1048795136
	.long 1548484685
	.long -453196730
	.long 1551630387
	.long 50
	.long 364
	.dbfile C:\DOCUME~1\Steve\MYDOCU~1\_Propeller_OBEX_\Ping\FdSerial_Array.h
	.dbsym e FdSerial_Array _FdSerial_Array A[344:86]L
	.align	4
_gFdSerialCog:
	.long 0
	.dbfile C:\DOCUME~1\Steve\MYDOCU~1\_Propeller_OBEX_\Ping\FdSerial.c
	.dbsym s gFdSerialCog _gFdSerialCog L
	.area text(rom,rel)
	.dbfile C:\DOCUME~1\Steve\MYDOCU~1\_Propeller_OBEX_\Ping\FdSerial.c
	.dbfunc e FdSerial_start _FdSerial_start fI
;        clkfreq -> R5
;             id -> R4
;       baudrate -> R6
;           mode -> R7
;          txpin -> R8
;          rxpin -> R9
_FdSerial_start::
	@FENTER	
	.long R4,R5,R6,R7,R8,R9,R15,0	
	mov R9,R0	
	mov R8,R1	
	mov R7,R2	
	mov R6,R3	
	.dbline -1
	.dbline 39
; /**
;  * @file FdSerial.c
;  * Full Duplex Serial adapter module.
;  *
;  * Copyright (c) 2008, Steve Denson
;  * See end of file for terms of use.
;  */
; #include <stdio.h>
; #include <stdlib.h>
; #include <string.h>
; #include <propeller.h>
; 
; #include "FdSerial.h"
; #include "FdSerial_Array.h"
; 
; static long  gFdSerialCog = 0;  //cog flag/id
; static long  gclkfreq;          // clock frequency
; 
; FdSerial_t gFdSerial;    // fdserial descriptor
; 
; /* 
;  * These buffers must be contiguous. Their size must match the asm expectation.
;  * Asm also expects the address of txbuff to be after rxbuff.
;  * Apparently the C compiler "allocates" this memory in reverse order.
;  * Using a struct would correct it, but for now let's just reverse the entry.
;  */
; char  gFdSerial_txbuff[FDSERIAL_BUFF_MASK+1];  // transmit buffer
; char  gFdSerial_rxbuff[FDSERIAL_BUFF_MASK+1];  // receive buffer
; 
; /**
;  * start initializes and starts native assembly driver in a cog.
;  * @param rxpin is pin number for receive input
;  * @param txpin is pin number for transmit output
;  * @param mode is interface mode. see header FDSERIAL_MODE_...
;  * @param baudrate is frequency of bits ... 115200, 57600, etc...
;  * @returns non-zero on success
;  */
; int FdSerial_start(int rxpin, int txpin, int mode, int baudrate)
; {
	.dbline 40
;     int id = 0;
	.dbline 42
;     // clkfreq is internal cpu clock frequency (80000000 for 5M*pll16x)
;     int clkfreq = CLKFREQ;
	rdlong R5,#0	
	.dbline 44
; 
;     FdSerial_stop();
	@FCALL	
	.long _FdSerial_stop	
	.dbline 45
;     memset(&gFdSerial, 0, sizeof(FdSerial_t));
	@FLDCNST	
	.long _gFdSerial	
	mov R0,TEMP0	
	mov R1,#0	
	mov R2,#36	
	@FCALL	
	.long _memset	
	.dbline 46
;     gFdSerial.rx_pin = rxpin; // recieve pin
	@FSTOREL	
	.long _gFdSerial+16	
	.long R9	
	.dbline 47
;     gFdSerial.tx_pin = txpin; // transmit pin
	@FSTOREL	
	.long _gFdSerial+20	
	.long R8	
	.dbline 48
;     gFdSerial.mode   = mode;  // interface mode
	@FSTOREL	
	.long _gFdSerial+24	
	.long R7	
	.dbline 49
;     gclkfreq = clkfreq;
	@FSTOREL	
	.long _gclkfreq	
	.long R5	
	.dbline 50
;     gFdSerial.ticks = clkfreq/baudrate; // baud
	mov R1,R6	
	mov R0,R5	
	@FDIV32S	
	mov R15,R0	
	@FSTOREL	
	.long _gFdSerial+28	
	.long R15	
	.dbline 51
;     gFdSerial.buffptr = (int)&gFdSerial_rxbuff[0];
	@FLDCNST	
	.long _gFdSerial_rxbuff	
	mov R15,TEMP0	
	@FSTOREL	
	.long _gFdSerial+32	
	.long R15	
	.dbline 52
;     id = cognew_native((void*)FdSerial_Array, (void*)&gFdSerial) + 1;
	mov R0,#8	
	@FLDCNST	
	.long _FdSerial_Array	
	mov R1,TEMP0	
	@FLDCNST	
	.long _gFdSerial	
	mov R2,TEMP0	
	@FCALL	
	.long _coginit_native	
	mov R15,R0	
	mov R4,R0	
	add R4,#1	
	.dbline 53
;     gFdSerialCog = id;
	@FSTOREL	
	.long _gFdSerialCog	
	.long R4	
	.dbline 54
;     wait(1000000); // give cog chance to load
	@FLDCNST	
	.long 1000000	
	mov R0,TEMP0	
	@FCALL	
	.long _wait	
	.dbline 55
;     return id;
	mov R0,R4	
	.dbline -2
L1:
	@FPOP	
	.long R15,R9,R8,R7,R6,R5,R4,0	
	@FRET
	.dbline 0 ; func end
	.dbsym r clkfreq 5 I
	.dbsym r id 4 I
	.dbsym r baudrate 6 I
	.dbsym r mode 7 I
	.dbsym r txpin 8 I
	.dbsym r rxpin 9 I
	.dbend
	.dbfunc e FdSerial_stop _FdSerial_stop fV
;             id -> R0
_FdSerial_stop::
	@FENTER	
	.long R15,0	
	.dbline -1
	.dbline 62
; }
; 
; /**
;  * stop stops the cog running the native assembly driver 
;  */
; void FdSerial_stop(void)
; {
	.dbline 63
;     int id = gFdSerialCog - 1;
	@FLOADL	
	.long _gFdSerialCog	
	.long R15	
	mov R0,R15	
	sub R0,#1	
	.dbline 64
;     if(gFdSerialCog > 0) {
	@FLOADL	
	.long _gFdSerialCog	
	.long R15	
	cmps R15,#0	WZ WC
IF_BE	add PC,#4	;Jump to L8
	.dbline 64
	.dbline 65
;         asm("cogstop %id");
	cogstop R0
	.dbline 66
;     }
L8:
	.dbline -2
L7:
	@FPOP	
	.long R15,0	
	@FRET
	.dbline 0 ; func end
	.dbsym r id 0 I
	.dbend
	.dbfunc e FdSerial_rxflush _FdSerial_rxflush fV
_FdSerial_rxflush::
	@FENTER	
	.long R15,0	
	.dbline -1
	.dbline 73
; }
; 
; /**
;  * rxflush empties the receive queue 
;  */
; void FdSerial_rxflush(void)
; {
L11:
	.dbline 75
;     while(FdSerial_rxcheck() >= 0)
;         ; // clear out queue by receiving all available 
L12:
	.dbline 74
	@FCALL	
	.long _FdSerial_rxcheck	
	mov R15,R0	WC
IF_AE	sub PC,#16	;Jump to L11
	.dbline -2
L10:
	@FPOP	
	.long R15,0	
	@FRET
	.dbline 0 ; func end
	.dbend
	.dbfunc e FdSerial_rxcheck _FdSerial_rxcheck fI
	.dbstruct 0 36 FdSerial_struct
	.dbfield 0 rx_head I
	.dbfield 4 rx_tail I
	.dbfield 8 tx_head I
	.dbfield 12 tx_tail I
	.dbfield 16 rx_pin I
	.dbfield 20 tx_pin I
	.dbfield 24 mode I
	.dbfield 28 ticks I
	.dbfield 32 buffptr I
	.dbend
;             rc -> R1
;              p -> R2
_FdSerial_rxcheck::
	@FENTER	
	.long R14,R15,0	
	.dbline -1
	.dbline 84
; }
; 
; /**
;  * Gets a byte from the receive queue if available
;  * Function does not block. We move rxtail after getting char.
;  * @returns receive byte 0 to 0xff or -1 if none available 
;  */
; int FdSerial_rxcheck(void)
; {
	.dbline 85
;     int rc = -1;
	@FLDCNST	
	.long -1	
	mov R1,TEMP0	
	.dbline 86
;     FdSerial_t* p = &gFdSerial;
	@FLDCNST	
	.long _gFdSerial	
	mov R2,TEMP0	
	.dbline 87
;     if(p->rx_tail != p->rx_head)
	rdlong R15,TEMP0	
	mov R14,R2	
	add R14,#4	
	rdlong R14,R14	
	cmp R14,R15	WZ
IF_E	add PC,#64	;Jump to L15
	.dbline 88
;     {
	.dbline 89
;         rc = gFdSerial_rxbuff[p->rx_tail];
	@FLDCNST	
	.long _gFdSerial_rxbuff	
	mov R15,TEMP0	
	mov R14,R2	
	add R14,#4	
	rdlong R14,R14	
	add R14,R15	
	rdbyte R1,R14	
	and R1,MASKFF	
	.dbline 90
;         p->rx_tail = (p->rx_tail+1) & FDSERIAL_BUFF_MASK;
	mov R15,R2	
	add R15,#4	
	mov R15,R15	
	rdlong R14,R15	
	add R14,#1	
	and R14,#15	
	wrlong R14,R15	
	.dbline 91
;     }
L15:
	.dbline 92
;     return rc;
	mov R0,R1	
	.dbline -2
L14:
	@FPOP	
	.long R15,R14,0	
	@FRET
	.dbline 0 ; func end
	.dbsym r rc 1 I
	.dbsym r p 2 pS[FdSerial_struct]
	.dbend
	.dbfunc e FdSerial_rxtime _FdSerial_rxtime fI
;             t0 -> R5
;             t1 -> R6
;             rc -> R4
;             ms -> R7
_FdSerial_rxtime::
	@FENTER	
	.long R4,R5,R6,R7,R15,0	
	mov R7,R0	
	.dbline -1
	.dbline 102
; }
; 
; /**
;  * Get a byte from the receive queue if available within timeout period.
;  * Function blocks if no recieve for ms timeout.
;  * @param ms is number of milliseconds to wait for a char
;  * @returns receive byte 0 to 0xff or -1 if none available 
;  */
; int FdSerial_rxtime(int ms)
; {
	.dbline 103
;     int rc = -1;
	@FLDCNST	
	.long -1	
	mov R4,TEMP0	
	.dbline 104
;     int t0 = 0;
	mov R5,#0	
	.dbline 105
;     int t1 = 0;
	mov R6,#0	
	.dbline 106
;     asm("mov %t0, cnt");
	mov R5, cnt
L18:
	.dbline 107
;     do {
	.dbline 108
;         rc = FdSerial_rxcheck();
	@FCALL	
	.long _FdSerial_rxcheck	
	mov R4,R0	
	.dbline 109
;         asm("mov %t1, cnt");
	mov R6, cnt
	.dbline 110
;         if((t1 - t0)/(gclkfreq/1000) > ms)
	@FLDCNST	
	.long 1000	
	mov R1,TEMP0	
	@FLOADL	
	.long _gclkfreq	
	.long R0	
	@FDIV32S	
	mov R15,R0	
	mov R0,R6	
	sub R0,R5	
	mov R1,R15	
	@FDIV32S	
	mov R15,R0	
	cmps R15,R7	WZ WC
IF_BE	add PC,#4	;Jump to L21
	.dbline 111
;             break;
	add PC,#8	;Jump to L20
L21:
	.dbline 112
;     } while(rc < 0);
L19:
	.dbline 112
	cmps R4,#0	WC
IF_B	sub PC,#88	;Jump to L18
L20:
	.dbline 113
;     return rc;
	mov R0,R4	
	.dbline -2
L17:
	@FPOP	
	.long R15,R7,R6,R5,R4,0	
	@FRET
	.dbline 0 ; func end
	.dbsym r t0 5 I
	.dbsym r t1 6 I
	.dbsym r rc 4 I
	.dbsym r ms 7 I
	.dbend
	.dbfunc e FdSerial_rx _FdSerial_rx fI
;             rc -> R4
_FdSerial_rx::
	@FENTER	
	.long R4,R15,0	
	.dbline -1
	.dbline 121
; }
; 
; /**
;  * Wait for a byte from the receive queue. blocks until something is ready.
;  * @returns received byte 
;  */
; int FdSerial_rx(void)
; {
	.dbline 122
;     int rc = FdSerial_rxcheck();
	@FCALL	
	.long _FdSerial_rxcheck	
	mov R15,R0	
	mov R4,R0	
	add PC,#16	;Jump to L25
L24:
	.dbline 124
;     while(rc < 0)
;         rc = FdSerial_rxcheck();
	@FCALL	
	.long _FdSerial_rxcheck	
	mov R15,R0	
	mov R4,R0	
L25:
	.dbline 123
	cmps R4,#0	WC
IF_B	sub PC,#24	;Jump to L24
	.dbline 125
;     return rc;
	mov R0,R4	
	.dbline -2
L23:
	@FPOP	
	.long R15,R4,0	
	@FRET
	.dbline 0 ; func end
	.dbsym r rc 4 I
	.dbend
	.dbfunc e FdSerial_tx _FdSerial_tx fI
;         txbuff -> R6
;             rc -> R4
;              p -> R5
;         txbyte -> R7
_FdSerial_tx::
	@FENTER	
	.long R4,R5,R6,R7,R14,R15,0	
	mov R7,R0	
	.dbline -1
	.dbline 133
; }
; 
; /**
;  * tx sends a byte on the transmit queue.
;  * @param txbyte is byte to send. 
;  */
; int FdSerial_tx(int txbyte)
; {
	.dbline 134
;     int rc = -1;
	@FLDCNST	
	.long -1	
	mov R4,TEMP0	
	.dbline 135
;     char* txbuff = gFdSerial_txbuff;
	@FLDCNST	
	.long _gFdSerial_txbuff	
	mov R6,TEMP0	
	.dbline 136
;     FdSerial_t* p = &gFdSerial;
	@FLDCNST	
	.long _gFdSerial	
	mov R5,TEMP0	
	@FCACHE	
L28:
	.dbline 139
; 
;     while(p->tx_tail != p->tx_head) // wait for queue to be empty
;         ;
L29:
	.dbline 138
	mov R15,R5	
	add R15,#8	
	rdlong R15,R15	
	mov R14,R5	
	add R14,#12	
	rdlong R14,R14	
	cmp R14,R15	WZ
IF_NE	jmp #L28
	@FNEXT	
	.dbline 141
; 
;     txbuff[p->tx_head] = txbyte;
	mov R15,R5	
	add R15,#8	
	rdlong R15,R15	
	add R15,R6	
	mov R14,R7	
	wrbyte R14,R15	
	.dbline 142
;     p->tx_head = (p->tx_head+1) & FDSERIAL_BUFF_MASK;
	mov R15,R5	
	add R15,#8	
	mov R15,R15	
	rdlong R14,R15	
	add R14,#1	
	and R14,#15	
	wrlong R14,R15	
	.dbline 144
; 
;     if(p->mode & FDSERIAL_MODE_IGNORE_TX_ECHO)
	mov R15,R5	
	add R15,#24	
	rdlong R15,R15	
	test R15,#8	WZ
IF_E	add PC,#16	;Jump to L31
	.dbline 145
;         rc = FdSerial_rx(); // why not rxcheck or timeout ... this blocks for char
	@FCALL	
	.long _FdSerial_rx	
	mov R15,R0	
	mov R4,R0	
L31:
	.dbline 147
; 
;     return rc;
	mov R0,R4	
	.dbline -2
L27:
	@FPOP	
	.long R15,R14,R7,R6,R5,R4,0	
	@FRET
	.dbline 0 ; func end
	.dbsym r txbuff 6 pc
	.dbsym r rc 4 I
	.dbsym r p 5 pS[FdSerial_struct]
	.dbsym r txbyte 7 I
	.dbend
	.area bss(ram,rel)
	.dbfile C:\DOCUME~1\Steve\MYDOCU~1\_Propeller_OBEX_\Ping\FdSerial.c
_gFdSerial_rxbuff::
	.blkb 16
	.dbsym e gFdSerial_rxbuff _gFdSerial_rxbuff A[16:16]c
_gFdSerial_txbuff::
	.blkb 16
	.dbsym e gFdSerial_txbuff _gFdSerial_txbuff A[16:16]c
	.align	4
_gFdSerial::
	.blkb 36
	.dbsym e gFdSerial _gFdSerial S[FdSerial_struct]
	.align	4
_gclkfreq:
	.blkb 4
	.dbsym s gclkfreq _gclkfreq L
