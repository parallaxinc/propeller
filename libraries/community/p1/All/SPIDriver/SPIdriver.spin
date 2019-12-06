{{
 SPIdriver. Provide bus-level and chip-level methods for SPI bus communication.
 Erlend Fj. 2015

 Revisions:
 -  Changed decoding of SPI mode to: iIdleCLK:=   iMode >> 1               thanks to Seairth
 -  Changed main routine to correct for too early writes                   thanks to Seairth
 -  Added flag to keep tally of initialization
 -  Changed Init variables into type DAT in order to preserve values across multiple instances
 -  Added object instance id
 
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

 Supports modes 0, 1,2, 3 with any frame length (8bit is the normal)

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
}}
{
 Acknowledgements: the Forum, as usual
----------------------------------------------------------------------------------------------------------------------------------------------------------------------- 

Schematics:

 Propeller
+---------+
|         |                        SPI Bus
|   MOSI  +-------------------------------------------------------------------              The bus can have many chips connected, and 'addressing' is
|         |                |                       |               |                        achieved by pulling low the specific CS (Chip Select) signal
|   MISO  +-----------------------------------------------------------------------
|         |                |    |                  |  |            |  |
|    CLK  +------------------- --------------------------------------------------
|         |                |    |    |             |  |  |         |  |  |
|         |              +--------------+          |  |  |         |  |  |
|         |              | MOSI MISO CLK|          |  |  |         |  |  |
|         |              |    Chip n    |        +---------+       |  |  |
|   n CS  +--------------+              |        |         |       |  |  |
|         |              +--------------+        |  Chip m |     +---------+
|   m CS  +--------------------------------------+         |     |         |
|         |                                      +---------+     | Chip l  |
|   l CS  +------------------------------------------------------+         |
|         |                                                      +---------+
+---------+

 
=======================================================================================================================================================================

 About SPI
 ---------
 During each SPI clock cycle, a full duplex data transmission occurs. The master sends a bit on the MOSI line and the slave reads it, while the slave sends a bit on the
 MISO line and the master reads it. This sequence is maintained even when only one-directional data transfer is intended. Transmissions normally involve two shift registers
 of some given word size, such as eight bits, one in the master and one in the slave; they are connected in a virtual ring topology. Data is usually shifted out with the
 most-significant bit first, while shifting a new less-significant bit into the same register. At the same time, Data from the counterpart is shifted into the
 least-significant bit register. After the register bits have been shifted out and in, the master and slave have exchanged register values. If more data needs to be exchanged,
 the shift registers are reloaded and the process repeats. Transmission may continue for any number of clock cycles. When complete, the master DeselectChips toggling the clock signal,
 and typically deselects the slave. Transmissions often consist of 8-bit words. However, other word sizes are also common, for example, 16-bit words for touchscreen controllers
 or audio codecs, such as the TSC2101 by Texas Instruments, or 12-bit words for many digital-to-analog or analog-to-digital converters. Every slave on the bus that has not
 been activated using its chip select line must disregard the input clock and MOSI signals, and must not drive MISO. The master must select only one slave at a time.

 
 REF:
 https://en.wikipedia.org/wiki/Serial_Peripheral_Interface_Bus

=======================================================================================================================================================================
}
 
CON

          _clkmode = xtal1 + pll16x
          _xinfreq = 5_000_000                                      'use 5MHz crystal
        
          clk_freq = (_clkmode >> 6) * _xinfreq                     'system freq as a constant
          mSec     = clk_freq / 1_000                               'ticks in 1ms
          uSec     = clk_freq / 1_000_000                           'ticks in 1us     (80 ticks)
  

VAR

          BYTE  iMsbLsb
          BYTE  iDelay
          BYTE  iBits
          BYTE  iMode
          BYTE  iIdleCLK
          BYTE  iActiveCLK
          BYTE  iPhaseCLK
          BYTE  iFirstPos
          BYTE  iLastPos
          BYTE  iChipSelect
          
DAT                                                  
          PINmosi             LONG    10                'Use DAT variable to make the assignment stick for later calls to the object, and optionally 
          PINmiso             LONG    11                'assign to default pin numbers. Use Init( ) to change at runtime. Best for many chips same one bus.          
          PINclk              LONG    12                'If this is not desired, change from defining PINmosi etc. as DAT to VAR, and
          MsbLsb              LONG    1                 'assign value to them in Init by means of 'PINmosi:= _PINmosi' etc. instead. Best when many busses.
          Delay               LONG    500
          FrameSize           LONG    8
          Mode                LONG    1                                                                                       
          BusInitialized      LONG    FALSE             
          ThisObjectInstance  LONG    1                 'Change to separate object loads for different physical buses
                                    

PUB Init(_PINmosi, _PINmiso, _PINclk, _MsbLsb, _Delay, _FrameSize, _Mode)
                                     'MsbLsb= 1 (MSB first) or = 0 (LSB first), normally= 1 (=MSB first)
   'Parameters:                              'Delay= wait for slave time in microseconds, use at least 50                I'm using 500 tics instead
                                                    'FrameSize= number of bits in a frame, normally= 8, maximum 32
                                                               'Mode= 0, 1, 2 or 3 (SPI mode), normally= 0
   LONG[@PINmosi]:=    _PINmosi
   LONG[@PINmiso]:=    _PINmiso
   LONG[@PINclk]:=     _PINclk
   LONG[@MsbLsb]:=     _MsbLsb
   LONG[@Delay]:=      _Delay
   LONG[@FrameSize]:=  _FrameSize
   LONG[@Mode]:=       _Mode
   
   iMsbLsb:=  MsbLsb                                                'Assign to global variables
 ' iDelay*=   uSec                DOES NOT WORK, use 500            'Convert delay parameter into tics. Shorter than 400tics is hard for Spin to do
   iBits :=   FrameSize                                             'Maximum a LONG can carry is 32 bits    
   iMode:=    Mode       
   iChipSelect:= 0                                                  'Bringing the CS pin low(0) will effect chip select

   IF iMsbLsb == 1                                                  'If MSB first, Start at highest position in frame
     iFirstPos:= FrameSize-1
     iLastPos:= 0

   IF iMsbLsb == 0                                                  'If LSB first, Start at lowest postion in frame
     iFirstPos:= 0
     iLastPos:= FrameSize-1  
                                                                    
   DIRA[PINmosi]:= 1                                                'Set up the IO
   DIRA[PINmiso]:= 0
   DIRA[PINclk]:=  1

   iIdleCLK:= 0                                                     'clear all bits first 
   iActiveCLK:= 0
   iPhaseCLK:= 0
   
   iIdleCLK:=   iMode >> 1                                          'the neat trick here is that the mode number is the decimal of a number with bit0=CPHA and bit1=CPOL
   iActiveCLK:= ! iIdleCLK
   iPhaseCLK:=  iMode & %01

   OUTA[PINclk]:=  iIdleCLK                                         'Set to idle state
   OUTA[PINmosi]:= 0

   LONG[@BusInitialized]:= TRUE                                     'Keep tally of initialization
   

PUB IsInitialized

   RETURN BusInitialized  
   

'CHIP LEVEL READ/WRITE DATA  --  with SPI, data is always transferred both ways simultanously, i.e. trasferred, not written OR read
 '===================================================================================================================================

PUB ShiftOut(Data, PINcs)                                           'A write method. Receives data anyway, but this is normally not used

   SelectChip(PINcs)   
   RETURN Transfer(Data)                                            'Returns data just for the sake of it
   DeselectChip(PINcs)     

 
PUB ShiftIn(PINcs) | dummy                                          'A read method. Writes dummy data in order to receive pay data

   SelectChip(PINcs)
   RETURN Transfer(dummy)
   DeselectChip(PINcs)


PUB WriteRead(Data, PINcs)                                          'Same as ShiftOut, but with the intention by the caller to both write and read valid data

   SelectChip(PINcs)
   RETURN Transfer(Data)                                            'E.g. with MCP320x, use MSB, Framesize= 19, Mode= 0
   DeselectChip(PINcs)
   

PUB WriteFrames(Frames, ptrData, PINcs)  | dummy                    'Write a bunch of data in one go. Normally the frame size should be set to 8 bits first (by Init)

    'tbd


PUB ReadFrames(Frames, ptrData, PINcs)  | dummy                     'Read a bunch of data in one go   Normally the frame size should be set to 8 bits first (by Init)

    'tbd


    

 'BUS LEVEL METHODS
 '=====================================================================================================================


PUB SelectChip(PINcs)
  
   OUTA[PINcs]:= iChipSelect                                        'normally chip select is effected by pulling the pin low
   DIRA[PINcs]:= 1                                                  'set as output and keep it that way
   WAITCNT(500 + cnt)
   
   
PUB DeselectChip(PINcs)

   OUTA[PINcs]:= ! iChipSelect                                       
   WAITCNT(500 + cnt)



PUB WakeUpChip(PINcs)

   DIRA[PINcs]:= 1                                                  'toggle ChipSelect to wake up chip (may be needed if chip is powered up while CS is low)
   OUTA[PINcs]:= ! iChipSelect                                       
   WAITCNT(1000 + cnt)
   OUTA[PINcs]:= iChipSelect                                          
   OUTA[PINcs]:= ! iChipSelect

   

PUB Transfer(FRAMEtx) | FRAMErx, bitpos    
                                                                                                                                                                     
   FRAMErx:= 0                                                       'clear all bits in input buffer                                                                 
                                                                                                                                                                     
   REPEAT bitpos FROM iFirstPos TO iLastPos                          'follow the direction set by choice of MSB first or LSB first 
     IF iPhaseCLK== 0                                                '*new
       OUTA[PINmosi]:= FRAMEtx >>bitpos                              'if the bit at at that postion is one, output 1
                                                                      
     WAITCNT(500 + cnt)                                              'allow the slave time to react                                                                  
     OUTA[PINclk]:= iActiveCLK                                       'leading edge of clock (whether Active is 1 or 0 is defined by SPI mode)
     
     IF iPhaseCLK== 0                                                'if acting on leading edge read the input now:
       IF INA[PINmiso]== 1                                           'if incoming data bit is 1                                                                      
         Framerx |= 1<<bitpos                                         'set bit in the buffer at respective position to 1, otherwise leavi it at 0
     ELSE
       OUTA[PINmosi]:= FRAMEtx >>bitpos                              'if the bit at at that postion is one, output 1
         
     WAITCNT(500 + cnt)                                              'allow the slave time to react    
     OUTA[PINclk]:= iIdleCLK                                         'trailing edge of clock (whether Idle is 1 or 0 is defined by SPI mode)
     
     IF iPhaseCLK== 1                                                'if acting on trailing edge read the input now:
       IF INA[PINmiso]== 1                                           'if incoming data bit is 1                                                                      
         Framerx |= 1<<bitpos                                        'set bit in the buffer at respective position to 1, otherwise leave it at 0 
       
   RETURN FRAMErx

DAT

{{

  Terms of Use: MIT License

  Permission is hereby granted, free of charge, to any person obtaining a copy of this                    
  software and associated documentation files (the "Software"), to deal in the Software                   
  without restriction, including without limitation the rights to use, copy, modIFy,                      
  merge, PUBlish, distribute, sublicense, and/or sell copies of the Software, and to                      
  permit persons to whom the Software is furnished to do so, subject to the following                     
  conditions:                                                                                             
                                                                                                          
  The above copyright notice and this permission notice shall be included in all copies                   
  or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
  PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
  OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 

}}