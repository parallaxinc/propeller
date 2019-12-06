' Bluetooth HCI Test

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 6_000_000
  
OBJ
  bt : "bluetooth-host"
  rx : "bluetooth-ring"
  tx : "bluetooth-ring"
  term : "tv_text"

VAR
  word  socket
  long  rxCount
  long  errCount

  ' Bytes per second
  long  bpsDeadline
  long  bpsCount
  long  bps
  
PUB main
  term.start(12)

  term.str(string("Starting Bluetooth... "))
  if showError(\bt.Start, string("Can't start Bluetooth host"))
    return

  bt.SetName(string("Propeller"))
  bt.SetClass(bt#COD_Computer)
  bt.SetDiscoverable
  bt.SetFixedPIN(string("0000"))

  bt.AddService(@mySerialService)
  bt.AddService(@myChatService)
  socket := bt.ListenRFCOMM(3, rx.Ring, tx.Ring)
  
  term.str(string("Done.", $D, "Local Address: ", $C, $85, " "))
  term.str(bt.AddressToString(bt.LocalAddress))
  term.str(string(" ", $C, $80, $D))

  'showDiscovery
  'terminal
  'debug
  echoServer

PRI terminal | tmp
  repeat
    if (tmp := rx.RxCheck) > 0
      term.out(tmp)

PRI echoServer | tmp
  repeat
    tmp := rx.charIn
    tx.str(string("You pressed: "))
    tx.hex(tmp, 2)
    tx.str(string(" ("))
    tx.char(tmp)
    tx.str(string(")",$a,$d))
    tx.txFlush

PRI debug | t
  bpsDeadline := cnt
  
  repeat
    term.out($a)
    term.out(0)
    term.out($b)
    term.out(3)

    ' Raw socket struct
    t := socket
    term.str(string("Socket: "))
    repeat 5
      term.hex(WORD[t], 4)
      t += 2
      term.out(" ")

    ' Raw ring struct
    t := rx.Ring
    term.str(string(13, "  Ring: "))
    repeat 4
      term.hex(WORD[t], 4)
      t += 2
      term.out(" ")

    ' Temporary debugging
    t := $4000
    term.str(string(13, " Debug: "))
    repeat 6
      term.hex(WORD[t], 4)
      t += 2
      term.out(" ")

    ' count and show error codes
    term.str(string(13, "Errors: "))
    if t := bt.GetLastError
      errCount++
      term.dec(errCount)
      term.out(" ")
      term.dec(t)
                            
    ' Incoming data
    term.str(string(13, 13, " Bytes: "))
    rxCount += rx.RxDiscard
    term.dec(rxCount)
   
    ' Count bytes per second
    if (cnt - bpsDeadline) > 0
      bpsDeadline += clkfreq
      bps := rxCount - bpsCount
      bpsCount := rxCount
    term.str(string(" ("))
    term.dec(bps)
    term.str(string(" B/s)    "))
      
    
PRI showDiscovery | i, count
  bt.DiscoverDevices(30)
  repeat
    term.str(string($A, 1, $B, 2, "Devices found: "))
    term.dec(count := bt.NumDiscoveredDevices)
    if bt.DiscoveryInProgress
      term.str(string(" (Scanning...)"))
    else
      term.str(string("              "))
    
    if count
      repeat i from 0 to count - 1
        term.out($A)
        term.out(0)
        term.out($B)
        term.out(3+i)
        term.str(bt.AddressToString(bt.DiscoveredAddr(i)))
        term.out(" ")
        term.hex(bt.DiscoveredClass(i), 6)
  
PRI showError(error, message) : bool
  if error < 0
    term.str(message)
    term.str(string(" (Error "))
    term.dec(error)
    term.str(string(")", 13))
    return 1
  return 0


DAT

mySerialService word 0

    byte  bt#DE_Seq8, @t0 - @h0            ' <sequence>
h0      

    byte    bt#DE_Uint16, $00,$00          '   ServiceRecordHandle
    byte    bt#DE_Uint32, $00,$01,$00,$02  '     (Arbitrary unique value)

    byte    bt#DE_Uint16, $00,$01          '   ServiceClassIDList
    byte    bt#DE_Seq8, @t1 - @h1          '   <sequence>
h1  byte      bt#DE_UUID16, $11,$01        '     SerialPort
t1

    byte    bt#DE_Uint16, $00,$04          '   ProtocolDescriptorList
    byte    bt#DE_Seq8, @t2 - @h2          '   <sequence>
h2  byte      bt#DE_Seq8, @t3 - @h3        '     <sequence>
h3  byte        bt#DE_UUID16, $01,$00      '       L2CAP
t3  byte      bt#DE_Seq8, @t4 - @h4        '     <sequence>
h4  byte        bt#DE_UUID16, $00,$03      '       RFCOMM
    byte        bt#DE_Uint8, $03           '       Channel
t4
t2

    byte    bt#DE_Uint16, $00,$05          '   BrowseGroupList
    byte    bt#DE_Seq8, @t5 - @h5          '   <sequence>
h5  byte      bt#DE_UUID16, $10,$02        '     PublicBrowseGroup
t5

    byte    bt#DE_Uint16, $00,$06          '   LanguageBaseAttributeIDList
    byte    bt#DE_Seq8, @t16 - @h16        '   <sequence>
h16 byte      bt#DE_Uint16, $65,$6e        '     Language
    byte      bt#DE_Uint16, $00,$6a        '     Encoding
    byte      bt#DE_Uint16, $01,$00        '     Base attribute ID value
t16             

    byte    bt#DE_Uint16, $00,$09          '   BluetoothProfileDescriptorList
    byte    bt#DE_Seq8, @t7 - @h7          '   <sequence>
h7  byte      bt#DE_Seq8, @t8 - @h8        '     <sequence>
h8  byte      bt#DE_UUID16, $11,$01        '       SerialPort
    byte      bt#DE_Uint16, $01,$00        '       Version 1.0
t8
t7              

    byte    bt#DE_Uint16, $01,$00          '   ServiceName + Language Base
    byte    bt#DE_Text8, @t19 - @h19
h19 byte      "Serial"
t19

t0


DAT

' This service is compatible with the BluetoothChat example in the Android SDK

myChatService word 0

    byte  bt#DE_Seq8, @t20 - @h20          ' <sequence>
h20      

    byte    bt#DE_Uint16, $00,$00          '   ServiceRecordHandle
    byte    bt#DE_Uint32, $00,$01,$00,$03  '     (Arbitrary unique value)

    byte    bt#DE_Uint16, $00,$01          '   ServiceClassIDList
    byte    bt#DE_Seq8, @t21 - @h21        '   <sequence>
h21 byte      bt#DE_UUID128                '     Android BluetoothChat sample
    byte         $fa, $87, $c0, $d0
    byte         $af, $ac, $11, $de
    byte         $8a, $39, $08, $00
    byte         $20, $0c, $9a, $66
t21

    byte    bt#DE_Uint16, $00,$04          '   ProtocolDescriptorList
    byte    bt#DE_Seq8, @t22 - @h22        '   <sequence>
h22 byte      bt#DE_Seq8, @t23 - @h23      '     <sequence>
h23 byte        bt#DE_UUID16, $01,$00      '       L2CAP
t23 byte      bt#DE_Seq8, @t24 - @h24      '     <sequence>
h24 byte        bt#DE_UUID16, $00,$03      '       RFCOMM
    byte        bt#DE_Uint8, $03           '       Channel
t24
t22

    byte    bt#DE_Uint16, $00,$05          '   BrowseGroupList
    byte    bt#DE_Seq8, @t25 - @h25        '   <sequence>
h25 byte      bt#DE_UUID16, $10,$02        '     PublicBrowseGroup
t25

t20
