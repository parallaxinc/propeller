''********************************************
''*  1Mbaud Full-Duplex Serial Driver v1.0   *
''*  Author: David Sloan                     *
''*  Copyright (c) 2017 David Sloan          *
''*  See end of file for terms of use.       *
''********************************************

''This code provides fixed buad rate simultaneous Receive and Transmit at a baud rate of SysClk/80
''  at 80 MHz this is 1Mbaud.  Receive sampling is 2x over sampled using a cog counter to select
''  the appropriat sampling window.  This means that the incomming bitstream will be sampled
''  +/- 250 ns from the center of each bit.
''       bit0    bit1    bit2
''  .../'|'''|'\_|___|_/'|'''|'\...
''        ^^^     ^^^     ^^^
''          Sampling windows

''Spin methods are provided for low throughput use, for higher throughputs the addressed of the control
''  registers can be accessed.
''  -To write using TxReg
''    -pole the hub address TxRegAddr for the flag TX_RTS to be set
''    -once TX_RTS has been set write byte to transmit to TxReg clearing the TX_RTS bit
''    -the serial transmitter code will set TX_RTS once it has been read and preped for transmit
''  -To read using the Rx buffer
''    -pole RxWritePos and either RxReadPos or your own internal read position if the spin methods
''      are never used.
''      -wait for RxWritePos <> RxReadPos
''    -Read byte from RxBuffer[RxReadPos] and increment RxReadPos rolling over to 0 when RxBufferSize is reached
''  -example assembly write methods are included in "asm_write_ex.spin"

con
  RX_RDY        = $40_00_00_00
  TX_RTS        = $80_00_00_00
  RxBufferSize  = 64

var             
  long  TxReg
  byte  RxBuffer[RxBufferSize]
  long  RxReadPos
  long  RxWritePos

pub start(rxpin, txpin)
  pinRx := (1 << rxpin)
  pinTx := (1 << txpin)  
  pRxWriteStart := @RxBuffer
  'exclusive end pointer
  pRxWriteEnd := @RxBuffer +  RxBufferSize
  pRxWritePos := @RxWritePos
  pTxReg := @TxReg
  rxCtrPin := rxpin
  tx_ror := (31 - txpin) + 1
  if (tx_ror == 32)
    tx_ror := 0

  TxReg := 0
  cognew(@asm_start, 0)
  'wait for cog startup     
  repeat while ((TxReg & TX_RTS) == 0)

pub tx(value)
  repeat while ((TxReg & TX_RTS) == 0)
  TxReg := value & $ff 

pub rx | value   
  repeat while RxReadPos == RxWritePos
  value := RxBuffer[RxReadPos++]
  if (rxReadPos == RxBufferSize)
    rxReadPos := 0                  
  return value              

pub RxBufAddr
  return @RxBuffer

pub RxBufEndAddr
  return @RxBuffer + RxBufferSize
                       
pub RxBufWritePosAddr
  return @RxWritePos
  
pub RxBufReadPosAddr
  return @RxReadPos

pub TxRegAddr
  return @TxReg 

dat
asm_start
org
              'flag cog started
              wrlong    tx_flagRTS, pTxReg
              'configure tx
              mov       dira, pinTx
              mov       outa, high
              'tx starts on bit 7 (currently set high by outa = high) this is where new data is read
              mov       txcode, #tx_bit_7
              mov       rxcode, #rx_wait_1
              'configure rx
              andn      dira, pinRx  
              mov       frqa, #1
              mov       ctra, rxCtrMode
              movs      ctra, rxCtrPin  
              mov       phsa, #0   
              mov       frqa, #1
              mov       rx_dataReg, #0
              mov       pRxWrite, pRxWriteStart
              'Hold Tx line high for one byte time before starting
              mov       tmp, cnt
              add       tmp, byteTime
              waitcnt   tmp, byteTime
              'jumb to execution code
              jmp       txcode
       
{-------------------------------------------------------------------------------------
*********************************  RX Section  ***************************************
-------------------------------------------------------------------------------------}




'note if rxcode is not updated this becomes a loop
rx_wait_1
              'inst 1/5
              and       pinRx, ina              nr, wz  
              'inst 2/5
              mov       phsa, #0
              'inst 3/5                 
        if_nz mov       rxcode, #rx_wait_0                                      
              'inst 4/5   
              nop                                   
              'inst 5/5
              jmp       txcode   
'note if rxcode is not updated this becomes a loop
rx_wait_0
              'inst 1/5
              mov       tmp, phsa
              'inst 2/5                  
              mov       phsa, #0                         
              'inst 3/5
              'test how long it's been sinse the last falling edge
              ' and decide wheter to use this sampling interval or
              ' the next (2x over-sampling)            
              cmp       tmp, #16               wc, wz                 
              'inst 4/5
        if_ae mov       rxcode, #rx_read_bit_start  
              'inst 5/5
              jmp       txcode    
rx_read_bit_start   
              'inst 1/5
              mov       rx_bitcount, #8
              'inst 2/5
              mov       rx_bit, #1
              'inst 3/5
              mov       rx_data, #0
              'inst 4/5
              nop
              'inst 5/5
              jmpret    rxcode, txcode 
'read rx bit 
rx_read_bit            
              'inst 1/5
              and       pinRx, ina              nr, wz
              'inst 2/5
              muxnz     rx_data, rx_bit
              'inst 3/5
              shl       rx_bit, #1
              'inst 4/5
              sub       rx_bitcount, #1
              'inst 5/5
              jmpret    rxcode, txcode
rx_mid_bit            
              'inst 1/5
              cmp       rx_bitcount, #0         wc, wz
              'inst 2/5
        if_e  mov       rxcode, #rx_check_frame
              'inst 3/5
        if_ne mov       rxcode, #rx_read_bit
              'inst 4/5
              or        rx_data, rx_flagRdy
              'inst 5/5
              jmp       txcode
rx_check_frame  
              'inst 1/5
              and       pinRx, ina              nr, wz       
              'inst 2/5
              'reset low time counter
              mov       phsa, #0
              'inst 3/5
              'successfull read, write data to reg for write to hub (handled by tx code)
        if_nz mov       rx_dataReg, rx_data
              'inst 4/5
              mov       rxcode, #rx_wait_0
              'inst 5/5
              jmp       txcode



{-------------------------------------------------------------------------------------
*********************************  TX Section  ***************************************
-------------------------------------------------------------------------------------}

              

tx_bit_start                          
              'inst 1/5 'hub sync
              nop
              'inst 2/5
              nop
              'inst 3/5
              mov       outa, tx_dataReg
              'inst 4/5
              nop
              'inst 5/5
              jmpret    txcode, rxcode
tx_idle_start
              'inst 1/5
              and       rx_dataReg, rx_flagRDY  nr, wz
              'inst 2/5
        if_z  mov       txcode, #tx_bit_0_norm
              'inst 3/5 'hub sync
        if_nz mov       txcode, #tx_bit_0_rx2hub
              'inst 4/5
              nop
              'inst 5/5
              jmp       rxcode   
tx_bit_0_norm
              'inst 1/5 'hub sync 
              nop             
              'inst 2/5
              nop
              'inst 3/5
              ror       outa, #1
              'inst 4/5
              nop
              'inst 5/5          
              jmpret    txcode, rxcode    
tx_idle_0_norm
              'inst 1/5       
              mov       txcode, #tx_bit_1
              'inst 2/5
              nop
              'inst 3/5 'hub sync
              nop
              'inst 4/5
              nop
              'inst 5/5                        
              jmp       rxcode 
tx_bit_0_rx2hub
              'inst 1-2/5 'hub sync  
              wrbyte    rx_dataReg, pRxWrite
              'inst 3/5
              ror       outa, #1
              'inst 4/5
              mov       rx_dataReg, #0
              'inst 5/5
              jmpret    txcode, rxcode
tx_idle_0_rx2hub
              'inst 1/5
              add       pRxWrite, #1
              'inst 2/5
              cmp       pRxWrite, pRxWriteEnd   wc, wz
              'inst 3/5 'hub sync
        if_e  mov       pRxWrite, pRxWriteStart
              'inst 4/5
              nop
              'inst 5/5
              jmpret    txcode, rxcode
tx_bit_1
              'inst 1/5 'hub sync
              nop
              'inst 2/5
              nop
              'inst 3/5    
              ror       outa, #1
              'inst 4/5
              nop
              'inst 5/5
              jmpret    txcode, rxcode
tx_idle_1
              'inst 1/5
              mov       tmp, pRxWrite
              'inst 2/5
              sub       tmp, pRxWriteStart
              'inst 3-4/5 'hub sync
              wrlong    tmp, pRxWritePos
              'inst 5/5
              jmpret    txcode, rxcode 
tx_bit_2
              'inst 1/5 'hub sync
              nop
              'inst 2/5
              nop
              'inst 3/5     
              ror       outa, #1
              'inst 4/5
              nop
              'inst 5/5
              jmpret    txcode, rxcode
tx_idle_2
              'inst 1/5
              nop
              'inst 2/5
              nop
              'inst 3/5 'hub sync
              nop
              'inst 4/5
              nop
              'inst 5/5
              jmpret    txcode, rxcode 
tx_bit_3
              'inst 1/5 'hub sync
              nop
              'inst 2/5
              nop
              'inst 3/5     
              ror       outa, #1
              'inst 4/5
              nop
              'inst 5/5
              jmpret    txcode, rxcode
tx_idle_3
              'inst 1/5
              nop
              'inst 2/5
              nop
              'inst 3/5 'hub sync
              nop
              'inst 4/5
              nop
              'inst 5/5
              jmpret    txcode, rxcode                  
tx_bit_4
              'inst 1/5 'hub sync
              nop
              'inst 2/5
              nop
              'inst 3/5     
              ror       outa, #1
              'inst 4/5
              nop
              'inst 5/5
              jmpret    txcode, rxcode
tx_idle_4                             
              'inst 1/5
              and       rx_dataReg, rx_flagRDY  nr, wz
              'inst 2/5
        if_z  mov       txcode, #tx_bit_5_norm
              'inst 3/5 'hub sync
        if_nz mov       txcode, #tx_bit_5_rx2hub
              'inst 4/5
              nop
              'inst 5/5
              jmp       rxcode         
tx_bit_5_norm                       
              'inst 1/5 'hub sync  
              nop               
              'inst 2/5
              nop
              'inst 3/5
              ror       outa, #1
              'inst 4/5
              nop
              'inst 5/5   
              jmpret    txcode, rxcode            
tx_idle_5_norm
              'inst 1/5     
              mov       txcode, #tx_bit_6
              'inst 2/5
              nop
              'inst 3/5 'hub sync
              nop
              'inst 4/5
              nop
              'inst 5/5                       
              jmp       rxcode        
tx_bit_5_rx2hub
              'inst 1-2/5 'hub sync  
              wrbyte    rx_dataReg, pRxWrite
              'inst 3/5
              ror       outa, #1
              'inst 4/5
              mov       rx_dataReg, #0
              'inst 5/5
              jmpret    txcode, rxcode
tx_idle_5_rx2hub
              'inst 1/5
              add       pRxWrite, #1
              'inst 2/5
              cmp       pRxWrite, pRxWriteEnd   wc, wz
              'inst 3/5 'hub sync
        if_e  mov       pRxWrite, pRxWriteStart
              'inst 4/5
              nop
              'inst 5/5
              jmpret    txcode, rxcode     
tx_bit_6
              'inst 1/5 'hub sync
              nop
              'inst 2/5
              nop
              'inst 3/5   
              ror       outa, #1
              'inst 4/5
              nop
              'inst 5/5
              jmpret    txcode, rxcode
tx_idle_6
              'inst 1/5   
              mov       tmp, pRxWrite
              'inst 2/5
              sub       tmp, pRxWriteStart
              'inst 3-4/5 'hub sync
              wrlong    tmp, pRxWritePos      
              'inst 5/5
              jmpret    txcode, rxcode 
tx_bit_7
              'inst 1-2/5 'hub sync
              rdlong    tx_dataReg, pTxReg
              'inst 3/5   
              ror       outa, #1
              'inst 4/5
              nop
              'inst 5/5
              jmpret    txcode, rxcode
tx_idle_7
              'inst 1/5
              and       tx_dataReg, tx_flagRTS  nr, wz
              'inst 2/5
        if_nz mov       txcode, #tx_bit_stop_idle
              'inst 3/5 'hub sync   
        if_z  mov       txcode, #tx_bit_stop_tx
              'inst 4/5
              nop
              'inst 5/5
              jmp       rxcode 
tx_bit_stop_idle
              'inst 1/5 'hub sync  
              mov       tx_dataReg, high
              'inst 2/5
              nop
              'inst 3/5
              mov       outa, high
              'inst 4/5
              nop
              'inst 5/5
              jmpret    txcode, rxcode
tx_idle_stop_idle
              'inst 1/5              
              mov       txcode, #tx_bit_start  
              'inst 2/5
              nop
              'inst 3/5 'hub sync
              nop
              'inst 4/5  
              nop                      
              'inst 5/5
              jmp       rxcode  
tx_bit_stop_tx
              'inst 1/5 'hub sync
              'set stop bit of tx data
              shl       tx_dataReg, #1
              'inst 2/5
              'shift data to proper position in outs
              ror       tx_dataReg, tx_ror
              'inst 3/5
              mov       outa, high
              'inst 4/5
              nop
              'inst 5/5
              jmpret    txcode, rxcode
tx_idle_stop_tx
              'inst 1/5      
              mov       txcode, #tx_bit_start   
              'inst 2/5
              nop
              'inst 3-4/5 'hub sync
              'flag data read and ready for next data in hub
              wrlong    tx_flagRTS, pTxReg                          
              'inst 5/5
              jmp       rxcode 
              

pinRx         long      0     
pRxWriteEnd   long      0
pRxWriteStart long      0
pRxWritePos   long      0
rx_flagRDY    long      RX_RDY
rxCtrPin      long      0
rxCtrMode     long      %0_10101_000_00000000_000000_000_000000 'Inc on pina == 0

pinTx         long      0
pTxReg        long      0
tx_flagRTS    long      TX_RTS
tx_ror        long      0  

high          long      $ff_ff_ff_ff
byteTime      long      800          

rxcode        res       1
rx_data       res       1
rx_dataReg    res       1
rx_bitcount   res       1
rx_bit        res       1 
pRxWrite      res       1

txcode        res       1
tx_dataReg    res       1

tmp           res       1
fit

{{

--------------------------------------------------------------------------------------------------------------------------------
|                                                   TERMS OF USE: MIT License                                                  |                                                            
--------------------------------------------------------------------------------------------------------------------------------
|Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    | 
|files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    |
|modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software|
|is furnished to do so, subject to the following conditions:                                                                   |
|                                                                                                                              |
|The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.|
|                                                                                                                              |
|THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          |
|WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         |
|COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   |
|ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         |
--------------------------------------------------------------------------------------------------------------------------------
}}