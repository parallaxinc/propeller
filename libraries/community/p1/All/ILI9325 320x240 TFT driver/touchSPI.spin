{{ SPI.spin }}
CON
  SETUP      =  $1000000
  RD_BYTE    =  $2000000
  RD_WORD    =  $4000000
  WR_BYTE    =  $8000000
  WR_WORD    = $10000000
  TRAN_BLK   = $20000000

  SPI_LOCK   = 7

VAR

  long command[2]
  word cog


PUB Start (sclkpin, misopin, mosipin, cspin, delaycount, spilock)
  if delaycount < 40
    delaycount := 40
  if delaycount > 400
    delaycount := 400
  command[1] := delaycount
  command[0] := SETUP | (spilock << 20) | ((cspin & $1F) << 15) | ((mosipin & $1F) << 10) | ((misopin & $1F) << 5) | (sclkpin & $1F)
  'if cog == 0 ' not sure cog is inited to zero
  cog := 1+cognew (@SPIasm, @command)
  if cog > 0
    repeat until command[0] == 0
  result := cog-1

PUB Stop
  if cog > 0
    cogstop (cog-1)
    cog := 0

PUB readByteReg (reg)
  command[0] := RD_BYTE | reg
  repeat until command[0] == 0
  result := command[1]

PUB readWordReg (reg)
  command[0] := RD_WORD | reg
  repeat until command[0] == 0
  result := command[1]

PUB writeByteReg (reg, val)
  command[1] := val
  command[0] := WR_BYTE | reg
  repeat until command[0] == 0

PUB writeWordReg (reg, val)
  command[1] := val
  command[0] := WR_WORD | reg
  repeat until command[0] == 0

PUB transferBlock (numbytes, buff)
  command[1] := buff
  command[0] := TRAN_BLK | numbytes
  repeat until command[0] == 0





DAT

                ORG     0

SPIasm
:waitcmd	rdlong  op, par  wz
	if_z	jmp	#:waitcmd
                mov     parm, par
                add     parm, #4

		test	op, OP_RD_BYTE  wz
	if_nz	call	#readbyte
		test	op, OP_WR_BYTE  wz
	if_nz	call	#writebyte
		test	op, OP_RD_WORD  wz
	if_nz	call	#readword
		test	op, OP_WR_WORD  wz
	if_nz	call	#writeword
		test	op, OP_TRAN_BLK  wz
	if_nz	call	#transferblk

		test	op, OP_SETUP  wz
	if_nz	call	#setup_pins

		mov	op, #0
		wrlong  op, par
		jmp	#:waitcmd

setup_pins
		call	#get_pin
		mov	SCK_PIN, pin
		call	#get_pin
		mov	MISO_PIN, pin
		call	#get_pin
		mov	MOSI_PIN, pin
		call	#get_pin
		mov	CS_PIN, pin
		mov	lock, op
		and	lock, #7

		or      dira, CS_PIN
                or      outa, CS_PIN
                or      dira, MOSI_PIN
                or      dira, SCK_PIN
		rdlong	bitdel, parm	' get the delay value
setup_pins_ret  ret


get_pin		mov	t, op
		shr	op, #5
		and	t, #$1F
		mov	pin, #1
		shl	pin, t
get_pin_ret	ret



readbyte	call	#select
		and	op, #$3F
		shl	op, #26
		call	#spibyte
		call	#spibyte
                and     resultword, #$FF
		wrlong  resultword, parm
		call	#deselect
readbyte_ret    ret


writebyte	call	#select
		and	op, #$3F
		shl	op, #26
		or	op, WRITE_BIT
		call	#spibyte
		rdlong	op, parm
		shl	op, #24
		call	#spibyte
		call	#deselect
writebyte_ret   ret


readword        call	#select
		and	op, #$FF
		shl	op, #24
                call	#spibyte
		call	#spibyte
		call	#spibyte
                and     resultword, HFFFF
		wrlong  resultword, parm
		call	#deselect
readword_ret    ret

writeword	call	#select
		and	op, #$3F
		shl	op, #26
		or	op, WRITE_BIT
		call	#spibyte
		rdlong	op, parm
		shl	op, #16
		call	#spibyte
		call	#spibyte
		call	#deselect
writeword_ret   ret

transferblk	call	#select
		and	op, #$1FF
		mov	bcount, op
		waitcnt	t, blockdelay    ' PSX hack
		waitcnt t, bitdel
		rdlong	buffer, parm
:loop		rdbyte	op, buffer
		shl	op, #24
		call	#spibyte
		andn	outa, SCK_PIN
		wrbyte	resultword, buffer
		add	buffer, #1
		waitcnt	t, blockdelay    ' PSX hack
		waitcnt t, bitdel
		djnz	bcount, #:loop
		call	#deselect
                mov     op, #0
transferblk_ret ret


select		lockset lock  wc         ' try to claim spi lock
	if_c	jmp	#select          ' if was already claimed, repeat until we get it properly
		mov     t, cnt
                add     t, bitdel
                'waitcnt t, bitdel
		andn	outa, CS_PIN     ' select the device...
select_ret	ret


deselect	waitcnt t, bitdel
		andn	outa, SCK_PIN    ' these outputs must go low so other cogs can share
		andn	outa, MOSI_PIN
		waitcnt t, bitdel
		or	outa, CS_PIN     ' we assume only this cog handles this CS
		waitcnt t, bitdel
		lockclr	lock		 ' release the lock we hold
                mov     op, #0
deselect_ret	ret


spibyte		mov	count, #8
:loop
		rcl	op, #1  wc
                waitcnt t, bitdel
		andn	outa, SCK_PIN
		muxc	outa, MOSI_PIN
		waitcnt t, bitdel
		or	outa, SCK_PIN
		test	MISO_PIN, ina  wc
		rcl	resultword, #1
		djnz	count, #:loop
spibyte_ret	ret

HFFF            long    $00000FFF
HFFFF		long	$0000FFFF
SCK_PIN		long	$10000
MISO_PIN	long	$20000
MOSI_PIN	long	$40000
CS_PIN		long	$80000
WRITE_BIT	long	$02000000
blockdelay      long    50*80

OP_SETUP        long    SETUP
OP_RD_BYTE      long    RD_BYTE
OP_RD_WORD      long    RD_WORD
OP_WR_BYTE      long    WR_BYTE
OP_WR_WORD      long    WR_WORD
OP_TRAN_BLK     long    TRAN_BLK

lock		long	SPI_LOCK

bitdel          long    80

parm            res     1
arg             res     1
op              res     1
buffer          res     1

pin             res     1
c		res	1
t		res	1
resultword      res     1
tim             res     1
count		res	1
bcount		res	1

		FIT	$1F0
