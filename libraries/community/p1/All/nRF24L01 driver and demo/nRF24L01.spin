''****************************************
''*  nFR24L01                            *
''*  Authors: Nikita Kareev              *
''*  See end of file for terms of use.   *
''****************************************
''
'' Nordic nRF24L01 driver
''
'' http://www.sparkfun.com/commerce/product_info.php?products_id=691
''
'' Updated... 6 SEP 2009
''
'' Rev 0.1 
CON

  'nRF24L01 constants:
  
  'Commands
  R_REGISTER = %0000_0000 '+ reg
  W_REGISTER = %0010_0000 '+ reg
  R_RX_PAYLOAD = %0110_0001
  W_TX_PAYLOAD = %1010_0000
  FLUSH_TX = %1110_0001
  FLUSH_RX = %1110_0010
  REUSE_TX_PL = %1110_0011
  R_RX_PL_WID = %0110_0000
  W_ACK_PAYLOAD = %1010_1000 '+ pipe
  W_TX_PAYLOAD_NOACK = %1011_0000
  NOOP = %1111_1111

  'Registers
  CONFIG = $00   '%0000_1000 / $08
  EN_AA = $01  '%0011_1111  / $3F
  EN_RXADDR = $02  '%0000_0011
  SETUP_AW = $03   '%0000_0011
  SETUP_RETR = $04  '%0000_0011
  RF_CH = $05   '%0000_0010
  RF_SETUP = $06  '%0000_1110
  STATUS = $07     '%0000_1110 / $E 
  OBSERVE_TX = $08  '%0000_0000
  RPD = $09   '%0000_0000 
  RX_ADDR_P0 = $0A '$E7E7E7E7E7
  RX_ADDR_P1 = $0B '$C2C2C2C2C2
  RX_ADDR_P2 = $0C  '$C3
  RX_ADDR_P3 = $0D  '$C4 
  RX_ADDR_P4 = $0E  '$C5 
  RX_ADDR_P5 = $0F  '$C6 
  TX_ADDR = $10    '$E7E7E7E7E7
  RX_PW_P0 = $11   '%0000_0000
  RX_PW_P1 = $12   '%0000_0000 
  RX_PW_P2 = $13   '%0000_0000 
  RX_PW_P3 = $14  '%0000_0000 
  RX_PW_P4 = $15  '%0000_0000 
  RX_PW_P5 = $16  '%0000_0000 
  FIFO_STATUS = $17 '%0001_0001 
  DYNPD = $1C   '%0000_0000
  FEATURE = $1D  '%0000_0000

OBJ 

  TIME  : "Clock"                                       'Clock

VAR

  'Pins:
  
  byte SPI_Sck
  byte SPI_Miso
  byte SPI_Mosi 
  byte SPI_Csn    
  byte SPI_Ce
  byte SPI_Irq   

PUB Init(sck, miso, mosi, csn, ce)

  SPI_Sck := sck
  SPI_Miso := miso
  SPI_Mosi := mosi 
  SPI_Csn := csn     
  SPI_Ce := ce

  'Initialize clock object
  TIME.Init(5_000_000)
  
  'Configure for receive
  ConfigureRX

PUB ConfigureRX
{{
  Configure nRF24L01 registers for receive mode.
  1. Data pipe 0 used
  2. RX Address is E7E7E7E7E7 
  3. Data rate is 1Mb (compatability mode) - no ESB
  4. No Auto Ack (compatability mode) - no ESB 
  Tested with Nordic FOB from Sparkfun
}}
  
  Low(SPI_Ce)
    
  'Set PRX, CRC enabled
  Low(SPI_Csn)
  SpiReadWrite($20)
  SpiReadWrite($39) 
  High(SPI_Csn)   
    
  'Disable auto-ack for all channels
  Low(SPI_Csn)      
  SpiReadWrite($21)
  SpiReadWrite($00)     
  High(SPI_Csn)    
    
  'Set address width = 5 bytes
  Low(SPI_Csn)   
  SpiReadWrite($23)
  SpiReadWrite($03)    
  High(SPI_Csn)    
   
  'Data rate = 1Mb
  Low(SPI_Csn)   
  SpiReadWrite($26)
  SpiReadWrite($07)    
  High(SPI_Csn)

  'Set 4 byte payload
  Low(SPI_Csn)   
  SpiReadWrite($31)
  SpiReadWrite($04)    
  High(SPI_Csn)    

  'Set channel 2
  Low(SPI_Csn)
  SpiReadWrite($25)
  SpiReadWrite($02)    
  High(SPI_Csn)     

  'Set pipe 0 address E7E7E7E7E7
  Low(SPI_Csn)
  SpiReadWrite($30)
  repeat 5
    SpiReadWrite($E7) 
  High(SPI_Csn)  
    
  'PWR_UP = 1
  Low(SPI_Csn)   
  SpiReadWrite($20)
  SpiReadWrite($3B)   
  High(SPI_Csn)
    
  'Start receiving
  High(SPI_Ce)

PUB ReadPayload | idx, payload[4]
{{
  Reads payload from nRF24L01.
  Also flushes RX FIFO and resets IRQ state
}}    

  'Stop receiving
  Low(SPI_Ce)
    
  'Read RX payload   
  Low(SPI_Csn)    
  SpiReadWrite(R_RX_PAYLOAD) 
    
  repeat idx from 0 to 3  'Payload size = 4 byte
    payload[idx] := SpiReadWrite(NOOP)
  High(SPI_Csn)
    
  'Flush RX FIFO    
  Low(SPI_Csn)    
  SpiReadWrite($E2)    
  High(SPI_Csn)

  'Reset IRQ 
  Low(SPI_Csn)
  SpiReadWrite($27)
  SpiReadWrite($40)    
  High(SPI_Csn)

  'Start receiving
  High(SPI_Ce)
  return payload

PUB SpiReadWrite(byte_out) : byte_in | bit
{{
  SPI read-write procedure (8-bit SPI mode 0)
  Read and write are synced, i.e. for each byte in it is one byte out
  For deatails see: http://en.wikipedia.org/wiki/Serial_Peripheral_Interface_Bus
}}

  byte_in := byte_out

  repeat bit from 0 to 7
    'Write MOSI on trailing edge of previous clock
    if (byte_in & $80)
      High(SPI_Mosi)
    else
      Low(SPI_Mosi)
    byte_in <<= 1
 
    'Half a clock cycle before leading/rising edge
    TIME.PauseUSec(1)
    High(SPI_Sck)
 
    'Half a clock cycle before trailing/falling edge
    TIME.PauseUSec(1)
 
    'Read MISO on trailing edge
    byte_in |= Read(SPI_Miso)
    Low(SPI_Sck)

  return byte_in
  
PUB High(Pin)
    dira[Pin]~~
    outa[Pin]~~
         
PUB Low(Pin)
    dira[Pin]~~
    outa[Pin]~
    
PUB Read(Pin)
    dira[Pin]~
    return ina[Pin]