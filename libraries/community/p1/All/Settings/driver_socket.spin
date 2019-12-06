{{
  Ethernet TCP/IP Socket Driver
  ----------------------------- 
  Original code (c) 2007,2008 Harrison Pham.
  Modifications (c) 2008 Robert Quattlebaum.
}}

OBJ
  nic : "driver_enc28j60"
  random   : "RealRandom"
  settings : "settings"
  q : "qring"

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000                                                      
  version = 1.3
  apiversion = 3
  RTCADDR = $7A00
  MIN_ADVERTISED_WINDOW = q#Q_SIZE/2
  
DAT
' Don't set any of these values by hand!
' Use the associated setting keys instead.
' See the settings object for more details.
local_macaddr   byte    $02, $00, $00, $00, $00, $01
local_mtu       word    1500
bcast_ipaddr    long    $FFFFFFFF
any_ipaddr    long    $00000000
ip_addr         byte    0,0,0,0            ' device's ip address
ip_subnet       byte    $ff,$ff,$ff,00        ' network subnet
ip_gateway      byte    192, 168, 2, 1          ' network gateway (router)
ip_dns          byte    $04,$02,$02,$04          ' network dns        
ip_maxhops      byte    $80
 
bcast_macaddr   byte    $FF, $FF, $FF, $FF, $FF, $FF

DAT
  stack       long 0[200]
  randseed    long 0
  socketlockid long -1  
DAT             

  ' Global variables (accessable between cogs)
  cog         long 0                       
  
  pkt         long 0                  ' memory address of packet start
  pkt_count   byte 0                  ' packet count

  pkt_id      long 0                  ' packet fragmentation id
  pkt_isn     long 0                  ' packet initial sequence number
DAT

last_listen_port WORD   0
last_listen_time LONG   0

PUB init
'  term.start(12)
  settings.start
'  subsys.init
'  subsys.StatusLoading
  start(1,2,3,4,6,7,-1,-1)
  
PUB start(cs, sck, si, so, int, xtalout, macptr, ipconfigptr) : okay
'' Call this to launch the Telnet driver
'' Only call this once, otherwise you will get conflicts
'' macptr      = HUB memory pointer (address) to 6 contiguous mac address bytes
'' ipconfigptr = HUB memory pointer (address) to ip configuration block (20 bytes)
''               Must be in order: ip_addr. ip_subnet, ip_gateway, ip_dns

  stop
  q.init

  if(SocketLockID := locknew) == -1
    abort FALSE
  
  random.start
  randseed := random.random
  random.stop

  ifnot settings.getData(settings#NET_MAC_ADDR,@local_macaddr,6)
    settings.setData(settings#NET_MAC_ADDR,@local_macaddr,6)  
  settings.getData(settings#NET_IPv4_ADDR,@ip_addr,4)
  settings.getData(settings#NET_IPv4_MASK,@ip_subnet,4)
  settings.getData(settings#NET_IPv4_GATE,@ip_gateway,4)
  settings.getData(settings#NET_IPv4_DNS,@ip_dns,4)

  dhcp_init

  cog := cognew(engine(cs, sck, si, so, int, xtalout, macptr, ipconfigptr), @stack) + 1
  return cog
    
PUB stop
'' Stop the driver
  if cog
    cogstop(cog~ - 1)           ' stop the tcp engine
  nic.stop                    ' stop nic driver (kills spi engine)

PRI engine(cs, sck, si, so, int, xtalout, macptr, ipconfigptr) | i, linkstat

  ' Start the ENC28J60 driver in a new cog
  nic.start(cs, sck, si, so, int, xtalout, @local_macaddr)                    ' init the nic
    
  pkt := nic.get_packetpointer

  i := 0
  linkstat:=nic.isLinkUp

  if linkstat  
    dhcp_process

  repeat
    ifnot nic.isLinkUp
      repeat while NOT nic.isLinkUp
      dhcp_rebind
      
    nic.banksel(nic#EPKTCNT)  ' re-select the packet count bank
    pkt_count := nic.rd_cntlreg(nic#EPKTCNT)
    if pkt_count > 0
      service_packet            ' handle packet

    dhcp_process
    ++i
    
    if has_valid_ip_addr AND i > 1
      ' perform send tick (occurs every 2 cycles, since incoming packets more important)
      tick_tcpsend
      i := 0

PRI service_packet
  ' lets process this frame
  nic.get_frame

  ' check for arp packet type (highest priority obviously)
  if BYTE[pkt][enetpacketType0] == $08 AND BYTE[pkt][enetpacketType1] == $06
    if BYTE[pkt][constant(arp_hwtype + 1)] == $01 AND BYTE[pkt][arp_prtype] == $08 AND BYTE[pkt][constant(arp_prtype + 1)] == $00 AND BYTE[pkt][arp_hwlen] == $06 AND BYTE[pkt][arp_prlen] == $04
      if compare_ipaddr(pkt+arp_tipaddr,@ip_addr)
        case BYTE[pkt][constant(arp_op + 1)]
          $01 : handle_arp
          $02 : handle_arpreply
  elseif NOT has_valid_ip_addr
    if BYTE[pkt][enetpacketType0] == $08 AND BYTE[pkt][enetpacketType1] == $00 AND BYTE[pkt][ip_proto] == PROT_UDP
      handle_udp 
  else
    if BYTE[pkt][enetpacketType0] == $08 AND BYTE[pkt][enetpacketType1] == $00
      case BYTE[pkt][ip_proto]
        PROT_ICMP : \handle_icmp
        PROT_TCP :  \handle_tcp                       ' handles abort out of tcp handlers (no socket found)
        PROT_UDP :  \handle_udp
       
PRI compare_ipaddr(ip1ptr,ip2ptr)
  return BYTE[ip1ptr][0] == BYTE[ip2ptr][0] AND BYTE[ip1ptr][1] == BYTE[ip2ptr][1] AND BYTE[ip1ptr][2] == BYTE[ip2ptr][2] AND BYTE[ip1ptr][3] == BYTE[ip2ptr][3]

' *******************************
' ** Protocol Receive Handlers **
' *******************************
PRI compose_ethernet_header(dst_macaddr,src_macaddr,size)
  nic.wr_frame_data(dst_macaddr,6)
  nic.wr_frame_data(src_macaddr,6)
  nic.wr_frame_word(size)
PRI compose_ip_header(protocol,dst_addr,src_addr) | chksum
  nic.wr_frame($45)        ' ip vesion and header size
  nic.wr_frame($00)        ' TOS
  nic.wr_frame_word($00)  ' IP Packet Length (Will be filled in at a later step)
  nic.wr_frame_word(++pkt_id)
  nic.wr_frame($40)  ' Don't fragment
  nic.wr_frame($00)  ' frag stuff
  nic.wr_frame(ip_maxhops)  ' TTL
  nic.wr_frame(protocol)  ' UDP
  nic.wr_frame_word($00)  ' header checksum (Filled in by hardware)
  nic.wr_frame_data(src_addr,4)
  nic.wr_frame_data(dst_addr,4)

  return protocol + calc_chksumhalf(src_addr, 4) + calc_chksumhalf(dst_addr, 4)

PRI compose_udp_header(dst_port,src_port,chksum)
  nic.wr_frame_word(src_port)  ' Source Port
  nic.wr_frame_word(dst_port)  ' Dest Port
  nic.wr_frame_word($00)  ' UDP packet Length (Will be filled in at a later step)
  nic.wr_frame_word(chksum)  ' UDP checksum

PRI compose_arp(type,lmac,lip,rmac,rip)
  nic.wr_frame_word($0001)        ' 10mb ethernet

  nic.wr_frame_word($0800)             ' ip proto

  nic.wr_frame($06)             ' mac addr len
  nic.wr_frame($04)             ' proto addr len

  nic.wr_frame_word(type)       'type

  ' write ethernet module mac address
  nic.wr_frame_data(lmac,6)

  ' write ethernet module ip address
  nic.wr_frame_data(lip,4)

  ' write remote mac address
  nic.wr_frame_data(rmac,6)

  ' write remote ip address
  nic.wr_frame_data(rip,4)


PRI arp_request(rip) | i
  nic.start_frame
  compose_ethernet_header(@bcast_macaddr,@local_macaddr,$0806)
  compose_arp(1,@local_macaddr,@ip_addr,@bcast_macaddr,rip)
  return nic.send_frame


PRI handle_arp | i
  nic.start_frame
  compose_ethernet_header(pkt+enetpacketSrc0,@local_macaddr,$0806)
  compose_arp(2,@local_macaddr,@ip_addr,pkt+enetpacketSrc0,pkt+arp_sipaddr)
  return nic.send_frame


PRI handle_arpreply | handle, handle_addr, ip, found
  ' Gets arp reply if it is a response to an ip we have

  bytemove(@ip, pkt + arp_sipaddr, 4)

  found := false
  if ip == LONG[@ip_gateway]
    ' find a handle that wants gateway mac
    repeat handle from 0 to constant(sNumSockets - 1)
      handle_addr := @sSockets + (sSocketBytes * handle)
      if BYTE[handle_addr + sConState] == SCONNECTINGARP2G
        found := true
        quit
  else
    ' find the one that wants this arp
    repeat handle from 0 to constant(sNumSockets - 1)
      handle_addr := @sSockets + (sSocketBytes * handle)
      if BYTE[handle_addr + sConState] == SCONNECTINGARP2
        if LONG[handle_addr + sSrcIp] == ip
          found := true
          quit
          
  if found
    bytemove(handle_addr + sSrcMac, pkt + arp_shaddr, 6)
    BYTE[handle_addr + sConState] := SCONNECTING
PRI bounce_unreachable(code) | i
  ifnot compare_ipaddr(pkt+ip_destaddr,@ip_addr)
    ' Don't bounce unless it was specifically for us
    ' In other words, don't bounce broadcasts
    return

  nic.start_frame
  compose_ethernet_header(pkt+enetpacketSrc0,@local_macaddr,$0800)
  compose_ip_header(PROT_ICMP,pkt+ip_srcaddr,@ip_addr)
  nic.wr_frame_byte(3) ' type: destination unreachable
  nic.wr_frame_byte(code)
  nic.wr_frame_word(0) ' checksum
  nic.wr_frame_long(0) ' padding
  nic.wr_frame_data(pkt+enetpacketData,36)
  nic.calc_frame_ip_length
  nic.calc_frame_ip_checksum
  nic.calc_frame_icmp_checksum

  return nic.send_frame

PRI handle_icmp | i,pkt_len
    case BYTE[pkt][icmp_type]
      8 : ' echo request
        ++pkt_id

        ' Reply to the same MAC
        wordmove(pkt + enetpacketDest0, pkt + enetpacketSrc0, 3)
        wordmove(pkt + enetpacketSrc0, @local_macaddr, 3)                             ' Set source mac address

        ' Reply to the same IP
        wordmove(pkt + ip_destaddr, pkt + ip_srcaddr, 2)
        wordmove(pkt + ip_srcaddr, @ip_addr, 2)
  
        BYTE[pkt][ip_id] := pkt_id >> 8
        BYTE[pkt][ip_id+1] := pkt_id

        BYTE[pkt][icmp_type] := 0 'Set to echo reply

        ' Zero out the checksums (to be caculated in hardware)
        WORD[pkt+ip_hdr_cksum][0] := 0
        WORD[pkt+icmp_cksum][0] := 0

        BYTE[pkt][ip_ttl] := ip_maxhops ' reset the time to live

        pkt_len := (BYTE[pkt+ip_pktlen]<<8)+BYTE[pkt+ip_pktlen+1]  +14

        ' send the packet
        nic.start_frame
        nic.wr_frame_data(pkt,pkt_len)
         
        nic.calc_frame_ip_length
        nic.calc_frame_icmp_checksum
        nic.calc_frame_ip_checksum

        ' send the packet
        nic.send_frame

   
  
PRI handle_udp | dstport
  ' Handles incoming UDP packets

  dstport := BYTE[pkt][UDP_destport] << 8 + BYTE[pkt][constant(UDP_destport + 1)]

  case dstport
    DHCP_PORT_CLIENT: handle_dhcp
    other: bounce_unreachable(3)
        
PRI handle_tcp | i, ptr, handle, handle_addr, srcip, dstip, dstport, srcport, datain_len  , seq
  ' Handles incoming TCP packets

  ifnot compare_ipaddr(pkt+ip_destaddr,@ip_addr)
    ' Only let TCP work if the destination matches our address.
    abort -1

  bytemove(@srcip, pkt + ip_srcaddr, 4)
  dstport := BYTE[pkt][TCP_destport] << 8 + BYTE[pkt][constant(TCP_destport + 1)]
  srcport := BYTE[pkt][TCP_srcport] << 8 + BYTE[pkt][constant(TCP_srcport + 1)]

  if (handle := \find_socket(srcip, dstport, srcport))==-1
    ' If this is a syn packet and we have listened on this
    ' port in the past 5 seconds then just drop the packet.
    ' Hopefully we'll be listening again on that port at
    ' some point in the near future.
    ifnot dstport==last_listen_port AND LONG[RTCADDR]<last_listen_time+5 AND (BYTE[pkt][constant(TCP_hdrflags + 1)] & TCP_SYN)
      reject_tcp
    abort -1
  handle_addr := @sSockets + (sSocketBytes * handle)

  ' at this point we assume we have an active socket, or a socket available to be used
  datain_len := ((BYTE[pkt][ip_pktlen] << 8) + BYTE[pkt][constant(ip_pktlen + 1)]) - ((BYTE[pkt][ip_vers_len] & $0F) * 4) - (((BYTE[pkt][TCP_hdrflags] & $F0) >> 4) * 4)

  bytemove(@seq, pkt + TCP_seqnum, 4)
  seq:=conv_endianlong(seq)

  if (BYTE[handle_addr + sConState] == SLISTEN) AND (BYTE[pkt][constant(TCP_hdrflags + 1)] & TCP_FIN) > 0
    reject_tcp
    abort -1
  elseif (BYTE[handle_addr + sConState] <> SLISTEN) AND (BYTE[pkt][constant(TCP_hdrflags + 1)] & TCP_ACK) > 0 AND datain_len > 0
    ' ACK, without SYN, with data

    ' set socket state, established session
    BYTE[handle_addr + sConState] := SESTABLISHED
    LONG[handle_addr + sAge] := long[RTCADDR]

    if seq==LONG[handle_addr + sMyAckNum]
      ' copy data to buffer
      if \q.pushData(BYTE[handle_addr+sSockQRx],pkt+TCP_data,datain_len) > 0
        ' recalculate ack Num
        LONG[handle_addr + sMyAckNum]+=datain_len
       
    ' Send an ACK
    send_tcppacket(handle_addr,TCP_ACK,0,0)

  elseif (BYTE[handle_addr + sConState] == SSYNSENT) AND (BYTE[pkt][constant(TCP_hdrflags + 1)] & TCP_SYN) > 0 AND (BYTE[pkt][constant(TCP_hdrflags + 1)] & TCP_ACK) > 0
    ' We got a server response, so we ACK it


    LONG[handle_addr+sMyAckNum]:=seq+1

    bytemove(handle_addr + sMySeqNum, pkt + TCP_acknum, 4)
    LONG[handle_addr+sMySeqNum]:=conv_endianlong(LONG[handle_addr+sMySeqNum])

    ' ACK response
    send_tcppacket(handle_addr,TCP_ACK,0,0)

    ' set socket state, established session
    LONG[handle_addr + sAge] := long[RTCADDR]
    BYTE[handle_addr + sConState] := SESTABLISHED
  
  elseif (BYTE[handle_addr + sConState] == SLISTEN) AND (BYTE[pkt][constant(TCP_hdrflags + 1)] & TCP_SYN) > 0
    ' Reply to SYN with SYN + ACK

    ' copy mac address so we don't have to keep an ARP table
    bytemove(handle_addr + sSrcMac, pkt + enetpacketSrc0, 6)

    ' copy ip, port data
    LONG[handle_addr+sSrcIp]:= srcip
    WORD[handle_addr+sDstPort]:= dstport
    WORD[handle_addr+sSrcPort]:= srcport

    ' get updated ack numbers
    LONG[handle_addr+sMyAckNum]:=seq+1
    LONG[handle_addr + sMySeqNum] := randseed?               ' Initial seq num (random)

    send_tcppacket(handle_addr,TCP_SYN|TCP_ACK,0,0)

    ' incremement the sequence number for the next packet (it will be for an established connection)                                          
    LONG[handle_addr + sMySeqNum]++

    ' set socket state, waiting for establish
    LONG[handle_addr + sAge] := long[RTCADDR]
    BYTE[handle_addr + sConState] := SSYNSENT

    ' Little hack
    last_listen_port:=dstport
    last_listen_time:=long[RTCADDR]
   
  elseif (BYTE[handle_addr + sConState] <> SLISTEN) AND (BYTE[pkt][constant(TCP_hdrflags + 1)] & TCP_FIN) > 0
    ' Reply to FIN with ACK
      
    ' We only want to ACK a FIN if we have received everything up to this point.
    if seq<>LONG[handle_addr + sMyAckNum]
      send_tcppacket(handle_addr,TCP_ACK,0,0)
      abort -1 ' Bad sequence Num!

    ' get updated sequence and ack numbers (gaurantee we have correct ones to kill connection with)
    bytemove(handle_addr + sMySeqNum, pkt + TCP_acknum, 4)
                                              
    LONG[handle_addr+sMyAckNum]:=seq+1
    LONG[handle_addr+sMySeqNum]:=conv_endianlong(LONG[handle_addr+sMySeqNum])

    send_tcppacket(handle_addr,TCP_RST,0,0)

    ' set socket state, now free
    \q.delete(BYTE[handle_addr + sSockQTx]~)
    \q.delete(BYTE[handle_addr + sSockQRx]~)
    bytefill(handle_addr,0,sSocketBytes)
    LONG[handle_addr + sAge] := long[RTCADDR]
    BYTE[handle_addr + sConState] := SCLOSED
    
  elseif (BYTE[handle_addr + sConState] == SSYNSENT) AND (BYTE[pkt][constant(TCP_hdrflags + 1)] & TCP_ACK) > 0
    ' if just an ack, and we sent a syn before, then it's established
    ' this just gives us the ability to send on connect
    BYTE[handle_addr + sConState] := SESTABLISHED
    LONG[handle_addr + sAge] := long[RTCADDR]
    
  elseif (BYTE[pkt][constant(TCP_hdrflags + 1)] & TCP_RST) > 0

    ' Reset, reset states
    \q.delete(BYTE[handle_addr + sSockQTx]~)
    \q.delete(BYTE[handle_addr + sSockQRx]~)
    bytefill(handle_addr,0,sSocketBytes)
    LONG[handle_addr + sAge] := long[RTCADDR]
    BYTE[handle_addr + sConState] := SCLOSED

PRI reject_tcp | srcip,dstport,srcport,seq,ack,chksum
  bounce_unreachable(3)

  dstport := BYTE[pkt][TCP_destport] << 8 + BYTE[pkt][constant(TCP_destport + 1)]
  srcport := BYTE[pkt][TCP_srcport] << 8 + BYTE[pkt][constant(TCP_srcport + 1)]

  bytemove(@seq, pkt + TCP_acknum, 4)
  seq:=conv_endianlong(seq)

  bytemove(@ack, pkt + TCP_seqnum, 4)
  ack:=conv_endianlong(ack)+1
  
  nic.start_frame
  compose_ethernet_header(pkt+enetpacketSrc0,@local_macaddr,$0800)
  chksum:=compose_ip_header(PROT_TCP,pkt+ip_srcaddr,@ip_addr)
  chksum+=TCP_data-TCP_srcport
  compose_tcp_header(srcport,dstport,seq,ack,TCP_RST,0,chksum)
  nic.calc_frame_ip_length
  nic.calc_frame_ip_checksum
  nic.calc_frame_tcp_checksum

  return nic.send_frame


PRI compose_tcp_header(dstport,srcport,seq,ack,flags,window,chksum)
  nic.wr_frame_word(srcport)  ' Source Port
  nic.wr_frame_word(dstport)  ' Dest Port
  nic.wr_frame_long(seq)
  nic.wr_frame_long(ack)
  nic.wr_frame_byte($50)
  nic.wr_frame_byte(flags)
  nic.wr_frame_word(window)
  
  chksum := (chksum >> 16) + (chksum & $FFFF)
  nic.wr_frame_word(chksum)  ' TCP checksum (work in progress)
  nic.wr_frame_word($00)  ' TCP urgent pointer
  

PRI send_tcppacket(handle_addr,flags,data,datalen) | hdrlen, hdr_chksum

  nic.start_frame
  compose_ethernet_header(handle_addr + sSrcMac,@local_macaddr,$0800)
  hdr_chksum:=compose_ip_header(PROT_TCP,handle_addr + sSrcIp,@ip_addr)
  hdr_chksum+=TCP_data-TCP_srcport+datalen
  WORD[handle_addr + sLastWindow]:= q.bytesFree(BYTE[handle_addr + sSockQRx])

  if WORD[handle_addr + sLastWindow]<MIN_ADVERTISED_WINDOW
    WORD[handle_addr + sLastWindow]:=0
   
  compose_tcp_header(WORD[handle_addr + sSrcPort],WORD[handle_addr + sDstPort],LONG[handle_addr + sMySeqNum],LONG[handle_addr + sMyAckNum],flags,WORD[handle_addr + sLastWindow],hdr_chksum)
  if datalen > 0
    nic.wr_frame_data(data,datalen)

  nic.calc_frame_ip_length
  nic.calc_frame_ip_checksum
  nic.calc_frame_tcp_checksum

  nic.send_frame

  LONG[handle_addr + sMySeqNum]+= datalen               ' update running sequence number
    
PRI socketLock
  repeat while NOT lockset(SocketLockid)
PRI socketUnlock
  lockclr(SocketLockid)

PRI find_socket(srcip, dstport, srcport) | handle, free_handle, handle_addr
  ' Search for socket, matches ip address, port states
  ' Returns handle number
  '  If no matches, will abort with -1
  '  If supplied with srcip = 0 then will return free unused handle, aborts with -1 if none avail
  
  free_handle := -1
  repeat handle from 0 to constant(sNumSockets - 1)
    handle_addr := @sSockets + (sSocketBytes * handle)   ' generate handle address (mapped to memory)
    if BYTE[handle_addr + sConState] <> SCLOSED
      if (LONG[handle_addr + sSrcIp] == 0) OR (LONG[handle_addr + sSrcIp] == srcip)
        ' ip match, ip socket srcip = 0, then will try to match dst port (find listening socket)
          if (WORD[handle_addr + sDstPort] == dstport) AND (WORD[handle_addr + sSrcPort] == 0 OR WORD[handle_addr + sSrcPort] == srcport)
            ' port match, will match port, if srcport = 0 then will match dstport only (find listening socket)
            return handle
    elseif srcip == 0
      ' we only return a free handle if we are searching for srcip = 0 (just looking for free handle)
      free_handle := handle     ' we found a free handle, may need this later
      
  if free_handle <> -1
    return free_handle 
  else
    abort(-1)

' ******************************
' ** Transmit Buffer Handlers **
' ******************************
PRI tick_tcpsend | state,i, ptr, handle, handle_addr
  ' Check buffers for data to send (called in main loop)
  
  repeat handle from 0 to constant(sNumSockets - 1)
    handle_addr := @sSockets + (sSocketBytes * handle)
    state := BYTE[handle_addr + sConState]

    if state == SESTABLISHED OR state == SCLOSING
      ' Check to see if we have data to send, if we do, send it
      ' If we have hit out next ack marker, send an ACK

      i := local_mtu-TCP_DATA
      ' TODO: If dest window is smaller than i, replace i with dest window size
      if i AND NOT q.isEmpty(BYTE[handle_addr+sSockQTx])
        i := q.pullData(BYTE[handle_addr+sSockQTx],pkt,i)
        send_tcppacket(handle_addr,TCP_ACK|TCP_PSH,pkt,i)
      else
        i:=q.bytesFree(BYTE[handle_addr + sSockQRx])
        if i<MIN_ADVERTISED_WINDOW
          i:=0
        if WORD[handle_addr + sLastWindow]<>i
          send_tcppacket(handle_addr,TCP_ACK,0,0)
  
    if state == SSYNSENT AND (long[RTCADDR]-LONG[handle_addr + sAge]>5)
      ' If we haven't gotten back an ACK 5 seconds after sending the SYN, forget about it
      send_tcppacket(handle_addr,TCP_RST,0,0)

      \q.delete(BYTE[handle_addr + sSockQTx]~)
      \q.delete(BYTE[handle_addr + sSockQRx]~)
      bytefill(handle_addr,0,sSocketBytes)
      LONG[handle_addr + sAge] := long[RTCADDR]
      BYTE[handle_addr + sConState] := SCLOSED

    if state == SCLOSING

      send_tcppacket(handle_addr,TCP_ACK|TCP_FIN,0,0)

      ' set socket state, now free
      LONG[handle_addr + sAge] := long[RTCADDR]
      BYTE[handle_addr + sConState] := SCLOSING2
    elseif state == SCLOSING2 AND (long[RTCADDR]-LONG[handle_addr + sAge]>10)
      ' Force connection close, I'll just RST it (bad I know, but it ensures closing...)

      LONG[handle_addr + sMyAckNum] ++

      send_tcppacket(handle_addr,TCP_RST,0,0)

      ' set socket state, now free
      \q.delete(BYTE[handle_addr + sSockQTx]~)
      \q.delete(BYTE[handle_addr + sSockQRx]~)
      bytefill(handle_addr,0,sSocketBytes)
      LONG[handle_addr + sAge] := long[RTCADDR]
      BYTE[handle_addr + sConState] := SCLOSED
       
    elseif state == SCONNECTINGARP1
      ' We need to send an arp request

      arp_request_checkgateway(handle_addr)

    elseif state == SCONNECTING
      ' Yea! We got an arp response previously, so now we can send the SYN

      LONG[handle_addr + sMySeqNum] := randseed?
      LONG[handle_addr + sMyAckNum] := 0
       
      send_tcppacket(handle_addr,TCP_SYN,0,0)

      BYTE[handle_addr + sConState] := SSYNSENT
      LONG[handle_addr + sAge] := long[RTCADDR]
      

PRI arp_request_checkgateway(handle_addr) | ip_ptr

  ip_ptr := handle_addr + sSrcIp
  
  if (BYTE[ip_ptr] & ip_subnet[0]) == (ip_addr[0] & ip_subnet[0]) AND (BYTE[ip_ptr + 1] & ip_subnet[1]) == (ip_addr[1] & ip_subnet[1]) AND (BYTE[ip_ptr + 2] & ip_subnet[2]) == (ip_addr[2] & ip_subnet[2]) AND (BYTE[ip_ptr + 3] & ip_subnet[3]) == (ip_addr[3] & ip_subnet[3])   
    arp_request(ip_ptr)
    BYTE[handle_addr + sConState] := SCONNECTINGARP2
    LONG[handle_addr + sAge] := long[RTCADDR]
  else
    arp_request(@ip_gateway)
    BYTE[handle_addr + sConState] := SCONNECTINGARP2G   
    LONG[handle_addr + sAge] := long[RTCADDR]
  
  
' *******************************
' ** IP Packet Helpers (Calcs) **
' *******************************    
PRI calc_chksum(packet, hdrlen) : chksum
  ' Calculates IP checksums
  ' packet = pointer to IP packet
  ' returns: chksum
  ' http://www.geocities.com/SiliconValley/2072/bit33.txt
  chksum := calc_chksumhalf(packet, hdrlen)
  chksum := calc_chksumfinal(chksum)

PRI calc_chksumfinal(chksumin) : chksum
  ' Performs the final part of checksums
  chksum := (chksumin >> 16) + (chksumin & $FFFF)
  chksum := (!chksum) & $FFFF
  
PRI calc_chksumhalf(packet, hdrlen) : chksum
  ' Calculates checksum without doing the final stage of calculations
  chksum := 0
  repeat while hdrlen > 1
    chksum += (BYTE[packet++] << 8) + BYTE[packet++]
    chksum := (chksum >> 16) + (chksum & $FFFF)
    hdrlen -= 2
  if hdrlen > 0              
    chksum += BYTE[packet] << 8

' ***************************
' ** Memory Access Helpers **
' ***************************    
PRI conv_endianlong(in)
  return (in << 24) + ((in & $FF00) << 8) + ((in & $FF0000) >> 8) + (in >> 24)  ' we can sometimes get away with shifting without masking, since shifts kill extra bits anyways

PRI conv_endianword(in)
  return ((in & $FF) << 8) + ((in & $FF00) >> 8)

' ************************************
' ** Public Accessors (Thread Safe) **
' ************************************
PUB listen(port) | handle, handle_addr, x
'' Sets up a socket for listening on a port
'' Returns handle if available, -1 if none available
'' Nonblocking

  ' just find any avail closed socket
  socketlock
  handle := \find_socket(0, 0, 0)
  
  if handle < 0
    socketunlock
    return -1

  handle_addr := @sSockets + (sSocketBytes * handle)

  ' Start with a clean slate
  bytefill(handle_addr,0,sSocketBytes)

  LONG[handle_addr + sAge] := long[RTCADDR]

  if (x:=\q.new)=<0
    socketunlock
    return -1
  else
    BYTE[handle_addr + sSockQTx] := x
    
  if (x:=\q.new)=<0
    \q.delete(BYTE[handle_addr + sSockQTx]~)
    socketunlock
    return -1
  else
    BYTE[handle_addr + sSockQRx] := x

  WORD[handle_addr + sSrcPort] := 0                     ' no source port yet
  WORD[handle_addr + sDstPort] := port ' we do have a dest port though

  ' it's now listening
  BYTE[handle_addr + sConState] := SLISTEN

  socketunlock
  
  return handle 

PUB connect(ip, remoteport, localport) | handle, handle_addr,x
'' Connect to remote host
'' Returns handle to new socket, -1 if no socket available
'' Nonblocking

  ' just find any avail closed socket
  socketlock
  handle := \find_socket(0, 0, 0)

  if handle < 0
    socketunlock
    return -1

  handle_addr := @sSockets + (sSocketBytes * handle)

  ' Start with a clean slate
  bytefill(handle_addr,0,sSocketBytes)
  
  if (x:=\q.new)=<0
    socketunlock
    return -1
  else
    BYTE[handle_addr + sSockQTx] := x
    
  if (x:=\q.new)=<0
    \q.delete(BYTE[handle_addr + sSockQTx]~)
    socketunlock
    return -1
  else
    BYTE[handle_addr + sSockQRx] := x

  ' copy in ip, port data (with respect to the remote host, since we use same code as server)
  LONG[handle_addr + sSrcIp] := LONG[ip]
  WORD[handle_addr + sSrcPort] := remoteport
  WORD[handle_addr + sDstPort] := localport

  LONG[handle_addr + sAge] := long[RTCADDR]

  BYTE[handle_addr + sConState] := SCONNECTINGARP1
  socketunlock
  
  return handle

PUB close(handle) | handle_addr
'' Closes a connection
  socketlock
  handle_addr := @sSockets + (sSocketBytes * handle)
  if \isConnected(handle) OR BYTE[handle_addr + sConState]==SCLOSING OR BYTE[handle_addr + sConState]==SCLOSING2
    BYTE[handle_addr + sConState] := SCLOSING
    LONG[handle_addr + sAge] := long[RTCADDR]
    repeat while BYTE[handle_addr + sConState]==SCLOSING
    \q.delete(BYTE[handle_addr + sSockQTx]~)
    \q.delete(BYTE[handle_addr + sSockQRx]~)
  else
    \q.delete(BYTE[handle_addr + sSockQTx]~)
    \q.delete(BYTE[handle_addr + sSockQRx]~)
    bytefill(handle_addr,0,sSocketBytes-1)
    LONG[handle_addr + sAge] := long[RTCADDR]
    BYTE[handle_addr + sConState] := SCLOSED
  socketunlock

PUB closeall | handle
  repeat handle from 0 to constant(sNumSockets - 1)
    close(handle)
    
PUB isConnected(handle) | handle_addr
'' Returns true if the socket is connected, false otherwise
  if handle => 2 OR handle < 0
    abort handle
  handle_addr := @sSockets + (sSocketBytes * handle)
  if BYTE[handle_addr + sConState] == SESTABLISHED
    return true
  return false
PUB isEOF(handle) | handle_addr
  handle_addr := @sSockets + (sSocketBytes * handle)
  if BYTE[handle_addr + sConState] == SESTABLISHED
    return false
  return q.isEmpty(BYTE[handle_addr + sSockQRx])

PUB isValidHandle(handle) | handle_addr
'' Checks to see if the handle is valid, handles will become invalid once they are used
'' In other words, a closed listening socket is now invalid, etc

  if handle => 2 OR handle < 0
    abort -111

  handle_addr := @sSockets + (sSocketBytes * handle)

  return BYTE[handle_addr + sConState] <> SCLOSED
  
PUB readByteNonBlocking(handle) : rxbyte | ptr
'' Read a byte from the specified socket
'' Will not block (returns q#ERR_Q_EMPTY if no byte avail)

  if (rxbyte:=\q.pull(BYTE[@sSockets + (sSocketBytes * handle) + sSockQRx])) < 0 AND rxbyte<>q#ERR_Q_EMPTY
    abort rxbyte  
    
PUB readByteTimeout(handle,ms) : rxbyte | ptr,t
'' Read a byte from the specified socket
'' Will block until a byte is received
'' or a timeout occurs

  t := cnt
  repeat while (rxbyte := readByteNonBlocking(handle)) == q#ERR_Q_EMPTY AND isValidHandle(handle)
    if (cnt - t) / (clkfreq / 1000) > ms
      abort q#ERR_Q_EMPTY
PUB readByte(handle) : rxbyte | ptr
'' Read a byte from the specified socket
'' Will block until a byte is received
  repeat while (rxbyte := readByteNonBlocking(handle)) == q#ERR_Q_EMPTY AND isValidHandle(handle)

PUB writeByteNonBlocking(handle, txbyte):retVal | ptr
'' Writes a byte to the specified socket
'' Will not block (returns q#ERR_Q_FULL if no buffer space available)

  if (retVal:=\q.push(BYTE[@sSockets + (sSocketBytes * handle) + sSockQTx],txbyte)) < 0 AND retVal<>q#ERR_Q_FULL
    abort retVal  

PUB writeDataNonBlocking(handle, ptr,len):retVal
'' Writes a byte to the specified socket
'' Will not block (returns q#ERR_Q_FULL if no buffer space available)

  if (retVal:=\q.pushData(BYTE[@sSockets + (sSocketBytes * handle) + sSockQTx],ptr,len)) < 0 AND retVal<>q#ERR_Q_FULL
    abort retVal  

PUB writeByte(handle, txbyte):retVal
'' Write a byte to the specified socket
'' Will block until space is available for byte to be sent 

  repeat while (retVal:=writeByteNonBlocking(handle, txbyte)) == q#ERR_Q_FULL
    ifnot isValidHandle(handle)
      abort -1

PRI writeData_(handle, ptr,len): retVal
  repeat while (retVal:=writeDataNonBlocking(handle, ptr,len)) == q#ERR_Q_FULL
    ifnot isValidHandle(handle)
      abort -1

PUB writeData(handle, ptr,len)
  repeat while len > q#Q_SIZE-1
    writeData_(handle,ptr,q#Q_SIZE-1)
    ptr+=q#Q_SIZE-1
    len-=q#Q_SIZE-1
  return writeData_(handle,ptr,len)

CON
' The following is an 'array' that represents all the socket handle data (with respect to the remote host)
' longs first, then words, then bytes (for alignment)
'
'         4 bytes - (1 long ) my sequence number
'         4 bytes - (1 long ) my acknowledgement number
'         4 bytes - (1 long ) src ip
'         4 bytes - (1 long ) time last activity occured in this state
'         2 bytes - (1 word ) src port
'         2 bytes - (1 word ) dst port
'         4 bytes - (1 long ) When to send next ack (a terrible hACK)
'         1 byte  - (1 byte ) conn state
'         6 bytes - (6 bytes) src mac address
'         1 byte  - (1 byte ) handle index
' total: 32 bytes

  sSocketBytes  = 40      ' MUST BE MULTIPLE OF 4 (long aligned) set this to total socket state data size
  
  sNumSockets = 2         ' number of sockets

' Offsets for socket status arrays
  sMySeqNum = 0
  sMyAckNum = 4
  sSrcIp = 8
  sAge = 12 
  sSrcPort = 16
  sDstPort = 18
  sLastWindow = 24
  sConState = 26
  sSrcMac = 27

  sSockQTx = 33
  sSockQRx = 34

' Socket states (user should never touch these)
  SCLOSED = 0                   ' closed, handle not used
  SLISTEN = 1                   ' listening, in server mode
  SSYNSENT = 2                  ' SYN sent, connection is opening stage 1
  SESTABLISHED = 3              ' established connection (either SYN+ACK, or ACK+Data)
  SCLOSING = 4                  ' connection is being forced closed by code
  SCLOSING2 = 9                 ' 
  SCONNECTINGARP1 = 5           ' connecting, next step: send arp request
  SCONNECTINGARP2 = 6           ' connecting, next step: arp request sent, waiting for response
  SCONNECTINGARP2G = 7          ' connecting, next step: arp request sent, waiting for response [GATEWAY REQUEST]
  SCONNECTING = 8               ' connecting, next step: got mac address, send SYN

DAT
              long      0       ' long align the socket state data
sSockets      byte      0[sSocketBytes*sNumSockets]


CON
  ' sFlags variables (not related to the TCP header flags)
  ARP_REPLY     = %0000_0001
  SEND_WAITING  = %0000_0010  

  ' TCP Flags
  TCP_FIN = 1
  TCP_SYN = 2
  TCP_RST = 4
  TCP_PSH = 8
  TCP_ACK = 16
  TCP_URG = 32
  TCP_ECE = 64
  TCP_CWR = 128

  ' Constants for TCP / UDP
  '******************************************************************
  '*      Ethernet Header Layout
  '******************************************************************                
  enetpacketDest0 = $00  'destination mac address
  enetpacketDest1 = $01
  enetpacketDest2 = $02
  enetpacketDest3 = $03
  enetpacketDest4 = $04
  enetpacketDest5 = $05
  enetpacketSrc0 = $06  'source mac address
  enetpacketSrc1 = $07
  enetpacketSrc2 = $08
  enetpacketSrc3 = $09
  enetpacketSrc4 = $0A
  enetpacketSrc5 = $0B
  enetpacketType0 = $0C  'type/length field
  enetpacketType1 = $0D
  enetpacketData = $0E  'IP data area begins here
  '******************************************************************
  '*      ARP Layout
  '******************************************************************
  arp_hwtype = $0E
  arp_prtype = $10
  arp_hwlen = $12
  arp_prlen = $13
  arp_op = $14
  arp_shaddr = $16   'arp source mac address
  arp_sipaddr = $1C   'arp source ip address
  arp_thaddr = $20   'arp target mac address
  arp_tipaddr = $26   'arp target ip address
  '******************************************************************
  '*      IP Header Layout
  '******************************************************************
  ip_vers_len = $0E       'IP version and header length 1a19
  ip_tos = $0F    'IP type of service
  ip_pktlen = $10 'packet length
  ip_id = $12     'datagram id
  ip_frag_offset = $14    'fragment offset
  ip_ttl = $16    'time to live
  ip_proto = $17  'protocol (ICMP=1, TCP=6, UDP=11)
  ip_hdr_cksum = $18      'header checksum 1a23
  ip_srcaddr = $1A        'IP address of source
  ip_destaddr = $1E       'IP addess of destination
  ip_data = $22   'IP data area
  '******************************************************************
  '*      TCP Header Layout
  '******************************************************************
  TCP_srcport = $22       'TCP source port
  TCP_destport = $24      'TCP destination port
  TCP_seqnum = $26        'sequence number
  TCP_acknum = $2A        'acknowledgement number
  TCP_hdrflags = $2E      '4-bit header len and flags
  TCP_window = $30        'window size
  TCP_cksum = $32 'TCP checksum
  TCP_urgentptr = $34     'urgent pointer
  TCP_data = $36 'option/data
  '******************************************************************
  '*      IP Protocol Types
  '******************************************************************
  PROT_ICMP = $01
  PROT_TCP = $06
  PROT_UDP = $11
  '******************************************************************
  '*      ICMP Header
  '******************************************************************
  ICMP_type = ip_data
  ICMP_code = ICMP_type+1
  ICMP_cksum = ICMP_code+1
  ICMP_id = ICMP_cksum+2
  ICMP_seqnum = ICMP_id+2
  ICMP_data = ICMP_seqnum+2
  '******************************************************************
  '*      UDP Header
  '******************************************************************
  UDP_srcport = ip_data
  UDP_destport = UDP_srcport+2
  UDP_len = UDP_destport+2
  UDP_cksum = UDP_len+2
  UDP_data = UDP_cksum+2


DAT
' ================================================================
' DHCP Implementation
' ================================================================
DAT
' DHCP Vars
        ip_dhcp_server_ip  byte    0,0,0,0
        ip_dhcp_server_mac byte    $FF, $FF, $FF, $FF, $FF, $FF
        ip_dhcp_state   byte    0
        ip_dhcp_xid     long    0
        ip_dhcp_next    long    0                   ' Time for next DHCP op
        ip_dhcp_delay   word    0
CON
  DHCP_STATE_UNBOUND = 0       
  DHCP_STATE_RENEW = 1       
  DHCP_STATE_REBIND = 0       
  DHCP_STATE_BOUND = 3       
  DHCP_STATE_DISABLED = 4       

  DHCP_PORT_CLIENT = 68
  DHCP_PORT_SERVER = 67

  DHCP_TYPE_DISCOVER = 1
  DHCP_TYPE_OFFER = 2
  DHCP_TYPE_REQUEST = 3
  DHCP_TYPE_DECLINE = 4
  DHCP_TYPE_ACK = 5
  DHCP_TYPE_NAK = 6
  DHCP_TYPE_RELEASE = 7
  DHCP_TYPE_INFORM = 8

  '******************************************************************
  '*      DHCP Message
  '******************************************************************
  DHCP_op = UDP_data
  DHCP_htype = DHCP_op+1
  DHCP_hlen = DHCP_htype+1
  DHCP_hops = DHCP_hlen+1
  DHCP_xid = DHCP_hops+1
  DHCP_secs = DHCP_xid+4
  DHCP_flags = DHCP_secs+2
  DHCP_ciaddr = DHCP_flags+2
  DHCP_yiaddr = DHCP_ciaddr+4
  DHCP_siaddr = DHCP_yiaddr+4
  DHCP_giaddr = DHCP_siaddr+4
  DHCP_chaddr = DHCP_giaddr+4
  DHCP_sname = DHCP_chaddr+16
  DHCP_file = DHCP_sname+64
  DHCP_options = DHCP_file+128
  DHCP_message_end = DHCP_options+312
PRI dhcp_init
  if settings.findKey(settings#NET_DHCPv4_DISABLE)
    ip_dhcp_state:=DHCP_STATE_DISABLED
  else
    ip_dhcp_next:=LONG[RTCADDR]
    ip_dhcp_state:=DHCP_STATE_UNBOUND
    settings.removeKey(settings#NET_IPv4_ADDR)
    settings.removeKey(settings#NET_IPv4_MASK)
    settings.removeKey(settings#NET_IPv4_GATE)
  ip_dhcp_xid := randseed?
pub dhcp_rebind
'' This should be called when the ethernet cable is unplugged.
  if ip_dhcp_state<>DHCP_STATE_DISABLED
    ip_dhcp_state:=DHCP_STATE_UNBOUND
    ip_dhcp_delay:=2       
    ip_dhcp_next~
PRI dhcp_process
'' Called by the main network loop periodicly
  if ip_dhcp_state<>DHCP_STATE_DISABLED AND LONG[RTCADDR] => ip_dhcp_next
    case ip_dhcp_state
      DHCP_STATE_UNBOUND:
        send_dhcp_request
        if ip_dhcp_delay<33
          ip_dhcp_delay*=2
          ip_dhcp_delay++
        ip_dhcp_next:=LONG[RTCADDR]+ip_dhcp_delay      
      DHCP_STATE_BOUND:
        dhcp_rebind
      other:
        dhcp_rebind
   
PRI compose_bootp(op,hops,xid,secs,ciaddr_ptr,yiaddr_ptr,siaddr_ptr,giaddr_ptr)
  nic.wr_frame(op) ' op (bootrequest)
  nic.wr_frame($01) ' htype
  nic.wr_frame($06) ' hlen
  nic.wr_frame(hops) ' hops

  ' xid
  nic.wr_frame_long(xid)
  
  nic.wr_frame_word(secs) ' secs

  nic.wr_frame_pad(2) ' padding ('flags')

  nic.wr_frame_data(ciaddr_ptr,4) 'ciaddr
  nic.wr_frame_data(yiaddr_ptr,4) 'yiaddr
  nic.wr_frame_data(siaddr_ptr,4) 'siaddr
  nic.wr_frame_data(giaddr_ptr,4) 'giaddr

  ' source mac address
  nic.wr_frame_data(@local_macaddr,6)
  nic.wr_frame_pad(10) ' padding

  nic.wr_frame_pad(64) ' sname (empty)

  nic.wr_frame_pad(128) ' file (empty)

PRI send_dhcp_request | i, pkt_len
  nic.start_frame

  ip_dhcp_xid++

  compose_ethernet_header(@bcast_macaddr,@local_macaddr,$0800)
  compose_ip_header(PROT_UDP,@bcast_ipaddr,@any_ipaddr)
  compose_udp_header(DHCP_PORT_SERVER,DHCP_PORT_CLIENT,0)
  compose_bootp(1,0,ip_dhcp_xid,ip_dhcp_delay,@any_ipaddr,@any_ipaddr,@any_ipaddr,@any_ipaddr)
   
  ' DHCP Magic Cookie
  nic.wr_frame($63)
  nic.wr_frame($82)
  nic.wr_frame($53)
  nic.wr_frame($63)

  ' DHCP Message Type
  nic.wr_frame(53)
  nic.wr_frame($01)
  nic.wr_frame(DHCP_TYPE_DISCOVER)

  ' DHCP Parameter Request List
  nic.wr_frame(55)
  nic.wr_frame(5) ' 5 bytes long
  nic.wr_frame(1) ' subnet mask
  nic.wr_frame(3) ' gateway
  nic.wr_frame(6) ' DNS server
  nic.wr_frame(23) ' IP maxhops
  nic.wr_frame(51) ' lease time

  ' DHCP Client-ID
  nic.wr_frame(61)
  nic.wr_frame($07)
  nic.wr_frame($01)
  nic.wr_frame_data(@local_macaddr,6)

  ' End of vendor data
  nic.wr_frame($FF)

  nic.wr_frame_pad(47)

  nic.calc_frame_udp_length
  nic.calc_frame_ip_checksum
  
  'UDP Checksum, but missing the pseudo ip appendage.
  'Not a problem, because in UDP the checksum is optional.
  'nic.calc_frame_udp_checksum
  return nic.send_frame

  
PRI dhcp_offer_response | i, ptr         
  nic.start_frame

  compose_ethernet_header(@bcast_macaddr,@local_macaddr,$0800)
  compose_ip_header(PROT_UDP,@bcast_ipaddr,@any_ipaddr)
  compose_udp_header(DHCP_PORT_SERVER,DHCP_PORT_CLIENT,0)

  ip_dhcp_xid++
  
  compose_bootp($01,byte[pkt+DHCP_hops],ip_dhcp_xid,conv_endianword(word[pkt+DHCP_secs]),@any_ipaddr,@any_ipaddr,@any_ipaddr,@any_ipaddr)
  
  ' DHCP Magic Cookie
  nic.wr_frame($63)
  nic.wr_frame($82)
  nic.wr_frame($53)
  nic.wr_frame($63)

  ' DHCP Message Type
  nic.wr_frame(53)
  nic.wr_frame($01)
  nic.wr_frame(DHCP_TYPE_REQUEST)

  ' DHCP Parameter Request List
  nic.wr_frame(55)
  nic.wr_frame(5) ' 5 bytes long
  nic.wr_frame(1) ' subnet mask
  nic.wr_frame(3) ' gateway
  nic.wr_frame(6) ' DNS server
  nic.wr_frame(23) ' IP maxhops
  nic.wr_frame(51) ' lease time

  ' DHCP Client-ID
  nic.wr_frame(61)
  nic.wr_frame($07)
  nic.wr_frame($01)
  nic.wr_frame_data(@local_macaddr,6)

  if long[pkt+DHCP_yiaddr]
    nic.wr_frame(50)
    nic.wr_frame($04)
    nic.wr_frame_data(pkt+DHCP_yiaddr,4) 'yiaddr
  elseif long[pkt+DHCP_ciaddr]
    nic.wr_frame(50)
    nic.wr_frame($04)
    nic.wr_frame_data(pkt+DHCP_ciaddr,4) 'ciaddr

  ptr:=pkt+DHCP_Options+4
  repeat while byte[ptr]<>$FF
    case byte[ptr]
      54 : ' DHCP server id
        nic.wr_frame(54)
        nic.wr_frame(byte[ptr+1])
        nic.wr_frame_data((ptr+2),byte[ptr+1])
      51 : ' DHCP Lease Time
        nic.wr_frame(51)
        nic.wr_frame(byte[ptr+1])
        nic.wr_frame_data((ptr+2),byte[ptr+1])
      12 : ' Hostname
        nic.wr_frame(12)
        nic.wr_frame(byte[ptr+1])
        nic.wr_frame_data((ptr+2),byte[ptr+1])
    if byte[ptr]
      ptr++
      ptr+=byte[ptr]+1
    else   
      ptr++

  ' End of vendor data
  nic.wr_frame($FF)

  nic.wr_frame_pad(30) ' Padding

  nic.calc_frame_udp_length
  nic.calc_frame_ip_checksum
  
  'UDP Checksum, which is optional. Leaving it out because it isn't finished.
  'nic.calc_frame_udp_checksum

  return nic.send_frame

PRI handle_dhcp | i, ptr, handle, handle_addr, xid, srcport', datain_len

  srcport := BYTE[pkt][UDP_srcport] << 8 + BYTE[pkt][constant(UDP_srcport + 1)]

  if srcport <> DHCP_PORT_SERVER
    ' If the sender isn't sending on the DHCP server port
    ' then we shouldn't be listening.
    return
    
  if ip_dhcp_state=>DHCP_STATE_BOUND
    return
    
  xid := BYTE[pkt][DHCP_xid] << 24 + BYTE[pkt][constant(DHCP_xid + 1)] << 16 + BYTE[pkt][constant(DHCP_xid + 2)] << 8 + BYTE[pkt][constant(DHCP_xid + 3)]

  if xid<>ip_dhcp_xid
    ' Transaction ID doesn't match. Ignore this packet.
    return
   
  if BYTE[pkt][DHCP_options] == $63 and BYTE[pkt][DHCP_options+1] == $82 and BYTE[pkt][DHCP_options+2] == $53 and BYTE[pkt][DHCP_options+3] == $63
    ' this is a DHCP packet! We should send a request.
    ptr:=pkt+DHCP_Options+4
    repeat while byte[ptr]<>$FF
      case byte[ptr]
        53 : ' DHCP message type
          if byte[ptr+2]==DHCP_TYPE_OFFER
            dhcp_offer_response
            ' Lets wait extra time
            ip_dhcp_next:=LONG[RTCADDR]+ip_dhcp_delay      
            ' Had to comment out this return so DHCP would work properly
            ' with internet sharing on the macosx. Not sure what is wrong.
            'return
          elseif byte[ptr+2]==DHCP_TYPE_NAK
            ' Nak'd!
            ip_dhcp_xid++
            return
          elseif byte[ptr+2]<>DHCP_TYPE_ACK
            ' If this isn't an ACK, then ignore it.
            return
      if byte[ptr]
        ptr++
        ptr+=byte[ptr]+1
      else   
        ptr++
   
  ' This is a DHCP/BOOTP reply! And guess what, we have no IP address.
  bytemove(@ip_addr, pkt+DHCP_yiaddr, 4)
   
  ' Hackity hack hack... This is a dirty assumption we are making here...
  ' We only end up using this assumption if this is BOOTP and not DHCP,
  ' so it isn't a big deal.
  if BYTE[pkt][DHCP_giaddr]
    bytemove(@ip_gateway, pkt+DHCP_giaddr, 4)
  else
    bytemove(@ip_gateway, pkt+ip_srcaddr, 4)
    
  ' Set this IP address to expire in an hour.
  ' This will be overridden by DHCP option 51, if set
  ip_dhcp_next := long[RTCADDR] + 3600
   
  if BYTE[pkt][DHCP_options] == $63 and BYTE[pkt][DHCP_options+1] == $82 and BYTE[pkt][DHCP_options+2] == $53 and BYTE[pkt][DHCP_options+3] == $63
    ptr:=pkt+DHCP_Options+4
    repeat while byte[ptr]<>$FF
      case byte[ptr]
        01 : bytemove(@ip_subnet,ptr+2,4)
        03 : bytemove(@ip_gateway,ptr+2,4)
        06 : bytemove(@ip_dns,ptr+2,4)
        54 : bytemove(@ip_dhcp_server_ip,ptr+2,4)
        23 : ' Default IP maxhops
          bytemove(@ip_maxhops,ptr+2,1)
        51 :
          bytemove(@ip_dhcp_next,ptr+2,4) ' lease time
          ip_dhcp_next := conv_endianlong(ip_dhcp_next)
          if ip_dhcp_next == $FFFFFFFF
            ip_dhcp_next := $7FFFFFFF
          else
            ip_dhcp_next>>=1
            ip_dhcp_next+=long[RTCADDR]
        '58 : ' DHCP renewal time
        '  bytemove(@ip_dhcp_expire,ptr+2,4) ' lease time
        '  ip_dhcp_expire := conv_endianlong(ip_dhcp_expire)
        '  ip_dhcp_expire+=long[RTCADDR]
        '  term.str(string("Renewal set to:"))
        '  term.dec(ip_dhcp_expire/(3600))
        '  term.out(13)
        '28 : ' Broadcast address
        '37 : ' Default TCP TTL
        '42 : ' NTP Servers
      if byte[ptr]
        ptr++
        ptr+=byte[ptr]+1
      else   
        ptr++

  ip_dhcp_state:=DHCP_STATE_BOUND
  bytemove(@ip_dhcp_server_mac, pkt+enetpacketSrc0, 6)
   
  settings.setData(settings#NET_IPv4_ADDR,@ip_addr,4)
  settings.setData(settings#NET_IPv4_MASK,@ip_subnet,4)
  settings.setData(settings#NET_IPv4_GATE,@ip_gateway,4)
  settings.setData(settings#NET_IPv4_DNS,@ip_dns,4)

PRI has_valid_ip_addr
  return long[@ip_addr] AND ip_dhcp_state=>DHCP_STATE_BOUND