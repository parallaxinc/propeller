{{
////////////////////////////////////////////////////////////////////////////////////////////
//                  ILI9320.spin
// 320x240 LCD driver for ILI9320 controller

// Author: Mark Tillotson
// Updated: 2012-08-14
// Designed For: P8X32A
// Version: 1.0

// Provides

// PUB  Stop

// PUB  Start (nRES, nCS, RS, nWR, nRD, backLight, vidgroup)
// pin numbers for nRESET, nCS, RS, nWR, nRD and backight enable (not currently used)
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
// Note you must ensure xl <= xr, yt <= yb else it will hang


// ToDo:   Allow setting up in portrait or landscape mode (currently landscape mode on the TechToy board)


// See end of file for standard MIT licence / terms of use.

// Update History:

// v1.0 - Initial version 2012-08-14

////////////////////////////////////////////////////////////////////////////////////////////
}}

CON
  CMD_SETUP = 1
  CMD_SETCOLOURS = 2
  CMD_TEST   = 3
  CMD_RECT   = 4
  CMD_CLEAR  = 5
  CMD_LINE   = 6
  CMD_STRING = 7
  CMD_CHAR   = 8
  CMD_DOT    = 9

VAR
  long  cog

  long  cmd
  long  arg0
  long  arg1


PUB  Stop
  if cog <> 0
    cogstop (cog-1)
  cog := 0

PUB  Start (nRES, nCS, RS, nWR, nRD, backLight, vidgroup) | mask
  Stop
  cmd  := CMD_SETUP

  pingroup := vidgroup
  bLightmask := 1 << backLight
  nRESmask := 1 << nRES
  nCSmask := 1 << nCS
  RSmask := 1 << RS
  nWRpin := nWR
  nWRmask := 1 << nWR
  nRDmask := 1 << nRD
  datashift := vidgroup << 3
  datamask := $FF << datashift

  IF_REG := nRESmask | nRDmask | nWRmask
  IF_ACTIVE := IF_REG | RSmask
  IF_IDLE := IF_ACTIVE | nCSmask

  arg0 := @init_data

  cog := 1 + cognew (@entry, @cmd)
  if cog <> 0
    repeat until cmd == 0
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
 

DAT      ' init calls: delayms,reg,valhi,vallo

init_data       long    $0A000001
                long    $00A40001  ' is this needed
                long    $0A070000
                long    $00010100
                long    $00020700
                long    $00031038
                long    $00040000
                long    $00080202
                long    $00090000
                long    $00070101
                long    $00170001
                long    $00100000
                long    $00110007
                long    $00120000
                long    $14130000
                long    $001016B0

                long    $32110037

                long    $3212013E

                long    $00131A00
                long    $3229000F

                long    $00200000
                long    $00210000

                long    $00500000
                long    $005100EF
                long    $00520000
                long    $0053013F

                long    $0060A700
                long    $00610001
                long    $006A0000
                
                long    $00900010
                long    $00920000
                long    $00930000

                long    $00300507
                long    $00310404
                long    $00320205
                long    $00350707      ' $00350002
                long    $00360000       ' $00360707   ' amp
                long    $00370507
                long    $00380404
                long    $00390205
                long    $003c0707        ' $003c0700
                long    $003d0000      ' $003d0707   ' amp

                long    $32070173
                long    0



DAT

                ORG     0

entry           mov     parm, PAR
                rdlong  op, parm        ' can assume is setup
                add     parm, #4
                rdlong  ptr, parm

                movd    vcfg_go, pingroup
                movd    vcfg_go1, pingroup
                movd    vcfg_stop, pingroup

                mov     OUTA, IF_IDLE
                mov     DIRA, IF_IDLE
                or      DIRA, datamask
                'or     DIRA, bLightmask
                'or     OUTA, bLightmask

                andn    OUTA, nRESmask
                mov     delaycount, #2
                call    #del_millis
                or      OUTA, nRESmask
                mov     delaycount, #25
                call    #del_millis

                call    #wv_setup

:init_loop      rdlong  t, ptr  wz
        if_z    jmp     #command_loop
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
        if_z    mov     foreground, y0
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
                call    #wv_draw_rect
                mov     foreground, t
                jmp     #command_return

:done_clear     cmp     op, #CMD_RECT  wz
        if_nz   jmp     #:done_rect

                call    #wv_draw_rect
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
                call    #wv_glyph_sm
                jmp     #command_return
:normal         call    #wv_glyph
                jmp     #command_return


:done_char      cmp     op, #CMD_DOT  wz
        if_nz   jmp     #command_return

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

wv_draw_rect    mov     col, x0
                mov     row, y0
                mov     rcount, y1
                sub     rcount, y0
                add     rcount, #1

:rloop          call    #move_to
                call    #start_ram
                mov     reg_val, foreground
                mov     icount, x1
                sub     icount, x0

                mov     sixteens, icount
                shr     sixteens, #4  wz
                and     icount, #15
                add     icount, #1
                shl     icount, #1

                or      DIRA, datamask
                andn    OUTA, datamask

                movs    CTRB, nWRpin       ' take control of nWR

                cmp     sixteens, #0  wz
        if_z    jmp     #:short_case

                mov     VSCL, vscale32
                mov     VCFG, vcfg_go1   ' start vid gen
                waitvid foreground, H55555555  ' first data also synchronizes
                andn    OUTA, nWRmask    ' expose counter control of nWR pulses
:testwaits      djnz    sixteens, #:morewaits
                movs    VSCL, icount
                waitvid foreground, H55555555
                jmp     #:donewaits
:morewaits      waitvid foreground, H55555555
                jmp     #:testwaits

:short_case     mov     VSCL, vscale32
                movs    VSCL, icount
                mov     VCFG, vcfg_go1   ' start vid gen
                waitvid foreground, H55555555  ' first data also synchronizes
                andn    OUTA, nWRmask    ' expose counter control of nWR pulses

:donewaits      waitvid zero, #0          ' synchronize for ending nWR pulses
                or      OUTA, nWRmask   ' force nWR high
                mov     VCFG, vcfg_stop ' stop vid gen

                movs    CTRB, #0        ' relinquish counter control of nWR
:no_waits
{
:iloop          call    #wr_ram
                djnz    icount, #:iloop
                }
                call    #stop_ram
                add     row, #1
                djnz    rcount, #:rloop
wv_draw_rect_ret ret


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

dot             cmp     col, #320  wc,wz
        if_ae   jmp     #dot_ret
                cmp     row, #240  wc,wz
        if_ae   jmp     #dot_ret
                ' #move_to
                mov     OUTA, IF_ACTIVE
                or      DIRA, datamask

                cmp     col, old_col  wz
        if_z    jmp     #:skip_col
                mov     old_col, col

                mov     regaddr, #$21
                mov     reg_val, col
                call    #wr_reg

:skip_col       cmp     row, old_row  wz
        if_z    jmp     #:skip_row
                mov     old_row, row

                mov     regaddr, #$20
                mov     reg_val, row
                call    #wr_reg

:skip_row       mov     regaddr, #$22
                mov     reg_val, foreground
                call    #wr_reg

                mov     OUTA, IF_IDLE
dot_ret         ret



{ ------------------------------------------------------ }

draw_string     rdbyte  char, strp  wz
        if_z    jmp     #draw_string_ret
                add     strp, #1
                test    t, #1  wz
        if_z    call    #wv_glyph
                test    t, #1  wz
        if_nz   call    #wv_glyph_sm
                jmp     #draw_string
draw_string_ret ret


{ ------------------------------------------------------ }

rd_data         andn    DIRA, datamask
                andn    OUTA, nRDmask
                nop
                mov     dval, INA
                or      OUTA, nRDmask
                shr     dval, datashift
                and     dval, #$FF
                or      DIRA, datamask
rd_data_ret     ret

{ ------------------------------------------------------ }

wr_data         shl     dval, datashift
                or      OUTA, dval
                andn    OUTA, nWRmask
                mov     OUTA, IF_ACTIVE
wr_data_ret     ret


{ ------------------------------------------------------ }

set_ind         mov     OUTA, IF_REG
                andn    OUTA, nWRmask
                or      OUTA, nWRmask
                mov     dval, regaddr
                shl     dval, datashift
                or      OUTA, dval
                andn    OUTA, nWRmask
                or      OUTA, nWRmask
                mov     OUTA, IF_ACTIVE
set_ind_ret     ret

{ ------------------------------------------------------ }

read_reg        andn    OUTA, nCSmask
                call    #set_ind
                call    #rd_data
                mov     reg_val, dval
                shl     reg_val, #8
                call    #rd_data
                or      reg_val, dval
                or      OUTA, nCSmask
read_reg_ret    ret

{ ------------------------------------------------------ }

write_reg       andn    OUTA, nCSmask
                call    #set_ind
                call    #wr_ram
                or      OUTA, nCSmask
write_reg_ret   ret

wr_reg          call    #set_ind
                call    #wr_ram
wr_reg_ret      ret

{ ------------------------------------------------------ }

move_to         mov     regaddr, #$21  ' swap $20 and $31 for portrait mode
                mov     reg_val, col
                call    #write_reg
                mov     regaddr, #$20
                mov     reg_val, row
                call    #write_reg
move_to_ret     ret

{ ------------------------------------------------------ }

start_ram       mov     OUTA, IF_ACTIVE
                mov     regaddr, #$22
                call    #set_ind
start_ram_ret   ret

{ ------------------------------------------------------ }

wr_ram          mov     dval, reg_val
                shr     dval, #8
                shl     dval, datashift
                or      OUTA, dval
                andn    OUTA, nWRmask
                mov     OUTA, IF_ACTIVE
                mov     dval, reg_val
                and     dval, #$FF
                shl     dval, datashift
                or      OUTA, dval
                andn    OUTA, nWRmask
                mov     OUTA, IF_ACTIVE
wr_ram_ret      ret

{ ------------------------------------------------------ }

stop_ram        mov     OUTA, IF_IDLE
stop_ram_ret    ret

{ ------------------------------------------------------ }

wv_setup        movi    CTRA, #%0_00001_100 ' divide by 8
                mov     FRQA, pllclkrate
                movi    CTRB, #%0_00100_000
                movs    CTRB, #0
                mov     FRQB, ctrclkrate

                mov     PHSA, #0
                mov     PHSB, phasey

                mov     VSCL, vscale
                mov     VCFG, vcfg_stop
wv_setup_ret    ret

{ ------------------------------------------------------ }

wv_stop         mov     VCFG, #0
                mov     VSCL, #0
                mov     CTRB, #0
                mov     CTRA, #0
wv_stop_ret     ret

{ ------------------------------------------------------ }

get_patt        rdlong  pattern, gaddr
                add     gaddr, #4
                test    char, #1  wz
        if_nz   shr     pattern, #1
get_patt_ret    ret

{ ------------------------------------------------------ }

spread          mov     expand, H11111111   ' from font we have a bit every two, but we need a bit every four   
                shr     pattern, #2  wc     ' in order to send 2 bytes per pixel using 2 bits/clk video mode
                muxc    expand, H0000000A
                shr     pattern, #2  wc     ' we need 2 bits/clk since one represents foreground/background and
                muxc    expand, H000000A0   ' one represents high byte / low byte for the 16 bit LCD pixels
                shr     pattern, #2  wc
                muxc    expand, H00000A00   ' This routine spreads the bits in the deadtimes between waitvid,
                shr     pattern, #2  wc     ' only just enough time as pumping out 16 bytes per waitvid at 10MHz
                muxc    expand, H0000A000   ' and only 30 instructions allowed between waitvids.
                shr     pattern, #2  wc
                muxc    expand, H000A0000   ' here we duplicate the bits as needed and mux into the right place
                shr     pattern, #2  wc     ' the high/low byte bits are set up with first instruction.
                muxc    expand, H00A00000
                shr     pattern, #2  wc
                muxc    expand, H0A000000
                shr     pattern, #2  wc
                muxc    expand, HA0000000
spread_ret      ret

{ ------------------------------------------------------ }

wv_glyph        mov     gaddr, char
                shr     gaddr, #1
                or      gaddr, #$100
                shl     gaddr, #7

                mov     colours, foreground
                shl     colours, #16
                or      colours, background

                call    #get_patt
                call    #spread
                mov     lout, expand
                call    #spread
                mov     rout, expand

                mov     linecount, #32

:loop           call    #move_to
                add     row, #1
                call    #start_ram


                or      DIRA, datamask
                andn    OUTA, datamask

                movs    CTRB, nWRpin      ' take control of nWR

                call    #get_patt       ' get pattern

                mov     VSCL, vscale
                mov     VCFG, vcfg_go   ' start vid gen
                waitvid colours, lout   ' first data also synchronizes
                andn    OUTA, nWRmask   ' expose counter control of nWR pulses
                call    #spread           ' process next line while waiting
                mov     lout, expand
                waitvid colours, rout   ' right hand chunk
                call    #spread          ' process next line while waiting
                mov     rout, expand
                waitvid zero, #0        ' synchronize for ending nWR pulses
                or      OUTA, nWRmask   ' force nWR high
                mov     VCFG, vcfg_stop ' stop vid gen
                movs    CTRB, #0        ' relinquish counter control of nWR
                call    #stop_ram

                djnz    linecount, #:loop
                sub     row, #32
                add     col, #16
wv_glyph_ret    ret

{ ------------------------------------------------------ }

wv_glyph_sm     mov     gaddr, char
                shr     gaddr, #1
                or      gaddr, #$100
                shl     gaddr, #7

                mov     colours, foreground
                shl     colours, #16
                or      colours, background

                mov     linecount, #16

:loop           call    #move_to
                add     row, #1
                call    #start_ram


                or      DIRA, datamask
                andn    OUTA, datamask

                movs    CTRB, nWRpin    ' take control of nWR

                call    #get_patt       ' get pattern
                add     gaddr, #4
                and     pattern, H11111111 ' get every other bit from our char to shrink it
                mov     t2, pattern
                shl     t2, #2
                or      pattern, t2     ' duplicate the bit 
                shl     pattern, #1     ' now    h0h0g0g0f0f0e0e0d0d0c0c0b0b0a0a0 ( hgfedcba are bits from font)
                or      pattern, H11111111 ' now h0h1g0g1f0f1e0e1d0d1c0c1b0b1a0a1
                                   '  x1 codes a high byte of pixel, x0 codes low byte
                                   '  so colours register is  HHHHHHHHLLLLLLLLhhhhhhhhllllllll where upper case = foreground
                                   '  lower case = background.

                mov     VSCL, vscale
                mov     VCFG, vcfg_go   ' start vid gen in 2 bits/ pixel mode
                waitvid colours, pattern' first data also synchronizes

                andn    OUTA, nWRmask   ' expose counter control of nWR pulses
                waitvid zero, #0        ' synchronize for ending nWR pulses

                or      OUTA, nWRmask   ' force nWR high
                mov     VCFG, vcfg_stop ' stop vid gen

                movs    CTRB, #0        ' relinquish counter control of nWR
                call    #stop_ram

                djnz    linecount, #:loop
                sub     row, #16
                add     col, #8
wv_glyph_sm_ret ret

{ ------------------------------------------------------ }


foreground      long    $FFFF
background      long    $0000

MSdelay         long    80_000

zero            long    0

colours         long    $FFFF0000

vcfg_go         long    %0_01_1_0_0_000_00000_000000010_011111111
vcfg_go1        long    %0_01_0_0_0_000_00000_000000010_011111111
vcfg_stop       long    %0_00_0_0_0_000_00000_000000010_011111111

H11111111       long    $11111111
H55555555       long    $55555555

ctrclkrate      long    $20000000  ' 10MHz for counter
pllclkrate      long    $10000000  ' 5MHz for pll
phasey          long    $C0000000

HFFFF           long    $FFFF

H0000000A       long    $0000000A
H000000A0       long    $000000A0
H00000A00       long    $00000A00
H0000A000       long    $0000A000
H000A0000       long    $000A0000
H00A00000       long    $00A00000
H0A000000       long    $0A000000
HA0000000       long    $A0000000


vscale32        long    (1 << 12) | 32   ' 1 clock per pixel, 16 clocks per frame
vscale          long    (1 << 12) | 16   ' 1 clock per pixel, 16 clocks per frame

pingroup        long    0
datamask        long    0
datashift       long    0

nWRpin          long    0
nWRmask         long    0
nRDmask         long    0
nCSmask         long    0
RSmask          long    0
nRESmask        long    0
bLightmask      long    0

IF_IDLE         long    0
IF_ACTIVE       long    0
IF_REG          long    0

parm            res     1
op              res     1
arg             res     1
pins            res     1
pin             res     1
msk             res     1

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
sixteens        res     1
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
