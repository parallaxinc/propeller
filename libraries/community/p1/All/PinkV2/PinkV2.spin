{{
***************************
* Pink V2 object v1.2     *
* Coded by Peter Verkaik  *
* Date: December 19, 2007 *
***************************
}}


CON
  'public constants
  '//general purpose read/write registers (in order of memory map)
  Nb_var00 = 00
  Nb_var01 = 01
  Nb_var02 = 02
  Nb_var03 = 03
  Nb_var04 = 04
  Nb_var05 = 05
  Nb_var06 = 06
  Nb_var07 = 07
  Nb_var08 = 08
  Nb_var09 = 09
  Nb_var10 = 10
  Nb_var11 = 11
  Nb_var12 = 12
  Nb_var13 = 13
  Nb_var14 = 14
  Nb_var15 = 15
  Nb_var16 = 16
  Nb_var17 = 17
  Nb_var18 = 18
  Nb_var19 = 19
  Nb_var20 = 20
  Nb_var21 = 21
  Nb_var22 = 22
  Nb_var23 = 23
  Nb_var24 = 24
  Nb_var25 = 25
  Nb_var26 = 26
  Nb_var27 = 27
  Nb_var28 = 28
  Nb_var29 = 29
  Nb_var30 = 30
  Nb_var31 = 31
  Nb_var32 = 32
  Nb_var33 = 33
  Nb_var34 = 34
  Nb_var35 = 35
  Nb_var36 = 36
  Nb_var37 = 37
  Nb_var38 = 38
  Nb_var39 = 39
  Nb_var40 = 40
  Nb_var41 = 41
  Nb_var42 = 42
  Nb_var43 = 43
  Nb_var44 = 44
  Nb_var45 = 45
  Nb_var46 = 46
  Nb_var47 = 47
  Nb_var48 = 48
  Nb_var49 = 49
  Nb_var50 = 50
  Nb_var51 = 51
  Nb_var52 = 52
  Nb_var53 = 53
  Nb_var54 = 54
  Nb_var55 = 55
  Nb_var56 = 56
  Nb_var57 = 57
  Nb_var58 = 58
  Nb_var59 = 59
  Nb_var60 = 60
  Nb_var61 = 61
  Nb_var62 = 62
  Nb_var63 = 63
  Nb_var64 = 64
  Nb_var65 = 65
  Nb_var66 = 66
  Nb_var67 = 67
  Nb_var68 = 68
  Nb_var69 = 69
  Nb_var70 = 70
  Nb_var71 = 71
  Nb_var72 = 72
  Nb_var73 = 73
  Nb_var74 = 74
  Nb_var75 = 75
  Nb_var76 = 76
  Nb_var77 = 77
  Nb_var78 = 78
  Nb_var79 = 79
  Nb_var80 = 80
  Nb_var81 = 81
  Nb_var82 = 82
  Nb_var83 = 83
  Nb_var84 = 84
  Nb_var85 = 85
  Nb_var86 = 86
  Nb_var87 = 87
  Nb_var88 = 88
  Nb_var89 = 89
  Nb_var90 = 90
  Nb_var91 = 91
  Nb_var92 = 92
  Nb_var93 = 93
  Nb_var94 = 94
  Nb_var95 = 95
  Nb_var96 = 96
  Nb_var97 = 97
  Nb_var98 = 98
  Nb_var99 = 99
  '//special read/write registers (in order of memory map)
  Nb_varBP = 100 '//IP address of UDP message port
  Nb_varBM = 101 '//content of udp message (both send and receive)
  Nb_varBI = 102 '//IP destination address for udp message (send only)
  Nb_varEA = 103 '//Email Authentication
  Nb_varEP = 104 '//Email Password
  Nb_varEU = 105 '//Email Username
  Nb_varEV = 106 '//Email smtp server register
  Nb_varEC = 107 '//Email Content register
  Nb_varES = 108 '//Email Subject register
  Nb_varEF = 109 '//Email From register
  Nb_varET = 110 '//Email To register
  '//readonly variables
  Nb_varSD = 111 '//current DNS address register, read only
  Nb_varSG = 112 '//current default gateway register, read only
  Nb_varSI = 113 '//current IP address register, read only
  Nb_varSN = 114 '//current network mask register, read only
  Nb_varST = 115 '//STatus register, read only
  Nb_varSU = 116 '//IP address of last incoming UDP message, read only
  Nb_varSV = 117 '//post register, read only

  '//private constants
  CLS = 0

  
DAT
  'private data
codes
  BYTE "BP" '100
  BYTE "BM" '101
  BYTE "BI" '102
  BYTE "EA" '103
  BYTE "EP" '104
  BYTE "EU" '105
  BYTE "EV" '106
  BYTE "EC" '107
  BYTE "ES" '108
  BYTE "EF" '109
  BYTE "ET" '110
  BYTE "SD" '111 readonly
  BYTE "SG" '112 readonly
  BYTE "SI" '113 readonly
  BYTE "SN" '114 readonly
  BYTE "ST" '115 readonly
  BYTE "SU" '116 readonly
  BYTE "SV" '117 readonly

  
VAR
  'private variables
  byte gStatus
  byte pinkId

  
OBJ
  sio:   "FullDuplexSerial"     'serial driver for Pink device
  
    
PUB PinkV2(id,tx,rx)
  '/**
  ' * Constructor for Pink object
  ' *
  ' * @param id Identifies Pink webserver (use default '0')
  ' * @param tx Transmit pin used to send commands and data to Pink
  ' * @param rx Receive pin to receive status and data from Pink
  ' */
  pinkId := id
  sio.start(rx,tx,0,9600)


PUB clearVar(addr,num)
  '/**
  ' * Clear range of Pink variables.
  ' *
  ' * @param addr Address (0-110) of first Pink variable to clear.
  ' * @param num Number of variables (1-111) to clear.
  ' */
  if (addr => 0) AND (addr < 111) AND (num => 1) '//only write to PINK with valid parameters
    repeat while (addr < 111) AND (num > 0)
      sendCommand(addr++,1)
      sio.tx(":")
      sio.tx(CLS) '//inform PINK this write command is completed
      num--

  
PUB writeVar(addr,buf): writtenBytes | i,c,n
  '/**
  ' * Write value to Pink variable.
  ' * If the number of bytes to write is 64 or more, this method only writes the first 63 bytes.
  ' * Bytes are written up to a binary null (CLS character).
  ' * No bytes are written if any of the parameters is invalid.
  ' *
  ' * @param addr Address (0-110) of Pink variable.
  ' * @param buf Array holding value to write.
  ' * @return Number of bytes written (exclusive closing null) or errorcode.
  ' */
  if (addr < 0) OR (addr > 110)
    writtenBytes := -1 '//do not write to PINK with invalid parameters
  else
    n := 63 'buf.length-1; //maximum number of bytes to write
    i := 0
    c := -1
    sendCommand(addr,1)
    sio.tx(":")
    repeat while (i < n) AND (c <> CLS)
      c := byte[buf+i]
      if (c <> CLS)
        sio.tx(c)
        i++
    sio.tx(CLS) '//inform PINK this write command is completed
    writtenBytes := i

  
PUB readVar(addr,buf): readBytes | i,c,n
  '/**
  ' * Read value from Pink variable.
  ' * This method reads bytes from a variable until a CLS character is encountered,
  ' * or until the buffer is filled, whichever comes first. A closing 0 will be
  ' * appended to the bytes that are read.
  ' *
  ' * @param addr Address (0-117) of Pink variable.
  ' * @param buf Array to hold value (array size should be 64 bytes).
  ' * @return Number of bytes read (exclusive closing 0) or errorcode in case of timeout or invalid parameter.
  ' */
  if (addr < 0) OR (addr > 117)
    readBytes := -1 '//do not write to PINK with invalid parameters
  else 
    n := 63 '//maximum number of bytes to read, last byte is cleared
    sendCommand(addr,0)
    i := 0
    c := -2
    repeat while (c <> CLS) AND (c <> -1) '//keep reading until CLS, even if not stored in buf
      c := sio.rxtime(1000)
      if (i < n) AND (c <> -1)
        byte[buf+i] := c '//only write to buf until position is buf.length-1
        i++
    byte[buf+i] := CLS
    if c == CLS
      readBytes := i-1
    else
      readBytes := -1

  
PUB sendEmail
  '/**
  ' * Send email message.
  ' * Nb_varET, Nb_varEF, Nb_varES, Nb_varEC and Nb_varEV must contain correct values.
  ' */
  sio.tx("!")
  sio.tx("N")
  sio.tx("B")
  sio.tx(pinkId)
  sio.tx("S")
  sio.tx("M")

  
PUB sendUdp
  '/**
  ' * Send UDP message.
  ' * Nb_varBI and Nb_varBM must contain correct values.
  ' */
  sio.tx("!")
  sio.tx("N")
  sio.tx("B")
  sio.tx(pinkId)
  sio.tx("S")
  sio.tx("B")

  
PUB getStatus: status
  '/**
  ' * Get status register.
  ' * Also internally stored for status methods.
  ' *
  ' * @return status or errorcode
  ' */
  sio.tx("!")
  sio.tx("N")
  sio.tx("B")
  sio.tx(pinkId)
  sio.tx("S")
  sio.tx("T")
  gStatus := sio.rxtime(2000) 'wait 2000ms for response, returns -1 if no response
  return gStatus

  
PUB getPost: post
  '/**
  ' * Get post register.
  ' *
  ' * @return post or errorcode
  ' */
  sio.tx("!")
  sio.tx("N")
  sio.tx("B")
  sio.tx(pinkId)
  sio.tx("S")
  sio.tx("V")
  post := sio.rxtime(1000) 'wait 1000ms for response, returns -1 if no response

  
PUB isConnected: YesNo
  '/**
  ' * Check if network connection is established.
  ' * Method getStatus() must have been called.
  ' *
  ' * @return True if network connection established, false otherwise.
  ' */
  YesNo := ((gStatus & $01) <> 0) AND (gStatus <> $FF)

  
PUB isUpdated: YesNo
  '/**
  ' * Check if variable is updated via webpage.
  ' * Method getStatus() must have been called.
  ' * Nb_varSV will hold the number of the last variable updated from a web page POST.
  ' * To read the value of this variable, use readVar(Nb_varSV,buf,offset).
  ' *
  ' * @return True if variable updated, false otherwise.
  ' */
  YesNo := ((gStatus & $02) <> 0) AND (gStatus <> $FF)

  
PUB isReady: YesNo
  '/**
  ' * Check if Pink ready to send email.
  ' * Method getStatus() must have been called.
  ' * Nb_varET, Nb_varEF, Nb_varES, Nb_varEC and Nb_varEV must contain correct values.
  ' *
  ' * @return True if Pink ready to send email, false otherwise.
  ' */
  YesNo := ((gStatus & $04) == 0) AND (gStatus <> $FF)

  
PUB isSent: YesNo
  '/**
  ' * Check if email has been sent succesfully.
  ' * Method getStatus() must have been called.
  ' *
  ' * @return True if email has been sent succesfully, false otherwise.
  ' */
  YesNo := ((gStatus & $10) <> 0) AND (gStatus <> $FF)

  
PUB isUdp: YesNo
  '/**
  ' * Check if there is a new udp message.
  ' * Method getStatus() must have been called.
  ' *
  ' * @return True if new udp message received, false otherwise.
  ' */
  YesNo := ((gStatus & $20) <> 0) AND (gStatus <> $FF)


PUB noResponse: YesNo
  '/**
  ' * Check if Pink responded (no timeout on getStatus).
  ' * Method getStatus() must have been called.
  ' *
  ' * @return True if Pink did not respond, false if Pink did respond.
  ' */
  YesNo := (gStatus == $FF)
  
  
PRI sendCommand(addr,write)
  '/**
  ' * Send command to Pink webserver.
  ' *
  ' * @param addr Address (0-117) of Pink variable.
  ' * @param write True for write command, false for read command
  ' */
  sio.tx("!")
  sio.tx("N")
  sio.tx("B")
  sio.tx(pinkId)
  if write == 1
    sio.tx("W")
  else
    sio.tx("R")
  if addr < 100
    sio.tx((addr/10)+"0")
    sio.tx((addr//10)+"0")
  else
    sio.tx(codes[(addr-100) << 1])
    sio.tx(codes[((addr-100) << 1) + 1])

    