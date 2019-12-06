{{
  Ethernet TCP/IP Socket Driver
  $Id$
  ----------------------------- 
  (c) 2007 Harrison Pham.

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
  version = 1.3
  apiversion = 3

DAT
        ' ** This is the ethernet MAC address, it is critical that you change this
        '    if you have more than one device using this code on a local network.
        ' ** If you plan on commercial deployment, you must purchase MAC address
        '    groups from IEEE or another organization.
        local_macaddr   byte    $10, $00, $00, $00, $00, $01
         
        ' ** The following are tcp stack ip addresses.  It is critical that the
        '    device IP address is unique and on the same subnet when used on a
        '    local network.
                        long    0                       ' long alignment for addresses, don't remove
        ip_addr         byte    192, 168, 1, 4            ' device's ip address
        ip_subnet       byte    255, 255, 255, 0        ' network subnet
        ip_gateway      byte    192, 168, 1, 1          ' network gateway (router)
        ip_dns          byte    192,168,1,1          ' network dns        

OBJ
  nic : "driver_enc28j60"

  'ser : "SerialMirror"
  'stk : "Stack Length"

VAR
  long stack[128]     ' stack for new cog (currently ~74 longs, using 128 for future expansion)                      

DAT             
  ' Global variables (accessable between cogs)
  cog                   long 0                       
  
  pkt                   long 0                  ' memory address of packet start
  pkt_count             byte 0                  ' packet count

  pkt_id                long 0                  ' packet fragmentation id
  pkt_isn               long 0                  ' packet initial sequence number

'  sFlags                byte 0                  ' stack flags (arp response received, data to send, etc)

'  local_macaddr         byte 0,0,0,0,0,0        ' local mac address (device mac)
'  remote_macaddr        byte 0,0,0,0,0,0        ' remote host mac address

  ' Statistic variables (don't really need these, but it's only 4 longs, so what the heck..)
'  count_ping            long 0
'  count_arp             long 0
'  count_tcp             long 0
'  count_udp             long 0
  

PUB start(cs, sck, si, so, int, xtalout, macptr, ipconfigptr) : okay
'' Call this to launch the Telnet driver
'' Only call this once, otherwise you will get conflicts
'' macptr      = HUB memory pointer (address) to 6 contiguous mac address bytes
'' ipconfigptr = HUB memory pointer (address) to ip configuration block (20 bytes)
''               Must be in order: ip_addr. ip_subnet, ip_gateway, ip_dns

  stop
  'stk.Init(@stack, 128)
  cog := cognew(engine(cs, sck, si, so, int, xtalout, macptr, ipconfigptr), @stack) + 1

PUB stop
'' Stop the driver

  if cog
    nic.stop                    ' stop nic driver (kills spi engine)
    cogstop(cog~ - 1)           ' stop the tcp engine

PRI engine(cs, sck, si, so, int, xtalout, macptr, ipconfigptr) | i

  ' Start the ENC28J60 driver in a new cog
  if macptr == -1
    nic.start(cs, sck, si, so, int, xtalout, @local_macaddr)                    ' init the nic
  else
    nic.start(cs, sck, si, so, int, xtalout, macptr)                            ' init the nic

  if ipconfigptr <> -1                                                          ' init ip configuration
    bytemove(@ip_addr, ipconfigptr, 16)
    
  bytemove(@local_macaddr, nic.get_mac_pointer, 6)                              ' get the mac address

  pkt := nic.get_packetpointer

  i := 0
  nic.banksel(nic#EPKTCNT)      ' select packet count bank
  repeat
    pkt_count := nic.rd_cntlreg(nic#EPKTCNT)
    if pkt_count > 0
      service_packet            ' handle packet
      nic.banksel(nic#EPKTCNT)  ' re-select the packet count bank

    ++i
    if i > 10
      ' perform send tick (occurs every 10 cycles, since incoming packets more important)
      tick_tcpsend
      i := 0
      nic.banksel(nic#EPKTCNT)  ' re-select the packet count bank

PRI service_packet

  ' lets process this frame
  nic.get_frame

  ' check for arp packet type (highest priority obviously)
  if BYTE[pkt][enetpacketType0] == $08 AND BYTE[pkt][enetpacketType1] == $06
    if BYTE[pkt][constant(arp_hwtype + 1)] == $01 AND BYTE[pkt][arp_prtype] == $08 AND BYTE[pkt][constant(arp_prtype + 1)] == $00 AND BYTE[pkt][arp_hwlen] == $06 AND BYTE[pkt][arp_prlen] == $04
      if BYTE[pkt][arp_tipaddr] == ip_addr[0] AND BYTE[pkt][constant(arp_tipaddr + 1)] == ip_addr[1] AND BYTE[pkt][constant(arp_tipaddr + 2)] == ip_addr[2] AND BYTE[pkt][constant(arp_tipaddr + 3)] == ip_addr[3]
        case BYTE[pkt][constant(arp_op + 1)]
          $01 : handle_arp
          $02 : handle_arpreply
        '++count_arp
  else
    if BYTE[pkt][enetpacketType0] == $08 AND BYTE[pkt][enetpacketType1] == $00
      if BYTE[pkt][ip_destaddr] == ip_addr[0] AND BYTE[pkt][constant(ip_destaddr + 1)] == ip_addr[1] AND BYTE[pkt][constant(ip_destaddr + 2)] == ip_addr[2] AND BYTE[pkt][constant(ip_destaddr + 3)] == ip_addr[3]
        case BYTE[pkt][ip_proto]
          'PROT_ICMP : 'handle_ping
                      'ser.str(stk.GetLength(0, 0))
                      '++count_ping
          PROT_TCP :  \handle_tcp                       ' handles abort out of tcp handlers (no socket found)
                      '++count_tcp
          'PROT_UDP :  ++count_udp

' *******************************
' ** Protocol Receive Handlers **
' *******************************
PRI handle_arp | i
  nic.start_frame

  ' destination mac address
  repeat i from 0 to 5
    nic.wr_frame(BYTE[pkt][enetpacketSrc0 + i])

  ' source mac address
  repeat i from 0 to 5
    nic.wr_frame(local_macaddr[i])

  nic.wr_frame($08)             ' arp packet
  nic.wr_frame($06)

  nic.wr_frame($00)             ' 10mb ethernet
  nic.wr_frame($01)

  nic.wr_frame($08)             ' ip proto
  nic.wr_frame($00)

  nic.wr_frame($06)             ' mac addr len
  nic.wr_frame($04)             ' proto addr len

  nic.wr_frame($00)             ' arp reply
  nic.wr_frame($02)

  ' write ethernet module mac address
  repeat i from 0 to 5
    nic.wr_frame(local_macaddr[i])

  ' write ethernet module ip address
  repeat i from 0 to 3
    nic.wr_frame(ip_addr[i])

  ' write remote mac address
  repeat i from 0 to 5
    nic.wr_frame(BYTE[pkt][enetpacketSrc0 + i])

  ' write remote ip address
  repeat i from 0 to 3
    nic.wr_frame(BYTE[pkt][arp_sipaddr + i])

  return nic.send_frame

PRI handle_arpreply | handle, handle_addr, ip, found
  ' Gets arp reply if it is a response to an ip we have

  ip := (BYTE[pkt][arp_sipaddr] << 24) + (BYTE[pkt][constant(arp_sipaddr + 1)] << 16) + (BYTE[pkt][constant(arp_sipaddr + 2)] << 8) + (BYTE[pkt][constant(arp_sipaddr + 3)])

  found := false
  if ip == conv_endianlong(LONG[@ip_gateway])
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
        if LONG[handle_addr + sSrcIp] == conv_endianlong(ip)
          found := true
          quit
          
  if found
    bytemove(handle_addr + sSrcMac, pkt + arp_shaddr, 6)
    BYTE[handle_addr + sConState] := SCONNECTING

'PRI handle_ping
  ' Not implemented yet (save on space!)
  
PRI handle_tcp | i, ptr, handle, handle_addr, srcip, dstip, dstport, srcport, datain_len
  ' Handles incoming TCP packets

  srcip := BYTE[pkt][ip_srcaddr] << 24 + BYTE[pkt][constant(ip_srcaddr + 1)] << 16 + BYTE[pkt][constant(ip_srcaddr + 2)] << 8 + BYTE[pkt][constant(ip_srcaddr + 3)]
  dstport := BYTE[pkt][TCP_destport] << 8 + BYTE[pkt][constant(TCP_destport + 1)]
  srcport := BYTE[pkt][TCP_srcport] << 8 + BYTE[pkt][constant(TCP_srcport + 1)]

  handle_addr := find_socket(srcip, dstport, srcport)   ' if no sockets avail, it will abort out of this function
  handle := BYTE[handle_addr + sSockIndex]

  ' at this point we assume we have an active socket, or a socket available to be used
  datain_len := ((BYTE[pkt][ip_pktlen] << 8) + BYTE[pkt][constant(ip_pktlen + 1)]) - ((BYTE[pkt][ip_vers_len] & $0F) * 4) - (((BYTE[pkt][TCP_hdrflags] & $F0) >> 4) * 4)

  if (BYTE[handle_addr + sConState] <> SLISTEN) AND (BYTE[pkt][constant(TCP_hdrflags + 1)] & TCP_ACK) > 0 AND datain_len > 0
    ' ACK, without SYN, with data

    ' set socket state, established session
    BYTE[handle_addr + sConState] := SESTABLISHED
    
    ' copy data to buffer
    repeat i from 0 to datain_len - 1
      if (BYTE[@rx_tail][handle] <> (BYTE[@rx_head][handle] + 1) & buffer_mask)
        ptr := @rx_buffer + (handle * buffer_length)  
        byte[ptr][BYTE[@rx_head][handle]] := BYTE[pkt][TCP_data + i]
        BYTE[@rx_head][handle] := (BYTE[@rx_head][handle] + 1) & buffer_mask
      else
        quit  ' out of space!
     
    ' recalculate ack number
    LONG[handle_addr + sMyAckNum] := conv_endianlong(conv_endianlong(LONG[handle_addr + sMyAckNum]) + datain_len)

    ' ACK response
    build_ipheaderskeleton(handle_addr)
    build_tcpskeleton(handle_addr, TCP_ACK)
    send_tcpfinal(handle_addr, 0)

  elseif (BYTE[handle_addr + sConState] == SSYNSENT) AND (BYTE[pkt][constant(TCP_hdrflags + 1)] & TCP_SYN) > 0 AND (BYTE[pkt][constant(TCP_hdrflags + 1)] & TCP_ACK) > 0
    ' We got a server response, so we ACK it

    bytemove(handle_addr + sMySeqNum, pkt + TCP_acknum, 4)
    bytemove(handle_addr + sMyAckNum, pkt + TCP_seqnum, 4)
    
    LONG[handle_addr + sMyAckNum] := conv_endianlong(conv_endianlong(LONG[handle_addr + sMyAckNum]) + 1)

    ' ACK response
    build_ipheaderskeleton(handle_addr)
    build_tcpskeleton(handle_addr, TCP_ACK)
    send_tcpfinal(handle_addr, 0)

    ' set socket state, established session
    BYTE[handle_addr + sConState] := SESTABLISHED
  
  elseif (BYTE[handle_addr + sConState] == SLISTEN) AND (BYTE[pkt][constant(TCP_hdrflags + 1)] & TCP_SYN) > 0
    ' Reply to SYN with SYN + ACK

    ' copy mac address so we don't have to keep an ARP table
    bytemove(handle_addr + sSrcMac, pkt + enetpacketSrc0, 6)

    ' copy ip, port data
    bytemove(handle_addr + sSrcIp, pkt + ip_srcaddr, 4)
    bytemove(handle_addr + sSrcPort, pkt + TCP_srcport, 2)
    bytemove(handle_addr + sDstPort, pkt + TCP_destport, 2)

    ' get updated ack numbers
    bytemove(handle_addr + sMyAckNum, pkt + TCP_seqnum, 4)

    LONG[handle_addr + sMyAckNum] := conv_endianlong(conv_endianlong(LONG[handle_addr + sMyAckNum]) + 1)
    LONG[handle_addr + sMySeqNum] := conv_endianlong(++pkt_isn)               ' Initial seq num (random)

    build_ipheaderskeleton(handle_addr)
    build_tcpskeleton(handle_addr, constant(TCP_SYN | TCP_ACK))
    send_tcpfinal(handle_addr, 0)      

    ' incremement the sequence number for the next packet (it will be for an established connection)                                          
    LONG[handle_addr + sMySeqNum] := conv_endianlong(conv_endianlong(LONG[handle_addr + sMySeqNum]) + 1)

    ' set socket state, waiting for establish
    BYTE[handle_addr + sConState] := SSYNSENT
   
  elseif (BYTE[handle_addr + sConState] <> SLISTEN) AND (BYTE[pkt][constant(TCP_hdrflags + 1)] & TCP_FIN) > 0
    ' Reply to FIN with ACK

    ' get updated sequence and ack numbers (gaurantee we have correct ones to kill connection with)
    bytemove(handle_addr + sMySeqNum, pkt + TCP_acknum, 4)
    bytemove(handle_addr + sMyAckNum, pkt + TCP_seqnum, 4)
                                              
    LONG[handle_addr + sMyAckNum] := conv_endianlong(conv_endianlong(LONG[handle_addr + sMyAckNum]) + 1)

    build_ipheaderskeleton(handle_addr)
    build_tcpskeleton(handle_addr, TCP_RST)
    send_tcpfinal(handle_addr, 0)

    ' set socket state, now free
    BYTE[handle_addr + sConState] := SCLOSED
    
  elseif (BYTE[handle_addr + sConState] == SSYNSENT) AND (BYTE[pkt][constant(TCP_hdrflags + 1)] & TCP_ACK) > 0
    ' if just an ack, and we sent a syn before, then it's established
    ' this just gives us the ability to send on connect
    BYTE[handle_addr + sConState] := SESTABLISHED
  
  elseif (BYTE[pkt][constant(TCP_hdrflags + 1)] & TCP_RST) > 0
    ' Reset, reset states
    BYTE[handle_addr + sConState] := SCLOSED

PRI build_ipheaderskeleton(handle_addr) | hdrlen, hdr_chksum
  
  bytemove(pkt + ip_destaddr, handle_addr + sSrcIp, 4)                          ' Set destination address

  bytemove(pkt + ip_srcaddr, @ip_addr, 4)                                       ' Set source address

  bytemove(pkt + enetpacketDest0, handle_addr + sSrcMac, 6)                     ' Set destination mac address

  bytemove(pkt + enetpacketSrc0, @local_macaddr, 6)                             ' Set source mac address

  BYTE[pkt][enetpacketType0] := $08
  BYTE[pkt][constant(enetpacketType0 + 1)] := $00
  
  BYTE[pkt][ip_vers_len] := $45
  BYTE[pkt][ip_tos] := $00

  ++pkt_id
  
  BYTE[pkt][ip_id] := pkt_id >> 8                                               ' Used for fragmentation
  BYTE[pkt][constant(ip_id + 1)] := pkt_id

  BYTE[pkt][ip_frag_offset] := $40                                              ' Don't fragment
  BYTE[pkt][constant(ip_frag_offset + 1)] := 0
  
  BYTE[pkt][ip_ttl] := $20                                                      ' TTL = 128

  BYTE[pkt][ip_proto] := $06                                                    ' TCP protocol

PRI build_tcpskeleton(handle_addr, flags)

  bytemove(pkt + TCP_srcport, handle_addr + sDstPort, 2)                        ' Source port
  bytemove(pkt + TCP_destport, handle_addr + sSrcPort, 2)                       ' Destination port

  bytemove(pkt + TCP_seqnum, handle_addr + sMySeqNum, 4)                        ' Seq Num
  bytemove(pkt + TCP_acknum, handle_addr + sMyAckNum, 4)                        ' Ack Num

  BYTE[pkt][TCP_hdrflags] := $50                                                ' Header length
  
  BYTE[pkt][constant(TCP_hdrflags + 1)] := flags                                ' TCP state flags

  BYTE[pkt][TCP_window] := constant((buffer_length & $FF00) >> 8)               ' Window size (max data that can be received before ACK must be sent)
  BYTE[pkt][constant(TCP_window + 1)] := constant(buffer_length & $FF)          '  we use our buffer_length to ensure our buffer won't get overloaded
                                                                                '  may cause slowness so some people may want to use $FFFF on high latency networks
  
PRI send_tcpfinal(handle_addr, datalen) | i, tcplen, hdrlen, hdr_chksum

  LONG[handle_addr + sMySeqNum] := conv_endianlong(conv_endianlong(LONG[handle_addr + sMySeqNum]) + datalen)               ' update running sequence number

  tcplen := 40 + datalen                                                        ' real length = data + headers

  BYTE[pkt][ip_pktlen] := tcplen >> 8
  BYTE[pkt][constant(ip_pktlen + 1)] := tcplen

  ' calc ip header checksum
  BYTE[pkt][ip_hdr_cksum] := $00
  BYTE[pkt][constant(ip_hdr_cksum + 1)] := $00
  hdrlen := (BYTE[pkt][ip_vers_len] & $0F) * 4
  hdr_chksum := calc_chksum(@BYTE[pkt][ip_vers_len], hdrlen)  
  BYTE[pkt][ip_hdr_cksum] := hdr_chksum >> 8
  BYTE[pkt][constant(ip_hdr_cksum + 1)] := hdr_chksum

  ' calc checksum
  BYTE[pkt][TCP_cksum] := $00
  BYTE[pkt][constant(TCP_cksum + 1)] := $00
  hdr_chksum := calc_chksumhalf(@BYTE[pkt][ip_srcaddr], 8)
  hdr_chksum += BYTE[pkt][ip_proto]
  i := tcplen - ((BYTE[pkt][ip_vers_len] & $0F) * 4)
  hdr_chksum += i
  hdr_chksum += calc_chksumhalf(@BYTE[pkt][TCP_srcport], i)
  hdr_chksum := calc_chksumfinal(hdr_chksum)
  BYTE[pkt][TCP_cksum] := hdr_chksum >> 8
  BYTE[pkt][constant(TCP_cksum + 1)] := hdr_chksum

  tcplen += 14
  if tcplen < 60
    tcplen := 60

  ' protect from buffer overrun
  if tcplen => nic#TX_BUFFER_SIZE
    return
    
  ' send the packet
  nic.start_frame
  
  repeat i from 0 to tcplen - 1
    nic.wr_frame(BYTE[pkt][i])

  ' send the packet
  nic.send_frame

PRI find_socket(srcip, dstport, srcport) | handle, free_handle, handle_addr
  ' Search for socket, matches ip address, port states
  ' Returns handle address (start memory location of socket)
  '  If no matches, will abort with -1
  '  If supplied with srcip = 0 then will return free unused handle, aborts with -1 if none avail
  
  free_handle := -1
  repeat handle from 0 to constant(sNumSockets - 1)
    handle_addr := @sSockets + (sSocketBytes * handle)   ' generate handle address (mapped to memory)
    if BYTE[handle_addr + sConState] <> SCLOSED
      if (LONG[handle_addr + sSrcIp] == 0) OR (LONG[handle_addr + sSrcIp] == conv_endianlong(srcip))
        ' ip match, ip socket srcip = 0, then will try to match dst port (find listening socket)
          if (WORD[handle_addr + sDstPort] == conv_endianword(dstport)) AND (WORD[handle_addr + sSrcPort] == 0 OR WORD[handle_addr + sSrcPort] == conv_endianword(srcport))
            ' port match, will match port, if srcport = 0 then will match dstport only (find listening socket)
            return handle_addr
    elseif srcip == 0
      ' we only return a free handle if we are searching for srcip = 0 (just looking for free handle)
      free_handle := handle_addr     ' we found a free handle, may need this later
      
  if free_handle <> -1
    return free_handle 
  else
    abort(-1)

' ******************************
' ** Transmit Buffer Handlers **
' ******************************
PRI tick_tcpsend | i, ptr, handle, handle_addr
  ' Check buffers for data to send (called in main loop)
  
  'if sFlags & SEND_WAITING == 0
  '  return

  repeat handle from 0 to constant(sNumSockets - 1)
    handle_addr := @sSockets + (sSocketBytes * handle)
    i := BYTE[handle_addr + sConState]
    if i == SESTABLISHED
      ' Check to see if we have data to send, if we do, send it
      
      i := 0
      repeat
        if BYTE[@tx_tail][handle] <> BYTE[@tx_head][handle]
          ptr := @tx_buffer + (handle * buffer_length)
          BYTE[pkt][TCP_data + i] := byte[ptr][BYTE[@tx_tail][handle]]
          BYTE[@tx_tail][handle] := (BYTE[@tx_tail][handle] + 1) & buffer_mask
          ++i
        else
          quit  ' no data left

      if i > 0 
        build_ipheaderskeleton(handle_addr)
        build_tcpskeleton(handle_addr, constant(TCP_ACK | TCP_PSH))
        send_tcpfinal(handle_addr, i)
        
    elseif i == SCLOSING
      ' Force connection close, I'll just RST it (bad I know, but it ensures closing...)
                                         
      LONG[handle_addr + sMyAckNum] := conv_endianlong(conv_endianlong(LONG[handle_addr + sMyAckNum]) + 1)
       
      build_ipheaderskeleton(handle_addr)
      build_tcpskeleton(handle_addr, TCP_RST)
      send_tcpfinal(handle_addr, 0)

      ' set socket state, now free
      BYTE[handle_addr + sConState] := SCLOSED

    elseif i == SCONNECTINGARP1
      ' We need to send an arp request

      arp_request_checkgateway(handle_addr)

    elseif i == SCONNECTING
      ' Yea! We got an arp response previously, so now we can send the SYN

      LONG[handle_addr + sMySeqNum] := conv_endianlong(++pkt_isn)        
      LONG[handle_addr + sMyAckNum] := 0
       
      build_ipheaderskeleton(handle_addr)
      build_tcpskeleton(handle_addr, TCP_SYN)
      send_tcpfinal(handle_addr, 0)

      BYTE[handle_addr + sConState] := SSYNSENT
      

  'sFlags &= !SEND_WAITING

PRI arp_request_checkgateway(handle_addr) | ip_ptr

  ip_ptr := handle_addr + sSrcIp
  
  if (BYTE[ip_ptr] & ip_subnet[0]) == (ip_addr[0] & ip_subnet[0]) AND (BYTE[ip_ptr + 1] & ip_subnet[1]) == (ip_addr[1] & ip_subnet[1]) AND (BYTE[ip_ptr + 2] & ip_subnet[2]) == (ip_addr[2] & ip_subnet[2]) AND (BYTE[ip_ptr + 3] & ip_subnet[3]) == (ip_addr[3] & ip_subnet[3])   
    arp_request(BYTE[ip_ptr], BYTE[ip_ptr + 1], BYTE[ip_ptr + 2], BYTE[ip_ptr + 3])
    BYTE[handle_addr + sConState] := SCONNECTINGARP2
  else
    arp_request(ip_gateway[0], ip_gateway[1], ip_gateway[2], ip_gateway[3])
    BYTE[handle_addr + sConState] := SCONNECTINGARP2G   
  
PRI arp_request(ip1, ip2, ip3, ip4) | i
  nic.start_frame

  ' destination mac address (broadcast mac)
  repeat i from 0 to 5
    nic.wr_frame($FF)

  ' source mac address (this device)
  repeat i from 0 to 5
    nic.wr_frame(local_macaddr[i])

  nic.wr_frame($08)             ' arp packet
  nic.wr_frame($06)

  nic.wr_frame($00)             ' 10mb ethernet
  nic.wr_frame($01)

  nic.wr_frame($08)             ' ip proto
  nic.wr_frame($00)

  nic.wr_frame($06)             ' mac addr len
  nic.wr_frame($04)             ' proto addr len

  nic.wr_frame($00)             ' arp request
  nic.wr_frame($01)

  ' source mac address (this device)
  repeat i from 0 to 5
    nic.wr_frame(local_macaddr[i])

  ' source ip address (this device)
  repeat i from 0 to 3
    nic.wr_frame(ip_addr[i])

  ' unknown mac address area
  repeat i from 0 to 5
    nic.wr_frame($00)

  ' figure out if we need router arp request or host arp request
  ' this means some subnet masking

  ' dest ip address
  nic.wr_frame(ip1)
  nic.wr_frame(ip2)
  nic.wr_frame(ip3)
  nic.wr_frame(ip4)

  ' send the request
  return nic.send_frame
  
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
PUB listen(port) | handle_addr
'' Sets up a socket for listening on a port
'' Returns handle if available, -1 if none available
'' Nonblocking

  ' just find any avail closed socket
  handle_addr := \find_socket(0, 0, 0)

  if handle_addr < 0
    return -1               

  WORD[handle_addr + sSrcPort] := 0                     ' no source port yet
  WORD[handle_addr + sDstPort] := conv_endianword(port) ' we do have a dest port though

  ' it's now listening
  BYTE[handle_addr + sConState] := SLISTEN

  return BYTE[handle_addr + sSockIndex] 

PUB connect(ip1, ip2, ip3, ip4, remoteport, localport) | handle_addr
'' Connect to remote host
'' Returns handle to new socket, -1 if no socket available
'' Nonblocking

  ' just find any avail closed socket
  handle_addr := \find_socket(0, 0, 0)

  if handle_addr < 0
    return -1

  ' copy in ip, port data (with respect to the remote host, since we use same code as server)
  LONG[handle_addr + sSrcIp] := conv_endianlong((ip1 << 24) + (ip2 << 16) + (ip3 << 8) + ip4)
  WORD[handle_addr + sSrcPort] := conv_endianword(remoteport)
  WORD[handle_addr + sDstPort] := conv_endianword(localport)

  BYTE[handle_addr + sConState] := SCONNECTINGARP1
  
  return BYTE[handle_addr + sSockIndex]

PUB close(handle) | handle_addr
'' Closes a connection
  handle_addr := @sSockets + (sSocketBytes * handle)
  if isConnected(handle)
    BYTE[handle_addr + sConState] := SCLOSING
  else
    BYTE[handle_addr + sConState] := SCLOSED

PUB isConnected(handle) | handle_addr
'' Returns true if the socket is connected, false otherwise

  handle_addr := @sSockets + (sSocketBytes * handle)
  if BYTE[handle_addr + sConState] == SESTABLISHED
    return true
  else
    return false

PUB isValidHandle(handle) | handle_addr
'' Checks to see if the handle is valid, handles will become invalid once they are used
'' In other words, a closed listening socket is now invalid, etc

  handle_addr := @sSockets + (sSocketBytes * handle)

  return BYTE[handle_addr + sConState] <> SCLOSED

PUB readByteNonBlocking(handle) : rxbyte | ptr
'' Read a byte from the specified socket
'' Will not block (returns -1 if no byte avail)

  rxbyte := -1
  if BYTE[@rx_tail][handle] <> BYTE[@rx_head][handle]
    ptr := @rx_buffer + (handle * buffer_length)
    rxbyte := byte[ptr][BYTE[@rx_tail][handle]]
    BYTE[@rx_tail][handle] := (BYTE[@rx_tail][handle] + 1) & buffer_mask
    
PUB readByte(handle) : rxbyte | ptr
'' Read a byte from the specified socket
'' Will block until a byte is received

  repeat while (rxbyte := readByteNonBlocking(handle)) < 0

PUB writeByteNonBlocking(handle, txbyte) | ptr
'' Writes a byte to the specified socket
'' Will not block (returns -1 if no buffer space available)

  ifnot (BYTE[@tx_tail][handle] <> (BYTE[@tx_head][handle] + 1) & buffer_mask)
    return -1

  ptr := @tx_buffer + (handle * buffer_length)  
  byte[ptr][BYTE[@tx_head][handle]] := txbyte
  BYTE[@tx_head][handle] := (BYTE[@tx_head][handle] + 1) & buffer_mask

  return txbyte

PUB writeByte(handle, txbyte)
'' Write a byte to the specified socket
'' Will block until space is available for byte to be sent 

  repeat while writeByteNonBlocking(handle, txbyte) < 0

PUB resetBuffers(handle)
'' Resets send/receive buffers for the specified socket

  BYTE[@rx_tail][handle] := BYTE[@rx_head][handle]
  BYTE[@tx_head][handle] := BYTE[@tx_tail][handle]    

CON
' The following is an 'array' that represents all the socket handle data (with respect to the remote host)
' longs first, then words, then bytes (for alignment)
'
'         4 bytes - (1 long ) my sequence number
'         4 bytes - (1 long ) my acknowledgement number
'         4 bytes - (1 long ) src ip
'         2 bytes - (1 word ) src port
'         2 bytes - (1 word ) dst port
'         1 byte  - (1 byte ) conn state
'         6 bytes - (6 bytes) src mac address
'         1 byte  - (1 byte ) handle index
' total: 24 bytes

  sSocketBytes  = 24      ' MUST BE MULTIPLE OF 4 (long aligned) set this to total socket state data size
  
  sNumSockets = 2         ' number of sockets

' Offsets for socket status arrays
  sMySeqNum = 0
  sMyAckNum = 4
  sSrcIp = 8
  sSrcPort = 12
  sDstPort = 14
  sConState = 16
  sSrcMac = 17
  sSockIndex = 23

' Socket states (user should never touch these)
  SCLOSED = 0                   ' closed, handle not used
  SLISTEN = 1                   ' listening, in server mode
  SSYNSENT = 2                  ' SYN sent, connection is opening stage 1
  SESTABLISHED = 3              ' established connection (either SYN+ACK, or ACK+Data)
  SCLOSING = 4                  ' connection is being forced closed by code
  SCONNECTINGARP1 = 5           ' connecting, next step: send arp request
  SCONNECTINGARP2 = 6           ' connecting, next step: arp request sent, waiting for response
  SCONNECTINGARP2G = 7          ' connecting, next step: arp request sent, waiting for response [GATEWAY REQUEST]
  SCONNECTING = 8               ' connecting, next step: got mac address, send SYN

DAT
              long      0       ' long align the socket state data
sSockets      byte      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0           ' [0] socket 1 (last byte denotes handle index)
              byte      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1           ' [1] socket 2 (last byte denotes handle index)

CON
' Circular Buffer constants
  buffer_length = 128
  buffer_mask   = buffer_length - 1

DAT
' Circular buffer variables (one long per socket)
'             Socket:   [           1            ] [           2            ]
rx_head       byte      0                        , buffer_length
rx_tail       byte      0                        , buffer_length
tx_head       byte      0                        , buffer_length
tx_tail       byte      0                        , buffer_length

tx_buffer     long      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0     ' socket 1
              long      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0     ' 128 bytes

              long      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0     ' socket 2
              long      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0     ' 128 bytes

rx_buffer     long      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0     ' socket 1
              long      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0     ' 128 bytes

              long      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0     ' socket 2
              long      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0     ' 128 bytes


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