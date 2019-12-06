{{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// RS232 Communications Engine
//
// Author: Kwabena W. Agyeman
// Updated: 7/27/2010
// Designed For: P8X32A
// Version: 1.6
//
// Copyright (c) 2010 Kwabena W. Agyeman
// See end of file for terms of use.
//
// Update History:
//
// v1.0 - Original release - 1/2/2009.
// v1.1 - Made code faster - 2/18/2009.
// v1.2 - Reduced code size by more - 3/27/2009.
// v1.3 - Increased maximum speed - 7/15/2009.
// v1.5 - Fixed timing errors and continous transfer errors - 8/30/2009.
// v1.6 - Added support for variable pin assignments. - 7/27/2010.
//                                   
// For each included copy of this object only one spin interpreter should access it at a time.
//
// Nyamekye,
// v1.7 - by spiritplumber@gmail.com standardized i/o with other spin serial objects - no numeric output, use ftof instead
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Serial Circuit:
//
// Transmitter Pin Number --- Receiving Device
// Receiver Pin Number    --- Transmitting Device
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

  long cog
  byte inputHead, inputTail, outputHead, outputTail, inputBuffer[256], outputBuffer[256]

PUB rx '' 6 Stack Longs
  repeat until(available)
  return inputBuffer[inputTail++]

PUB available '' 3 Stack Longs
  return ((inputHead - inputTail) & $FF)

PUB rxfull '' 6 Stack Longs
  return (available == $FF)

PUB rxflush '' 3 Stack Longs
  inputTail := inputHead

PUB tx(character) '' 4 Stack Longs
  repeat until(outputTail <> ((outputHead + 1) & $FF))
  outputBuffer[outputHead++] := character

PUB str(StringAddr) '' 8 Stack Longs
  repeat strsize(StringAddr)
    tx(byte[StringAddr++])
    
PUB rxcheck : rxbyte
  if (available)
      return inputBuffer[inputTail++]
  return -1
PUB rxtime(ms) : t 

'' Wait ms milliseconds for a byte to be received
'' returns -1 if no byte received, $00..$FF if byte
  t := cnt
  repeat
    if (cnt - t) / (clkfreq / 1000) > ms
       return -1
  until available
  return inputBuffer[inputTail++]

pub start (rp,tp,f,b) ' for compatibility with fullduplexserial: flags are not actually read
return init(rp,tp,b)

PUB init(receiverPin, transmitterPin, baudRate) '' 9 Stack Longs
    stop

    baudRateSetup := ((clkfreq / ((baudRate <# (clkfreq / constant(80_000_000 / 250_000))) #> 1)) / 4)

    baudRate := ((transmitterPin <# 31) #> 0)
    counterModeSetup := (baudRate + constant(%0_0100 << 26))

    RXPin := ((|<((receiverPin <# 31) #> 0)) & (receiverPin <> -1))
    TXPin := ((|<baudRate) & (transmitterPin <> -1))

    inputHeadAddress := @inputHead
    inputTailAddress := @inputTail
    outputHeadAddress := @outputHead
    outputTailAddress := @outputTail
    inputBufferAddress := @inputBuffer
    outputBufferAddress := @outputBuffer

    cog := cognew(@initialization[0], @cog[0])
    result or= ++cog

PUB stop '' 3 Stack Longs

  if(cog)
    cogstop(-1 + cog~)

PUB hex(value, digits)

'' Print a hexadecimal number

  value <<= (8 - digits) << 2
  repeat digits
    tx(lookupz((value <-= 4) & $F : "0".."9", "A".."F"))


PUB bin(value, digits)

'' Print a binary number

  value <<= 32 - digits
  repeat digits
    tx((value <-= 1) & 1 + "0")

PUB dec(value) | i

'' Print a decimal number

  if value < 0
    -value
    tx("-")

  i := 1_000_000_000

  repeat 10
    if value => i
      tx(value / i + "0")
      value //= i
      result~~
    elseif result or i == 1
      tx("0")
    i /= 10



DAT

' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'                       COM Driver
' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

                        org     0

' //////////////////////Initialization/////////////////////////////////////////////////////////////////////////////////////////

initialization          mov     transmitterPC,      #transmitter        ' Setup transmitter.
                        neg     phsa,               #1                  '
                        mov     ctra,               counterModeSetup    '
                        mov     dira,               TXPin               '

                        rdlong  receiverHead,       inputHeadAddress    ' Setup head and tail pointers.
                        rdlong  transmitterTail,    outputTailAddress   '

                        mov     counter,            baudRateSetup       ' Setup synchronization.
                        add     counter,            cnt                 '

' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'                       Receiver
' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

receiver                add     counter,            baudRateSetup       ' Add in phase offset.

                        waitcnt counter,            baudRateSetup       ' Wait for transmitter.
                        jmpret  receiverPC,         transmitterPC       '

                        waitcnt counter,            baudRateSetup       ' Wait for start bit.
                        test    RXPin,              ina wz              '

if_nz                   waitcnt counter,            baudRateSetup       ' Wait for start bit.
if_nz                   test    RXPin,              ina wc              '

if_nz_and_c             jmp     #receiver                               ' Repeat.

' //////////////////////Receiver Setup/////////////////////////////////////////////////////////////////////////////////////////

                        mov     receiverCounter,    #9                  ' Setup loop to receive the packet.

' //////////////////////Receive Packet/////////////////////////////////////////////////////////////////////////////////////////

receive                 waitcnt counter,            baudRateSetup       ' Input bits.
                        test    RXPin,              ina wc              '
                        rcl     receiverBuffer,     #1                  '

if_z                    add     counter,            baudRateSetup       ' Wait for transmitter.
                        waitcnt counter,            baudRateSetup       '
                        jmpret  receiverPC,         transmitterPC       '
if_nz                   add     counter,            baudRateSetup       '
                        waitcnt counter,            baudRateSetup       '

                        djnz    receiverCounter,    #receive            ' Ready next bit.

                        rev     receiverBuffer,     #24                 ' Reverse backwards bits.

' //////////////////////Update Packet//////////////////////////////////////////////////////////////////////////////////////////

                        rdbyte  receiverTail,       inputTailAddress    ' Check if the buffer is full.
                        mov     buffer,             receiverHead        '
                        sub     buffer,             receiverTail        '
                        and     buffer,             #$FF                '
                        cmp     buffer,             #255 wc             '

' //////////////////////Set Packet/////////////////////////////////////////////////////////////////////////////////////////////

if_z                    add     counter,            baudRateSetup       ' Set packet and synchronize.
if_c                    mov     buffer,             inputBufferAddress  '
if_c                    add     buffer,             receiverHead        '
if_c                    wrbyte  receiverBuffer,     buffer              '

if_c                    add     receiverHead,       #1                  ' Update receiver head pointer.
if_c                    and     receiverHead,       #$FF                '
if_c                    wrbyte  receiverHead,       inputHeadAddress    '

' //////////////////////Repeat/////////////////////////////////////////////////////////////////////////////////////////////////

                        jmp     #receiver                               ' Repeat.

' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'                       Transmitter
' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

transmitter             jmpret  transmitterPC,      receiverPC          ' Run some code.

loop                    rdbyte  buffer,             outputHeadAddress   ' Check if the buffer is empty.
                        sub     buffer,             transmitterTail     '
                        tjz     buffer,             #transmitter        '

' //////////////////////Get Packet/////////////////////////////////////////////////////////////////////////////////////////////

                        mov     transmitterBuffer,  outputBufferAddress ' Get packet and output start bit.
                        add     transmitterBuffer,  transmitterTail     '
                        jmpret  transmitterPC,      receiverPC          '
                        rdbyte  phsa,               transmitterBuffer   '

                        add     transmitterTail,    #1                  ' Update transmitter tail pointer.
                        and     transmitterTail,    #$FF                '
                        wrbyte  transmitterTail,    outputTailAddress   '

' //////////////////////Transmitter Setup///////////////////////////////////////////////////////////////////////////////////////

                        mov     transmitterCounter, #9                  ' Setup loop to transmit the packet.

' //////////////////////Transmit Packet////////////////////////////////////////////////////////////////////////////////////////

transmit                or      phsa,               #$100               ' Output bits.
                        jmpret  transmitterPC,      receiverPC          '
                        ror     phsa,               #1                  '

                        djnz    transmitterCounter, #transmit           ' Ready next bit.

' //////////////////////Repeat/////////////////////////////////////////////////////////////////////////////////////////////////

                        jmp     #loop                                   ' Repeat.

' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'                       Data
' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

baudRateSetup           long    0
counterModeSetup        long    0

' //////////////////////Pin Masks//////////////////////////////////////////////////////////////////////////////////////////////

RXPin                   long    0
TXPin                   long    0

' //////////////////////Addresses//////////////////////////////////////////////////////////////////////////////////////////////

inputHeadAddress        long    0
inputTailAddress        long    0
outputHeadAddress       long    0
outputTailAddress       long    0
inputBufferAddress      long    0
outputBufferAddress     long    0

' //////////////////////Run Time Variables/////////////////////////////////////////////////////////////////////////////////////

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