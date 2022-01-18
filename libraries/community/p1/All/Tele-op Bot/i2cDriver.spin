{{
 i2cDriver. Provide bus-level and chip-level methods for I2C bus communication.
 Erlend Fj. 2015, 2016
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Supports standard 7 bit chip addressing, and both 8bit, 16bit, and 32bit register addressing. Use of 32bit is rare.
 Assumes the caller uses the chip address 7 bit format, onto which a r/w bit is added by the code before being transmitted.
 Signalling 'Open Collector Style' is achieved by setting pins OUTA := 0 permanent, and then manipulate on DIRA to either
 float the output, i.e. let PU resistor pull up to '1' -or- unfloat the output (which was set to 0) to bring it down to '0'

 Revisions:
 - Changed DAT assignment of scl and sda pins
 - Added BusInitialized flag
 - Added object instance identifier
 - Added IsBusy
 - Added self-demo PUB Main
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
}}
{
 Acknowledgements: I have mainly built upon the work of Jon "JonnyMac" McPhalen
=======================================================================================================================================================================
      Propeller
   +-------------+
   |             +-------+  3.3V  +------------------------------------------------------// -----------------------------------+
   |             |  |  |                 |                              |                                 |                |   |
   |             |  |  |               +-----------+                  +-----------+                     +-----------+      |   |
   |             |  |  |               | V+        |                  | V+        |                     | V+        |      |   |
   |   master    |  |  +               |           |                  |           |                     |           |      +   |
   |             |  | 4k7              | Chip/slave|                  | Chip/slave|                     | Chip/slave|     4k7  |
   |             |  +  +  Pull-up      |           |                  |           |                     |           |      +   |
   |             | 4k7 |               |SDA SCL GND|                  |SDA SCL GND|                     |SDA SCL GND|      |   +
   |             |  +  |               +-----------+                  +-----------+                     +-----------+      |  4k7
   |             |  |  |                 |   |   |                      |   |   |                         |   |   |        |   +
   |             |  |  |                 |   |   |                      |   |   |                         |   |   |        |   |
   |             |  |  |                 |   |   |                      |   |   |                         |   |   |        |   |
   |      PINsda +-----------------------------------------------------------------------// -------------------------------+   |
   |             |     |  I2C Bus            |   |                          |   |                             |   |            |
   |      PINscl +-----------------------------------------------------------------------// -----------------------------------+
   |             |                               |                              |                                 |
   |         GND +-----------------------------------------------------------------------// ----------------------+
   |             |
   +-------------+
 About I2C
 ---------
 Both the SCL and the SDA line needs to be pulled up by p-u resistors. Value not critical for such slow speeds that Spin can do, but should be in the order of 1k-47k.
 With long lines have p-u resistors at each node to reduce noise or interference.

 REF:
 http://www.8051projects.net/wiki/I2C_TWI_Tutorial
 http://i2c.info/i2c-bus-specification
=======================================================================================================================================================================
}

CON

          _clkmode = xtal1 + pll16x
          _xinfreq = 5_000_000                                      'use 5MHz crystal

          clk_freq = (_clkmode >> 6) * _xinfreq                     'system freq as a constant
          mSec     = clk_freq / 1_000                               'ticks in 1ms
          uSec     = clk_freq / 1_000_000                           'ticks in 1us

          ACK = 0                                                   'signals ready for more
          NAK = 1                                                   'signals not ready for more



VAR
          LONG  Slaves[120]                                        'Used only by PUB Main, i.e. demo code (comment out if you need the space)


DAT
          PINscl              LONG    1                            'Use DAT variable to make the assignment stick for later calls to the object, and optionally        'Use DAT variable to make the assignment stick for later calls to the object
          PINsda              LONG    2                            'assign to default pin numbers. Use Init( ) to change at runtime. Best for many chips same one bus. 'and assign to default pin numbers Use Init( ) to change at runtime
          BusInitialized      LONG    FALSE                        'If this is not desired, change from defining PINmosi etc. as DAT to VAR, and
                                                                   'assign value to them in Init by means of 'PINmosi:= _PINmosi' etc. instead. Best when many busses.

          ThisObjectInstance  LONG    1                            'Change to separate object loads for different physical buses


OBJ
          pst   : "Parallax Serial Terminal"


PUB Main | value, i                                                    'Demo code (comment out if you need the space)

  pst.Start(9600)                                                      'Remember to start the terminal at 9600b/s
  WAITCNT(clkfreq + cnt)

  pst.Str(String("Test of I2C bus, push button to start"))
  value := pst.DecIn
   REPEAT
     pst.Str(String("Enter SCL pin number:"))
     PINscl:= || pst.DecIn
     pst.Dec(PINscl)
     pst.Chars(pst#NL, 2)
     pst.Str(String("Enter SDA pin number:"))
     PINsda:= || pst.DecIn
     pst.Dec(PINsda)
     pst.Chars(pst#NL, 2)
     IF PINscl>31 OR PINsda>31
       pst.Str(String("Pin number maximum 31!"))
       pst.Chars(pst#NL, 2)
     ELSE
       QUIT
   pst.Str(String("Now initialising bus..."))
   Init(PINscl, PINsda)
   pst.Chars(pst#NL, 2)
   pst.Str(String("Status of SCL: "))
   IF INA[PINscl] == 1
     pst.Str(String(" HIGH (good)"))
   ELSE
     pst.Str(String(" LOW (pull-up resistor missing?)"))
   pst.Chars(pst#NL, 2)
   pst.Str(String("Status of SDA: "))
   IF INA[PINsda] == 1
     pst.Str(String(" HIGH (good)"))
   ELSE
     pst.Str(String(" LOW (pull-up resistor missing?)"))
   pst.Chars(pst#NL, 2)
   pst.Str(String("Bus initialization completed."))
   pst.Chars(pst#NL, 2)
  pst.Chars(pst#NL, 2)

  IF INA[PINscl] == 1 AND INA[PINsda] == 1
    pst.Str(String("Now scanning bus..."))
    pst.Chars(pst#NL, 2)
    WhoOnBus(@Slaves)
     IF Slaves[0] > 0
       REPEAT i FROM 1 TO Slaves[0]
         pst.Str(String("Bus slave detected at address: $"))
         pst.Hex(Slaves[i], 4)
         pst.Chars(pst#NL, 2)
     pst.Dec(Slaves[0])
     pst.Str(String("  slaves found.  "))
     pst.Str(String("Scan completed."))
     pst.Chars(pst#NL, 2)


'INITIATION METHOD
'=================================================================================================================================================

PUB Init(_PINscl, _PINsda)

   LONG[@PINscl]:= _PINscl                                          'Copy pin into DAT where it will survive
   LONG[@PINsda]:= _PINsda                                          'into later calls to this object

   DIRA[PINscl] := 0                                                'Float output
   OUTA[PINscl] := 0                                                'and set to 0
   DIRA[PINsda] := 0                                                'to simulate open collector i/o (i.e. pull-up resistors required)
   Reset                                                            'Do bus reset to clear any chips' activity
   LONG[@BusInitialized]:= TRUE                                     'Keep tally of initialization


PUB IsInitialized

   RETURN BusInitialized


'CHIP LEVEL METHODS    - calls BUS LEVEL METHODS below, encapsulates the details of the workings of the bus
'=================================================================================================================================================
'Write

'Byte (8bit)

PUB WriteByteA8(ChipAddr, RegAddr, Value)                           'Write a byte to specified chip and 8bit register address

   IF CallChip(ChipAddr << 1)== ACK                                 'Shift left 1 to add on the read/write bit, default 0 (write)
     WriteBus(RegAddr)
     WriteBus(Value)
     Stop


PUB WriteByteA16(ChipAddr, RegAddr, Value)                          'Write a byte to specified chip and 16bit register address

   IF CallChip(ChipAddr << 1)== ACK                                 'Shift left 1 to add on the read/write bit, default 0 (write)
     WriteBus(RegAddr.BYTE[1])                                      'MSB
     WriteBus(RegAddr.BYTE[0])                                      'LSB
     WriteBus(Value)
     Stop


'Word (16bit)

PUB WriteWordA8(ChipAddr, RegAddr, Value)                           'Write a Word to specified chip and 8bit register address

   IF CallChip(ChipAddr << 1)== ACK                                 'Shift left 1 to add on the read/write bit, default 0 (write)
     WriteBus(RegAddr)
     WriteBus(Value.BYTE[1])                                        'MSB
     WriteBus(Value.BYTE[0])                                        'LSB
     Stop


PUB WriteWordA16(ChipAddr, RegAddr, Value)                          'Write a Word to specified chip and 16bit register address

   IF CallChip(ChipAddr << 1)== ACK                                 'Shift left 1 to add on the read/write bit, default 0 (write)
     WriteBus(RegAddr.BYTE[1])                                      'MSB
     WriteBus(RegAddr.BYTE[0])                                      'LSB
     WriteBus(Value.BYTE[1])                                        'MSB
     WriteBus(Value.BYTE[0])                                        'LSB
     Stop


'Long (32bit)

PUB WriteLongA8(ChipAddr, RegAddr, Value)                           'Write a Long to specified chip and 8bit register address

   IF CallChip(ChipAddr << 1)== ACK                                 'Shift left 1 to add on the read/write bit, default 0 (write)
     WriteBus(RegAddr)
     WriteBus(Value.BYTE[3])                                        'MSB
     WriteBus(Value.BYTE[2])                                        'NMSB
     WriteBus(Value.BYTE[1])                                        'NLSB
     WriteBus(Value.BYTE[0])                                        'LSB
     Stop


PUB WriteLongA16(ChipAddr, RegAddr, Value)                          'Write a Long to specified chip and 16bit register address

   IF CallChip(ChipAddr << 1)== ACK                                 'Shift left 1 to add on the read/write bit, default 0 (write)
     WriteBus(RegAddr.BYTE[1])                                      'MSB
     WriteBus(RegAddr.BYTE[0])                                      'LSB
     WriteBus(Value.BYTE[3])                                        'MSB
     WriteBus(Value.BYTE[2])                                        'NMSB
     WriteBus(Value.BYTE[1])                                        'NLSB
     WriteBus(Value.BYTE[0])                                        'LSB
     Stop


' Special ------------not debugged, written in attempt to communicate with adafruit oled -------------------------------------------------------------------------

PUB WriteByteDirect(ChipAddr, FlagByte, OneByte)                    'Write direct, flagbyte determines if command, parameter or data,  register addressing not used

   IF CallChip(ChipAddr << 1)== ACK                                 'Shift left 1 to add on the read/write bit, default 0 (write)
     WriteBus(FlagByte)                                             'FlagByte determines if data is received as command, parameter or data
     WriteBus(OneByte)
     Stop


PUB WriteBlockDirect(ChipAddr, FlagByte, OneByte, begin_end)        'Write direct, flagbyte must signal 'data write' begin_end=  1:begin, 0:continue, -1:end
   IF begin_end== 1
     IF CallChip(ChipAddr << 1)== ACK                               'Shift left 1 to add on the read/write bit, default 0 (write)
        WriteBus(FlagByte)                                          'FlagByte determines if data is received as command, parameter or data
        WriteBus(OneByte)                                           'First byte of data
   ELSEIF begin_end== 0
      WriteBus(FlagByte)
      WriteBus(OneByte)                                             'A number of bytes of data
   ELSEIF begin_end== -1
       WriteBus(FlagByte)
       WriteBus(OneByte)                                            'Last byte of data
       Stop



'Read------------------------------------------------------------------------------------------------------
'Byte

PUB ReadByteA8(ChipAddr, RegAddr) | Value                           'Read a byte from specified chip and 8bit register address

   IF CallChip(ChipAddr << 1)== ACK                                 'Check if chip responded
     WriteBus(RegAddr)
     Start                                                          'Restart for reading
     WriteBus(ChipAddr << 1 | 1 )                                   'address again, but with the read/write bit set to 1 (read)
     Value:= ReadBus(NAK)
     Stop
     RETURN Value
   ELSE
     RETURN FALSE


PUB ReadByteA16(ChipAddr, RegAddr) | Value                          'Read a byte from specified chip and 16bit register address

   IF CallChip(ChipAddr << 1)== ACK                                 'Check if chip responded
     WriteBus(RegAddr.BYTE[1])                                      'MSB
     WriteBus(RegAddr.BYTE[0])                                      'LSB
     Start                                                          'Restart for reading
     WriteBus(ChipAddr << 1 | 1 )                                   'address again, but with the read/write bit set to 1 (read)
     Value:= ReadBus(NAK)
     Stop
     RETURN Value
   ELSE
     RETURN FALSE

'Word

PUB ReadWordA8(ChipAddr, RegAddr) | Value                           'Read a Word from specified chip and 8bit register address

   IF CallChip(ChipAddr << 1)== ACK                                 'Check if chip responded
     WriteBus(RegAddr)
     Start                                                          'Restart for reading
     WriteBus(ChipAddr << 1 | 1 )                                   'address again, but with the read/write bit set to 1 (read)
     Value.BYTE[3]:= 0                                              'clear the rubbish
     Value.BYTE[2]:= 0                                              'clear the rubbish
     Value.BYTE[1]:= ReadBus(ACK)                                   'MSB
     Value.BYTE[0]:= ReadBus(NAK)                                   'LSB
     Stop
     RETURN Value
   ELSE
     RETURN FALSE


PUB ReadWordA16(ChipAddr, RegAddr) | Value                          'Read a Word from specified chip and 16bit register address

   IF CallChip(ChipAddr << 1)== ACK                                 'Check if chip responded
     WriteBus(RegAddr.BYTE[1])                                      'MSB
     WriteBus(RegAddr.BYTE[0])                                      'LSB
     Start                                                          'Restart for reading
     WriteBus(ChipAddr << 1 | 1 )                                   'address again, but with the read/write bit set to 1 (read)
     Value.BYTE[3]:= 0                                              'clear the rubbish
     Value.BYTE[2]:= 0                                              'clear the rubbish
     Value.BYTE[1]:= ReadBus(ACK)                                   'MSB
     Value.BYTE[0]:= ReadBus(NAK)                                   'LSB
     Stop
     RETURN Value
   ELSE
     RETURN FALSE


'Long

PUB ReadLongA8(ChipAddr, RegAddr) | Value                           'Read a Long from specified chip and 8bit register address

   IF CallChip(ChipAddr << 1)== ACK                                 'Check if chip responded
     WriteBus(RegAddr)
     Start                                                          'Restart for reading
     WriteBus(ChipAddr << 1 | 1 )                                   'address again, but with the read/write bit set to 1 (read)
     Value.BYTE[3]:= ReadBus(ACK)                                   'MSB
     Value.BYTE[2]:= ReadBus(ACK)                                   'NMSB
     Value.BYTE[1]:= ReadBus(ACK)                                   'NLSB
     Value.BYTE[0]:= ReadBus(NAK)                                   'LSB
     Stop
     RETURN Value
   ELSE
     RETURN FALSE


PUB ReadLongA16(ChipAddr, RegAddr) | Value                          'Read a Long from specified chip and 16bit register address

   IF CallChip(ChipAddr << 1)== ACK                                 'Check if chip responded
     WriteBus(RegAddr.BYTE[1])                                      'MSB
     WriteBus(RegAddr.BYTE[0])                                      'LSB
     Start                                                          'Restart for reading
     WriteBus(ChipAddr << 1 | 1 )                                   'address again, but with the read/write bit set to 1 (read)
     Value.BYTE[3]:= ReadBus(ACK)                                   'MSB
     Value.BYTE[2]:= ReadBus(ACK)                                   'NMSB
     Value.BYTE[1]:= ReadBus(ACK)                                   'NLSB
     Value.BYTE[0]:= ReadBus(NAK)                                   'LSB
     Stop
     RETURN Value
   ELSE
     RETURN FALSE


'BUS LEVEL METHODS
'=============================================================================================================================================
PUB Reset                                                           'Do bus reset to clear any chips' activity

   OUTA[PINsda] := 0                                                'Float SDA
   REPEAT 9
     DIRA[PINscl] := 1                                              'Toggle SCL to clock out any remaining bits, maximum 8bits + acknak bit
     DIRA[PINscl] := 0                                              'or until
     IF (INA[PINsda])                                               'SDA is released to go high by chip(s)
       QUIT


PUB IsBusy

   IF INA[PINsda]== 1 AND INA[PINscl]== 1
     RETURN FALSE
   ELSE
     RETURN TRUE


PUB WhoOnBus(ptrOnBusArr) | onbus, addr                             'Fills an array with max 119 elements with addresses that get a response
                                                                    'and writes how many is onbus to the 0th element
   onbus:= 1

   REPEAT addr FROM %0000_1000 TO %0111_0111                        'Scan the entire address space, exept for reserved spaces
     IF CallChip(addr << 1)== ACK                                   'If a chip acknowledges,
       LONG[ptrOnBusArr][onbus]:= addr                              'put that address in the callers array
       LONG[ptrOnBusArr][0]:= onbus                                 'and update the total count of chips on the bus
       onbus++
       IF onbus> 119                                                'until loop expires or maximum number of elements in the array is reached
         Stop
         QUIT
     Stop                                                           'After each call send a stop signal to avoid confusion


PUB CallChip(ChipAddr) | acknak, t                                  'Address the chip until it acknowledges or timeout

  t:= CNT                                                           'Set start time
  REPEAT
     Start                                                          'Prepare chips for responding
     acknak:= WriteBus(ChipAddr)                                    'Address the chip
     IF CNT > t+ 10*mSec                                            'and break if timeout
       RETURN NAK
  UNTIL acknak == ACK                                               'or until it acknowledges
  RETURN ACK


PUB Start                                                           'Check that no chip is holding down SCL, then signal 'start'

   DIRA[PINsda] := 0
   DIRA[PINscl] := 0
   WAITPEQ(|<PINscl,|<PINscl, 0)                                    'Check/ wait for SCL to be released
   DIRA[PINsda] := 1                                                'Signal 'start'
   DIRA[PINscl] := 1


PUB WriteBus(BusByte) | acknak                                      'Clock out 8 bits to the bus

   BusByte := (BusByte ^ $FF) << 24                                 'XOR all bits with '1' to invert them, then shift left to bit 31
   REPEAT 8                                                         '(output the bits as inverted because DIRA:= 1 gives pin= '0')
     DIRA[PINsda] := BusByte <-= 1                                  'send msb first and bitwise rotate left to send the next bits
     DIRA[PINscl] := 0                                              'clock the bus
     DIRA[PINscl] := 1                                              'and leave SCL low

   DIRA[PINsda] := 0                                                'Float SDA to read ack bit
   DIRA[PINscl] := 0                                                'clock the bus
   acknak := INA[PINsda]                                            'read ack bit
   DIRA[PINscl] := 1                                                'and leave SCL low

   RETURN acknak


PUB ReadBus(acknak) | BusByte                                       'Clock in  8 bits from the bus

  DIRA[PINsda] := 0                                                 'Float SDA to read input bits

  REPEAT 8
    DIRA[PINscl] := 0                                               'clock the bus
    WAITPEQ(|<PINscl,|<PINscl, 0)                                   'check/ wait for SCL to be released
    BusByte := (BusByte << 1) | INA[PINsda]                         'read the bit
    DIRA[PINscl] := 1                                               'and leave SCL low

  DIRA[PINsda] := !acknak                                           'output nak if finished, ack if more reads
  DIRA[PINscl] := 0                                                 'clock the bus
  DIRA[PINscl] := 1                                                 'and leave SCL low

  RETURN BusByte


PUB Stop                                                            'Send stop sequence

  DIRA[PINsda] := 1                                                 'Pull SDA low
  DIRA[PINscl] := 0                                                 'float SCL and
  WAITPEQ(|<PINscl,|<PINscl,0)                                      'wait for SCL to be released
  DIRA[PINsda] := 0                                                 'and leave SDA floating


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