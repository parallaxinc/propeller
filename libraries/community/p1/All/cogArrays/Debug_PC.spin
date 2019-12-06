'' *****************************
'' *  Debug_PC                 *
'' *  (C) 2006 Parallax, Inc.  *
'' *****************************

'' Debugging wrapper for FullDuplexSerial object.  Code is designed for connection to PC through
'' an inverter (e.g., Propeller Clip
''
'' Author.... Jon Williams
'' Updated... 05 MAY 2006


CON

  LF   = 10                                             ' line feed
  FF   = 12                                             ' form feed
  CR   = 13                                             ' carriage return

  MODE = %0000                                          ' RX true
                                                        ' TX true
                                                        ' TX is driven
                                                        ' don't ingore TX on RX
  

OBJ

  uart : "fullduplexserial"
  num  : "simple_numbers"



PUB padchar(count, txbyte)
  repeat count
     uart.tx(txbyte)
  

PUB start(baud) : okay

'' Starts uart object (at baud specified) in a cog
'' -- uses Propeller programming connection
'' -- returns false if no cog available
  okay := uart.start(31, 30, MODE, baud) 


PUB startx(rxpin, txpin, baud) : okay
'' Starts uart object (at baud specified) in a cog
'' -- uses specified rx and tx pins
'' -- returns false if no cog available
  okay := uart.start(rxpin, txpin, MODE, baud) 

PUB getCogID : result
  return uart.getCogID  

PUB stop
'' Stops uart -- frees a cog
  uart.stop

  
PUB putc(txbyte)
'' Send a byte to the terminal
  uart.tx(txbyte)
  
  
PUB str(strAddr)
'' Print a zero-terminated string
  uart.str(strAddr)

PUB strln(strAddr)
'' Print a zero-terminated string
  uart.str(strAddr)
  uart.tx(13)  

PUB dec(value)
'' Print a signed decimal number
  uart.str(num.dec(value))  


PUB decf(value, width) 
'' Prints signed decimal value in space-padded, fixed-width field
  uart.str(num.decf(value, width))   
  

PUB decx(value, digits) 
'' Prints zero-padded, signed-decimal string
'' -- if value is negative, field width is digits+1
  uart.str(num.decx(value, digits)) 


PUB hex(value, digits)
'' Print a hexadecimal number
  uart.str(num.hex(value, digits))


PUB ihex(value, digits)
'' Print an indicated hexadecimal number
  uart.str(num.ihex(value, digits))   


PUB bin(value, digits)
'' Print a binary number
  uart.str(num.bin(value, digits))


PUB ibin(value, digits)
'' Print an indicated binary number
  uart.str(num.ibin(value, digits)) 
  

PUB newline
  putc(CR)
'  putc(LF)


PUB cls
  putc(FF)
  

PUB getc
'' Get a character
'' -- will block until something in uart buffer
   return uart.rxcheck
'  return uart.rx
  
  