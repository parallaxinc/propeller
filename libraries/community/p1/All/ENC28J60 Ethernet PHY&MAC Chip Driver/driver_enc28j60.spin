{{
  ENC28J60 Ethernet MAC / PHY Driver
  ----------------------------------
  
  Copyright (c) 2006-2009 Harrison Pham <harrison@harrisonpham.com>
   
  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:
   
  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.
   
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.

  The latest version of this software can be obtained from
  http://hdpham.com/PropTCP and http://obex.parallax.com/

  Constant Names / Code Logic based on code from
  Microchip Technology, Inc.'s enc28j60.c / enc28j60.h source files
}}

CON
  version = 5     ' major version
  release = 0     ' minor version

CON
' ***************************************
' **       ENC28J60 SRAM Defines       **
' ***************************************
  ' ENC28J60 Frequency
  enc_freq = 25_000_000

  ' ENC28J60 SRAM Usage Constants              
  MAXFRAME = 1518                               ' 6 (src addr) + 6 (dst addr) + 2 (type) + 1500 (data) + 4 (FCS CRC) = 1518 bytes
  TX_BUFFER_SIZE = 1518
  
  TXSTART = 8192 - (TX_BUFFER_SIZE + 8)
  TXEND = TXSTART + (TX_BUFFER_SIZE + 8)
  RXSTART = $0000
  RXSTOP = (TXSTART - 2) | $0001                ' must be odd (B5 Errata)
  RXSIZE = (RXSTOP - RXSTART + 1)

DAT
' ***************************************
' **    MAC Address Vars / Defaults    **
' ***************************************
  ' ** This is the default MAC address used by this driver.  The parent object
  '    can override this by passing a pointer to a new MAC address in the public
  '    start() method.  It is recommend that this is done to provide a level of
  '    abstraction and makes tcp stack design easier.
  ' ** This is the ethernet MAC address, it is critical that you change this
  '    if you have more than one device using this code on a local network.
  ' ** If you plan on commercial deployment, you must purchase MAC address
  '    groups from IEEE or some other standards organization.
  eth_mac         byte    $02, $00, $00, $00, $00, $01

' ***************************************
' **         Global Variables          **
' ***************************************
  rxlen           word 0
  tx_end          word 0
 
  intpin          byte 0
                  
  packetheader    byte 0[6]

  'packet          byte 0[MAXFRAME]

PUB start(_cs, _sck, _si, _so, _int, xtalout, macptr)
'' Starts the driver (uses 1 cog for spi engine)

  intpin := _int
  dira[intpin] := 0

  ' Since some people don't have 25mhz crystals, we use the cog counters
  ' to generate a 25mhz frequency for the ENC28J60 (I love the Propeller)
  ' Note: This requires a main crystal that is a multiple of 25mhz (5mhz works).
  spi_start(_cs, _sck, _so, _si, xtalout)

  ' If a MAC address pointer is provided (addr > -1) then copy it into
  ' the MAC address array (this kind of wastes space, but simplifies usage).
  if macptr > -1
    bytemove(@eth_mac, macptr, 6)
  
  delay_ms(50)
  init_ENC28J60

  ' return the chip silicon version
  banksel(EREVID)
  return rd_cntlreg(EREVID)

PUB stop
'' Stops the driver, frees 1 cog

  spi_stop

PUB rd_macreg(address) : data
'' Read MAC Control Register

  spi_out_cs(cRCR | address)
  spi_out_cs(0)                 ' transmit dummy byte
  data := spi_in                ' get actual data

PUB rd_cntlreg(address) : data
'' Read ETH Control Register

  spi_out_cs(cRCR | address)
  data := spi_in

PUB wr_reg(address, data)
'' Write MAC and ETH Control Register

  spi_out_cs(cWCR | address)
  spi_out(data)

PUB bfc_reg(address, data)
'' Clear Control Register Bits

  spi_out_cs(cBFC | address)
  spi_out(data)

PUB bfs_reg(address, data)
'' Set Control Register Bits

  spi_out_cs(cBFS | address)
  spi_out(data)

PUB soft_reset
'' Soft Reset ENC28J60

  spi_out(cSC)

PUB banksel(register)
'' Select Control Register Bank

  bfc_reg(ECON1, %0000_0011)
  bfs_reg(ECON1, register >> 8)                         ' high byte

PUB rd_phy(register) | low, high
'' Read ENC28J60 PHY Register

  banksel(MIREGADR)
  wr_reg(MIREGADR, register)
  wr_reg(MICMD, MICMD_MIIRD)
  banksel(MISTAT)
  repeat while ((rd_macreg(MISTAT) & MISTAT_BUSY) > 0)
  banksel(MIREGADR)
  wr_reg(MICMD, $00)
  low := rd_macreg(MIRDL)
  high := rd_macreg(MIRDH)
  return (high << 8) + low

PUB wr_phy(register, data)
'' Write ENC28J60 PHY Register

  banksel(MIREGADR)
  wr_reg(MIREGADR, register)   
  wr_reg(MIWRL, data)
  wr_reg(MIWRH, data >> 8)
  banksel(MISTAT)
  repeat while ((rd_macreg(MISTAT) & MISTAT_BUSY) > 0)

PUB rd_sram : data
'' Read ENC28J60 8k Buffer Memory

  spi_out_cs(cRBM)
  data := spi_in

PUB wr_sram(data)
'' Write ENC28J60 8k Buffer Memory

  spi_out_cs(cWBM)
  spi_out(data)

PUB init_ENC28J60 | i
'' Init ENC28J60 Chip

  repeat
    i := rd_cntlreg(ESTAT)
  while (i & $08) OR (!i & ESTAT_CLKRDY)
  
  soft_reset
  delay_ms(5)                                           ' reset delay

  bfc_reg(ECON1, ECON1_RXEN)                            ' stop send / recv
  bfc_reg(ECON1, ECON1_TXRTS)

  bfs_reg(ECON2, ECON2_AUTOINC)                         ' enable auto increment of sram pointers (already default)

  packetheader[nextpacket_low] := RXSTART
  packetheader[nextpacket_high] := constant(RXSTART >> 8)

  banksel(ERDPTL)
  wr_reg(ERDPTL, RXSTART)
  wr_reg(ERDPTH, constant(RXSTART >> 8))

  banksel(ERXSTL)
  wr_reg(ERXSTL, RXSTART)
  wr_reg(ERXSTH, constant(RXSTART >> 8))
  wr_reg(ERXRDPTL, RXSTOP)
  wr_reg(ERXRDPTH, constant(RXSTOP >> 8))
  wr_reg(ERXNDL, RXSTOP)
  wr_reg(ERXNDH, constant(RXSTOP >> 8))
  wr_reg(ETXSTL, TXSTART)
  wr_reg(ETXSTH, constant(TXSTART >> 8))

  banksel(MACON1)
  wr_reg(MACON1, constant(MACON1_TXPAUS | MACON1_RXPAUS | MACON1_MARXEN))
  wr_reg(MACON3, constant(MACON3_TXCRCEN | MACON3_PADCFG0 | MACON3_FRMLNEN))
  
  ' don't timeout transmissions on saturated media
  wr_reg(MACON4, MACON4_DEFER)
  ' collisions occur at 63rd byte
  wr_reg(MACLCON2, 63)
  
  wr_reg(MAIPGL, $12)
  wr_reg(MAIPGH, $0C)
  wr_reg(MAMXFLL, MAXFRAME)                     
  wr_reg(MAMXFLH, constant(MAXFRAME >> 8))

  ' back-to-back inter-packet gap time
  ' full duplex = 0x15 (9.6us)
  ' half duplex = 0x12 (9.6us)
  wr_reg(MABBIPG, $12)
  wr_reg(MAIPGL, $12)
  wr_reg(MAIPGH, $0C)

  ' write mac address to the chip
  banksel(MAADR1)
  wr_reg(MAADR1, eth_mac[0])
  wr_reg(MAADR2, eth_mac[1])
  wr_reg(MAADR3, eth_mac[2])
  wr_reg(MAADR4, eth_mac[3])
  wr_reg(MAADR5, eth_mac[4])
  wr_reg(MAADR6, eth_mac[5])

  ' half duplex 
  wr_phy(PHCON2, PHCON2_HDLDIS)
  wr_phy(PHCON1, $0000)

  ' set LED options
  wr_phy(PHLCON, $0742)         ' $0472 => ledA = link, ledB = tx/rx
                                ' $0742 => ledA = tx/rx, ledB = link           
   
  ' enable packet reception
  bfs_reg(ECON1, ECON1_RXEN)

PUB get_frame(pktptr) | packet_addr, new_rdptr
'' Get Ethernet Frame from Buffer

  banksel(ERDPTL)
  wr_reg(ERDPTL, packetheader[nextpacket_low])
  wr_reg(ERDPTH, packetheader[nextpacket_high])

  repeat packet_addr from 0 to 5
    packetheader[packet_addr] := rd_sram

  rxlen := (packetheader[rec_bytecnt_high] << 8) + packetheader[rec_bytecnt_low]

  'bytefill(@packet, 0, MAXFRAME)                       ' Uncomment this if you want to clean out the buffer first
                                                        '  otherwise, leave commented since it's faster to just leave stuff
                                                        '  in the buffer
  
  ' protect from oversized packet
  if rxlen =< MAXFRAME
    rd_block(pktptr, rxlen)
    {repeat packet_addr from 0 to rxlen - 1
      BYTE[@packet][packet_addr] := rd_sram}
     
  new_rdptr := (packetheader[nextpacket_high] << 8) + packetheader[nextpacket_low]
     
  ' handle errata read pointer start (must be odd)
  --new_rdptr
       
  if (new_rdptr < RXSTART) OR (new_rdptr > RXSTOP)
    new_rdptr := RXSTOP

  bfs_reg(ECON2, ECON2_PKTDEC)
  
  banksel(ERXRDPTL)
  wr_reg(ERXRDPTL, new_rdptr)
  wr_reg(ERXRDPTH, new_rdptr >> 8)

PUB start_frame
'' Start frame - Inits the NIC and sets stuff

  banksel(EWRPTL)
  wr_reg(EWRPTL, TXSTART)
  wr_reg(EWRPTH, constant(TXSTART >> 8))

  tx_end := constant(TXSTART - 1)                       ' start location is really address 0, so we are sending a count of - 1

  wr_frame(cTXCONTROL)

PUB wr_frame(data)
'' Write frame data

  wr_sram(data)
  ++tx_end

PUB wr_block(startaddr, count)
  blockwrite(startaddr, count)
  tx_end += count

PUB rd_block(startaddr, count)
  blockread(startaddr, count)

PUB send_frame
'' Sends frame
'' Will retry on send failure up to 15 times with a 1ms delay in between repeats

  repeat 15
    if p_send_frame                                     ' send packet, if successful then quit retry loop
      quit          
    delay_ms(1)

PRI p_send_frame | i, eirval
' Sends the frame
  banksel(ETXSTL)
  wr_reg(ETXSTL, TXSTART)
  wr_reg(ETXSTH, constant(TXSTART >> 8))

  banksel(ETXNDL)
  wr_reg(ETXNDL, tx_end)
  wr_reg(ETXNDH, tx_end >> 8)

  ' B5 Errata #10 - Reset transmit logic before send
  bfs_reg(ECON1, ECON1_TXRST)
  bfc_reg(ECON1, ECON1_TXRST)
  
  ' B5 Errata #10 & #13: Reset interrupt error flags
  bfc_reg(EIR, constant(EIR_TXERIF | EIR_TXIF))

  ' trigger send
  bfs_reg(ECON1, ECON1_TXRTS)
  
  ' fix for transmit stalls (derived from errata B5 #13), watches TXIF and TXERIF bits
  ' also implements a ~3.75ms (15 * 250us) timeout if send fails (occurs on random packet collisions)
  ' btw: this took over 10 hours to fix due to the elusive undocumented bug
  i := 0
  repeat
    eirval := rd_cntlreg(EIR)
    if ((eirval & constant(EIR_TXERIF | EIR_TXIF)) > 0)
      quit
    if (++i => 15)
      eirval := EIR_TXERIF
      quit
    delay_us(250)

  ' B5 Errata #13 - Reset TXRTS if failed send then reset logic
  bfc_reg(ECON1, ECON1_TXRTS)
  
  if ((eirval & EIR_TXERIF) == 0)
    return true   ' successful send (no error interrupt)
  else
    return false  ' failed send (error interrupt)

PUB get_mac_pointer
'' Gets mac address pointer
  return @eth_mac

PUB get_rxlen
'' Gets received packet length
  return rxlen - 4             ' knock off the 4 byte Frame Check Sequence CRC, not used anywhere outside of this driver (pg 31 datasheet)

PRI delay_us(Duration)
  waitcnt(((clkfreq / 1_000_000 * Duration - 3928)) + cnt)
  
PRI delay_ms(Duration)
  waitcnt(((clkfreq / 1_000 * Duration - 3932)) + cnt)

' ***************************************
' **          ASM SPI Engine           **
' ***************************************   
DAT
  cog         long 0
  command     long 0
  
CON
  SPIOUT        = %0000_0001
  SPIIN         = %0000_0010
  SRAMWRITE     = %0000_0100
  SRAMREAD      = %0000_1000
  CSON          = %0001_0000
  CSOFF         = %0010_0000
  CKSUM         = %0100_0000

  SPIBITS       = 8

PRI spi_out(value)
  setcommand(constant(SPIOUT | CSON | CSOFF), @value)
  
PRI spi_out_cs(value)
  setcommand(constant(SPIOUT | CSON), @value)

PRI spi_in : value
  setcommand(constant(SPIIN | CSON | CSOFF), @value)
  
PRI spi_in_cs : value
  setcommand(constant(SPIIN | CSON), @value)

PRI blockwrite(startaddr, count)
  setcommand(SRAMWRITE, @startaddr)

PRI blockread(startaddr, count)
  setcommand(SRAMREAD, @startaddr)

PUB chksum_add(startaddr, count)
  setcommand(CKSUM, @startaddr)
  return startaddr
  
PRI spi_start(_cs, _sck, _di, _do, _freqpin)
  spi_stop

  cspin := |< _cs
  dipin := |< _di
  dopin := |< _do
  clkpin := |< _sck

  ctramode := %0_00100_00_0000_0000_0000_0000_0000_0000 + _sck
  ctrbmode := %0_00100_00_0000_0000_0000_0000_0000_0000 + _do

  spi_setupfreqsynth(_freqpin)
  
  cog := cognew(@init, @command) + 1
  
PRI spi_stop
  if cog
    cogstop(cog~ - 1)
  ctra := 0
  command~
  
PRI setcommand(cmd, argptr)
  command := cmd << 16 + argptr                       'write command and pointer
  repeat while command                                'wait for command to be cleared, signifying receipt

PRI spi_setupfreqsynth(pin)

  if pin < 0
    ' pin num was negative -> disable freq synth
    return
    
  dira[pin] := 1

  ctra := constant(%00010 << 26)                                                                      '..set PLL mode
  ctra |= constant((>|((enc_freq - 1) / 1_000_000)) << 23)                                            'set PLLDIV
    
  frqa := spi_fraction(enc_freq, CLKFREQ, constant(4 - (>|((enc_freq - 1) / 1_000_000))))             'Compute FRQA/FRQB value
  ctra |= pin                                                                                         'set PINA to complete CTRA/CTRB value

PRI spi_fraction(a, b, shift) : f

  if shift > 0                         'if shift, pre-shift a or b left
    a <<= shift                        'to maintain significant bits while 
  if shift < 0                         'insuring proper result
    b <<= -shift
 
  repeat 32                            'perform long division of a/b
    f <<= 1
    if a => b
      a -= b
      f++           
    a <<= 1

DAT
              org
init          or        dira, cspin             'pin directions
              andn      dira, dipin
              or        dira, dopin
              or        dira, clkpin

              or        outa, cspin             'turn off cs (bring it high)

              mov       frqb, #0                'disable ctrb increment
              mov       ctrb, ctrbmode

              
loop          wrlong    zero,par                'zero command (tell spin we are done processing)
:subloop      rdlong    t1,par wz               'wait for command
        if_z  jmp       #:subloop

              mov       addr, t1                'used for holding return addr to spin vars
        
              rdlong    arg0, t1                'arg0
              add       t1, #4
              rdlong    arg1, t1                'arg1

              mov       lkup, addr              'get the command var from spin
              shr       lkup, #16               'extract the cmd from the command var

              test      lkup, #CSON wz          'turn on cs
        if_nz andn      outa, cspin
        
              test      lkup, #SPIOUT wz        'spi out
        if_nz call      #spi_out_
              test      lkup, #SPIIN wz         'spi in 
        if_nz call      #xspi_in_
              test      lkup, #SRAMWRITE wz     'sram block write
        if_nz jmp       #sram_write_
              test      lkup, #SRAMREAD wz      'sram block read
        if_nz jmp       #sram_read_

              test      lkup, #CSOFF wz         'cs off
        if_nz or        outa, cspin

              test      lkup, #CKSUM wz         'perform checksum
        if_nz call      #csum16

              jmp       #loop                   ' no cmd found
              

spi_out_      andn      outa, clkpin
              shl       arg0, #24              
              mov       phsb, arg0              ' data to write
              mov       frqa, freqw             ' 20MHz write frequency
              mov       phsa, #0                ' start at clocking at 0
              
              mov       ctra, ctramode          ' send data @ 20MHz
              rol       phsb, #1
              rol       phsb, #1
              rol       phsb, #1
              rol       phsb, #1
              rol       phsb, #1
              rol       phsb, #1
              rol       phsb, #1
              mov       ctra, #0                ' disable
              andn      outa, clkpin
                       
spi_out__ret  ret


spi_in_       andn      outa, clkpin
              mov       phsa, phsr              ' start phs for clock
              mov       frqa, freqr             ' 10MHz read frequency
              nop

              mov       ctra, ctramode          ' start clocking
              test      dipin, ina wc
              rcl       arg0, #1
              test      dipin, ina wc
              rcl       arg0, #1
              test      dipin, ina wc
              rcl       arg0, #1
              test      dipin, ina wc
              rcl       arg0, #1
              test      dipin, ina wc
              rcl       arg0, #1
              test      dipin, ina wc
              rcl       arg0, #1
              test      dipin, ina wc
              rcl       arg0, #1
              test      dipin, ina wc
              mov       ctra, #0                ' stop clocking
              rcl       arg0, #1
              andn      outa, clkpin
                            
spi_in__ret   ret

xspi_in_      call      #spi_in_
              wrbyte    arg0, addr                 ' write byte back to spin result var
xspi_in__ret  ret

' SRAM Block Read/Write
sram_write_   ' block write (arg0=hub addr, arg1=count)
              mov       t1, arg0
              mov       t2, arg1

              andn      outa, cspin
              mov       arg0, #cWBM
              call      #spi_out_
:loop         rdbyte    arg0, t1
              call      #spi_out_              
              add       t1, #1
              djnz      t2, #:loop
              or        outa, cspin
              
              jmp       #loop
              
sram_read_    ' block read (arg0=hub addr, arg1=count)
              mov       t1, arg0
              mov       t2, arg1
              
              andn      outa, cspin
              mov       arg0, #cRBM
              call      #spi_out_
:loop         call      #spi_in_
              wrbyte    arg0, t1
              add       t1, #1 
              djnz      t2, #:loop
              or        outa, cspin
              
              jmp       #loop

csum16        ' performs checksum 16bit additions on the data
              ' arg0=hub addr, arg1=length, writes sum to first arg
              mov       t1, #0                  ' clear sum
:loop         rdbyte    t2, arg0                ' read two bytes (16 bits)
              add       arg0, #1
              rdbyte    t3, arg0
              add       arg0, #1
              shl       t2, #8                  ' build the word
              add       t2, t3
              add       t1, t2                  ' add numbers
              mov       t2, t1                  ' add lower and upper words together
              shr       t2, #16
              and       t1, hffff
              add       t1, t2
              sub       arg1, #2
              cmp       arg1, #1 wz, wc
 if_nc_and_nz jmp       #:loop
        if_z  rdbyte    t2, arg0                ' add last byte (odd)
        if_z  shl       t2, #8
        if_z  add       t1, t2
              wrlong    t1, addr                ' return result back to SPIN
csum16_ret    ret

zero                    long    0                       'constants

                                                        'values filled by spin code before launching
cspin                   long    0                       ' chip select pin
dipin                   long    0                       ' data in pin (enc28j60 -> prop)
dopin                   long    0                       ' data out pin (prop -> enc28j60)
clkpin                  long    0                       ' clock pin (prop -> enc28j60)
ctramode                long    0                       ' ctr mode for CLK
ctrbmode                long    0                       ' ctr mode for SPI Out

hffff                   long    $FFFF

freqr                   long    $2000_0000              'frequency of SCK /8 for receive
freqw                   long    $4000_0000              'frequency of SCK /4 for send
phsr                    long    $6000_0000

                                                        'temp variables
t1                      res     1                       '     loop and cog shutdown                          
t2                      res     1                       '     loop and cog shutdown
t3                      res     1                       '     Used to hold DataValue SHIFTIN/SHIFTOUT
t4                      res     1                       '     Used to hold # of Bits
t5                      res     1                       '     Used for temporary data mask

addr                    res     1                       '     Used to hold return address of first Argument passed
lkup                    res     1                       '     Used to hold command lookup

                                                        'arguments passed to/from high-level Spin
arg0                    res     1                       ' bits / start address
arg1                    res     1                       ' value / count                                                          

CON
' ***************************************
' **    ENC28J60 Control Constants     **
' ***************************************
  ' ENC28J60 opcodes (OR with 5bit address)
  cWCR = %010 << 5              ' write control register command
  cBFS = %100 << 5              ' bit field set command
  cBFC = %101 << 5              ' bit field clear command
  cRCR = %000 << 5              ' read control register command
  cRBM = (%001 << 5) | $1A      ' read buffer memory command
  cWBM = (%011 << 5) | $1A      ' write buffer memory command
  cSC = (%111 << 5) | $1F       ' system command

  ' This is used to trigger TX in the ENC28J60, it shouldn't change, but you never know...
  cTXCONTROL = $0E

  ' Packet header format (tail of the receive packet in the ENC28J60 SRAM)
  #0,nextpacket_low,nextpacket_high,rec_bytecnt_low,rec_bytecnt_high,rec_status_low,rec_status_high

' ***************************************
' **     ENC28J60 Register Defines     **
' ***************************************
  ' Bank 0 registers --------
  ERDPTL = $00
  ERDPTH = $01
  EWRPTL = $02
  EWRPTH = $03
  ETXSTL = $04
  ETXSTH = $05
  ETXNDL = $06
  ETXNDH = $07
  ERXSTL = $08
  ERXSTH = $09
  ERXNDL = $0A
  ERXNDH = $0B
  ERXRDPTL = $0C
  ERXRDPTH = $0D
  ERXWRPTL = $0E
  ERXWRPTH = $0F
  EDMASTL = $10
  EDMASTH = $11
  EDMANDL = $12
  EDMANDH = $13
  EDMADSTL = $14
  EDMADSTH = $15
  EDMACSL = $16
  EDMACSH = $17
  ' = $18
  ' = $19
  ' r = $1A
  EIE = $1B
  EIR = $1C
  ESTAT = $1D
  ECON2 = $1E
  ECON1 = $1F
   
  ' Bank 1 registers -----
  EHT0 = $100
  EHT1 = $101
  EHT2 = $102
  EHT3 = $103
  EHT4 = $104
  EHT5 = $105
  EHT6 = $106
  EHT7 = $107
  EPMM0 = $108
  EPMM1 = $109
  EPMM2 = $10A
  EPMM3 = $10B
  EPMM4 = $10C
  EPMM5 = $10D
  EPMM6 = $10E
  EPMM7 = $10F
  EPMCSL = $110
  EPMCSH = $111
  ' = $112
  ' = $113
  EPMOL = $114
  EPMOH = $115
  EWOLIE = $116
  EWOLIR = $117
  ERXFCON = $118
  EPKTCNT = $119
  ' r = $11A
  ' EIE = $11B
  ' EIR = $11C
  ' ESTAT = $11D
  ' ECON2 = $11E
  ' ECON1 = $11F
   
  ' Bank 2 registers -----
  MACON1 = $200
  MACON2 = $201
  MACON3 = $202
  MACON4 = $203
  MABBIPG = $204
  ' = $205
  MAIPGL = $206
  MAIPGH = $207
  MACLCON1 = $208
  MACLCON2 = $209
  MAMXFLL = $20A
  MAMXFLH = $20B
  ' r = $20C
  MAPHSUP = $20D
  ' r = $20E
  ' = $20F
  ' r = $210
  MICON = $211
  MICMD = $212
  ' = $213
  MIREGADR = $214
  ' r = $215
  MIWRL = $216
  MIWRH = $217
  MIRDL = $218
  MIRDH = $219
  ' r = $21A
  ' EIE = $21B
  ' EIR = $21C
  ' ESTAT = $21D
  ' ECON2 = $21E
  ' ECON1 = $21F
   
  ' Bank 3 registers -----
  
  MAADR5 = $300
  MAADR6 = $301
  MAADR3 = $302
  MAADR4 = $303
  MAADR1 = $304
  MAADR2 = $305

  {MAADR1 = $300
  MAADR0 = $301
  MAADR3 = $302
  MAADR2 = $303
  MAADR5 = $304
  MAADR4 = $305}
  
  EBSTSD = $306
  EBSTCON = $307
  EBSTCSL = $308
  EBSTCSH = $309
  MISTAT = $30A
  ' = $30B
  ' = $30C
  ' = $30D
  ' = $30E
  ' = $30F
  ' = $310
  ' = $311
  EREVID = $312
  ' = $313
  ' = $314
  ECOCON = $315
  ' EPHTST      $316
  EFLOCON = $317
  EPAUSL = $318
  EPAUSH = $319
  ' r = $31A
  ' EIE = $31B
  ' EIR = $31C
  ' ESTAT = $31D
  ' ECON2 = $31E
  ' ECON1 = $31F
   
  {******************************************************************************
  * PH Register Locations
  ******************************************************************************}
  PHCON1 = $00
  PHSTAT1 = $01
  PHID1 = $02
  PHID2 = $03
  PHCON2 = $10
  PHSTAT2 = $11
  PHIE = $12
  PHIR = $13
  PHLCON = $14
   
  {******************************************************************************
  * Individual Register Bits
  ******************************************************************************}
  ' ETH/MAC/MII bits
   
  ' EIE bits ----------
  EIE_INTIE = (1<<7)
  EIE_PKTIE = (1<<6)
  EIE_DMAIE = (1<<5)
  EIE_LINKIE = (1<<4)
  EIE_TXIE = (1<<3)
  EIE_WOLIE = (1<<2)
  EIE_TXERIE = (1<<1)
  EIE_RXERIE = (1)
   
  ' EIR bits ----------
  EIR_PKTIF = (1<<6)
  EIR_DMAIF = (1<<5)
  EIR_LINKIF = (1<<4)
  EIR_TXIF = (1<<3)
  EIR_WOLIF = (1<<2)
  EIR_TXERIF = (1<<1)
  EIR_RXERIF = (1)
        
  ' ESTAT bits ---------
  ESTAT_INT = (1<<7)
  ESTAT_LATECOL = (1<<4)
  ESTAT_RXBUSY = (1<<2)
  ESTAT_TXABRT = (1<<1)
  ESTAT_CLKRDY = (1)
        
  ' ECON2 bits --------
  ECON2_AUTOINC = (1<<7)
  ECON2_PKTDEC = (1<<6)
  ECON2_PWRSV = (1<<5)
  ECON2_VRTP = (1<<4)
  ECON2_VRPS = (1<<3)
        
  ' ECON1 bits --------
  ECON1_TXRST = (1<<7)
  ECON1_RXRST = (1<<6)
  ECON1_DMAST = (1<<5)
  ECON1_CSUMEN = (1<<4)
  ECON1_TXRTS = (1<<3)
  ECON1_RXEN = (1<<2)
  ECON1_BSEL1 = (1<<1)
  ECON1_BSEL0 = (1)
        
  ' EWOLIE bits -------
  EWOLIE_UCWOLIE = (1<<7)
  EWOLIE_AWOLIE = (1<<6)
  EWOLIE_PMWOLIE = (1<<4)
  EWOLIE_MPWOLIE = (1<<3)
  EWOLIE_HTWOLIE = (1<<2)
  EWOLIE_MCWOLIE = (1<<1)
  EWOLIE_BCWOLIE = (1)
        
  ' EWOLIR bits -------
  EWOLIR_UCWOLIF = (1<<7)
  EWOLIR_AWOLIF = (1<<6)
  EWOLIR_PMWOLIF = (1<<4)
  EWOLIR_MPWOLIF = (1<<3)
  EWOLIR_HTWOLIF = (1<<2)
  EWOLIR_MCWOLIF = (1<<1)
  EWOLIR_BCWOLIF = (1)
        
  ' ERXFCON bits ------
  ERXFCON_UCEN = (1<<7)
  ERXFCON_ANDOR = (1<<6)
  ERXFCON_CRCEN = (1<<5)
  ERXFCON_PMEN = (1<<4)
  ERXFCON_MPEN = (1<<3)
  ERXFCON_HTEN = (1<<2)
  ERXFCON_MCEN = (1<<1)
  ERXFCON_BCEN = (1)
        
  ' MACON1 bits --------
  MACON1_LOOPBK = (1<<4)
  MACON1_TXPAUS = (1<<3)
  MACON1_RXPAUS = (1<<2)
  MACON1_PASSALL = (1<<1)
  MACON1_MARXEN = (1)
        
  ' MACON2 bits --------
  MACON2_MARST = (1<<7)
  MACON2_RNDRST = (1<<6)
  MACON2_MARXRST = (1<<3)
  MACON2_RFUNRST = (1<<2)
  MACON2_MATXRST = (1<<1)
  MACON2_TFUNRST = (1)
        
  ' MACON3 bits --------
  MACON3_PADCFG2 = (1<<7)
  MACON3_PADCFG1 = (1<<6)
  MACON3_PADCFG0 = (1<<5)
  MACON3_TXCRCEN = (1<<4)
  MACON3_PHDRLEN = (1<<3)
  MACON3_HFRMEN = (1<<2)
  MACON3_FRMLNEN = (1<<1)
  MACON3_FULDPX = (1)
        
  ' MACON4 bits --------
  MACON4_DEFER = (1<<6)
  MACON4_BPEN = (1<<5)
  MACON4_NOBKOFF = (1<<4)
  MACON4_LONGPRE = (1<<1)
  MACON4_PUREPRE = (1)
        
  ' MAPHSUP bits ----
  MAPHSUP_RSTRMII = (1<<3)
        
  ' MICON bits --------
  MICON_RSTMII = (1<<7)
        
  ' MICMD bits ---------
  MICMD_MIISCAN = (1<<1)
  MICMD_MIIRD = (1)
   
  ' EBSTCON bits -----
  EBSTCON_PSV2 = (1<<7)
  EBSTCON_PSV1 = (1<<6)
  EBSTCON_PSV0 = (1<<5)
  EBSTCON_PSEL = (1<<4)
  EBSTCON_TMSEL1 = (1<<3)
  EBSTCON_TMSEL0 = (1<<2)
  EBSTCON_TME = (1<<1)
  EBSTCON_BISTST = (1)
   
  ' MISTAT bits --------
  MISTAT_NVALID = (1<<2)
  MISTAT_SCAN = (1<<1)
  MISTAT_BUSY = (1)
        
  ' ECOCON bits -------
  ECOCON_COCON2 = (1<<2)
  ECOCON_COCON1 = (1<<1)
  ECOCON_COCON0 = (1)
        
  ' EFLOCON bits -----
  EFLOCON_FULDPXS = (1<<2)
  EFLOCON_FCEN1 = (1<<1)
  EFLOCON_FCEN0 = (1)
   
   
   
  ' PHY bits
   
  ' PHCON1 bits ----------
  PHCON1_PRST = (1<<15)
  PHCON1_PLOOPBK = (1<<14)
  PHCON1_PPWRSV = (1<<11)
  PHCON1_PDPXMD = (1<<8)
   
  ' PHSTAT1 bits --------
  PHSTAT1_PFDPX = (1<<12)
  PHSTAT1_PHDPX = (1<<11)
  PHSTAT1_LLSTAT = (1<<2)
  PHSTAT1_JBSTAT = (1<<1)
   
  ' PHID2 bits --------
  PHID2_PID24 = (1<<15)
  PHID2_PID23 = (1<<14)
  PHID2_PID22 = (1<<13)
  PHID2_PID21 = (1<<12)
  PHID2_PID20 = (1<<11)
  PHID2_PID19 = (1<<10)
  PHID2_PPN5 = (1<<9)
  PHID2_PPN4 = (1<<8)
  PHID2_PPN3 = (1<<7)
  PHID2_PPN2 = (1<<6)
  PHID2_PPN1 = (1<<5)
  PHID2_PPN0 = (1<<4)
  PHID2_PREV3 = (1<<3)
  PHID2_PREV2 = (1<<2)
  PHID2_PREV1 = (1<<1)
  PHID2_PREV0 = (1)
   
  ' PHCON2 bits ----------
  PHCON2_FRCLNK = (1<<14)
  PHCON2_TXDIS = (1<<13)
  PHCON2_JABBER = (1<<10)
  PHCON2_HDLDIS = (1<<8)
   
  ' PHSTAT2 bits --------
  PHSTAT2_TXSTAT = (1<<13)
  PHSTAT2_RXSTAT = (1<<12)
  PHSTAT2_COLSTAT = (1<<11)
  PHSTAT2_LSTAT = (1<<10)
  PHSTAT2_DPXSTAT = (1<<9)
  PHSTAT2_PLRITY = (1<<5)
   
  ' PHIE bits -----------
  PHIE_PLNKIE = (1<<4)
  PHIE_PGEIE = (1<<1)
   
  ' PHIR bits -----------
  PHIR_PLNKIF = (1<<4)
  PHIR_PGIF = (1<<2)
   
  ' PHLCON bits -------
  PHLCON_LACFG3 = (1<<11)
  PHLCON_LACFG2 = (1<<10)
  PHLCON_LACFG1 = (1<<9)
  PHLCON_LACFG0 = (1<<8)
  PHLCON_LBCFG3 = (1<<7)
  PHLCON_LBCFG2 = (1<<6)
  PHLCON_LBCFG1 = (1<<5)
  PHLCON_LBCFG0 = (1<<4)
  PHLCON_LFRQ1 = (1<<3)
  PHLCON_LFRQ0 = (1<<2)
  PHLCON_STRCH = (1<<1)