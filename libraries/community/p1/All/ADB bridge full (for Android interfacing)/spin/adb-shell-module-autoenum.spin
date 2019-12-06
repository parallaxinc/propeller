' usb ADB bridge by spiritplumber@gmail.com
' credit to the guy at code.google.com/p/microbridge  for original implementation
' license: NAVCOM license
' buy my robot kits! www.f3.to first in android robotics!




' the desync problem is with multiple connections: single conn works great

CON
  _clkmode = xtal1 + pll16x
'  _xinfreq = 6_000_000
  _clkfreq = 96_000_000


dat
shell byte "shell:",0',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  ' "shell:",0 ' "shell:exec logcat",0
mbrdg byte "host::propbridge",0
flip  byte 0

pub PrimaryHandshake | t


 

'  term.char(term#CS)

    result:=\Enumerate
    if result<0 and result<>-150
      waitcnt(cnt+(clkfreq/10)) 
      abort -1        

    if \Identify < 0', string("Can't identify device"))
      abort -2
       
    if \Init < 0 ', string("Error initializing device"))
      abort -3


  ' do handshaking now
  
    'waitcnt(cnt + clkfreq)

'    term.str(string("Sending string host:"))

    repeat 10
        WriteMessage(A_CNXN,$0100_0000,MAX_PAYLOAD,@mbrdg,strsize(@mbrdg)+1)  ' send connection. the $0100_0000 is just ADB version.
        message_command~
        bytefill(@message_command,0,MESSAGE_HEADER_SIZE)
        \hc.BulkRead(BulkIn,@message_command, MESSAGE_HEADER_SIZE)
        if (message_command == A_CNXN)
           quit
    if (message_command <> A_CNXN)
    
'       term.str(string("Not a connection message "))
'       term.dec(message_command)
       abort -4000-message_command
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

      result:=-1
      repeat NUMCONNS
       result++  
         localID[result]:=result
         \WriteMessage(A_OPEN,LocalID[result],0,@shell,strsize(@shell)+1)  ' send request to open shell
         status[result]:=ADB_OPENING
         t~~
         repeat
           t:=GetMessage
         until t==0


     return 1                                    ' we're good

  abort -10                                       ' other error
con
NUMCONNS=4

pub closeall
result~
repeat NUMCONNS
   blink
   \writeEmptyMessage(A_CLSE,localID[result],remoteID[result++])
   status[result] := ADB_CLOSED


pub rxbuf
  return @stringin

pub shellbuf
  return @shell
pub debug_stat(conn)
  return status[conn]
pub debug_loc(conn)
  return localID[conn]
pub debug_rem(conn)
  return remoteID[conn]
pub debug_message_command
    return message_command
pub debug_message_arg0
    return message_arg0
pub debug_message_arg1
    return message_arg1      
pub debug_activeconn
    return activeconn      

  
pub rxclr
  bytefill(@stringin,0,strsize(@stringin))
var
long activeconn  
pub id
  return activeconn
{   
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
}

pub rx | c' returns the relevant buffer

      result:=-1
      repeat NUMCONNS
       result++  
        if status[result]==ADB_CLOSED
         localID[result]:=result
         \WriteMessage(A_OPEN,LocalID[result],0,@shell,strsize(@shell)+1)  ' send request to open shell
         status[result]:=ADB_OPENING
         repeat 
            GetMessage
         until status[result]==ADB_OPEN

GetMessage

return received

pri GetConNum | connum

      if (message_command == A_OKAY and status[message_arg1]==ADB_OPENING)
         return message_arg1
      connum:=-1
      result~
      repeat NUMCONNS
          if RemoteID[result]==message_arg0
             connum:=result
          result++
    activeconn:= connum
    return connum

pri GetMessage | prevstatus, connum
received~
  bytefill(@message_command,0,MESSAGE_HEADER_SIZE)
  result := \hc.BulkRead(BulkIn,@message_command, MESSAGE_HEADER_SIZE)         ' get ack, should be also A_CNXN, returns 24

  connum:=GetConNum

  if (result==-160) ' timeout: no need to abort
     return 0
  
  if (result < 0)
     abort result

  if (message_command == 0 and status[connum] == ADB_WRITING)
     abort -9

  if (message_command == 0)
     return 0
       
  
  if (connum<0)
     abort -120+connum

  if (connum>NUMCONNS-1)
     abort -130-connum
       
if (message_command == A_WRTE)
      connum:=GetConNum
      prevstatus := status[connum]
      status[connum] := ADB_RECEIVING
      bytefill(@stringin,0,BUFFERSIZE)
      if (message_data_length)
       repeat
         received := \hc.BulkRead(BulkIn,@stringin, message_data_length)
       until received 
      status[connum] := prevstatus
      \WriteEmptyMessage(A_OKAY, localID[connum], remoteID[connum])
      return A_WRTE

if (message_command == A_OKAY)
    connum:=GetConNum
    
    if (status[connum] == ADB_OPENING)
       remoteID[connum]:=message_arg0
       status[connum]:=ADB_OPEN
       
    if (status[connum] == ADB_WRITING)
         status[connum]:=ADB_OPEN
            
    if (status[connum] == ADB_RECEIVING)
         status[connum]:=ADB_OPEN
           
    return A_OKAY


if (message_command == A_CLSE)
         connum:=GetConNum
   status[connum]:=ADB_CLOSED
   return A_CLSE'abort -8 
   
abort -99

pub str(stringptr,conn)
    WriteMessage(A_WRTE,conn,RemoteID[conn],stringptr,strsize(stringptr))  ' send request to open shell
    status[conn] := ADB_WRITING
    'activeconn:=conn
    return true
OBJ
  hc : "usb-fs-host"
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

  ifd := hc.FirstInterface
  repeat
    if (BYTE[ifd + hc#IFDESC_bInterfaceClass] == ADB_CLASS) and (BYTE[ifd + hc#IFDESC_bInterfaceSubclass] == ADB_SUBCLASS)
       quit
    elseif (ifd<1)
       abort -222
    else
       ifd := hc.NextInterface(ifd)    

  {
  result~
  ifd := hc.FirstInterface
  repeat while ifd
     epd1 := hc.NextEndpoint(ifd)
     epd2 := hc.NextEndpoint(epd1)
     if (ifd>0 and epd1>0 and epd2>0 and BYTE[ifd + hc#IFDESC_bInterfaceNumber] == ADB_PROTOCOL and BYTE[ifd + hc#IFDESC_bInterfaceClass] == ADB_CLASS and BYTE[ifd + hc#IFDESC_bInterfaceSubclass] == ADB_SUBCLASS)
        result++
     else
        ifd := hc.NextInterface(ifd)
        {
  
  if (hc.FirstInterface <> 0 and hc.nextInterface(hc.FirstInterface) <> 0 and hc.nextInterface(hc.nextInterface(hc.FirstInterface)) == 0)
     ifd := (hc.FirstInterface)
     epd1 := hc.NextEndpoint(ifd)
     epd2 := hc.NextEndpoint(epd1)
     if (ifd>0 and epd1>0 and epd2>0 and BYTE[ifd + hc#IFDESC_bInterfaceNumber] == ADB_PROTOCOL and BYTE[ifd + hc#IFDESC_bInterfaceClass] == ADB_CLASS and BYTE[ifd + hc#IFDESC_bInterfaceSubclass] == ADB_SUBCLASS)
        return 1
     else
       ifd := hc.nextInterface(ifd)
       epd1 := hc.NextEndpoint(ifd)
       epd2 := hc.NextEndpoint(epd1)
       if (ifd>0 and epd1>0 and epd2>0 and BYTE[ifd + hc#IFDESC_bInterfaceNumber] == ADB_PROTOCOL and BYTE[ifd + hc#IFDESC_bInterfaceClass] == ADB_CLASS and BYTE[ifd + hc#IFDESC_bInterfaceSubclass] == ADB_SUBCLASS)
         return 1
         }
  ifd~
  return result
    }
PUB Init | one, two


  '' (Re)initialize this driver. This must be called after Enumerate
  '' and Identify are both run successfully. All three functions must be
  '' called again if the device disconnects and reconnects, or if it is
  '' power-cycled.
  ''
  '' This function sets the device's USB configuration, collects
  '' information about the device's descriptors, and sets default
  '' UART settings.

  epd1 := one := hc.NextEndpoint(ifd)
  epd2 := two := hc.NextEndpoint(one)
  
  if (BYTE[two + hc#EPDESC_bEndpointAddress] & $80 == $00)
     bulkIn := one
     bulkOut :=  two
  elseif (BYTE[two + hc#EPDESC_bEndpointAddress] & $80 == $80)
     bulkIn := two
     bulkOut := one
  else
     result:=two
     two:=one
     one:=result
     bulkIn := two
     bulkOut := one

'     abort (BYTE[two + hc#EPDESC_bEndpointAddress])*-1
'  bulkOut := hc.NextEndpoint(hc.nextInterface(hc.FirstInterface))
'  bulkIn :=  hc.NextEndpoint(bulkOut)

  hc.Configure
  return 1

var
long status[NUMCONNS]
long localID[NUMCONNS]
long remoteID[NUMCONNS]

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

pub blink
    waitcnt(cnt+constant(_clkfreq/100))
     