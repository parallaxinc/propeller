{{NMEA message generator for testing GPS parser

}} 
VAR
  long                stack[50]
  long                Bit_delay
  byte                tx_pin

DAT                  
'                                                                        satellites  horizontal dilution
'                                                                        quality  |  |           geoidal separation
'                                        time       latitude     longitude     |  |  |  altitude  |   age   differential reference ID
'                                        |          |            |             |  |  |  |         |    |    |
GGA_string              byte      "--GGA,123456.000,3848.75631,N,12117.75831,W,1,09,1.3,79.1,M,-33.5,M,,0000",0
'                                                                                                 magvar
'                                        time  status  latitude    longitude   speed  course  date  ||mode
'                                        |          |  |           |             |    |       |     |||
RMC_string              byte      "--RMC,123456.000,A,3848.75631,N,12117.75831,W,12.3,336.78,180419,,,A",0

PUB Null

PUB Start(pin, bit_rate)
  tx_pin := pin
  bit_delay := clkfreq / bit_rate
  cognew(Main,@stack)
  
PUB Main | t

  dira[tx_pin] := 1
  outa[tx_pin] := 1

  t := clkfreq + cnt

  repeat
    send(@GGA_string)
    waitcnt(clkfreq / 100 + cnt)
    send(@RMC_string)
    waitcnt(t += clkfreq)
    tick
    
PRI Tick                                                                       
  if ++GGA_string[11] == ":"
    GGA_string[11] := "0"
    if ++GGA_string[10] == "6"
      GGA_string[10] := "0"
      if ++GGA_string[9] == ":"
        GGA_string[9] := "0"
        if ++GGA_string[8] == "6"
          GGA_string[8] := "0"
          if ++GGA_string[7] == "4" and GGA_string[6] == "2"
            GGA_string[7] := GGA_string[6] := "0"
          if ++GGA_string[7] == "9"
            GGA_string[7] := 0
            ++GGA_string[6]
  bytemove(@RMC_string[6],@GGA_string[6],6)
   
PRI Send(stringPtr) | cksum

    cksum := 0
    tx("$")
    repeat strsize(stringPtr)
      tx(byte[stringPtr])                                                 
      cksum ^= byte[stringPtr++]
    tx("*")
    hex(cksum,2)
    tx($0D)
    tx($0A)
    
PRI Hex(value, digits)

  value <<= (8 - digits) << 2
  repeat digits                                         
    Tx(lookupz((value <-= 4) & $F : "0".."9", "A".."F"))

PRI Tx(txByte) | time

  time := cnt

  outa[Tx_pin]~
  repeat 8
    waitcnt(time += Bit_Delay)
    outa[Tx_pin] := txByte & 1
    txByte >>= 1
  waitcnt(time += Bit_Delay)
  outa[Tx_pin]~~
  waitcnt(time += Bit_Delay)    