One Wire Demo v1.0
July 18, 2006

OW-Demo1
-------------
- simple example of interfaces to a single DS1822 temperature chip
- same as the Basic Stamp OWIN_OWOUT demo

OW-SearchDemo
-------------
- demonstrates the 1-wire device search
- finds all devices on 1-wire and displays address and checks crc

OneWire Low-Level Routines
--------------------------

start(dataPin)
 where: dataPin is the pin number for the 1-wire data line
 - starts a new cog
 - selects the pin to use for the 1-wire data line
 - calculates timing value (clock must be >= 20 MHz)
    
stop
  - stops and releases cog
         
reset
  returns: 0 if no presence, or 1 if presence
  - send 1-wire reset sequence

writeAddress(p)
  params: p is pointer to 64-bit address
  - writes address to 1-wire

readAddress(p)
  params: p is pointer to 64-bit address
  - reads address from 1-wire and stores at pointer

writeByte(b)
  params: b is 8-bit value
  - writes 8-bit byte to 1-wire

writeBits(b, n)
  params: b is a 1 to 32 bit value
          n is the number of bits
  - writes n bits to 1-wire
    
readByte
  return: 8-bit value
  - reads 8-bit value from 1-wire

readBits(n)
  return: n bit value
  - reads n bit value from 1-wire
          
search(f, n, p)
  params: f is family code (not yet implemented, use 0 value for now)
          n is maximum number of addresses
          p is pointer to address array
  return: number of addresses found
  - performs 1-wire device search and returns the address of all devices
  - terminates search at maximum number of addresses

crc8(n, p)
  params: n is number of bytes
          p is pointer to byte array
  return: crc-8 for the selected bytes

