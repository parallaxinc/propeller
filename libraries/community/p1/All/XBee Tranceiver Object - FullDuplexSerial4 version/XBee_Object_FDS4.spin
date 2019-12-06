{{
*********************************************
*  XBee Object - FullDuplexSerial4 version  *
*  Author: Albert Emanuel Milani            *
*  Copyright (c) 2014 AEM                   *
*  See end of file for terms of use.        *
*********************************************
This object was modified by Albert Emanuel Milani from Martin Hebel's Xbee
Object Library to use pcFullDuplexSerial4FC512.spin instead of
FullDuplexSerial.spin

Start using Start or AddPort - they do the exact same thing.  There are two
because I wanted to rename it to AddPort but didn't want to confuse people
moving from the original version of this library

I also added API_AddArray, API_RxCheck, API_PacketLen, and dataSetPtr

Example:

PUB main
  xb .addPort(xbp, xbrx, xbtx, -1,-1,0,0, 19200)        'XBee
  ser.addPort(dbgp,dbgrx,dbgtx,-1,-1,0,0,115200)        'debug
  mb .addPort(mbp, mbrx, mbtx, -1,-1,0,0,  9600)        'modbus

  xb.api_newpacket

  xb.api_addstr(string("Hello World!"))

  xb.api_array(remoteaddr, xb.api_packet, xb.api_packetlen)

xb is this object, ser is pcFullDuplexSerial4FC512, and mb is my modbus library

}}
{{
Based on

  *************************************************
  *             XBee Object Library               *
  *                Version 1.6                    *
  *                  9/1/10                       *
  *            Author: Martin Hebel               *
  *    Southern Illinois University Carbondale    *
  *        Electronic Systems Technologies        *
  *                                               *
  *         Copyright 2009, Martin Hebel          *
  *************************************************
  *   See end of files for distribution terms     *
  *************************************************


Example code for starting:
' **************************
OBJ
    XB : "XBee_Object"

Pub Start
    XB.start(7,6,0,9600)           ' XBee Comms - RX,TX, Mode, Baud
    XB.AT_Init                     ' Initialize for fast AT command use - 5 second delay to perform
    XB.AT_ConfigVal(string("ATMY"),$5) ' Set MY address to 5
    .
    .
    .
    XB.str(string("Hello!",13))    ' Send a string
    Value := XB.RxDec              ' accept a decimal value.
' ****************************

This object supports both AT and API modes.

API mode allow reception via an incoming packet which can contain senders address,
RSSI level for reception, transmission status reports, etc.

API mode also allows data to a unit be performed by defining where to send:
XB.API_TX_str(5,string("Hello 5!"))  ' send string to Addy 5.

To shift XBee into API mode for a default configured unit:
   XB.AT_Config(string("ATAP 1"))

Notes:

This object does not currently use escape-sequences for special characters (11,13,7D,7E),
though I've not seen any issues.

Also, does not yet perform checksum error checking on received API packets nor 64-bit addressing.

This object does support reception of auto DIO/ADC packets (firmware versions 10A2/3)
If using the auto-sending features for DIO/ADC data for the XBee.
*** Data is now parsed out, see examples below ***

As data may come in fast and furious, without running in seperate cogs and creating more buffer
passing between them, chances of missing packets is possible if there are heavy transactions, of course,
dependent of what else is going on.  Reception of packets > 100 bytes (multiple payloads) not currently
supported.

Remote configuration using Firmward 10CD or higher IS supported.

Please see the XBee manual!

Revisions:
- Added automatic parsing of API analog data

- Added remote configuration API for firmware 10CD

- Added multiple methods for ease of use, please see below.

- Modified certain methods to accept/parse on commas in data

7/30/10
- Fixed byte clearing in RxStr for 100 character
- Removed support for RTS pin (wasn't well implemented)
  You can control RTS yourself if needed - Low to allow flow, high to stop flow
-Corrected problems with Command Query/Response & Remote Query/Response
 Receiving of value has changed, use XB.RxValue for data

}}

VAR
  Byte dataSet[120],_RxData[105], DigOffset
  Long _SrcAddr16, _RxLen, _RxValue
  Byte _RxFlag,_RxIdent, _RxOpt, _RxFrameID, _RxCmd[3], _Status, _FrameID, _API_Ready, _RSSI
  Byte dataIn[255], PacketOut[105], PacketPtr
  long _RxADC[6], _RxDig, _RxBit[8], _Temp2

  byte port

OBJ
  FDSerial4 : "pcFullDuplexSerial4FC512"

Pub Start (_port,rxpin,txpin,ctspin,rtspin,rtsthreshold,mode,baudrate)
{{
For partial compatibility with the original - just add a port number
}}
  AddPort(_port,rxpin,txpin,ctspin,rtspin,rtsthreshold,mode,baudrate)

PUB AddPort(_port,rxpin,txpin,ctspin,rtspin,rtsthreshold,mode,baudrate) |Started, ptr
{{
   Calls FDSerial4.AddPort to define a port, and initializes this XBee object
   Has same name as in FDSerial4 so you can just say XB instead of FDS4 and have everything line up nicely

   mode bit 0 = invert rx
   mode bit 1 = invert tx
   mode bit 2 = open-drain/source tx
   mode bit 3 = ignore tx echo on rx

   Sets XBee for low gaurd time for fast AT Command use - no it doesn't?
}}

    port := _port

    Started := FDSerial4.addPort(_port,rxpin,txpin,ctspin,rtspin,rtsthreshold,mode,baudrate)
    'if Started == -1
    '  return Started

    'FDSerial4.rxflush(port)     ' just for fun

    _FrameID := 1

    repeat ptr from 0 to 5                  ' set ADC data to -1
         _RxADC[ptr] := -1

PUB Stop
    '' See FullDuplex Serial Documentation
    'FDSerial4.Stop
    abort ' you can't!

PUB Tx (data)
    '' See FullDuplex Serial Documentation
    '' Serial.tx(13)   ' Send byte of data
    '' FOR Transparent (Non-API) MODE USE
    FDSerial4.tx(port, data)

Pub CR
   Tx(13)

PUB str(stringptr)
    '' See FullDuplex Serial Documentation
    '' XB.str(String("Hello World"))      ' transmit a string
    '' FOR Transparent (Non-API) MODE USE
    FDSerial4.str(port, stringptr)

PUB dec(value)
    '' See FullDuplex Serial Documentation
    '' XB.dec(1234)       ' send decimal value as chracters
    '' FOR Transparent (Non-API) MODE USE
    FDSerial4.dec(port, value)

PUB hex(value, digits)
    '' See FullDuplex Serial Documentation
    '' XB.hex(1234,4)      ' send value as hex string for 4 digits
    '' FOR Transparent (Non-API) MODE USE
    FDSerial4.hex(port, value, digits)

PUB bin(value, digits)
    '' See FullDuplex Serial Documentation
    '' XB.bin(32,8)      ' send value as binary string for 8 digits
    '' FOR Transparent (Non-API) MODE USE
    FDSerial4.bin(port, value, digits)

PUB RxCheck
    '' See FullDuplex Serial Documentation
    return (FDSerial4.RxCheck(port))

PUB RxFlush
    '' See FullDuplex Serial Documentation
    FDSerial4.RxFlush(port)

Pub Rx
    '' See FullDuplex Serial Documentation
    '' x := Serial.RX   ' receives a byte of data
    '' FOR Transparent (Non-API) MODE USE

    return (FDSerial4.rx(port))

PUB RxTime(ms)
    '' See FullDuplex Serial Documentation
    '' x:= Serial.RxTime(100)  ' receive byte with 100mS timeout
    '' FOR Transparent (Non-API) MODE USE
    return (FDSerial4.RxTime(port, ms))



PUB rxDec : Value | ptr
{{
   Accepts and returns serial decimal values, such as "1234" as a number.
   String must end in a carriage return or comma (ASCII 13)
   x:= Serial.rxDec     ' accept string of digits for value
   Multiple comma separated can be accepted with sequential calls.
}}

    ptr := 0
    dataIn[ptr] := Rx
    ptr++
    repeat while (DataIn[ptr-1] <> 13) and (DataIn[ptr-1] <> ",")
       dataIn[ptr] := Rx
       ptr++
    return ConvDEC(ptr)


PUB rxDecTime(ms)| ptr, temp
{{
   Accepts and returns serial decimal values, such as "1234" as a number
   with a timeout value.  No data returns -1
   String must end in a carriage return (ASCII 13) or comma
   x := Serial.rxDecTime(100)   ' accept data with timeout of 100mS
   Multiple comma separated can be accepted with sequential calls.
}}


    ptr := 0
    temp :=  RxTime(ms)
    if temp == -1
       return -1
       abort
    dataIn[ptr] := Temp
    ptr++
    repeat while (DataIn[ptr-1] <> 13) and (DataIn[ptr-1] <> ",")
      dataIn[ptr] :=  RxTime(ms)
      if datain[ptr] == 255
        return -1
        abort
      ptr++
    return ConvDEC(ptr)

PUB rxHex :Value | place, ptr, x, temp
{{
   Accepts and returns serial hexadecimal values, such as "A2F4" as a number.
   String must end in a carriage return (ASCII 13) or comma
   x := Serial.rxHex     ' accept string of hex digits for value
}}


    place := 1
    ptr := 0
    value :=0
    temp :=  Rx
    if temp == -1
       return -1
       abort
    dataIn[ptr] := Temp
    ptr++
    repeat while (DataIn[ptr-1] <> 13) and (DataIn[ptr-1] <> ",")
      dataIn[ptr] :=  Rx
      if datain[ptr] == 255
        return -1
        abort
      ptr++
    Value := ConvHex(ptr)

PUB RxHexTime(ms) :Value | place, ptr, x, temp
{{
   Accepts and returns serial hexadecimal values, such as "A2F4" as a number.
   with a timeout value.  No data returns -1
   String must end in a carriage return (ASCII 13) or commas
   x := Serial.rxHexTime(100)     ' accept string of digits for value with 100mS timeout
}}
    place := 1
    ptr := 0
    value :=0
    temp :=  RxTime(ms)
    if temp == -1
       return -1
       abort
    dataIn[ptr] := Temp
    ptr++
    repeat while (DataIn[ptr-1] <> 13) and (DataIn[ptr-1] <> ",")
      dataIn[ptr] :=  RxTime(ms)
      if datain[ptr] == 255
        return -1
        abort
      ptr++
    Value := ConvHex(ptr)

PUB RxStr (stringptr) : Value | ptr
{{
  Accepts a string of characters - up to 100 - to be passed by reference
  String acceptance terminates with a carriage return.
  Will accept up to 100 characters
  XB.rxStr(@MyStr)
  XB.str(@MyStr)
  FOR Transparent (Non-API) MODE USE
 }}
    ptr:=0
    bytefill(@dataSet,0,100)
   dataSet[ptr] :=  Rx
   ptr++
   repeat while (dataSet[ptr-1] <> 13) and (ptr < 101)
       dataSet[ptr] :=  RX
       ptr++
   dataSet[ptr-1]:=0
   byteMove(stringptr,@dataSet,16)

PUB RxStrTime (ms,stringptr) : Value | ptr, temp
{{
  Accepts a string of characters - up to 100 - to be passed by reference
  Allow timeout value.
  String acceptance terminates with a carriage return.
  Will accept up to 100 characters before passing back.
  XB.RxStrTime(200,@MyStr)
  XB.str(@MyStr)
  FOR Transparent (Non-API) MODE USE
 }}

    ptr:=0
    bytefill(@dataSet,0,100)
    bytefill(stringptr,0,100)
   temp :=  RxTime(ms)
   if temp <> -1
      dataSet[ptr] := temp
      ptr++
      repeat 100
          temp :=  RxTime(ms)
          if temp == -1
             ptr++
             quit
          dataSet[ptr] := temp
          ptr++
      dataSet[ptr-1]:=0
      byteMove(stringptr,@dataSet,100)



Pub AT_Init
{{
    Configure for low guard time for AT mode.
    Requires 5 seconds.  Required if AT_Config used.
}}

    delay(3000)
    str(string("+++"))
    delay(2000)
    rxflush
    str(string("ATGT 3,CN"))
    tx(13)
    delay(500)
    rxFlush
    return 0


PUB AT_Config(stringptr)
{{
  Send a configuration string for AT Mode
  XB.AT_Config(string("ATMY 2"))
  May also be used to query
  XB.AT_Config(string("ATMY"))   ' request value
  addr := XB.RxHEX               ' accept value
  FOR Transparent (Non-API) MODE USE
  Be sure to issue .AT_Init once at startup
}}
    delay(100)
    str(string("+++"))
    delay(100)
    rxflush
    str(stringptr)
    tx(13)
    str(string("ATCN"))
    tx(13)
    delay(10)

PUB AT_ConfigVal(stringptr,val)
{{
  Send a configuration string for AT Mode with a value
  XB.AT_Config(string("ATMY"), My_Addr)
  FOR Transparent (Non-API) MODE USE
  Be sure to issue XB.AT_Init once at startup
}}
    delay(100)
    str(string("+++"))
    delay(100)
    rxflush
    str(stringptr)
    hex(val,4)
    tx(13)
    str(string("ATCN"))
    tx(13)
    delay(10)



Pub API_Tx(addy16,char)| Length, chars, csum,ptr
{{
 Transmit a byte to a unit using API mode - 16 bit addressing
  XB.API_Str(2,ADC_Val)        ' Send byte data to address 2
  TX response of acknowledgement will be returned if FrameID not 0
  XB.API_RX
  If XB.Status == 0 '0 = Acc, 1 = No Ack
  To send more than 1 byte of data in a packet, use the API_Str method and assemble a string
  myStr[0] := adc_val >> 8  ' high byte
  myStr[1] := adc_val
  myStr[2] := 0
  API_Str(2,@myStr)
   OR, use Number object to create string of values:
  API_Str(2,num.ToStr(ADC_Val,num#DEC))
}}

  ptr := 0
  dataSet[ptr++] := $7E
  Length := 6                             ' API Ident + FrameID + API TX cmd + AddrHigh + AddrLow +Options
  dataSet[ptr++] := Length >> 8           ' MSB
  dataSet[ptr++] := Length                ' LSB
  dataSet[ptr++] := $01                   ' API Ident for AT Command (non queue)
  dataSet[ptr++] := _FrameID                   ' Frame ID
  dataSet[ptr++] := addy16 >>8            ' Dest Address MSB
  dataSet[ptr++] := addy16                ' Dest Address LSB
  dataSet[ptr++] := $00                   ' Options '$01 = disable ack, $04 = Broadcast PAN
  dataSet[ptr++] := char  ' Add char to packet
  csum := $FF                         ' Calculate checksum
  Repeat chars from 3 to ptr-1
    csum := csum - dataSet[chars]
  dataSet[ptr] := csum

  Repeat chars from 0 to ptr
    tx(dataSet[chars])

Pub API_Str (addy16,stringptr)| Length, chars, csum,ptr
{{
  Transmit a string to a unit using API mode - 16 bit addressing
  XB.API_Str(2,string("Hello number 2"))     ' Send data to address 2
  TX response of acknowledgement will be returned if FrameID not 0
  XB.API_RX
  If XB.Status == 0 '0 = Acc, 1 = No Ack

 }}
  ptr := 0
  dataSet[ptr++] := $7E
  Length := strsize(stringptr) + 5  ' API Ident + FrameID + API TX cmd +
                                    ' AddrHigh + AddrLow + Options
  dataSet[ptr++] := Length >> 8     ' Length MSB
  dataSet[ptr++] := Length          ' Length LSB
  dataSet[ptr++] := $01             ' API Ident for 16-bit TX
  dataSet[ptr++] := _FrameID        ' Frame ID
  dataSet[ptr++] := addy16 >>8      ' Dest Address MSB
  dataSet[ptr++] := addy16          ' Dest Address LSB
  dataSet[ptr++] := $00             ' Options '$01 = disable ack,
                                    ' $04 = Broadcast PAN ID
  Repeat strsize(stringptr)         ' Add string to packet
     dataSet[ptr++] := byte[stringptr++]
  csum := $FF                       ' Calculate checksum
  Repeat chars from 3 to ptr-1
    csum := csum - dataSet[chars]
  dataSet[ptr] := csum

  Repeat chars from 0 to ptr
    tx(dataSet[chars])              ' Send bytes to XBee

Pub API_Rx| char, ptr
{{
  Wait for incoming packet until packet identifer found ($7E)
  Then process packet.
  XB.API_RX
  Once data is received, the type of packet can be checked for processing:
  IF XB.RxData == $ 83 ' message string
      ...
  See RxPacket Now for more information
}}
    _RxIdent := $FF
    dataSet[0] := 0
    repeat
      char := FDSerial4.rx(port)
    while (char <> $7E)
    RxPacketNow

Pub API_RxTime(ms)| char, ptr, count
{{
  Wait for incoming data with timeout.
  This method actually loops number of times specified looking
  for packet identifier ($7E).
  If no data received, can be checked with RxIdent:
    If XB.Rx_Ident == $ff ' no data
  Once data is received, the type of packet can be checked for processing:
    IF XB.RxData == $81 ' message string
      ...
  See RxPacket Now for more information
}}
    dataSet[0] := 0
    _RxIdent := $ff
    repeat ms
      char := FDSerial4.rxTime(port, 1)
      If char == $7E
         RxPacketNow
         quit

Pub API_RxCheck | char, pt 'AE
{{
  Wait for incoming packet until packet identifer found ($7E), or for empty buffer
  If empty buffer, return 0
  Otherwise, process packet and return 1
  XB.API_RXCheck
  Once data is received, the type of packet can be checked for processing:
  IF XB.RxData == $ 83 ' message string
      ...
  See RxPacket Now for more information
}}
    _RxIdent := $FF
    dataSet[0] := 0
    repeat
      char := FDSerial4.rxcheck(port)
    while (char <> $7E) and char <> -1

    if char == $7E
      RxPacketNow
      return 1

    return 0

Pub API_Config (stringptr, val)| Length, chars, csum, ptr
{{
  Sends AT commands in API mode to be immediately processed.
  If FrameID is not 0, status will be returned as to success.
  XB.API_Config(string("DL"),$2)  ' Note, value and command are 2 parameters
}}

  dataSet[0]   := $7E
  Length := 11                  ' API Ident + FrameID + AT cmd + 4 bytes of data
  dataSet[1] := 0               ' MSB
  dataSet[2] := 08              ' LSB
  dataSet[3] := $08             ' API Ident for AT Command (non queue)
  dataSet[4] := _FrameID        ' Frame ID
  dataSet[5] := byte[stringptr]
  dataSet[6] := byte[stringptr + 1]
  dataSet[7] := val >> 24
  dataSet[8] := val >> 16
  dataSet[9] := val >> 8
  dataSet[10] := val
  csum := $FF                   ' Calculate checksum
  Repeat chars from 3 to 10
    csum := csum - dataSet[chars]
  dataSet[11] := csum
  Repeat chars from 0 to 11
    tx(dataSet[chars])

Pub API_Query (stringptr)| Length, chars, csum
{{
  Sends AT command in API mode to query a parameter value.
  Should also be used to set network identifier.
  Data is returned as an AT response as a string.
  XB.API_Query(string("DL"))                         ' Query
  XB.API_Rx                                          ' accept response
  myDL := XB.RxValue                                 ' Get returned value
}}
  dataSet[0] := $7E
  Length := 4                         ' API Ident + FrameID + AT cmd
  dataSet[1] := Length >> 8           ' MSB
  dataSet[2] := Length                ' LSB
  dataSet[3] := $08                   ' API Ident for AT Command (non queue)
  dataSet[4] := _FrameID              ' Frame ID
  dataSet[5] := byte[stringptr]
  dataSet[6] := byte[stringptr + 1]
  csum := $FF                         ' Calculate checksum
  Repeat chars from 3 to 6
    csum := csum - dataSet[chars]
  dataSet[7] := csum
  Repeat chars from 0 to 7            ' Send data
    tx(dataSet[chars])



Pub API_Queue (stringptr, val)| Length, chars, csum
{{
 Uses API mode to queue an AT command.
 Commands will not be processed until a non-queud command is sent or
 AC (apply changes) is issued.
 XB.API_Queue(string("DL"),$5) ' Note, value and command are 2 parameters
}}

  dataSet[0]   := $7E
  Length := 11                  ' API Ident + FrameID + AT cmd + 4 bytes of data
  dataSet[1] := 0               ' MSB
  dataSet[2] := 08              ' LSB
  dataSet[3] := $09             ' API Ident for AT Command (queue)
  dataSet[4] := _FrameID        ' Frame ID
  dataSet[5] := byte[stringptr]
  dataSet[6] := byte[stringptr + 1]
  dataSet[7] := val >> 24       ' 4 bytes for value
  dataSet[8] := val >> 16
  dataSet[9] := val >> 8
  dataSet[10] := val
  csum := $FF                   ' Calculate checksum
  Repeat chars from 3 to 10
    csum := csum - dataSet[chars]
  dataSet[11] := csum
  Repeat chars from 0 to 11
    tx(dataSet[chars])


Pub API_RemConfig (addy16,stringptr,val)| Length, chars, csum,ptr ,i
{{
  Sends AT commands in API mode to be immediately processed on REMOTE XBee.
  (Firmware 10CD or higher)
  If FrameID is not 0, status will be returned as to success.
  XB.API_Config(5, string("DL"),$2)  ' Configure DL on a remote XBee at addr 5

}}

  ptr := 0
  dataSet[ptr++] := $7E
  Length := 19            ' API Ident + FrameID +  long addr(8) + AddrHigh + AddrLow + Options
  dataSet[ptr++] := Length >> 8           ' MSB
  dataSet[ptr++] := Length                ' LSB
  dataSet[ptr++] := $17                   ' API Ident for AT Command (non queue)
  dataSet[ptr++] := 5              ' Frame ID

  Repeat 8                                ' 8 byte long address - not used
     dataSet[ptr++] := 0

  dataSet[ptr++] := addy16 >>8            ' Dest Address MSB
  dataSet[ptr++] := addy16                ' Dest Address LSB
  dataSet[ptr++] := $02                   ' Options $02 = apply now
  dataSet[ptr++] := byte[stringptr]
  dataSet[ptr++] := byte[stringptr + 1]
  dataSet[ptr++] := val >> 24
  dataSet[ptr++] := val >> 16
  dataSet[ptr++] := val >> 8
  dataSet[ptr++] := val
  csum := $FF                         ' Calculate checksum
  Repeat chars from 3 to ptr-1
    csum := csum - dataSet[chars]
  dataSet[ptr] := csum

  Repeat chars from 0 to ptr
    tx(dataSet[chars])

Pub API_RemQuery (addy16,stringptr)| Length, chars, csum,ptr ,i
{{
  Sends AT command in API mode to query a parameter value on a REMOTE XB.
  Data is returned as a string.
  XB.API_RemQuery(5, string("DL"))                   ' Query address 5
  XB.API_Rx                                          ' accept response
  HisDL := XB.RxValue                                ' Display in Hex
}}

  ptr := 0
  dataSet[ptr++] := $7E
  Length := strsize(stringptr) + 13    ' API Ident + FrameID +  long addr(8) + AddrHigh + AddrLow + Options
  dataSet[ptr++] := Length >> 8           ' MSB
  dataSet[ptr++] := Length                ' LSB
  dataSet[ptr++] := $17                   ' API Ident for AT Command (non queue)
  dataSet[ptr++] := 5              ' Frame ID

  Repeat 8                                ' 8 byte long address - not used
     dataSet[ptr++] := 0

  dataSet[ptr++] := addy16 >>8            ' Dest Address MSB
  dataSet[ptr++] := addy16                ' Dest Address LSB
  dataSet[ptr++] := $02                   ' Options $02 = apply now
  Repeat strsize(stringptr)               ' Add string to packet
     dataSet[ptr++] := byte[stringptr++]
  csum := $FF                         ' Calculate checksum
  Repeat chars from 3 to ptr-1
    csum := csum - dataSet[chars]
  dataSet[ptr] := csum

  Repeat chars from 0 to ptr
    tx(dataSet[chars])

Pub API_NewPacket
{{ To assist in sending packets in API mode, these next several instuctions can
   be made to assemble a data into a packet. Example:
   XB.API_NewPacket   ' Clear data out - fill with 0.
   XB.API_AddStr(string("Hello,"))
   XB.API_AddByte(32)
   'all done, send to address 5 for 7 bytes
   XB.API_txPacket(5,XB.API_Packet,7)
   ' for packets with no 0's in message:
   XB.API_str(5,XB.API_Packet)
 }}
    bytefill(@PacketOut,0,105)
    packetPtr :=0

Pub API_AddStr(stringPtr)
'' See API_NewPacket
    byteMove(@PacketOut + packetPtr,stringPtr,strsize(stringPtr))
    packetPtr += strsize(stringPtr)

Pub API_AddByte(byteVal)
'' See API_NewPacket
    byte[@PacketOut + packetPtr] := byteVal
    packetPtr++

Pub API_AddArray(stringPtr,size) 'AE
'' See API_NewPacket
    byteMove(@PacketOut + packetPtr,stringPtr,size)
    packetPtr += size

Pub API_txPacket(addy16,stringptr, size)
'' See API_NewPacket
    API_Array(addy16,stringptr,size)

Pub API_Array (addy16,stringptr,size)| Length, chars, csum,ptr
{{
  Replaced by the Packets - See API_NewPacket
  Transmit a byte to a unit using API mode - 16 bit addressing
  If data contains a 0, this method would be required.
    myStr[0] := $7d
    myStr[1] := 00
    myStr[2] := 13
    XB.API_array(2,@myStr,3)   ' send 3 bytes to address 2
  TX response of acknowledgement will be returned if FrameID not 0
  XB.API_RX
  If XB.Status == 0 '0 = Acc, 1 = No Ack
 }}
  ptr := 0
  dataSet[ptr++] := $7E
  Length := size + 5    ' API Ident + FrameID + API TX cmd + AddrHigh + AddrLow +Options
  dataSet[ptr++] := Length >> 8           ' MSB
  dataSet[ptr++] := Length                ' LSB
  dataSet[ptr++] := $01                   ' API Ident for AT Command (non queue)
  dataSet[ptr++] := _FrameID              ' Frame ID
  dataSet[ptr++] := addy16 >>8            ' Dest Address MSB
  dataSet[ptr++] := addy16                ' Dest Address LSB
  dataSet[ptr++] := $00                   ' Options '$01 = disable ack, $04 = Broadcast PAN ID
  Repeat size                             ' Add string to packet
     dataSet[ptr++] := byte[stringptr++]
  csum := $FF                         ' Calculate checksum
  Repeat chars from 3 to ptr-1
    csum := csum - dataSet[chars]
  dataSet[ptr] := csum

  Repeat chars from 0 to ptr
    tx(dataSet[chars])

Pub SetFrameID (val)
'' Sets frame ID. If set to 0, XMIT status will not be reported.
'' XB.SetFrameID(5)
    _FrameID := val

Pub ParseDEC(strPtr,position)| count, ptr, dataPtr
{{  Accepts a string and pulls out a decimal value at a defined position -
    values must be comma or ASCII 13 terminated.
    X := XB.ParseDEC(string("123,456,789"),2)  ' x would be 456
    WHen used with incoming API string:
    X := XB.ParseDEC(XB.RxData,2)
}}

    dataPtr := 0
    repeat ptr from 0 to 105
      dataIn[dataPtr] := byte[strPtr + ptr]
      dataPtr++
      if (byte[strPtr + ptr] == 13) or (byte[strPtr + ptr] == ",") or (byte[strPtr + ptr] == 0)
        count++
        if count == position
          Return (ConvDEC(dataPtr))
          quit
        else
          dataPtr := 0

Pub ParseHEX(strPtr,position)| count, ptr, dataPtr
{{  Accepts a string and pulls out a Hex value at a defined position -
    values must be comma or ASCII 13 terminated.
    X := XB.ParseHEX(string("1f,a2,55"),2)  ' x would be a2
    When used with incoming API string:
    X := XB.ParseHEX(XB.RxData,2)
}}
    dataPtr := 0
    repeat ptr from 0 to 105
      dataIn[dataPtr] := byte[strPtr + ptr]
      dataPtr++
      if (byte[strPtr + ptr] == 0) or (byte[strPtr + ptr] == ",")
        count++
        if count == position
          Return (ConvHEX(dataPtr))
          quit
        else
          dataPtr := 0


Pri ConvDEC(ptr) : Value |  place, x

    place := 1
    If ptr > 2
      repeat x from (ptr-2) to 1
        if (dataIn[x] => ("0")) and (datain[x] =< ("9"))
          value := value + ((DataIn[x]-"0") * place)
          place := place * 10
    if (dataIn[0] => ("0")) and (datain[0] =< ("9"))
      value := value + (DataIn[0]-48) * place
    elseif dataIn[0] == "-"
         value := value * -1
    elseif dataIn[0] == "+"
         value := value

Pri ConvHex(ptr):Value | x, place
    place := 1
    value := 0
    if ptr > 1
      repeat x from (ptr-2) to 0
        if (dataIn[x] => ("0")) and (datain[x] =< ("9"))
          value := value + ((DataIn[x]-"0") * place)
        if (dataIn[x] => ("a")) and (datain[x] =< ("f"))
          value := value + ((DataIn[x]-"a"+10) * place)
        if (dataIn[x] => ("A")) and (datain[x] =< ("F"))
          value := value + ((DataIn[x]-"A"+10) * place)
        place := place * 16


Pri RxPacketNow | char, ptr, chan
{{
  Process incoming frame based on Identifier
  See individual cases for data returned.
  Check ident with :
  IF XB.rxIdent == value
    and process data accordingly as shown below

}}

    ptr := 0
    Repeat
      Char := rxTime(1)            ' accept remainder of data
      dataSet[ptr++] := Char
    while Char <> -1
    ptr := 0
    _RxFlag := 1
    _RxLen := dataSet[ptr++] << 8 + dataSet[ptr++]
    _RxIdent := dataSet[ptr++]
         case _RxIdent
            $81:   '' ********* Rx data from another unit packet
                   '' Returns:
                   '' XB.srcAddr            16bit addr of sender   'AE: fixed typo scrAddr
                   '' XB.RxRSSI             RSSI level of reception
                   '' XB.RXopt              See XB manual
                   '' XB.RxData             Pointer to data string
                   '' XB.RXLen              Length of actual data
                _srcAddr16 := dataSet[ptr++] << 8 + dataSet[ptr++]
                _RSSI := dataSet[ptr++]
                _RXopt := dataSet[ptr++]
                bytefill(@_RxData,0,105)
                bytemove(@_RxData,@dataSet+ptr,_RxLen-5)
                _RxLen := _RxLen - 5

            $83:  '' ************ DIO/ADC data from unit auto sending
                                '' Returns:
                                '' XB.srcAddr            16bit addr of sender   'AE: fixed typo scrAddr
                                '' XB.RxRSSI             RSSI level of reception
                                '' XB.RXopt              See XB manual
                                '' XB.RxData             Pointer to data array of DIO/ADC data
                                '' XB.RXLen              Length of actual data
                                '' Individual channels of data can be access using
                                '' XB.rxADC(channel)
                                '' and
                                '' XB.rxBit(channel)
                _srcAddr16 := dataSet[ptr++] <<8 + dataSet[ptr++]
                _RSSI := dataSet[ptr++]
                _RXopt := dataSet[ptr++]
                bytefill(@_RxData,0,105)
                bytemove(@_RxData,@dataSet+ptr,_RxLen-5)
                chan := 1
                _RxLen := _RxLen - 5
                DigOffset := 0
                if (_RxData[1] & 1) << 8 + _RxData[2] > 0   ' is digital data present?
                   _RxDig :=  _RxData[3] << 8 + _RxData[4]
                   repeat ptr from 0 to 8
                      if (_RxData[1] << 8 + _RxData[2]) & (1 << ptr) > 0
                         _RxBit[ptr] := (_RxDig & (1<< ptr)) >> ptr
                      else
                         _RxBit[ptr] := -1
                   DigOffset := 2
                else
                   _RxDig := -1
                   repeat ptr from 0 to 8
                     _RxBit[ptr] := -1
                repeat ptr from 0 to 5                  ' break down analog and digital data
                  if _RxData[1] & (1 << (ptr+1)) <> 0
                      _RxADC[ptr] := (_RxData[chan * 2 + 1 + DigOffset] << 8) + (_RxData[chan * 2 + 2+DigOffset])
                      chan++
                  else
                     _RxADC[ptr] := -1


            $88:                '' *************  AT Response for configuration change
                                '' Returns:
                                '' XB.FrameID            FrameID to match with send if desired
                                '' XB.Status             Status of change - 0 OK, 1 error
                                ''                       2 Invalid cmd, 3 invalid value
                                '' XB.RxCmd              String of AT command issued
                                '' XB.RXLen              Length of actual data
                                '' XB.RxValue            Value of data returned
                _RxFrameID := dataSet[ptr++]
                _RxCmd[0] :=  dataSet[ptr++]
                _RxCmd[1] :=  dataSet[ptr++]
                _RxCmd[2] :=  0
                _Status :=  dataSet[ptr++]
                _RxValue := 0
                repeat ptr from ptr to _RxLen+1
                  _RxValue := (_RxValue << 8) + dataSet[ptr]
                _RxLen := _RxLen - 5

             '   bytefill(@_RxData,0,105)
             '   bytemove(@_RxData,@dataSet+ptr,_RxLen-5)
             '   _RxLen := _RxLen - 5

            $89:                '' *************** TX Status of packet
                                '' Returns:
                                '' XB.FrameID            FrameID to match with send if desired
                                '' XB.Status             Status of change-0 ACK, 1-NACK, 2-CCA fail, 3-purged
              _RxFrameID := dataSet[ptr++]
              _Status:= dataSet[ptr]

            $97:                '' *************  AT Response for configuration change
                                '' Returns:
                                '' XB.FrameID            FrameID to match with send if desired
                                '' XB.srcAddr            Address of remote unit
                                '' XB.Status             Status of change - 0 OK, 1 error
                                ''                       2 Invalid cmd, 3 invalid value, 4 no response
                                '' XB.RxCmd              String of AT command issued
                                '' XB.RxLen              Length of actual data
                                '' XB.RxValue            Data value Returned
                _RxFrameID := dataSet[ptr++]
                ptr += 8
                _srcAddr16 := dataSet[ptr++] << 8 + dataSet[ptr++]
                _rxCmd[0] := dataSet[ptr++]
                _rxCmd[1] := dataSet[ptr++]
                _rxCmd[2] := 0
                _Status :=  dataSet[ptr++]
                _RxValue := 0
                repeat ptr from ptr to _RxLen+1
                  _RxValue := (_RxValue << 8) + dataSet[ptr]
                _RxLen := _RxLen - 5
        _API_Ready := 1

Pub FrameID
'' Returns last FrameID recieved.
    Return _RxFrameID

Pub RxADC(channel)
'' On receipt of ADC/DIO API packet, returns parsed ADC channel data
    return _RxADC[channel]

Pub RxDig
    return _RxDig

Pub RxBit(bit)
'' On receipt of ADC/DIO API packet, returns parsed digital channel data
    return _RxBit[bit]

Pub RxData
'' Returns pointer to accepted data string/array
    Return @_RxData

Pub RxValue
    return _RxValue

Pub RxLen
'' returns length of accepted data
    Return _RxLen

Pub RxOpt
'' Returns recieved options field
    Return _RxOpt

Pub RxRSSI
'' Returns recieved RSSI value
    Return _RSSI

Pub srcAddr
'' Returns source address of sender
    Return _srcAddr16

Pub RxIdent
'' Returns Packet ID of last packet
    Return _RxIdent

Pub RxCmd
'' Returns AT command as string pointer for AT response
    Return @_RxCmd

Pub Status
'' Returns last status of transmissions or configuration changes
    Return _Status

Pub API_Packet
   return @PacketOut

PUB API_PacketLen 'AE
' example: xb.api_array(port, xb.api_packet, xb.api_packetlen)
  return packetPtr

PUB dataSetPtr 'AE
' for debug purposes only
  return @dataSet

Pub Delay(mS)
'' Delay routing
'' XB.Delay(1000)  ' pause 1 second
  waitcnt(clkfreq/1000 * mS + cnt)

{{

┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}
