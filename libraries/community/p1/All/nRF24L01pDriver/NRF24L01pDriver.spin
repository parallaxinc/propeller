{{
 NRF24L01pdriver. Provide chip-level and application-level methods for NRF24L01+ communication, interfacing by SPI
 Erlend Fj. 2015
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

 Supports modes Enhanced Shockburst Mode

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
}}
{
 Acknowledgements: Neil's Log Book, for providing a clear introduction to this chip
                   The Vikings, for being the ancestors of the NORDIC Semiconductor guys

=======================================================================================================================================================================

       +----------------+                                                           PrimaryTX                                                      
       |                +                                          Communication    +-------+                                                      
       |   nRF24L01+   10uF            Propeller                   link topology    | Pipe5 |    PrimaryTX                                         
       |  +---------+   +            +----------+                  in a one-many    |       |    +-------+                                         
3.3V+--+--+VCC |GND +---+-+GND       |          |                  configuration    | Pipe4 |    | Pipe5 |    PrimaryTX                            
          |    |    |                |          |                                   |       |    |       |    +-------+                            
     +----+CSN |CE  +----------------+ PINce    |                                   | Pipe3 |    | Pipe4 |    | Pipe5 |    PrimaryTX               
     |    |    |    |                |          |                    HUB            |       |    |       |    |       |    +-------+               
     | +--+MOSI|SCK +----------------+ PINclk   |                  PrimaryRX        | Pipe2 |    | Pipe3 |    | Pipe4 |    | Pipe5 |               
     | |  |    |    |                |          |                  +-------+        |       |    |       |    |       |    |       |               
     | |  |IRQ |MISO+----------------+ PINmiso  |                  | Pipe5 |        | Pipe1 |    | Pipe2 |    | Pipe3 |    | Pipe4 |               
     | |  +---------+                |          |                  |       |        |       |    |       |    |       |    |       |               
     | |                             |          |                  | Pipe4 |        | Pipe0 +--+ | Pipe1 | ++ | Pipe2 | ++ | Pipe3 | +--+  +       
     | |                             |          |                  |       |        |       |    |       |    |       |    |       |       |       
     | +-----------------------------+ PINmosi  |                  | Pipe3 +-<<----+ TX   |    | Pipe0 +--+ | Pipe1 | ++ | Pipe2 | +--+  |       
     |                               |          |                  |       |        +-------+    |       |    |       |    |       |       |       
     +-------------------------------+ PINcs    |                  | Pipe2 +-<<------------------+  TX   | ++ | Pipe0 +--+ | Pipe1 | +--+  |       
                                     |          |                  |       |                     +-------+    |       |    |       |       |       
                                                                   | Pipe1 +-<<-------------------------------+  TX   |    | Pipe0 +----+  | 
  Connection between nRF24L01+ module and Propeller                |       |                                  +-------+    |       |       | 
                                                                   | Pipe0 +-<<--------------------------------------------+  TX   |       | 
                                                                   |       |                                               +-------+       | 
                                                                   |   TX  +->>------------------------------------------------------------+ 
                                                                   +-------+   Pipe0 of satellites must be same address as TX of hub         
 About NRF24L01+                                                       
---------------                                                        
                                                                       
The nRF24L01 is controlled using twelve instructions that can be sent over the SPI bus. An instruction must be sent using this process:
     Use SPI Mode 0                                                    
  1  Set CSN low.
  2  Send the instruction byte.
  3  If the instruction has arguments, send the argument bytes. If the instruction returns data, send NOP bytes (0xFF) and read in the responses. 
  4  Set CSN high.

Before reading/writing packets, put the radio into Standby-I mode by setting CE low.
To enter Tx Mode from Standby-I(PTX) (i.e. to transmit), pulse CE high for at least 10 uS.
To enter into Rx Mode from Standby-I(PRX) hold the ce high.

Set the radio to either a primary receiver or primary transmitter, depending on it's role. Typically the hub/central  should be primary receiver (PRX).


PACKETS
===========================================================================================================================================
Enhanced Shockburst Mode applies a packet structure as follows:
_____________________________________________________________________________________________
PREAMBLE(1byte) | ADDRESS(3-5bytes) | PACKET CNTL(9bit) | PAYLOAD(0-32bytes) | CRC(1-2bytes)|
---------------------------------------------------------------------------------------------
- with the PACKET CNTL field having this structure:
______________________________________________________
PAYLOAD Length(6bit) | PacketID(2bit) | NO_ACK(1bit) |
------------------------------------------------------              

FIFOs
There are two packet queues, or FIFOs, in the radio, one for received packets (the Rx FIFO) and one for packets to transmit (the Tx FIFO0.
Each FIFO can hold up to three packets. If a transmission fails then the packet is not cleared from the Tx FIFO, it has to be removed using
the FLUSH_TX instruction. The Rx FIFO is different from the Rx pipes: a pipe refers to one of the up to six addresses by which
the radio can be addressed, whereas the Rx FIFO is the 3-packet queue in which received packets are stored until they are read out of the radio.
All six Rx pipes put data into the same 3-packet Rx FIFO.

When the Tx FIFO is full, adding packets to the FIFO pushes the oldest packet out of the queue. When the Rx FIFO is full, new packets are
dropped until a space in the FIFO becomes available.

The Tx FIFO is not a true queue. If a receiver is using the ack payload feature then the ack payload is stored in the Tx FIFO.
The ack payload is only transmitted in an ack packet though, even if it’s at the head of the FIFO during a transmission. If the ack payload
is not at the head of the FIFO and an ack packet is transmitted, then the ack payload is removed from whatever FIFO slot it occupies.



        NRF24L01+ REGISTER OVERVIEW
        =============================================================================================================================================
        $00   CONFIG          %00000100  rec:%0000111x                          Configure interrupts, CRC, power, and Tx/Rx status.
        $01   EN_AA           %00111111  enable all pipes ESB mode              Enable and disable Enhanced Shockburst™ on individual Rx pipes.
        $02   EN_RXADDR       %00000011  enable pipes 0 and 1                   Enable and disable the Rx pipes.
        $03   SETUP_AW        %00000011  enable 5byte address witht             Set the address width.
        $04   SETUP_RETR      %00000011  delay 250uS, 5 retries                 Configure the retry delay and number of retries that the radio will do
        $05   RF_CH           %00000010  rec:%01110000 +-3 (112+-3)             Set the RF channel on which the radio broadcasts.
        $06   RF_SETUP        %00001111  max power and rate                     Configure the radio’s on-air data rate, output power, and LNA gain.
        $07   STATUS          %00001110  status after reset                     Interrupt status bits, Tx FIFO full bit, and the number of the pipe that received a packet.
        $08   OBSERVE_TX      %00000000  read only                              Count of lost and re-transmitted packets.
        $09   CD              %00000000  read only                              Carrier detect bit.
        $0A   RX_ADDR_P0      $E7E7E7E7E7     avoid regular bit patterns        Set the address for Rx pipe 0 default 5byte wide
        $0B   RX_ADDR_P1      $C2C2C2C2C2     avoid regular bit patterns        Set the address for Rx pipe 1 default 5byte wide
        $0C   RX_ADDR_P2      $C3                                               Set the address for Rx pipe 2
        $0D   RX_ADDR_P3      $C4                                               Set the address for Rx pipe 3
        $0E   RX_ADDR_P4      $C5                                               Set the address for Rx pipe 4
        $0F   RX_ADDR_P5      $C6                                               Set the address for Rx pipe 5
        $10   TX_ADDR         $E7E7E7E7E7                                       Set the destination address for transmitted packets.
        $11   RX_PW_P0        %00000000  set to max 32                          Set the static payload width on Rx pipe 0
        $12   RX_PW_P1        %00000000  set to max 32                          Set the static payload width on Rx pipe 1
        $13   RX_PW_P2        %00000000  set to max 32                          Set the static payload width on Rx pipe 2
        $14   RX_PW_P3        %00000000  set to max 32                          Set the static payload width on Rx pipe 3
        $15   RX_PW_P4        %00000000  set to max 32                          Set the static payload width on Rx pipe 4
        $16   RX_PW_P5        %00000000  set to max 32                          Set the static payload width on Rx pipe 5
        $17   FIFO_STATUS     %00010001  read only                              Auto-retransmit status, Tx FIFO full/empty, Rx FIFO full/empty.
        
         na   ACK_PLD         The 32byte payload to send with ack packets, if ack packet payloads are enabled (written to with the W_ACK_PAYLOAD instruction).
         na   TX_PLD          The 32byte Tx FIFO (written to with the W_TX_PAYLOAD and W_TX_PAYLOAD_NO_ACK instructions).
         na   RX_PLD          The 32byte Rx FIFO (read from with the R_RX_PAYLOAD instruction)
         
        $1C   DYNPD           %00000000  have to do the ACTIVE cmd first        Enable or disable the dynamic payload calculation feature on the Rx pipes.
        $1D   FEATURE         %00000000  have to do the ACTIVE cmd first        Enable or disable the dynamic payload, ack payload, and selective ack features

}
CON

          _clkmode = xtal1 + pll16x
          _xinfreq = 5_000_000                                          ' use 5MHz crystal
        
          clk_freq = (_clkmode >> 6) * _xinfreq                         ' system freq as a constant
          mSec     = clk_freq / 1_000                                   ' ticks in 1ms
          uSec     = clk_freq / 1_000_000                               ' ticks in 1us


       CONFIG       =         $00
       EN_AA        =         $01
       EN_RXADDR    =         $02
       SETUP_AW     =         $03
       SETUP_RETR   =         $04
       RF_CH        =         $05
       RF_SETUP     =         $06
       STATUS       =         $07
       OBSERVE_TX   =         $08
       CD           =         $09
       RX_ADDR_P0   =         $0A
       RX_ADDR_P1   =         $0B
       RX_ADDR_P2   =         $0C
       RX_ADDR_P3   =         $0D
       RX_ADDR_P4   =         $0E
       RX_ADDR_P5   =         $0F
       TX_ADDR      =         $10
       RX_PW_P0     =         $11
       RX_PW_P1     =         $12
       RX_PW_P2     =         $13
       RX_PW_P3     =         $14
       RX_PW_P4     =         $15
       RX_PW_P5     =         $16
       FIFO_STATUS  =         $17
       DYNPD        =         $1C
       FEATURE      =         $1D
                     

  
                
VAR
      BYTE  PINcs
      BYTE  PINce

      
OBJ     
  bus      : "SPIdriver"


PUB Init(PINmosi, PINmiso, PINclk, _PINcs, _PINce)

   PINcs:= _PINcs
   PINce:= _PINce     
   bus.Init(PINmosi, PINmiso, PINclk, 1, 50, 8, 0)                                   'Arguments: (PINmosi, PINmiso, PINclk, MsbLsb, Delay, FrameSize, Mode)
   
   OUTA[PINce]:= 0                                                                   'Set CE low
   DIRA[PINce]:= 1                                                                   'as output

   WAITCNT((1500*uSec) + cnt)
   WakeUpChip 
   SetPowerRadio(1)
   WAITCNT(2*mSec + CNT)                                                             'Let it wake up and stabilize
   SetPrimaryMode(1)                                                                 '1=RX  0=TX  
   
         
'APPLICATION LEVEL METHODS
'=============================================================================================================================================================================================

PUB SetPowerRadio(on) | value                                                         'Radio, on=1 sets power on, on=0 shuts power off
                                                                                     
   value:= R_REGISTERbyte(CONFIG)
   IF on
     value|= %0000_0010                                                               'mask in the power bit
   ELSE
     value&= !%0000_0010                                                              'mask out the power bit
   W_REGISTERbyte(CONFIG, value)
   RETURN R_REGISTERbyte(CONFIG)


PUB EnableRXpipes(bitpipe)

   W_REGISTERbyte(EN_RXADDR, bitpipe)                                                'bits 0-5 represents pipes 0-5. Value=1 means enabled
   RETURN R_REGISTERbyte(EN_RXADDR)
   
   
PUB SetRFchannel(ch)                                                                  'Set the RF channel on which the radio transmits

   W_REGISTERbyte(RF_CH, ch)                                                          '112 or 113 are good values to use
   RETURN R_REGISTERbyte(RF_CH)


PUB SetPrimaryMode(mode) | value                                                      'Set the radio mode - usually to initiate a transmission or to listen

    W_REGISTERbyte(CONFIG, %00001110 + mode)                                           '=1 Primary Rx, =0 Primary Tx  (and always power on and 2-byte crc)                                                

   RETURN R_REGISTERbyte(CONFIG)

   
PUB SetShockburst(on) | value                                                         'Simply set all pipes to Shockburst on/off

   value:= R_REGISTERbyte(EN_AA)                                                                                 
   IF on                                                                                                          
     value|= %0011_1111                                                               'mask in the shockburst bits       
   ELSE                                                                                                              
     value&= !%0011_1111                                                              'mask out the shockburst bits
   W_REGISTERbyte(EN_AA, value)
   RETURN R_REGISTERbyte(EN_AA)


PUB SetTransmitterPower(dB) | value                                                   'Transmitter power setting - affects current drawn

   value:= R_REGISTERbyte(RF_SETUP)& !%0000_0110                                      'null the dB bits

   CASE dB                                                                                         
     -18  :  value|= %0000_0000                                                       'set the dB bits                       
     -12  :  value|= %0000_0010
     -6   :  value|= %0000_0100                                                              
     0    :  value|= %0000_0110

  W_REGISTERbyte(RF_SETUP, value)
  RETURN R_REGISTERbyte(RF_SETUP)

  
PUB SetRadioDatarate(rate) | value                                                   'Set data transmission rate. 1= 2MB/s, 0= 1MB/s

   value:= R_REGISTERbyte(RF_SETUP)& !%0000_1000                                     'null the datarate bit
   W_REGISTERbyte(RF_SETUP, value|= (rate&1)<<3)
   RETURN R_REGISTERbyte(RF_SETUP)

    
PUB SetPayloadWidth(pipe, width)                                                     'Set payload width in specified pipe - max 32 bytes. 0= pipe not used                      
                                                                                                                                 
   W_REGISTERbyte(RX_PW_P0 + pipe, width)                                              
   RETURN R_REGISTERbyte(RX_PW_P0 + pipe)
  
  
PUB WriteRxPipeAddress(ptrAddr, pipe) | addrwidth                                    'Write the unique address to be used by the rx radio - for a given pipe                      
                                                                                     'address width is set to 3-5 bytes in SETUP_AW, use this value                                                                                                                      
   addrwidth:= R_REGISTERbyte(SETUP_AW)                                              'pipes 0 and 1 takes full address width, but pipes 2-5 only uses the LSB, don't know what 
   RETURN W_REGISTERdata(ptrAddr, addrwidth, RX_ADDR_P0 + pipe)                      'happens when attempting to write more address bytes in this case                                                                                                                                                                             


PUB WriteTxPipeAddress(ptrAddr) | addrwidth                                          'Write the unique address to be used by the tx radio                      
                                                                                     'address width is set to 3-5 bytes in SETUP_AW, use this value                                                                                                                      
   addrwidth:= R_REGISTERbyte(SETUP_AW)                                               
   RETURN W_REGISTERdata(ptrAddr, addrwidth, TX_ADDR)                                'when using auto-ACK, this address should be the same as Pipe0 rx address
                                                                                                                                                              

PUB ReadNclearInterrupts | value                                                     'Read interrupt status bits and clear them
                                                                             
   value:= R_REGISTERbyte(STATUS)                                                   
   RESULT:= value                                                                    'caller needs to extract the individual IRQ bits from byte and store them while needed
   W_REGISTERbyte(STATUS, value)                                                     'writing back the same value clears the interrupt bits

   
PUB IsPayloadRX                                                                      'Get if RX payload is waiting

   RETURN (R_REGISTERbyte(STATUS)&0100_0000)>>6                                      'mask read the payload bit.
   

PUB IsPayloadPipe                                                                    'Get in which pipe# payload is ready. Value of %111 means no payload

   RETURN (R_REGISTERbyte(STATUS)&0000_1110)>>1                                      'mask read the payload bits.    


PUB IsDataSent

   RETURN (R_REGISTERbyte(STATUS)&0010_0000)>>5                                      'mask read the tx sent bit


PUB IsMaxRetries

   RETURN (R_REGISTERbyte(STATUS)&0001_0000)>>4                                      'mask read the tx sent bit   
   

PUB IsFullTX

   RETURN R_REGISTERbyte(STATUS)&0000_0001                                           'mask read the tx sent bit 


PUB IsCarrier

   RETURN R_REGISTERbyte(CD)&0000_0001                                               'mask read the carrier detect bit
 
   
PRI PulseOut(Pin, duration)                                                          'Let the Counter take care of creating a ce pulse (will repeat, so needs to be stopped before 26 sec)
 
  CTRA := (%00100 << 26) + Pin                                                       'configure counter
  FRQA := 1                                                                          
  PHSA := -duration

  
PRI PulseStop(Pin)                                                                   'Do this somewhere in the code after transmission finished

   IF ((CTRA) AND (INA[Pin] == 0))                                                   'if the pulse has expired, stop the Counter (from repeating)
     CTRA := 0


'CHIP LEVEL METHODS
'===========================================================================================================================================================================================     
PUB NoOp(bytes)                                                                      'Do nothing, returns STATUS

   bus.SelectChip(PINcs)
   REPEAT bytes
     RESULT:= bus.Transfer($FF)                                                      'returns Status read out at last write
   bus.DeselectChip(PINcs)


PUB WakeUpChip                                                                       'in case of hangup

   bus.WakeUpChip(PINcs)



PUB ChipEnable(on)                                                                   'Set to on=0 gfor receive/standby, use PulseOut to trigger transmission

   OUTA[PINce]:= on
     
        
PUB R_REGISTERbyte(reg)                                                             'Read the byte from the register that has the 5-bit address AAAAA.

   bus.SelectChip(PINcs)
   bus.Transfer(reg)                                                          
   RESULT:= bus.Transfer($FF)                                                       'write dummy data to read back result
   bus.DeselectChip(PINcs)


PUB R_REGISTERdata(ptrData, bytes, reg) | thebyte                                   'Read  1-5 byte data from the register that has the 5-bit address AAAAA.

   bus.SelectChip(PINcs)                         
   bus.Transfer(reg)                      
   REPEAT thebyte FROM 0 to bytes-1                
     BYTE[ptrData][thebyte]:= bus.Transfer($FF)
   bus.DeselectChip(PINcs)                       
   RETURN thebyte                                   

   
PUB W_REGISTERbyte(reg, value)                                                      'Write the argument byte to the register that has the 5-bit address AAAAA.

   bus.SelectChip(PINcs)  
   bus.Transfer(%0010_0000 | reg)                                              
   RESULT:= bus.Transfer(value)
   bus.DeselectChip(PINcs)


PUB W_REGISTERdata(ptrData, bytes, reg) | thebyte                                   'Write the 1-5 argument bytes to the register that has the 5-bit address AAAAA.

   bus.SelectChip(PINcs)                   
   bus.Transfer(%0010_0000 | reg)                
   REPEAT thebyte FROM 0 to bytes-1          
     bus.Transfer(BYTE[ptrData][thebyte])
   bus.DeselectChip(PINcs)                 
   RETURN thebyte
                        
        
PUB R_RX_PAYLOAD(ptrData, bytes) | thebyte                                          'Read the data payload that is at the head of the Rx FIFO.

   bus.SelectChip(PINcs)             
   bus.Transfer(%0110_0001)
   REPEAT thebyte FROM 0 to bytes-1
     BYTE[ptrData][thebyte]:= bus.Transfer($FF)                                     'send a dymmy byte for each to be read
   bus.DeselectChip(PINcs)
   RETURN thebyte
   
    
PUB W_TX_PAYLOAD(ptrData, bytes) | thebyte                                          'Write the data payload to transmit into the Tx FIFO.

   bus.SelectChip(PINcs)             
   bus.Transfer(%1010_0000)
   REPEAT thebyte FROM 0 to bytes-1
     bus.Transfer(BYTE[ptrData][thebyte])                                   
   bus.DeselectChip(PINcs)
   RETURN thebyte

        
PUB FLUSH_TX                                                                        'Delete all packets from the Tx FIFO.

   bus.SelectChip(PINcs)                  
   RESULT:= bus.Transfer(%1110_0001)                    
   bus.DeselectChip(PINcs)
   
        
PUB FLUSH_RX                                                                        ' Delete all packets from the Rx FIFO.

   bus.SelectChip(PINcs)                  
   RESULT:= bus.Transfer(%1110_0010)                          
   bus.DeselectChip(PINcs)

        
PUB REUSE_TX_PL                                                                     'The packet at the head of the Tx FIFO shall continually be re-sent.

   bus.SelectChip(PINcs)                  
   RESULT:= bus.Transfer(%1110_0011)                    
   bus.DeselectChip(PINcs)


'SPECIAL FUNCTIONS
'========================================================================================================================================================================================================                                                                                                     
PUB ACTIVATE                                                                        'This instruction, with an argument of 0x73, enables the next three instructions.

   bus.SelectChip(PINcs)                    
   RESULT:= bus.Transfer(%1010_0000)   
   bus.Transfer($73)                      
   bus.DeselectChip(PINcs)

                 
PUB R_RX_PL_WID                                                                     'When using dynamic payload lengths, this instruction returns the payload size of the packet at the head of the queue.

   bus.SelectChip(PINcs)                  
   bus.Transfer(%0110_0000)       
   RESULT:= bus.Transfer($FF)                 
   bus.DeselectChip(PINcs)

   
PUB W_ACK_PAYLOAD(ptrData, bytes, pipe) | thebyte                                   'Write a payload to include in the next ack packet that will be sent in response to a packet received on Rx pipe PPP.

   bus.SelectChip(PINcs)                        
   bus.Transfer(%1010_1000 | pipe)                     
   REPEAT thebyte FROM 0 to bytes               
     bus.Transfer(BYTE[ptrData][thebyte-1])     
   bus.DeselectChip(PINcs)                      
   RETURN thebyte                               

   
PUB W_TX_PAYLOAD_NO_ACK(ptrData, bytes) | thebyte                                   'Write the data payload to transmit into the Tx FIFO, and disable auto-ack for only that payload's packet.

   bus.SelectChip(PINcs)                     
   bus.Transfer(%1011_0000)                  
   REPEAT thebyte FROM 0 to bytes            
     bus.Transfer(BYTE[ptrData][thebyte-1])  
   bus.DeselectChip(PINcs)                   
   RETURN thebyte                            
                                             

DAT
name    byte  "string_data",0        
        