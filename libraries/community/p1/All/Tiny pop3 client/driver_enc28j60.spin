{{        
  Microchip ENC28J60 Ethernet NIC / MAC Driver
  $Id: driver_enc28j60.spin 301 2007-10-21 21:40:24Z hpham $
  --------------------------------------------
  Ported to SPIN by Harrison Pham

  Driver Framework / API derived from EDTP Framethrower Fundamental Driver by Fred Eady
  Constant names / Theoretical Code Logic derived from Microchip Technology, Inc.'s enc28j60.c / enc28j60.h files
}}

{{
  This file is part of PropTCP.
   
  PropTCP is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 3 of the License, or
  (at your option) any later version.
   
  PropTCP is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.
   
  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
}}

CON

  version = 3

CON

  ' Silicon Revision (used for revision checks, doesn't change operation of code)
  silicon_rev = %0000_0100      ' required silicon revision (current is B5)

  ' ENC28J60 SRAM usage constants (you prolly don't need to change these)               
  MAXFRAME = 1518               ' 6 (src addr) + 6 (dst addr) + 2 (type) + 1500 (data) + 4 (FCS CRC) = 1518 bytes
  TX_BUFFER_SIZE = 1518 '1024
  
  TXSTART = 8192 - (TX_BUFFER_SIZE + 8)
  TXEND = TXSTART + (TX_BUFFER_SIZE + 8)
  RXSTART = $0000
  RXSTOP = (TXSTART - 2) | $0001         ' must be odd (B5 Errata)
  RXSIZE = (RXSTOP - RXSTART + 1)

DAT
        ' ** This is the default MAC address used by this driver.  The parent object
        '    can override this by passing a pointer to a new MAC address in the public
        '    start() method.  It is recommend that this is done to provide a level of
        '    abstraction and makes tcp stack design easier.
        ' ** This is the ethernet MAC address, it is critical that you change this
        '    if you have more than one device using this code on a local network.
        ' ** If you plan on commercial deployment, you must purchase MAC address
        '    groups from IEEE or some other standards organization.
        eth_mac         byte    $10, $00, $00, $00, $00, $01

OBJ                                                   

  spi : "SPI_Engine"
  
{VAR

  ' Global Variables for packet tracking and ENC28J60 communication
  byte cs, sck, si, so, int     ' pins
  byte packet[MAXFRAME]         ' ethernet buffer
  byte packetheader[6]
  word rxlen                    ' rx length

  word tx_end                   ' for write_frame}

DAT

  rxlen           word 0
  tx_end          word 0
 
  cs              byte 0
  sck             byte 0
  si              byte 0
  so              byte 0
  int             byte 0
 
  packetheader    byte 0,0,0,0,0,0

PUB start(i_cs, i_sck, i_si, i_so, i_int, xtalout, macptr)
'' Starts the driver (uses 1 cog for spi engine)

  cs := i_cs
  sck := i_sck
  si := i_si
  so := i_so
  int := i_int
  
  dira[cs] := %1
  dira[sck] := %1
  dira[si] := %1
  dira[so] := %0
  dira[int] := %0

  eth_csoff

  ' Since some people don't have 25mhz crystals, we use the cog counters
  ' to generate a 25mhz frequency for the ENC28J60 (I love the Propeller)
  ' Note: This requires a main crystal that is a multiple of 25mhz (5mhz works).
  if xtalout > -1
    SynthFreq(xtalout, 25_000_000)      'determine ctr and frq for xtalout

  ' If a MAC address pointer is provided (addr > 0) then copy it into
  ' the MAC address array (this kind of wastes space, but simplifies usage).
  if macptr > 0
    bytemove(@eth_mac, macptr, 6)
  
  delay_ms(50)
  init_ENC28J60

  ' check to make sure its a valid supported silicon rev
  banksel(EREVID)
  return rd_cntlreg(EREVID) == silicon_rev      ' return true if silicon rev match

PUB stop
'' Stops the driver, frees 1 cog

  spi.stop

PUB rd_macreg(address) : data
'' Read MAC Control Register

  eth_cson
  eth_out(cRCR | address)
  eth_out(0)                    ' transmit dummy byte
  data := eth_in                ' get actual data
  eth_csoff

PUB rd_cntlreg(address) : data
'' Read ETH Control Register

  eth_cson
  eth_out(cRCR | address)
  data := eth_in
  eth_csoff

PUB wr_reg(address, data)
'' Write MAC and ETH Control Register

  eth_cson
  eth_out(cWCR | address)
  eth_out(data)
  eth_csoff

PUB bfc_reg(address, data)
'' Clear Control Register Bits

  eth_cson
  eth_out(cBFC | address)
  eth_out(data)
  eth_csoff

PUB bfs_reg(address, data)
'' Set Control Register Bits

  eth_cson
  eth_out(cBFS | address)
  eth_out(data)
  eth_csoff

PUB soft_reset
'' Soft Reset ENC28J60

  eth_cson
  eth_out(cSC)
  eth_csoff

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

  eth_cson
  eth_out(cRBM)
  data := eth_in
  eth_csoff

PUB wr_sram(data)
'' Write ENC28J60 8k Buffer Memory

  eth_cson
  eth_out(cWBM)
  eth_out(data)
  eth_csoff

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

  ' set LED options (led A = link, led B = tx/rx)
  wr_phy(PHLCON, $0472)         '$0472          
   
  ' enable packet reception
  bfs_reg(ECON1, ECON1_RXEN)

PUB get_frame | packet_addr, new_rdptr
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
    repeat packet_addr from 0 to rxlen - 1
      BYTE[@packet][packet_addr] := rd_sram
     
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

  tx_end := constant(TXSTART - 1)         ' start location is really address 0, so we are sending a count of - 1

  wr_frame(cTXCONTROL)

PUB wr_frame(data)
'' Write frame data

  wr_sram(data)
  ++tx_end

PUB send_frame
'' Sends frame
'' Will retry on send failure up to 15 times with a 1ms delay in between repeats

  repeat 15
    if p_send_frame             ' send packet, if successful then quit retry loop
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

PUB get_packetpointer
'' Gets packet pointer (for external object access)
  return @packet

PUB get_mac_pointer
'' Gets mac address pointer
  return @eth_mac

PUB get_rxlen
'' Gets received packet length
  return rxlen - 4             ' knock off the 4 byte Frame Check Sequence CRC, not used anywhere outside of this driver (pg 31 datasheet)

PRI eth_out(value)
  spi.shiftout(si, sck, spi#mmsbfirst, 8, value)

PRI eth_in
  return spi.shiftin(so, sck, spi#mmsbpre, 8)

PRI eth_cson
  outa[cs] := %0

PRI eth_csoff
  outa[cs] := %1

PRI delay_us(Duration)
  waitcnt(((clkfreq / 1_000_000 * Duration - 3928)) + cnt)
  
PRI delay_ms(Duration)
  waitcnt(((clkfreq / 1_000 * Duration - 3932)) + cnt)

PRI SynthFreq(Pin, Freq) | s, d, ctr, frq

  Freq := Freq #> 0 <# 128_000_000     'limit frequency range
  
  if Freq < 500_000                    'if 0 to 499_999 Hz,
    ctr := constant(%00100 << 26)      '..set NCO mode
    s := 1                             '..shift = 1
  else                                 'if 500_000 to 128_000_000 Hz,
    ctr := constant(%00010 << 26)      '..set PLL mode
    d := >|((Freq - 1) / 1_000_000)    'determine PLLDIV
    s := 4 - d                         'determine shift
    ctr |= d << 23                     'set PLLDIV
    
  frq := fraction(Freq, CLKFREQ, s)    'Compute FRQA/FRQB value
  ctr |= Pin                           'set PINA to complete CTRA/CTRB value

  CTRA := ctr                        'set CTRA
  FRQA := frq                        'set FRQA                   
  DIRA[Pin]~~                        'make pin output

PRI fraction(a, b, shift) : f

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

packet  LONG 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0    ' This is the packet byte array
        LONG 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0    ' It is declared as a long in order to reduce the source file size
        LONG 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        LONG 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        LONG 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0    ' 1 long = 4 bytes
        LONG 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0    
        LONG 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0    ' Since we want 1518 bytes (MAXFRAME constant), we use 
        LONG 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0    '  20 longs x 19 lines = 380 longs x 4 = 1520 bytes 
        LONG 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        LONG 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0    ' We do loose 2 bytes by going this route, but it's not a huge
        LONG 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0    '  loss since it does give us aligned access if we ever need it
        LONG 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        LONG 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        LONG 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        LONG 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        LONG 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        LONG 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        LONG 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        LONG 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0             

CON
  ' ENC28J60 Communication and Register Layout
  ' These contants should never change, so leave this alone!

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

CON
  ' ENC28J60 Register Defines
  ' These shouldn't change, so don't touch this either...
  
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