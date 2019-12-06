{{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Full-Duplex Communications Engine
//
// Author: Kwabena W. Agyeman
// Updated: 5/7/2012
// Designed For: P8X32A
// Version: 2.0
//
// Copyright (c) 2012 Kwabena W. Agyeman
// See end of file for terms of use.
//
// Update History:
//
// v1.0 - Original release - 1/2/2009.
// v1.1 - Made code faster - 2/18/2009.
// v1.2 - Reduced code size by more - 3/27/2009.
// v1.3 - Increased maximum speed - 7/15/2009.
// v1.4 - Identified timing errors with the code - 8/27/2009.
// v1.5 - Fixed timing errors and continous transfer errors - 8/30/2009.
// v1.6 - Added support for variable pin assignments - 7/27/2010.
// v1.7 - Rebuilt the entire driver and added a new interface - 5/29/2011.
// v1.8 - Added stop bit stretching and improved code - 8/29/2011.
// v1.9 - Added on the fly baud rate adjustment and fixed the serial receiver disabling issue - 8/30/2011.
// v2.0 - Increased the baud rate to 250K BPS at 96 MHz - 5/7/2012.
//
// For each included copy of this object only one spin interpreter should access it at a time.
//
// Nyamekye,
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Serial Circuit:
//
// Transmitter Pin Number --- Receiving Device Pin
//
// Receiver Pin Number --- Transmitting Device Pin
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}}

CON

  #0, Null, {
    } Start_Of_Heading, Start_Of_Text, End_Of_Text, End_Of_Transmission, {
    } Enquiry, Acknowledge, {
    } Bell, Backspace, Horizontal_Tab, Line_Feed, Vertical_Tab, Form_Feed, Carriage_Return, {
    } Shift_Out, Shift_In, Data_Link_Escape, {
    } Device_Control_1, Device_Control_2, Device_Control_3, Device_Control_4, {
    } Negative_Aknowledge, Synchronous_Idle, End_Of_Transmission_Block, Cancel, End_Of_Medium, Substitute, Escape, {
    } File_Seperator, Group_Seperator, Record_Seperator, Unit_Seperator

  #17, XON, #19, XOFF
  #34, Quotation_Marks, #127, Delete

VAR

  long cogNumber, lockNumber, baudNumber, stopNumber, transmitterNumber

  byte inputHead, inputTail, outputHead, outputTail, inputBuffer[256], outputBuffer[256]

PUB readByte '' 12 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Returns a byte from the serial port. May wait to receive the byte.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  readData(@result, 1)

PUB readShort '' 12 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Returns a short from the serial port. May wait to receive the short.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  readData(@result, 2)

PUB readLong '' 12 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Returns a long from the serial port. May wait to receive the long.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  readData(@result, 4)

PUB readString(stringPointer, maximumStringLength) '' 14 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Returns a string from the serial port. May wait to receive the string.
'' //
'' // This method will stop reading when line feed (ASCII 10) is found - it will be included within the string.
'' //
'' // This method will stop reading when carriage return (ASCII 13) is found - it will be included within the string.
'' //
'' // StringPointer - A pointer to a string to read to from the serial port.
'' // MaximumStringLength - The maximum read string length. Including the null terminating character.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  if(stringPointer and (maximumStringLength > 0))
    result := stringPointer

    bytefill(stringPointer--, 0, maximumStringLength--)
    repeat while(maximumStringLength--)
      ifnot( readData(++stringPointer, 1) and byte[stringPointer] and {
           } (byte[stringPointer] <> 10) and (byte[stringPointer] <> 13) )
        quit

PUB writeByte(value) '' 13 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Writes a byte out to be transmitted by the serial port. May wait to transmit the byte.
'' //
'' // Value - A byte.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  writeData(@value, 1)

PUB writeShort(value) '' 13 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Writes a short out to be transmitted by the serial port. May wait to transmit the short.
'' //
'' // Value - A short.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  writeData(@value, 2)

PUB writeLong(value) '' 13 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Writes a long out to be transmitted by the serial port. May wait to transmit the long.
'' //
'' // Value - A long.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  writeData(@value, 4)

PUB writeString(stringPointer) '' 13 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Writes a string out to be transmitted by the serial port. May wait to transmit the string.
'' //
'' // Value - A string.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  writeData(stringPointer, strsize(stringPointer))

PUB readData(addressToPut, count) | stride '' 9 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Reads data from the serial port. Returns the amount of data read from the serial port.
'' //
'' // AddressToPut - A pointer to the start of a data buffer to fill from the serial port.
'' // Count - The amount of data to read from the serial port. The data buffer must be at least this large.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  result := addressToPut
  setLock

  repeat while(count > 0)
    stride := (count <# ((256 - inputTail) <# 128))

    repeat ' Format saves two bytes.
    while(stride > receivedNumber)

    bytemove(addressToPut, @inputBuffer[inputTail], stride)
    inputTail += stride
    addressToPut += stride
    count -= stride

  clearLock
  return (addressToPut - result)

PUB writeData(addressToGet, count) | stride '' 9 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Writes data to the serial port. Returns the amount of data written to the serial port.
'' //
'' // AddressToPut - A pointer to the start of a data buffer to write to the serial port.
'' // Count - The amount of data to write to the serial port. The data buffer must be at least this large.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  result := addressToGet
  setLock

  repeat while(count > 0)
    stride := (count <# ((256 - outputHead) <# 128))

    repeat ' Format saves two bytes.
    while(stride > transmittedNumber)

    bytemove(@outputBuffer[outputHead], addressToGet, stride)
    outputHead += stride
    addressToGet += stride
    count -= stride

  clearLock
  return (addressToGet - result)

PUB receivedNumber '' 3 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Returns the number of used bytes in the receiver buffer. The receiver buffer can hold a maximum of 255 bytes.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  return ((inputHead - inputTail) & $FF)

PUB transmittedNumber '' 3 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Returns the number of free bytes in the transmitting buffer. The transmitter buffer can hold a maximum of 255 bytes.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  return (255 - ((outputHead - outputTail) & $FF))

PUB receiverFull '' 6 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Returns true if the receiver buffer is full and false if it is not.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  return (receivedNumber == 255)

PUB transmitterFull '' 6 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Returns true if the transmitter buffer is full and false if it is not.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  return (not(transmittedNumber))

PUB receiverEmpty '' 6 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Returns true if the receiver buffer is empty and false if it is not.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  return (not(receivedNumber))

PUB transmitterEmpty '' 6 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Returns true if the transmitter buffer is empty and false if it is not.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  return (transmittedNumber == 255)

PUB receiverFlush '' 3 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Flushes the receiver buffer.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  inputTail := inputHead

PUB transmitterFill '' 3 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Fills the transmitter buffer (with garbage).
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  outputHead := (outputTail - 1)

PUB baudRateTiming(baudRate) '' 4 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Sets the baud rate. The new baud rate goes into effect after the current byte is done being transmitted.
'' //
'' // BaudRate - The baud rate to transmit and receive at. Between 1 BPS and 250K BPS at 96 MHz.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  baudNumber := ((clkfreq / ((baudRate <# (clkfreq / constant(96_000_000 / 250_000))) #> 1)) / 4)

PUB stopBitTiming(extraStopBitsCount) '' 4 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Sets the e stop bit count. The new e stop bit count goes into effect after the current byte is done being transmitted.
'' //
'' // ExtraStopBitsCount - The extra stop bit count to transmit at. Between 0 e stop bits and 2,147,483,647 e stop bits.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  stopNumber := (extraStopBitsCount #> 0)

PUB COMEngineStart(receiverPin, transmitterPin, baudRate) '' 10 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Starts up the COM driver running on a cog, checks out a lock for the driver, and sets the extra stop bit count to zero.
'' //
'' // Returns true on success and false on failure.
'' //
'' // ReceiverPin - Pin to use to receive data on. This line is driven by the interface chip. -1 to disable.
'' // TransmitterPin - Pin to use to transmit data on. This line is driven by the propeller chip. -1 to disable.                                                                                                                                                                   ?
'' // BaudRate - The baud rate to transmit and receive at. Between 1 BPS and 250K BPS at 96 MHz.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  COMEngineStop

  baudRateTiming(baudRate)
  stopNumber := 0

  counterModeSetup := (constant(%00100 << 26) + (transmitterPin & $1F))

  RXPin := ((|<receiverPin) & (receiverPin <> -1))
  TXPin := ((|<transmitterPin) & (transmitterPin <> -1))

  baudNumberAddress := @baudNumber
  stopNumberAddress := @stopNumber
  inputHeadAddress := @inputHead
  inputTailAddress := @inputTail
  outputHeadAddress := @outputHead
  outputTailAddress := @outputTail
  inputBufferAddress := @inputBuffer
  outputBufferAddress := @outputBuffer

  lockNumber := locknew
  cogNumber := cognew(@initialization, @transmitterNumber)

  if((++lockNumber) and (++cogNumber) and (chipver == 1))
    return true

  COMEngineStop

PUB COMEngineStop '' 3 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Shuts down the COM driver running on a cog and returns the lock used by the driver. Waits for the transmitter to finish.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  if(cogNumber)

    repeat ' Format saves two bytes.
    while((not(transmitterEmpty)) or transmitterNumber)

    cogstop(-1 + cogNumber~)

  if(lockNumber)
    lockret(-1 + lockNumber~)

PRI setLock ' 3 Stack Longs

  if(lockNumber)

    repeat ' Format saves two bytes.
    while(lockset(lockNumber - 1))

PRI clearLock ' 3 Stack Longs

  if(lockNumber)
    lockclr(lockNumber - 1)

DAT

' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'                       COM Driver
' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

                        org     0

' //////////////////////Initialization/////////////////////////////////////////////////////////////////////////////////////////

initialization          neg     phsa,               #1                  ' Setup drivers.
                        mov     ctra,               counterModeSetup    '
                        mov     dira,               TXPin               '

                        rdbyte  receiverHead,       inputHeadAddress    ' Setup head and tail pointers.
                        rdbyte  transmitterTail,    outputTailAddress   '
                        mov     receiverPC,         #defaultReceiver    '
                        mov     transmitterPC,      #defaultTransmitter '

                        rdlong  baudRateSetup,      baudNumberAddress   ' Setup synchronization.
                        mov     counter,            baudRateSetup       '
                        add     counter,            cnt                 '

' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'                       Synchronize
' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

synchronize             waitcnt counter,            baudRateSetup       ' Run transmitter 1/4 of the time.
                        jmpret  buffer,             transmitterPC       '

                        waitcnt counter,            baudRateSetup       ' Run receiver 1/4 of the time.
                        jmpret  buffer,             receiverPC          '

                        waitcnt counter,            baudRateSetup       ' Run receiver 1/4 of the time.
                        jmpret  buffer,             receiverPC          '

                        waitcnt counter,            baudRateSetup       ' Run receiver 1/4 of the time.
                        jmpret  buffer,             receiverPC          '

                        jmp     #synchronize                            ' Loop.

' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'                       Receiver
' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

receiver                jmpret  receiverPC,         buffer              ' Run some code.

defaultReceiver         test    RXPin,              ina wc              ' Check for start bit.
                        tjz     RXPin,              #receiver           '
if_c                    jmp     #receiver                               '

' //////////////////////Receiver Setup/////////////////////////////////////////////////////////////////////////////////////////

                        jmpret  receiverPC,         buffer              ' Setup loop to receive the packet.
                        mov     receiverCounter,    #8                  '

' //////////////////////Receive Packet/////////////////////////////////////////////////////////////////////////////////////////

receive                 jmpret  receiverPC,         buffer              ' Wait a baud time.
                        jmpret  receiverPC,         buffer              '
                        jmpret  receiverPC,         buffer              '

                        test    RXPin,              ina wc              ' Input bits.
                        rcr     receiverBuffer,     #1                  '

                        djnz    receiverCounter,    #receive            ' Ready next bit.
                        shr     receiverBuffer,     #24                 '

                        rdbyte  receiverTail,       inputTailAddress    ' Check if the buffer is full.
                        sub     receiverTail,       #1                  '
                        and     receiverTail,       #$FF                '

                        jmpret  receiverPC,         buffer              ' Wait 1/2 stop bit.

                        cmp     receiverTail,       receiverHead wz     ' Set packet.
if_nz                   mov     receiverCounter,    inputBufferAddress  '
if_nz                   add     receiverCounter,    receiverHead        '
if_nz                   wrbyte  receiverBuffer,     receiverCounter     '

if_nz                   add     receiverHead,       #1                  ' Update receiver head pointer.
if_nz                   and     receiverHead,       #$FF                '
if_nz                   wrbyte  receiverHead,       inputHeadAddress    '

                        jmpret  receiverPC,         buffer              ' Wait 1/2 stop bit.

' //////////////////////Repeat/////////////////////////////////////////////////////////////////////////////////////////////////

                        jmp     #receiver                               ' Repeat.

' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'                       Transmitter
' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

transmitter             jmpret  transmitterPC,      buffer              ' Run some code.

defaultTransmitter      rdbyte  transmitterHead,    outputHeadAddress   ' Check if the buffer is empty.
                        sub     transmitterHead,    transmitterTail wz  '
if_z                    jmpret  transmitterPC,      buffer              '
                        wrlong  transmitterHead,    par                 '

                        mov     transmitterCounter, outputBufferAddress ' Get packet.
                        add     transmitterCounter, transmitterTail     '
                        rdlong  baudRateSetup,      baudNumberAddress   '
                        tjz     transmitterHead,    #transmitter        '

                        jmpret  transmitterPC,      buffer              ' Output the start bit.
                        mov     phsa,               #0                  '
                        rdbyte  phsa,               transmitterCounter  '

' //////////////////////Transmitter Setup//////////////////////////////////////////////////////////////////////////////////////

                        rdlong  transmitterCounter, stopNumberAddress   ' Update state.

                        add     transmitterTail,    #1                  ' Update transmitter tail pointer.
                        and     transmitterTail,    #$FF                '
                        wrbyte  transmitterTail,    outputTailAddress   '

                        add     transmitterCounter, #9                  ' Setup loop to transmit the packet.

' //////////////////////Transmit Packet////////////////////////////////////////////////////////////////////////////////////////

transmit                or      phsa,               #$100               ' Output bits.
                        jmpret  transmitterPC,      buffer              '
                        ror     phsa,               #1                  '

                        djnz    transmitterCounter, #transmit           ' Ready next bit.

' //////////////////////Repeat/////////////////////////////////////////////////////////////////////////////////////////////////

                        jmp     #defaultTransmitter                     ' Repeat.

' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'                       Data
' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

counterModeSetup        long    0

' //////////////////////Pin Masks//////////////////////////////////////////////////////////////////////////////////////////////

RXPin                   long    0
TXPin                   long    0

' //////////////////////Addresses//////////////////////////////////////////////////////////////////////////////////////////////

baudNumberAddress       long    0
stopNumberAddress       long    0
inputHeadAddress        long    0
inputTailAddress        long    0
outputHeadAddress       long    0
outputTailAddress       long    0
inputBufferAddress      long    0
outputBufferAddress     long    0

' //////////////////////Run Time Variables/////////////////////////////////////////////////////////////////////////////////////

baudRateSetup           res     1

buffer                  res     1
counter                 res     1

' //////////////////////Receiver Variables/////////////////////////////////////////////////////////////////////////////////////

receiverBuffer          res     1
receiverCounter         res     1
receiverHead            res     1
receiverTail            res     1

receiverPC              res     1

' //////////////////////Transmitter Variables//////////////////////////////////////////////////////////////////////////////////

transmitterBuffer       res     1
transmitterCounter      res     1
transmitterHead         res     1
transmitterTail         res     1

transmitterPC           res     1

' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

                        fit     496

{{

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                  TERMS OF USE: MIT License
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
// Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}}
