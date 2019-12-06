{{
DCC Driver 
  This object is a packet driver that operates according to NMRA (National Model
  Railroad Assocation) standards.
  The purpose of this driver is to accept packets, one at a time, and output them
  on a single pin according to the DCC packet formatting standards
  External circuitry is required to convert the single pin to a bipolar signal that can
  drive a booster connected to the model railroad track.
}}
'
' A higher level object (host) is required to format the content of the packets and pass
' them to this driver one at a time.  This host object will either receive the packets
' from a PC via a serial link, or generate them itself based on inputs from a keyboard,
' analog control, or other logic of some type.
'
' This object must be passed the address of a buffer consisting of approximately 10 bytes
' (length depending on the size of the longest packet to be transmitted). This buffer
' must be organized as follows:
'
' Byte 0: Packet Length - contains the number of bytes to be transmitted
' Byte 1: Preamble Count - contains the number of "1" BITS to be transmitted during
'         the preamble portion of the packet
' Bytes 2-n: The actual packet to be sent, including the check byte, minimum length=3
'            (2 data bytes and 1 check byte)
'
' Logic: During startup, a cog is started that is dedicated to output of the packets.
'        After initialization the DCC driver will output "1" bits continuously,
'        as long as the packet length byte contains 0. When a non-zero value is found
'        in the length byte, the entire buffer is copied to a second buffer, and
'        the primary buffer is cleared.  This can be used as a signal to the host
'        object to build or obtain the next packet to be sent.  The last step
'        the host object should perform is to insert the length into the buffer, as this
'        will signal the driver that the packet is ready to send.
'
'        Since a DCC packet takes at least 5 milliseconds to send, this amount of
'        time is available for the host to prepare the next packet and insert it into
'        the buffer, allowing the driver to send packets continuously with no delays
'        between packets.
' Bit Format: According to the DCC standards, a "1" bit consists of a full "cycle" of
'        output (high and low) each of which is exactly 58 microseconds in length.
'        The total time to output a "1" bit is therefore 116 microseconds. A "0" bit
'        consists of a full cycle with a minimum length of 100 탎ec each, or a total
'        time of 200 탎ec.
' Preamble: Each packet must be preceeded by a preamble consisting of at least 14 "1"
'        bits. This number may be increased if necessary.  Some newer DCC standards
'        require a longer time between packets, which is created by increasing the
'        number of preamble bits. Since one byte is used to hold this count, the
'        maximum allowed by this driver is 255.  However, if another packet is not
'        placed in the buffer, the driver will continue to send "1" bits until a
'        packet is found or the driver is halted.
' Data Bytes: Each data byte is preceded by a "0" bit that serves as a "start" bit.
'        Following the start bit, the 8 data bits of the byte are transmitted, most
'        significant bit first.  The last byte transmitted is the check byte, but from
'        the point of view of this driver it is just another data byte. After the last
'        data byte, at least one '1' bit must be tranmitted. If another packet is
'        waiting at this time, the cycle begins again with the preamble, otherwise, "1"
'        bits are sent until another packet is found in the buffer.
' Outputs: The DCC output of the driver is on a single pin (DCC_Pin)
'        For scoping purposes, a sync pulse is output at the start of each packet.
'        on another pin (Strobe_Pin).  Any available pins may be used.  If no strobe
'        is desired, set Strobe_Pin to -1.

con
  _CLKMODE = XTAL1+PLL16X      '16X CLOCK MULTIPLIER
  _XINFREQ = 5_000_000         '5 MHZ CRYSTAL = 80 MHZ TOTAL
  OneBit = 58*80  ' delay for half cycle of a one bit (58 탎ec)
  ZeroBit = 100*80 'delay for half cycle of zero bit (100 탎ec) 
var
  long Stack[30]    'stack space for the new cog
  byte Buffer2[10]  'secondary buffer
  byte cog          'holds the cog number
  long time         'holds the reference time for output pulses
  long BuffPtr      'points to next byte to transmit
  byte temp         'holds temp zero for test
  
   
Pub Start(Buff_Addr, DCC_Pin, Strobe_Pin): Success  {{Starts a cog running the driver}}
    Stop   'in case the cog is already running
    Success:=(cog:=cognew(DCCPacket(Buff_Addr, DCC_Pin, Strobe_Pin),@Stack) +1)
    
Pub  Stop   {{Stops the driver cog}}
    if cog  'is active
      cogstop(cog~ - 1)
      
Pri  DCCPacket(Buff, Pin, Strobe)    {{Waits for a packet and then sends it}}
    DIRA[Pin]:=1          'set DCC pin to output
    if Strobe>-1          'if strobe active
      DIRA[Strobe]:=1     'set strobe to output
    time:=cnt 'get the starting clock time
    repeat     'loop continuously until stopped
      repeat while byte[Buff][0]==0 'loop as long as buffer is empty
        waitcnt(time += OneBit) 'delay for half cycle time - produces continuous "1" bits
        OUTA[Pin]:=1     'flip bit every 58 탎ec
        waitcnt(time += OneBit) 'wait half one bit
        OUTA[Pin]:=0
     ' GET HERE ONLY WHEN FIRST BYTE OF BUFFER <> 0
      ByteMove(@Buffer2, Buff[0], 10) 'copy the buffer
      waitcnt(time += OneBit) 'wait one half bit
      OUTA[Pin]:=1 'set on
      ByteFill(Buff,0,1) 'clear the first byte of the buffer - indicate packet has be copied
      OUTA[Strobe]:=1 'trigger the strobe
      waitcnt(time += OneBit) 'Wait another half bit
      OUTA[Pin]:=0
      repeat Buffer2[1]-1 'repeat for count = preamble length (one of the bits was already sent, so subtract one)
        waitcnt(time += OneBit) 'delay for half cycle time
        OUTA[Pin]:=1     'flip bit
        waitcnt(time += OneBit)
        OUTA[Pin]:=0
      
      OUTA[Strobe]:=0 'clear the strobe when preamble finished  
      repeat BuffPtr from 2 to Buffer2[0]+1 'repeat for each byte to be output (byte 0 contains packet length)
        'output a start bit for the byte
        waitcnt(time += ZeroBit) 'delay for half cycle time   
        OUTA[Pin]:=1     'flip bit                                 
        waitcnt(time += ZeroBit) 'delay for half cycle time
        OUTA[Pin]:=0     'flop bit
        temp:=Buffer2[BuffPtr] 'get a byte from the buffer
        repeat 8     'output the eight bits of this byte, high order first
          case temp & 128'get high order bit
            0:   'bit is a zero
               waitcnt(time += ZeroBit)
               OUTA[Pin]:=1 'flip bit
               waitcnt(time += ZeroBit)
               OUTA[Pin]:=0 'flop bit
               
            128:  'bit is a one
               waitcnt(time += OneBit)
               OUTA[Pin]:=1 'flip bit
               waitcnt(time += OneBit)
               OUTA[Pin]:=0 'flop bit
                
          temp<<=1  'shift left to get next bit of byte
       
      waitcnt(time+=OneBit)   'output two "1" bits to terminate packet
      OUTA[Pin]:=1 'flip bit            
      waitcnt(time+=OneBit)
      OUTA[Pin]:=0 'flop bit
      waitcnt(time+=OneBit)    
      OUTA[Pin]:=1 'flip bit            
      waitcnt(time+=OneBit)
      OUTA[Pin]:=0 'flop bit
            