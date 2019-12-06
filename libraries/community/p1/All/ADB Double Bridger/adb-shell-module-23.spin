{{

Propeller ADB bridge -- multiple connections with IO demo

copyright 2011 spiritplumber@gmail.com

buy my kits at www.f3.to!

based off microbridge ( http://code.google.com/p/microbridge/ ) which is copyright 2011 Niels Brouwers

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
}}
CON
  _clkmode = xtal1 + pll16x
'  _xinfreq = 6_000_000
  _clkfreq = 96_000_000


dat
shell byte "shell:",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  ' "shell:",0 ' "shell:exec logcat",0
mbrdg byte "host::propbridge",0

pub PrimaryHandshake 

'  term.char(term#CS)

    if \Enumerate < 0
      abort -1         

    if \Identify < 0', string("Can't identify device"))
      abort -2
    
    if \Init < 0 ', string("Error initializing device"))
      abort -3
  
  ' do handshaking now
  
    'waitcnt(cnt + clkfreq)

'    term.str(string("Sending string host:"))
    WriteMessage(A_CNXN,$0100_0000,MAX_PAYLOAD,@mbrdg,strsize(@mbrdg)+1)  ' send connection
    waitcnt(cnt + constant(_clkfreq/2))
  
    bytefill(@message_command,0,MESSAGE_HEADER_SIZE)
    \hc.BulkRead(BulkIn,@message_command, MESSAGE_HEADER_SIZE)
'    term.dec(\hc.BulkRead(BulkIn,@message_command, MESSAGE_HEADER_SIZE))         ' get ack, should be also A_CNXN, returns 24

    if (message_command <> A_CNXN)
'       term.str(string("Not a connection message "))
'       term.dec(message_command)
       abort -4
    else
       'term.str(string("Got CNXN message"))

      bytefill(@stringin,0,BUFFERSIZE)
      'term.dec(\hc.BulkRead(BulkIn,@stringin, message_data_length))         ' get payload 
      \hc.BulkRead(BulkIn,@stringin, message_data_length)
      'term.char(" ")
      'term.str(@stringin)
      'term.char(13)

  if (strcomp(@stringin,string("device::")) == -1)
     bytefill(@stringin,0,BUFFERSIZE)

      repeat NUMCONNS*2
         rx

     
     return 1                                    ' we're good

  abort -10                                       ' other error
con
NUMCONNS=2
pub rx | c' returns the relevant buffer

  
c~~
repeat NUMCONNS
  c++  
  if (status[c] == ADB_CLOSED)
    'waitcnt(cnt + clkfreq)
    'term.str(string("Sending open string "))
    'term.str(@shell)
    'term.char(13)
    localID[c]:=c+1
    WriteMessage(A_OPEN,localID[c],0,@shell,strsize(@shell)+1)  ' send request to open shell
    'term.char(13)
    status[c]:=ADB_OPENING
    if (GetMessage==false)
      abort (c*-10)-5
    else
      return 0
      
GetMessage
return received
pub rxbuf
  return @stringin
pub shellbuf
  return @shell
pub rxclr
  bytefill(@stringin,0,BUFFERSIZE)
pub tx(char,conn)
  if (char>-1 and char<256)
    WriteMessage(A_WRTE,localID[conn],RemoteID[conn],@char,1)  ' send request to open shell
    status[conn] := ADB_WRITING

pub str(stringptr,conn)
    WriteMessage(A_WRTE,localID[conn],RemoteID[conn],stringptr,strsize(stringptr))  ' send request to open shell
    status[conn] := ADB_WRITING

var
long activeconn  
pub id
  return activeconn   
PUB dec(value,conn) | i

'' Print a decimal number

  if value < 0
    -value
    tx("-",conn)

  i := 1_000_000_000

  repeat 10
    if value => i
      tx(value / i + "0",conn)
      value //= i
      result~~
    elseif result or i == 1
      tx("0",conn)
    i /= 10



pri blink
    waitcnt(cnt+constant(_clkfreq/100))

dat

{

cmd1_1 byte "logcat -c",13,10,0
cmd1_2 byte "logcat -v raw NAVCOMOUT:* *:S",13,10,0

cmd2_1 byte "logcat -d -v raw NAVCOMOUT:* *:S",13,10,0
cmd2_2 byte "echo ",0
cmd2_3 byte " > /data/local/NAVCOMIN",13,10,0
}

pri GetMessage | prevstatus, connum
received~  
  bytefill(@message_command,0,MESSAGE_HEADER_SIZE)
  result := \hc.BulkRead(BulkIn,@message_command, MESSAGE_HEADER_SIZE)         ' get ack, should be also A_CNXN, returns 24
  
  if (result < 0)
     if (result <> -160) '-160 is timeout, so that's OK
       abort result

if (message_command == 0)
   activeconn:=-1
   return 0


'  if (message_arg1 <> localid)
'     return false

'term.char("!")                
'term.dec(message_arg0) ' remoteid
'term.char("!")                
'term.dec(message_arg1) ' localid
'term.char("!")
if (message_arg1 > NUMCONNS)
   abort -message_arg1-5000
else
  connum:=-1
  result:=-1
  repeat
    if (LocalID[++result]==message_arg1)
       connum := result
       activeconn := result
  until result > NUMCONNS
                  
  if (connum<0)
     abort -120+connum
  if (connum>NUMCONNS)
     abort -130-connum
       
if (message_command == A_WRTE)
      prevstatus := status[connum]
      status[connum] := ADB_RECEIVING
      bytefill(@stringin,0,BUFFERSIZE)
      if (message_data_length)
       repeat
         received := \hc.BulkRead(BulkIn,@stringin, message_data_length)
       until received 

      status[connum] := prevstatus

      \WriteEmptyMessage(A_OKAY, message_arg1, message_arg0)
      return A_WRTE

if (message_command == A_OKAY)
    if (status[connum] == ADB_OPENING)
         remoteID[connum]:=message_arg0
      status[connum]:=ADB_OPEN
      
    if (status[connum] == ADB_WRITING)
      status[connum]:=ADB_OPEN   
    return A_OKAY


if (message_command == A_CLSE)
   abort -8

if (message_command == 0 and status == ADB_WRITING)
   abort -9


return 0

pub msgcmd
  if (message_command == A_OKAY)
     return string("OKAY")
  if (message_command == A_CLSE)
     return string("CLSE")
  if (message_command == A_WRTE)
     return string("WRTE")
  if (message_command == A_OPEN)
     return string("OPEN")
  if (message_command == A_SYNC)
     return string("SYNC")
  if (message_command == A_CNXN)
     return string("CNXN")
  return string("UNKN")
OBJ
  hc : "usb-fs-host-23"
                   
CON
BUFFERSIZE = MAX_PAYLOAD ' adb buffer size 

E_SUCCESS       = 0


MESSAGE_HEADER_SIZE = 6*4 ' 6 longs in message header

'ADB
MAX_PAYLOAD = 4096 
         
A_SYNC = $434e5953  'CNYS
A_CNXN = $4e584e43  'NXNC
A_OPEN = $4e45504f  'NEPO
A_OKAY = $59414b4f  'YAKO
A_CLSE = $45534c43  'ESLC
A_WRTE = $45545257  'ETRW

ADB_CLASS = $ff
ADB_SUBCLASS = $42
ADB_PROTOCOL = $1



'ADB_USB_PACKETSIZE = $40
'ADB_CONNECTSTRING_LENGTH = 64
ADB_MAX_CONNECTIONS = 1
'ADB_CONNECTION_RETRY_TIME = 1000


ADB_UNUSED = 0
ADB_CLOSED = 1
ADB_OPEN = 2
ADB_OPENING = 3
ADB_RECEIVING = 4
ADB_WRITING = 5

ADB_CONNECT = 6
ADB_DISCONNECT = 7
ADB_CONNECTION_OPEN = 8
ADB_CONNECTION_CLOSE = 9
ADB_CONNECTION_FAILED = 10
ADB_CONNECTION_RECEIVE = 11

DAT
''
''
''==============================================================================
'' Device Driver Interface
''==============================================================================

' WITH ADB
'Found device 18D1:4E12
'Raw device descriptor:
'12 01 00 02 00 00 00 40 D1 18 12 4E 27 02 01 02 03 01
'Device configuration:
'  Interface ptr=0395 number=00 alt=00 class=08 subclass=06
'    Endpoint ptr=039E address=83 maxpacket=0040
'    Endpoint ptr=03A5 address=02 maxpacket=0040
'  Interface ptr=03AC number=01 alt=00 class=FF subclass=42
'    Endpoint ptr=03B5 address=84 maxpacket=0040
'    Endpoint ptr=03BC address=03 maxpacket=0040


' WITHOUT ADB
'Device configuration:
'  Interface ptr=0395 number=00 alt=00 class=08 subclass=06
'    Endpoint ptr=039E address=83 maxpacket=0040
'    Endpoint ptr=03A5 address=02 maxpacket=0040
'Found device 18D1:4E11



bulkIn  word    0
bulkOut word    0
ifd  long 0
epd1 long 0
epd2 long 0
PUB Enumerate
  '' Enumerate the available USB devices. This is provided for the convenience
  '' of applications that use no other USB class drivers, so they don't have to
  '' directly import the host controller object as well.

  return hc.Enumerate

PUB Identify

  '' The caller must have already successfully enumerated a USB device.
  '' This function tests whether the device looks like it's compatible
  '' with this driver.

  '' This function is meant to be non-invasive: it doesn't do any setup,
  '' nor does it try to communicate with the device. If your application
  '' needs to be compatible with several USB device classes, you can call
  '' Identify on multiple drivers before committing to using any one of them.
  ''
  '' Returns 1 if the device is supported, 0 if not. Does not abort.

  '' first: it must have 2 interfaces, no more and no less
  '' second: check (and save) the interface number,class and subclass

  ifd~
  epd1~
  epd2~
  result~
  repeat NUMCONNS
    status[result++]:=ADB_CLOSED
  
  if (hc.FirstInterface <> 0 and hc.nextInterface(hc.FirstInterface) <> 0 and hc.nextInterface(hc.nextInterface(hc.FirstInterface)) == 0)
     ifd := hc.nextInterface(hc.FirstInterface)
     epd1 := hc.NextEndpoint(ifd)
     epd2 := hc.NextEndpoint(epd1)
     if (ifd>0 and epd1>0 and epd2>0 and BYTE[ifd + hc#IFDESC_bInterfaceNumber] == ADB_PROTOCOL and BYTE[ifd + hc#IFDESC_bInterfaceClass] == ADB_CLASS and BYTE[ifd + hc#IFDESC_bInterfaceSubclass] == ADB_SUBCLASS)
        return 1
        
  return 0

PUB Init | epd

  '' (Re)initialize this driver. This must be called after Enumerate
  '' and Identify are both run successfully. All three functions must be
  '' called again if the device disconnects and reconnects, or if it is
  '' power-cycled.
  ''
  '' This function sets the device's USB configuration, collects
  '' information about the device's descriptors, and sets default
  '' UART settings.
  
  bulkOut := hc.NextEndpoint(hc.nextInterface(hc.FirstInterface))
  bulkIn :=  hc.NextEndpoint(bulkOut)

  hc.Configure


var
long status[2]
long localID[2]
long remoteID[2]

var
long received ' size of string buffer
byte stringin[BUFFERSIZE]
{
pub inbuffer(conn)
return @buffers+((conn<#constant(ADB_MAX_CONNECTIONS-1))*CONBUFSIZE)  
}
DAT
''
''==============================================================================
'' Low-level adb interface
''============================================================================
'' connection

'' message in/out
message_command long 0
message_arg0 long 0
message_arg1 long 0
message_data_length long 0
message_data_check long 0
message_magic long 0           

pub WriteEmptyMessage(cmd, arg0, arg1)

     message_command := cmd
     message_arg0 := arg0
     message_arg1 := arg1
     message_data_length~
     message_data_check~
     message_magic := cmd ^ $FFFF_FFFF

     return \hc.BulkWrite(BulkOut,@message_command, MESSAGE_HEADER_SIZE)
pub WriteMessage(cmd, arg0, arg1, MsgAddr, MsgSize)
                          
     message_command := cmd
     message_arg0 := arg0
     message_arg1 := arg1
     message_data_length := MsgSize   
     message_data_check~
     repeat MsgSize
        message_data_check := message_data_check + byte[MsgAddr++]
     MsgAddr -= MsgSize
     message_magic := cmd ^ $FFFF_FFFF
     
     result := \hc.BulkWrite(BulkOut,@message_command, MESSAGE_HEADER_SIZE)

     return \hc.BulkWrite(BulkOut,MsgAddr, MsgSize)
     