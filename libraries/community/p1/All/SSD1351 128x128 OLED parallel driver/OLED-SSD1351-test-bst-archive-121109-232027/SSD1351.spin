{{
////////////////////////////////////////////////////////////////////////////////////////////
//                  SSD1351.spin
// 128x128driver for SSD1351 OLED controller

// Author: Mark Tillotson
// Updated: 2012-11-09
// Designed For: P8X32A
// Version: 1.0

// Provides

// PUB  Stop

// PUB  Start (nRES, nCS, DC, nWR, nRD, Vcc_en, vidgroup)
// pin numbers for nRESET, nCS, DC, nWR, nRD
// vidgroup for the databus (0, 1 or 2 for 0..7, 8..15 and 16..23 respectively)

// PUB  Synch
// wait for previous command to finish, normally you don't need to call this

// PUB  SetColours (fore, back)
// Colours are 16 bit, RRRRRGGGGGGBBBBB (5, 6, 5 bits per colour)
// foreground colour used for drawing generally, background for clearing screen and character backgrounds

// PUB  ClearScreen

// PUB  DrawDot (xl, yt)

// PUB  DrawLine (xl, yt, xr, yb)

// PUB  DrawChar (xl, yt, chr)
// coords of top-left, used Prop font (16x32 pixels)

// PUB  DrawCharSmall (xl, yt, chr)
// shrunk Prop font, 8x16 pixels

// PUB  DrawString (xl, yt, str)
// null terminated byte string in hub memory

// PUB  DrawStringSmall (xl, yt, str)

// PUB  DrawRect (xl, yt, xr, yb)
// xl <= xr, yt <= yb otherwise deemed empty rect

// PUB  Brightness (percent)
// change the current drive to the whole display


// ToDo:   Allow changing the scan orientation


// See end of file for standard MIT licence / terms of use.

// Update History:

// v1.0 - Initial version 2012-11-09

////////////////////////////////////////////////////////////////////////////////////////////
}}

CON
  CMD_SETUP = 1
  CMD_SETCOLOURS = 2

  CMD_RECT   = 4
  CMD_CLEAR  = 5
  CMD_LINE   = 6
  CMD_STRING = 7
  CMD_CHAR   = 8
  CMD_DOT    = 9
  CMD_BRITE  = 10

  MAX_ROW    = 128
  MAX_COL    = 128

VAR
  long  cog

  long  cmd
  long  arg0
  long  arg1


PUB  Stop
  if cog <> 0
    cogstop (cog-1)
  cog := 0

PUB  Start (nRES, nCS, DC, nWR, nRD, Vcc_en, vidgroup) | mask
  Stop
  cmd  := CMD_SETUP

  nRESmask := 1 << nRES
  nCSmask := 1 << nCS
  DCmask := 1 << DC
  nWRmask := 1 << nWR
  nRDmask := 1 << nRD
  Vccmask := 1 << Vcc_en
  datashift := vidgroup << 3
  datamask := $FF << datashift

  IF_COMM := nRESmask | nRDmask | nWRmask | Vccmask  ' command state, DC = low
  IF_DATA := IF_COMM | DCmask ' data state, DC = high
  IF_IDLE := IF_COMM | nCSmask ' IDLE, CS is high
  IF_ALL  := nRESmask | nRDmask | nWRmask | nCSmask | DCmask | Vccmask  ' for DIRA

  arg0 := @init_data
  arg1 := @init_data2

  cog := 1 + cognew (@entry, @cmd)
  if cog <> 0
    Synch
  result := cog


PUB  Synch
  repeat until cmd == 0

PUB  ClearScreen
  Synch
  cmd := CMD_CLEAR

PUB  Brightness (percent)
  Synch
  arg0 := (percent * 5) >> 5
  cmd := CMD_BRITE

PUB  DrawDot (xl, yt)
  Synch
  arg0 := xl << 16 | yt
  cmd := CMD_DOT

PUB  DrawLine (xl, yt, xr, yb)
  Synch
  arg0 := xl << 16 | yt
  arg1 := xr << 16 | yb
  cmd := CMD_LINE

PUB  DrawChar (xl, yt, chr)
  Synch
  arg0 := xl << 16 | yt
  arg1 := chr & $FF
  cmd := CMD_CHAR

PUB  DrawCharSmall (xl, yt, chr)
  Synch
  arg0 := xl << 16 | yt
  arg1 := chr | $100
  cmd := CMD_CHAR

PUB  DrawString (xl, yt, str)
  Synch
  arg0 := xl << 16 | yt
  arg1 := str
  cmd := CMD_STRING

PUB  DrawStringSmall (xl, yt, str)
  Synch
  arg0 := xl << 16 | yt
  arg1 := -str
  cmd := CMD_STRING

PUB  DrawRect (xl, yt, xr, yb)
  Synch
  arg0 := (xl << 16) | yt
  arg1 := (xr << 16) | yb
  cmd := CMD_RECT

PUB  SetColours (fore, back)
  Synch
  arg0 := (back << 16) | (fore & $ffff)
  cmd := CMD_SETCOLOURS
 

DAT      ' init calls: delayms,reg,valhi,vallo

init_data '      byte    $02, $FD, $12  ' command lock
		byte	$02, $FD, $B1  ' command lock
		byte	$01, $AE       ' sleep
		byte	$02, $B3, $F1  ' divide ratio / osc freq   (default D1).  Change to F6 for v slow
'		byte	$02, $CA, $7F  ' multiplex ratio
		byte	$02, $A2, $00  ' vertical scroll display offset
		byte	$02, $A1, $00  ' vertical scroll start line
		byte	$02, $A0, $66  ' - 64K colours, enable even/odd split, reverse RGB, rev columns - tab at screen top
		byte	$02, $A0, $74  ' - 64K colours, enable even/odd split, reverse RGB, rev rows    - tab at screen bot
		byte	$02, $B5, $00  ' GPIO
'		byte	$02, $AB, $01  ' function selection - 8 bit parallel, internal Vdd generation
		byte	0
init_data2
'		byte	$04, $B4, $A0, $B5, $55 ' segment low volt
'		byte	$04, $C1, $C8, $80, $C8 ' contrast current
'		byte	$02, $C7, $0F  ' master current
		byte	$40, $B8, $02, $03, $04, $05, $06, $07, $08     ' gamma table
		byte	     $09, $0A, $0B, $0C, $0D, $0E, $0F, $10
		byte         $11, $12, $13, $15, $17, $19, $1B, $1D
		byte	     $1F, $21, $23, $25, $27, $2A, $2D, $30
		byte         $33, $36, $39, $3C, $3F, $42, $45, $48
		byte	     $4C, $50, $54, $58, $5C, $60, $64, $68
		byte         $6C, $70, $74, $78, $7D, $82, $87, $8C
		byte         $91, $96, $9B, $A0, $A5, $AA, $AF, $B4
'		byte	$02, $B1, $32  ' phase length   (default 82)
''		byte	$04, $B2, $A4, $00, $00  ' enhance driving  NOT DOCUMENTED
'		byte	$02, $BB, $17  ' precharge volt
'		byte	$02, $B6, $01  ' 2nd precharge period  (default 08)
'		byte	$02, $BE, $05  ' VCOMH volt
		byte	$01, $A6       ' display mode normal (A7 = inverse)
		' now clear screen '
		byte    $01, $AF       ' unsleep
		byte	0


DAT

                ORG     0

entry           mov     parm, PAR
                rdlong  op, parm        ' can assume is setup
		add	parm, #4

		andn	IF_IDLE, Vccmask
		andn	IF_COMM, Vccmask
		andn	IF_DATA, Vccmask

                mov     OUTA, IF_IDLE
                mov     DIRA, IF_ALL
		or      DIRA, datamask

		call	#tenms

                andn    OUTA, nRESmask
                mov     delaycount, #2
                call    #del_millis
                or      OUTA, nRESmask

		call	#tenms

                rdlong  ptr, parm	' arg0 = @init_data
	        add     parm, #4
		call	#init_loop

		or	IF_IDLE, Vccmask
		or	IF_COMM, Vccmask
		or	IF_DATA, Vccmask
		mov	OUTA, IF_IDLE	' enable Vcc power.

		call	#tenms

                rdlong  ptr, parm	' arg0 = @init_data
		add	parm, #4	' arg1 = @init_data2
		call	#init_loop

		call	#tenms

		jmp	#command_return

{ ------------------------------------------------------ }

init_loop       mov	OUTA, IF_IDLE
		rdbyte  icount, ptr  wz
                add     ptr, #1
init_loop_ret if_z ret

		rdbyte  dval, ptr
		add	ptr, #1

		mov	OUTA, IF_COMM

		call	#wr_comm
		djnz	icount, #:init_argloop
		jmp	#init_loop
:init_argloop
		mov	OUTA, IF_DATA
		rdbyte  dval, ptr
		add	ptr, #1

                call    #wr_data
		djnz	icount, #:init_argloop
                jmp     #init_loop

{ ------------------------------------------------------ }

tenms		mov	delaycount, #10
del_millis      mov     time, CNT
                add     time, MSdelay
                waitcnt time, #0
                djnz    delaycount, #del_millis
tenms_ret
del_millis_ret  ret

{ ------------------------------------------------------ }


command_return  wrlong  zero, PAR

command_loop    rdlong  op, PAR  wz
        if_z    jmp     #command_loop
                call    #read_args

                cmp     op, #CMD_SETCOLOURS  wz
        if_nz   jmp     #:done_setcolours
        if_z    mov     foreground, y0
                mov     background, x0
                jmp     #command_return

:done_setcolours
                cmp     op, #CMD_CLEAR  wz
        if_nz   jmp     #:done_clear

                mov     t, foreground
                mov     foreground, background
                mov     x0, #0
                mov     x1, #(MAX_COL-1)
                mov     y0, #0
                mov     y1, #(MAX_ROW-1)
                call    #draw_rect
                mov     foreground, t
                jmp     #command_return

:done_clear     cmp     op, #CMD_RECT  wz
        if_nz   jmp     #:done_rect

                call    #draw_rect
                jmp     #command_return

:done_rect      cmp     op, #CMD_LINE  wz
        if_nz   jmp     #:done_line

                call    #draw_line
                jmp     #command_return


:done_line      cmp     op, #CMD_STRING  wz
        if_nz   jmp     #:done_string

                mov     strp, t2

                cmps    strp, #0  wc
        if_c    neg     strp, strp
                rcl     t, #1
                call    #draw_string
                
                jmp     #command_return

:done_string    cmp     op, #CMD_CHAR  wz
        if_nz   jmp     #:done_char

                mov     char, t2

                test    char, #$100  wz
        if_z    jmp     #:normal
                and     char, #$FF
                call    #glyph_sm
                jmp     #command_return
:normal         call    #glyph
                jmp     #command_return


:done_char      cmp     op, #CMD_DOT  wz
        if_nz   jmp     #:done_dot

                call    #dot
                jmp     #command_return

:done_dot       cmp     op, #CMD_BRITE  wz
        if_nz   jmp     #command_return

                call    #brite
                jmp     #command_return
                

read_args       mov	parm, PAR
		add	parm, #4
		rdlong  t, parm
                add     parm, #4
                rdlong  t2, parm
                sub     parm, #4
                mov     x0, t
                sar     x0, #16		' sign extended
                mov     y0, t
		shl	y0, #16
		sar	y0, #16		' sign extended

                mov     x1, t2
                sar     x1, #16		' sign extended
                mov     y1, t2
                shl	y1, #16
		sar	y1, #16		' sign extended
                mov     col, x0
                mov     row, y0
read_args_ret   ret



{ ------------------------------------------------------ }

draw_rect       mins	x0, #0		' bound to visible
		maxs	x1, #(MAX_COL-1)
		mins	y0, #0
		maxs	y1, #(MAX_ROW-1)

		cmp	x0, x1  wz,wc	' check for empty rect
	if_a	jmp	#draw_rect_ret
		cmp	y0, y1  wz,wc	' check for empty rect
	if_a	jmp	#draw_rect_ret

		mov     rcount, y1
                sub     rcount, y0
                add     rcount, #1

		mov	OUTA, IF_COMM
		mov	regaddr, #$15
		mov	reg_val, x0
		call	#wr_reg
		mov	dval, x1
		call	#wr_data
		mov	OUTA, IF_IDLE
		nop
		nop
		mov	OUTA, IF_COMM
		mov	regaddr, #$75
		mov	reg_val, y0
		call	#wr_reg
		mov	dval, y1
		call	#wr_data
		mov	OUTA, IF_IDLE
		nop
                call    #start_ram

:rloop
                mov     icount, x1
                sub     icount, x0
                add     icount, #1


:iloop  	mov	reg_val, foreground
	        call    #wr_ram
                djnz    icount, #:iloop

                add     row, #1
                djnz    rcount, #:rloop
                call    #stop_ram

draw_rect_ret   ret


{ ------------------------------------------------------ }

draw_line       mov     dx, x1
                sub     dx, x0
                abs     dx, dx
                shl     dx, #8

                mov     dy, y1
                sub     dy, y0
                abs     dy, dy
                shl     dy, #8

                cmps    x0, x1  wc,wz
                mov     xstep, #1
        if_a    neg     xstep, xstep

                cmps    y0, y1  wc,wz
                mov     ystep, #1
        if_a    neg     ystep, ystep

                mov     row, y0
                mov     col, x0
                cmp     dx, dy  wc
        if_nc   jmp     #xdir

ydir            neg     t, dy
                sar     t, #1
:loop
                call    #dot
                cmp     row, y1  wz
        if_z    jmp     #draw_line_ret
                add     row, ystep
                add     t, dx  wc
        if_nc   jmp     #:loop
                add     col, xstep
                sub     t, dy
                jmp     #:loop

xdir            neg     t, dx
                sar     t, #1
:loop
                call    #dot
                cmp     col, x1  wz
        if_z    jmp     #draw_line_ret
                add     col, xstep
                add     t, dy  wc
        if_nc   jmp     #:loop
                add     row, ystep
                sub     t, dx
                jmp     #:loop

draw_line_ret   ret

{ ------------------------------------------------------ }

dot             cmp     col, #MAX_COL  wc,wz	' unsigned rejects negative as well as >=MAX
        if_ae   jmp     #dot_ret
                cmp     row, #MAX_ROW  wc,wz
        if_ae   jmp     #dot_ret
                ' #move_to

                mov     OUTA, IF_COMM
                mov     regaddr, #$15
                mov     reg_val, col
                call    #wr_reg
		mov	dval, #(MAX_COL-1)
		call	#wr_data
                mov     OUTA, IF_IDLE
		nop
		nop
                mov     OUTA, IF_COMM
                mov     regaddr, #$75
                mov     reg_val, row
                call    #wr_reg
		mov	dval, #(MAX_ROW-1)
		call	#wr_data
                mov     OUTA, IF_IDLE
		nop
         	call    #start_ram
		mov	reg_val, foreground
		call	#wr_ram
		call	#stop_ram

dot_ret         ret



{ ------------------------------------------------------ }

draw_string     rdbyte  char, strp  wz
        if_z    jmp     #draw_string_ret
                add     strp, #1
                test    t, #1  wz
        if_z    call    #glyph
                test    t, #1  wz
        if_nz   call    #glyph_sm
                jmp     #draw_string
draw_string_ret ret


{ ------------------------------------------------------ }
{{
rd_data         andn    DIRA, datamask
                andn    OUTA, nRDmask
                nop
                mov     dval, INA
                or      OUTA, nRDmask
                shr     dval, datashift
                and     dval, #$FF
                or      DIRA, datamask
rd_data_ret     ret
}}
{ ------------------------------------------------------ }


write_reg       andn    OUTA, nCSmask
		call	#wr_reg
                or      OUTA, nCSmask
write_reg_ret   ret

wr_reg		mov	dval, regaddr
		call	#wr_comm
		mov	dval, reg_val
                call    #wr_data
wr_reg_ret	ret

{ ------------------------------------------------------ }

brite		and	row, #15
		mov	regaddr, #$C7
		mov	reg_val, row
		call	#write_reg
brite_ret	ret

{ ------------------------------------------------------ }

move_to		andn	OUTA, nCSmask
		mov	regaddr, #$15
		mov	reg_val, col
		call	#wr_reg
		mov	dval, #(MAX_COL-1)
		call	#wr_data
		or	OUTA, nCSmask
		nop
		nop
		andn	OUTA, nCSmask
		mov	regaddr, #$75
		mov	reg_val, row
		call	#wr_reg
		mov	dval, #(MAX_ROW-1)
		call	#wr_data
		or	OUTA, nCSmask
move_to_ret     ret

{ ------------------------------------------------------ }

wr_comm         mov     OUTA, IF_COMM
		or	DIRA, datamask	' enable data base writes
                shl     dval, datashift
                or      OUTA, dval
                andn    OUTA, nWRmask
		nop
		nop
                or      OUTA, nWRmask
		nop
		nop
                mov     OUTA, IF_COMM
		andn	DIRA, datamask
wr_comm_ret	ret

{ ------------------------------------------------------ }

wr_data         mov     OUTA, IF_DATA
		or	DIRA, datamask	' enable data base writes
                shl     dval, datashift
                or      OUTA, dval
                andn    OUTA, nWRmask
		nop
		nop
                or      OUTA, nWRmask
		nop
		nop
                mov     OUTA, IF_DATA
		andn	DIRA, datamask
wr_data_ret	ret

{ ------------------------------------------------------ }

start_ram       mov	OUTA, IF_COMM	' ensure CS low
		mov     dval, #$5C
                call    #wr_comm
		mov	OUTA, IF_DATA	' ready for data writes
start_ram_ret   ret

{ ------------------------------------------------------ }

wr_ram          mov     dval, reg_val	' take top byte of reg_val first
                shr     dval, #8
                and     dval, #$FF
		call	#wr_data
                mov     dval, reg_val
                and     dval, #$FF
		call	#wr_data
wr_ram_ret      ret

{ ------------------------------------------------------ }

stop_ram        mov     OUTA, IF_IDLE
stop_ram_ret    ret

{ ------------------------------------------------------ }


get_patt        rdlong  pattern, gaddr		' read long from Prop font data
                add     gaddr, #4
                test    char, #1  wz		' deal with interleaving
        if_nz   shr     pattern, #1
get_patt_ret    ret

{ ------------------------------------------------------ }

glyph_setup     mov     gaddr, char	    ' calculate address of first long in Prop font entry for char
		and	gaddr, #$FF
                shr     gaddr, #1
                or      gaddr, #$100	    ' $8000 is base of font, $100 shifted left by 7
                shl     gaddr, #7	    ' 32 longs = 2^7 bytes per font entry

                mov     colours, foreground ' get colour table for waitvid, fg high / fg low / bg high / bg low
                shl     colours, #16
                or      colours, background
glyph_setup_ret	ret

{ ------------------------------------------------------ }

glyph           call    #glyph_setup
                mov     linecount, #32

:loop           call    #move_to
                add     row, #1

                call    #start_ram
                call    #get_patt       ' get pattern

		mov	icount, #16
:pixloop
		shr	pattern, #2  wc
	if_c	mov	reg_val, foreground
	if_nc	mov	reg_val, background
		call	#wr_ram
		djnz	icount, #:pixloop

                call    #stop_ram

                djnz    linecount, #:loop

                sub     row, #32        ' move to next char position
                add     col, #16
glyph_ret       ret

{ ------------------------------------------------------ }

glyph_sm        call	#glyph_setup

                mov     linecount, #16

:loop           call    #move_to
                add     row, #1

                call    #start_ram
                call    #get_patt       ' get pattern
		add	gaddr, #4	' skip next row

		mov	icount, #8
:pixloop
		shr	pattern, #4  wc
	if_c	mov	reg_val, foreground
	if_nc	mov	reg_val, background
		call	#wr_ram
		djnz	icount, #:pixloop

                call    #stop_ram

                djnz    linecount, #:loop

                sub     row, #16	' move to next char position
                add     col, #8
glyph_sm_ret    ret

{ ------------------------------------------------------ }


foreground      long    $FFFF
background      long    $0000

MSdelay         long    80_000

zero            long    0

colours         long    $FFFF0000

datamask        long    0
datashift       long    0

nWRmask         long    0
nRDmask         long    0
nCSmask         long    0
DCmask          long    0
nRESmask        long    0
Vccmask		long	0

IF_IDLE         long    0
IF_COMM         long    0
IF_DATA         long    0
IF_ALL		long	0

parm            res     1
op              res     1
arg             res     1

delaycount      res     1

time            res     1

icount          res     1
rcount          res     1

regaddr         res     1
reg_val         res     1
dval            res     1
t               res     1
t2              res     1
ptr             res     1
char            res     1

col             res     1
row             res     1
gaddr           res     1
linecount       res     1
pattern         res     1
strp            res     1

x0              res     1
y0              res     1
x1              res     1
y1              res     1
xstep           res     1
ystep           res     1
dx              res     1
dy              res     1

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
