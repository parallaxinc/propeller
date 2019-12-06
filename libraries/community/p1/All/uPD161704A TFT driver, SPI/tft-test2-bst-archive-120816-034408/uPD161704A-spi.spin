{{
////////////////////////////////////////////////////////////////////////////////////////////
//                  uPD161704A-spi.spin
// 320x240 LCD driver for uPD161704A controller.  This version is SPI based.

// Author: Mark Tillotson
// Updated: 2012-08-16
// Designed For: P8X32A
// Version: 1.0

// Provides

// PUB  Stop

// PUB  Start (nRES, nCS, RS, MOSI, SCLK)
// pin numbers for nRESET, nCS, RS, MOSI and SCLK

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
// Note you must ensure xl <= xr, yt <= yb else it will hang


// ToDo:   Allow setting up in portrait or landscape mode (currently landscape mode)


// See end of file for standard MIT licence / terms of use.

// Update History:

// v1.0 - Initial version 2012-08-16, based on my ILI9320 driver but SPI rather than parallel

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

VAR
  long  cog

  long  cmd
  long	arg0
  long	arg1
  long  guard

PUB  Stop
  if cog <> 0
    cogstop (cog-1)
  cog := 0

PUB  Start (nRES, nCS, RS, MOSI, SCLK) | mask
  Stop
  cmd := CMD_SETUP

  nCSmask := 1 << nCS
  RSmask  := 1 << RS
  MOSImask := 1 << MOSI
  SCLKmask := 1 << SCLK
  nRESmask := 1 << nRES

  IF_IDLE := nRESmask | nCSmask | SCLKmask

  arg0 := @init_data

  cog := 1 + cognew (@entry, @cmd)
  if cog <> 0
    Synch
  result := cog


PUB  Synch
  repeat until cmd == 0

PUB  ClearScreen
  Synch
  cmd := CMD_CLEAR

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
  arg0 := xl << 16 | yt
  arg1 := xr << 16 | yb
  cmd := CMD_RECT

PUB  SetColours (fore, back)
  Synch
  arg0 := (back << 16) | (fore & $ffff)
  cmd := CMD_SETCOLOURS
 

DAT

init_data	long	$0A030001 ' software reset
		long    $013A0001 ' Oscillator control (0:oscillator stop, 1: oscillator operation)

		long    $0124007B ' amplitude setting
		long    $0025003B ' amplitude setting     
		long    $01260034 ' amplitude setting
		long    $00270004 ' amplitude setting     
		long    $01520025 ' circuit setting 1
		long    $00530033 ' circuit setting 2     

		long    $0161001C ' adjustment V10 positive polarity
		long    $0062002C ' adjustment V9 negative polarity
		long    $01630022 ' adjustment V34 positive polarity
		long    $01640027 ' adjustment V31 negative polarity
		long    $01650014 ' adjustment V61 negative polarity
		long    $00660010 ' adjustment V61 negative polarity

		long    $002E002D ' Basical clock for 1 line (BASECOUNT[7:0]) number specified
  
		' Power supply setting
		long    $01190000 ' DC/DC output setting
		long    $001A1000 ' DC/DC frequency setting
		long    $001B0023 ' DC/DC rising setting
		long    $001C0C01 ' Regulator voltage setting
		long    $001D0000 ' Regulator current setting
		long    $001E0009 ' VCOM output setting
		long    $001F0035 ' VCOM amplitude setting        
		long 	$00200015 ' VCOMM cencter setting 
		long    $00181E7B ' DC/DC operation setting
		' windows setting
		long    $00080000 ' Minimum X address in window access mode
		long    $000900EF ' Maximum X address in window access mode
		long    $000a0000 ' Minimum Y address in window access mode
		long    $000b013F ' Maximum Y address in window access mode

		' LCD display area setting
		long    $00290000 ' [LCDSIZE]  X MIN. size set
		long    $002A0000 ' [LCDSIZE]  Y MIN. size set
		long    $002B00EF ' [LCDSIZE]  X MAX. size set
		long    $002C013F ' [LCDSIZE]  Y MAX. size set

		' Gate scan setting
		long    $00320002  ' 2 needed, 4 switches gate scan (swap y dir)
		' n line inversion line number
		long    $00330000
		' Line inversion/frame inversion/interlace setting
		long    $00370000
		' Gate scan operation setting register
		long    $003B0001
		' Color mode
		long    $00040000 ' GS = 0: 260-k color (64 gray scale), GS = 1: 8 color (2 gray scale)
		' RAM control register
		long    $00050004 ' 0010 Windowed access, 0008 inverse colours.0004 = swap x,y  Windowed doesn't work?
		' Display setting register 2
		long    $00010040 '  $0040 swaps Y write dir, $0080 swaps x write dir 0010 = BGR,
		' display setting       
		long    $01000000 ' display on.0020=ADC  $0080 forces WHITE, $0040 forces BLACK. 0002 low power
		                  ' adc swaps x write direction (and colours?)

		long    0


DAT

                ORG     0

entry           mov     parm, PAR
                rdlong  op, parm        ' can assume is setup
                add     parm, #4
                rdlong  ptr, parm

                mov     OUTA, IF_IDLE
                mov     DIRA, IF_IDLE
                or      DIRA, RSmask
                or      DIRA, MOSImask
                mov     delaycount, #1
                call    #del_millis


                andn    OUTA, nRESmask
                mov     delaycount, #2
                call    #del_millis
                or      OUTA, nRESmask
                mov     delaycount, #25
                call    #del_millis


:init_loop      rdlong  t, ptr  wz
        if_z    jmp     #command_return
                add     ptr, #4

                ror     t, #16
                mov     regaddr, t
                and     regaddr, #$FF
                mov     reg_val, t
                shr     reg_val, #16
                call    #write_reg

                ror     t, #8
                mov     delaycount, t
                and     delaycount, #$FF  wz
        if_nz   call    #del_millis

                jmp     #:init_loop



del_millis      mov     time, CNT
                add     time, MSdelay
                waitcnt time, #0
                djnz    delaycount, #del_millis
del_millis_ret  ret



command_return  wrlong  zero, PAR

command_loop    rdlong  op, PAR  wz
        if_z    jmp     #command_loop
                call    #read_args

                cmp     op, #CMD_SETCOLOURS  wz
        if_nz   jmp     #:done_setcolours
                mov     foreground, y0
                mov     background, x0
                jmp     #command_return

:done_setcolours
                cmp     op, #CMD_CLEAR  wz
        if_nz   jmp     #:done_clear

                mov     t, foreground
                mov     foreground, background
                mov     x0, #0
                mov     x1, #319
                mov     y0, #0
                mov     y1, #239
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
        if_nz   jmp	#command_return
		call    #dot
                jmp     #command_return
                

read_args       rdlong  t, parm
                add     parm, #4
                rdlong  t2, parm
                sub     parm, #4
                mov     x0, t
                shr     x0, #16
                mov     y0, t
                and     y0, HFFFF
                mov     x1, t2
                shr     x1, #16
                mov     y1, t2
                and     y1, HFFFF
                mov     col, x0
                mov     row, y0
read_args_ret   ret



{ ------------------------------------------------------ }

draw_rect       mov     col, x0
                mov     row, y0
                mov     rcount, y1
                sub     rcount, y0
                add     rcount, #1

:rloop          call    #move_to
                call    #start_ram
                mov     reg_val, foreground
                mov     icount, x1
                sub     icount, x0
                add     icount, #1

:iloop          call    #wr_ram
                djnz    icount, #:iloop

                call    #stop_ram
                add     row, #1
                djnz    rcount, #:rloop
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

                cmp     x0, x1  wc
                mov     xstep, #1
        if_nc   neg     xstep, xstep

                cmp     y0, y1  wc
                mov     ystep, #1
        if_nc   neg     ystep, ystep

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

dot             cmp     col, #320  wc,wz  ' these assume landscape mode
        if_ae   jmp     #dot_ret
                cmp     row, #240  wc,wz
        if_ae   jmp     #dot_ret

		call	#move_to

:skip_row       mov     regaddr, #$0E
                mov     reg_val, foreground
                call    #write_reg

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
glyph_setup_ret	ret

{ ------------------------------------------------------ }

glyph           call    #glyph_setup

                mov     linecount, #32

:loop           call    #move_to
                add     row, #1

                call    #start_ram

                call    #get_patt       ' get pattern
		mov	icount, #16

:iloop		shr	pattern, #2  wc
	if_c	mov	reg_val, foreground
	if_nc	mov	reg_val, background
		call	#wr_ram
		djnz	icount, #:iloop

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
                add     gaddr, #4

                and     pattern, H11111111 ' get every other bit from our char to shrink it
                mov     t2, pattern
                shl     t2, #2
                or      pattern, t2     ' duplicate the bit 

		mov	icount, #8

:iloop		shr	pattern, #4  wc
	if_c	mov	reg_val, foreground
	if_nc	mov	reg_val, background
		call	#wr_ram
		djnz	icount, #:iloop

                call    #stop_ram

                djnz    linecount, #:loop

                sub     row, #16	' move to next char position
                add     col, #8
glyph_sm_ret    ret

{ ------------------------------------------------------ }

set_ind         andn	OUTA, RSmask
                nop
                andn    OUTA, nCSmask
		mov	dval, regaddr
		call	#spi16
                or      OUTA, nCSmask
                nop
                or      OUTA, RSmask
set_ind_ret     ret

{ ------------------------------------------------------ }

write_reg       call    #set_ind
                andn    OUTA, nCSmask
		mov	dval, reg_val
		call	#spi16
		or	OUTA, nCSmask
write_reg_ret   ret


{ ------------------------------------------------------ }

move_to       {  cmp     col, old_col  wz
        if_z    jmp     #:skip_col
                mov     old_col, col
              }
		mov     regaddr, #$07  ' swap $06 and $07 for portrait mode
                mov     reg_val, col
                call    #write_reg
              {
:skip_col       cmp     row, old_row  wz
        if_z    jmp     #:skip_row
                mov     old_row, row
              }
                mov     regaddr, #$06
                mov     reg_val, row
                call    #write_reg
:skip_row
move_to_ret     ret


{ ------------------------------------------------------ }

start_ram       mov     regaddr, #$0E
                call    #set_ind
		andn	OUTA, nCSmask
		nop
		or	OUTA, RSmask
start_ram_ret   ret

{ ------------------------------------------------------ }

wr_ram   	mov	dval, reg_val
		call	#spi16
wr_ram_ret	ret

{ ------------------------------------------------------ }

stop_ram        andn	OUTA, RSmask
		nop
		or	OUTA, nCSmask
stop_ram_ret    ret

{ ------------------------------------------------------ }

spi16		mov	bitcount, #16
                shl     dval, #16
:loop		shl	dval, #1  wc
		muxc	OUTA, MOSImask
		andn	OUTA, SCLKmask
              	or	OUTA, SCLKmask
              	djnz	bitcount, #:loop
 spi16_ret	ret

{ ------------------------------------------------------ }

clear_screen	mov     regaddr, #$08
		mov	reg_val, #0
		call	#write_reg
		mov	regaddr, #$0A
		call	#write_reg
		mov	regaddr, #$09
		mov	reg_val, #$EF
		call	#write_reg
		mov	regaddr, #$0B
		mov	reg_val, #$13F
		call	#write_reg

		mov	regaddr, #$06
		mov	reg_val, #0
		call	#write_reg
		mov	regaddr, #$07
		call	#write_reg

		mov	regaddr, #$0E
		call	#set_ind

		call	#start_ram

		mov	rcount, #75
		shl	rcount, #10
		mov	reg_val, t
:loop
		call	#wr_ram
		djnz	rcount, #:loop


		call	#stop_ram
clear_screen_ret ret
		

{ ------------------------------------------------------ }



foreground      long    $FFFF
background      long    $0000

MSdelay         long    80_000

zero            long    0

HFFFF           long    $FFFF
H8000           long    $8000
H11111111       long    $11111111

nCSmask         long    0
RSmask          long    0
MOSImask	long	0
SCLKmask	long	0
nRESmask        long    0

IF_IDLE		long	0

parm            res     1
op              res     1
arg             res     1
'pins            res     1
'pin             res     1
'msk             res     1

delaycount      res     1

time            res     1


icount          res     1
bitcount        res     1
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
left            res     1
right           res     1
lout            res     1
rout            res     1
expand          res     1

old_col         res     1
old_row         res     1

x0              res     1
y0              res     1
xx              res     1
yy              res     1
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
