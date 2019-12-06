'' *****************************
'' *  PC_Debug                 *
'' *  (C) 2006 Parallax, Inc.  *
'' *****************************
''
'' Creates a "debug" object useful for sending values to a PC terminal program.

  
OBJ

  uart : "fullduplex"


PUB start(baud) : okay

'' Starts uart object (at baud specified) in a cog
'' -- uses Propeller programming connection
'' -- returns false if no cog available

  okay := uart.start(31, 30, baud) 


PUB startx(rx_pin, tx_pin, baud) : okay

'' Starts uart object (at baud specified) in a cog
'' -- uses specified rx and tx pins
'' -- returns false if no cog available

  okay := uart.start(rx_pin, tx_pin, baud) 


PUB stop

'' Stops uart -- frees a cog

  uart.stop


PUB out(txbyte)

  uart.tx(txbyte)


PUB str(string_ptr)

'' Print a zero-terminated string

  uart.str(string_ptr)

   
PUB dec(value) | div, zpad

'' Print a signed decimal number

  if (value < 0)                                        ' negative?
    -value                                              '   yes, make positive
    out("-")                                            '   and print sign indicator

  div := 1_000_000_000                                  ' initialize divisor
  zpad~                                                 ' clear zero-pad flag

  repeat 10
    if (value => div)                                   ' printable character?
      out(value / div + "0")                            '   yes, print ASCII digit
      value //= div                                     '   update value
      zpad~~                                            '   set zflag
    elseif zpad or (div == 1)                           ' printing or last column?
      out("0")
    div /= 10                                           ' point to next column


PUB hex(value, digits)

'' Print a hexadecimal number

  digits := 1 #> digits <# 8                            ' qualify digits
  value <<= (8 - digits) << 2                           ' prep MS digit
  repeat digits
    out(lookupz((value <-= 4) & %1111 : "0".."9", "A".."F"))


PUB ihex(value, digits)

  out("$")
  hex(value, digits)
    

PUB bin(value, digits)

'' Print a binary number

  digits := 1 #> digits <# 32                           ' qualify digits 
  value <<= 32 - digits                                 ' prep MSB
  repeat digits
    out((value <-= 1) & 1 + "0")    


PUB ibin(value, digits)

  out("%")
  bin(value, digits)

  
PUB tab

  out(9)                                                ' send Tab character
  
    
PUB lf

  out(10)                                               ' send line feed
  
    
PUB ff

  out(12)                                               ' send form feed
  

PUB newline

  out(13)                                               ' send CR character


PUB crlf

'' Useful for terminals that don't add LF to CR

  out(13)                                               ' send CR character
  out(10)                                               ' send line feed


PUB in : rxbyte

'' Get a character
'' -- will block until something in uart buffer

  rxbyte := uart.rx
  
    