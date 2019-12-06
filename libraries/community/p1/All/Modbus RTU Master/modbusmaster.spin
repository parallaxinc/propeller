{{
*****************************************************
*  Modbus RTU Master                                *
*  Author: Albert Emanuel Milani a.k.a. Electrodude *
*  Copyright (c) 2016 Albert Emanuel Milani         *
*  See end of file for terms of use.                *
*****************************************************

Modbus RTU Master using pcFullDuplexSerial4FC512
Methods run in calling cog, but serial IO is done in pcFullDuplexSerial4FC512 cog.
You must start the pcFullDuplexSerial4FC512 cog yourself.

Example usage:
OBJ
  ser:          "pcFullDuplexSerial4FC512"
  mb:           "modbusmaster"

PUB main | station, addr, val
  ser.init

  mb .addPort(mbp, mbrx, mbtx, -1,-1,0,0,  9600)        'modbus
  ser.addPort(dbgp,dbgrx,dbgtx,-1,-1,0,0,115200)        'debug

  ser.start

  station := 1
  addr := $0000

  ' keep trying until it returns 1
  repeat until \mb.readmhr(station, addr, 1, @val)

  ' do something with value in val



Supported Methods:
$03: Read Multiple Holding Registers
$04: Read Multiple Input Registers
$10: Write Single Holding Register

These methods all return 1 on success and abort 0 on failure.
Make sure you call them as success := \mb.

Please PM me on the Parallax Forums if you want me to add support for any
methods I didn't implement and I'll implement them if I have time.  I'm not
making any promises that I'll have time to implement any methods for anyone.
If you do implement any methods yourself, please tell me so I can include them
in future versions of this object so everyone else can use them too.


Most commented-out code in this object is for debugging.  If you want to use the
debugging code, you'll have to initialize the port of pcFullDuplexSerial4FC512
that you intend to use for debugging - this way you can share the same port for
your code's and this object's debug output.

}}

CON

  maxtries = 2                  ' how many times to try before giving up

  'dbgp=2                        ' port number for debug

  inittimeout = 50              ' timeout for first byte of response
  intertimeout = 5              ' timeout between characters of response

OBJ

  ser:          "pcFullDuplexSerial4FC512"

VAR

  long timeout                  ' timeout until next char

  word crc                      ' checksum

  byte port                     ' current port to use

CON '' initialization/misc methods
PUB AddPort(_port,rxpin,_txpin,ctspin,rtspin,rtsthreshold,mode,baudrate)
'' Works the same way as pcFullDuplexSerial4FC512's AddPort and calls its AddPort but also remembers the port number

  ser.AddPort(_port,rxpin,_txpin,ctspin,rtspin,rtsthreshold,mode,baudrate)

  port := _port

PUB setport(_port)
'' Sets the current port number, so you can do modbus on multiple ports.
'' It's probably a better idea to just have multiple instances of this object instead of using this.

  port := _port

CON '' modbus request methods
PUB readmhr(station, start, len, ptr) : success
'' Read multiple holding registers
'' Returns true or false depending on whether or not the request was successful
'' ptr: where in hubram to put the read data

  { debug
  ser.str(dbgp, string(13, "readmhr("))
  ser.hex(dbgp, station, 2)
  ser.str(dbgp, string(", "))
  ser.hex(dbgp, start, 2)
  ser.str(dbgp, string(", "))
  ser.hex(dbgp, len, 2)
  ser.str(dbgp, string(", "))
  ser.hex(dbgp, ptr, 2)
  ser.str(dbgp, string(")",13))
  '}

  repeat maxtries
    newpkt

    putc(station)
    putc($03)
    putw(start)
    putw(len)

    sendcrc

    if success := \readrecv(station, $03, start, len, ptr)
      'ser.strln(dbgp, string("valid response!"))
      return
    else
      repeat until ser.rxtime(port, timeout) == -1  'wait for slave to shut up

PUB readmir(station, start, len, ptr) : success
'' Read multiple input registers
'' Returns true or false depending on whether or not the request was successful
'' ptr: where in hubram to put the read data

  repeat maxtries
    newpkt

    putc(station)
    putc($04)
    putw(start)
    putw(len)

    sendcrc

    if success := \readrecv(station, $04, start, len, ptr)
      'ser.strln(dbgp, string("valid response!"))
      return
    else
      repeat until ser.rxtime(port, timeout) == -1  'wait for slave to shut up

PUB writeshr(station, addr, data) : success
'' Write single holding register
'' Returns true or false depending on whether or not the request was successful

  repeat maxtries
    newpkt

    putc(station)
    putc($06)
    putw(addr)
    putw(data)

    sendcrc

    if success := \writerecv(station, $06, addr, data)
      'ser.strln(dbgp, string("valid response!"))
      return
    else
      repeat until ser.rxtime(port, timeout) == -1  'wait for slave to shut up

{ doesn't work!
PUB writemhr(station, start, len, ptr) : success
'' Doesn't work!!!  Might be writerecv's fault.  Maybe I shouldn't be using writerecv
''   for this (writeshr also uses it) and this should have its own receive method

'' Write multiple holding registers
'' Returns true or false depending on whether or not the request was successful
'' ptr: where in hubram to get the data to be written

  repeat maxtries
    newpkt

    putc(station)
    putc($10)
    putw(start)
    putw(len*2)

    repeat len
      putw(word[ptr])
      ptr+=2

    sendcrc

    if success := \writerecv(station, $10, start, len)
      'ser.str(dbgp, string("valid response!",13))
      return
    else
      repeat until ser.rxtime(port, timeout) == -1  'wait for slave to shut up
}

CON '' higher-level private methods
PRI readrecv(station, op, start, len, ptr) | x
'' Receives and validates response from read request
'' This is a separate method so it can abort in case of error

  newpkt

  '{
  ifnot getc == station and getc == op and getc == len*2
    abort

  repeat len
    word[ptr] := getw
    ptr+=2

  result := recvcrc
  '}

  { debug - comment out the block above if you want to use this
  ser.str(dbgp, string(13,"station: "))
  ifnot (x := getc) == station
    ser.str(dbgp, string(13, "bad station: expected "))
    ser.hex(dbgp, station, 2)
    ser.str(dbgp, string(", got "))
    ser.hex(dbgp, x, 2)
    ser.newline(dbgp)
    abort

  ser.str(dbgp, string(13,"op: "))
  ifnot (x := getc) == op
    ser.str(dbgp, string(13, "bad op: expected "))
    ser.hex(dbgp, op, 2)
    ser.str(dbgp, string(", got "))
    ser.hex(dbgp, x, 2)
    ser.newline(dbgp)
    abort

  ser.str(dbgp, string(13,"length: "))
  ifnot (x := getc) == len*2
    ser.str(dbgp, string(13, "bad length: expected "))
    ser.hex(dbgp, len*2, 2)
    ser.str(dbgp, string(", got "))
    ser.hex(dbgp, x, 2)
    ser.newline(dbgp)
    abort

  ser.str(dbgp, string(13,"data: "))

  repeat len
    word[ptr] := getw
    ptr+=2

  ser.str(dbgp, string(13,"crc: "))
  result := recvcrc

  ser.newline(dbgp)

  ifnot result
    ser.strln(dbgp, string("bad checksum"))
  else
    ser.strln(dbgp, string("good checksum"))
  '}

PRI writerecv(station, op, start, len) | x
'' Receives response from write request
'' This is a separate method so it can abort in case of error

  newpkt

  ifnot getc == station and getc == op and getw == start and getw == len
    abort

  result := recvcrc

CON '' lower-level private methods
PRI putc(char)
'' Sends a byte
'' Handles timeout and checksum

  ser.tx(port, char)

  {
  ser.hex(dbgp, char, 2)
  ser.tx(dbgp, " ")
  '}

  docrc(char)

PRI putw(x)
'' Sends a big-endian word
'' Handles timeout, checksum, etc.

  putc(x.byte[1])
  putc(x.byte[0])

PRI putl(x)
'' Sends a big-endian long
'' Handles timeout, checksum, etc.

  putc(x.byte[3])
  putc(x.byte[2])
  putc(x.byte[1])
  putc(x.byte[0])

PRI getc : char
'' Receives a byte
'' Handles timeout and checksum, etc.

  if (char := ser.rxtime(port,timeout)) == -1
    'ser.strln(dbgp, string("timeout, abort"))
    abort 0

  timeout := intertimeout

  {
  ser.hex(dbgp, char, 2)
  ser.tx(dbgp, " ")
  '}

  docrc(char)

PRI getw
'' Receives a big-endian word
'' Handles timeout, checksum, etc.

  return (getc << 8) | getc

PRI getl
'' Receives a big-endian long
'' Handles timeout, checksum, etc.

  return (getc << 24) | (getc << 16) | (getc << 8) | getc

PRI sendcrc
'' Sends checksum at the end of a packet

  ser.tx(port, crc.byte[0])
  ser.tx(port, crc.byte[1])

  ser.rxflush(port)

PRI recvcrc : valid
'' Receives and validates checksum at the end of a packet

  valid := getc == crc.byte[0] and getc == crc.byte[1]

PRI docrc(char)
'' Accumulates a character into the checksum

  crc ^= char
  repeat 8
    crc := (crc >> 1) ^ ($A001 & ((crc & 1) <> 0))

PRI newpkt
'' Gets ready to send or receive a new packet
'' Resets the checksum and the timeout

  crc:= $FFFF

  timeout := inittimeout

DAT
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
