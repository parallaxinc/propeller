{{ serial_terminal.spin

  Bob Belleville

  *******************************
  *  Simple Debug Object        *
  *    (C) 2006 Parallax, Inc.  *
  *******************************
  
  Provide a version of SimpleDebug that matches
  the method calls for tv_terminal so that code
  can use either object with modification.

  Uses FullDuplex and operates at 115200 baud and
  uses the propPlug tx/rcv lines by default.
  (start method)

  Adds a non-blocking get function.
  
  2007/03/03 - simpledebug.spin
               and tv_terminal_demo.spin

}}
 


OBJ
  uart  : "FullDuplexSerial"


PUB start(dummy) : okay

'' Starts uart object (at baud specified) in a cog
'' -- uses Propeller programming connection
'' -- returns false if no cog available

  okay := uart.start(31, 30, 0, 115200) 


PUB startbd(baud) : okay

'' Starts uart object (at baud specified) in a cog
'' -- uses Propeller programming connection
'' -- returns false if no cog available

  okay := uart.start(31, 30, 0, baud) 


PUB startx(rxpin, txpin, baud) : okay

'' Starts uart object (at baud specified) in a cog
'' -- uses specified rx and tx pins
'' -- returns false if no cog available

  okay := uart.start(rxpin, txpin, 0, baud) 


PUB stop

'' Stops uart -- frees a cog

  uart.stop

  
PUB out(txbyte)

'' Send a byte to the terminal

  uart.tx(txbyte)
  
  
PUB putc(txbyte)

'' Send a byte to the terminal

  uart.tx(txbyte)
  
  
PUB str(stringPtr) | i

'' Print a zero-terminated string

  repeat i from 0 to strsize(stringPtr) - 1
    putc(byte[stringPtr][i])


PUB dec(value) | i, z

'' Print a signed decimal number

  if value < 0
    -value
    putc("-")

  i := 1_000_000_000
  z~

  repeat 10
    if value => i
      putc(value / i + "0")
      value //= i
      z~~
    elseif z or i == 1
      putc("0")
    i /= 10


PUB hex(value, digits)

'' Print a hexadecimal number

  value <<= (8 - digits) << 2
  repeat digits
    putc(lookupz((value <-= 4) & $F : "0".."9", "A".."F"))


PUB bin(value, digits)

'' Print a binary number

  value <<= 32 - digits
  repeat digits
    putc((value <-= 1) & 1 + "0")
    

PUB getc : rxbyte

'' Get a character
'' -- will block until something in uart buffer

  rxbyte := uart.rx

 
PUB getcnb : rxbyte

'' Get a character or not (doesn't block)
'' returns -1 if none available

  rxbyte := uart.rxcheck
  
  