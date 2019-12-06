{{
Object file:    FullDuplexSerial.spin
Version:        1.2.1
Date:           2006 - 2011
Author:         Chip Gracey, Jeff Martin, Daniel Harris
Company:        Parallax Semiconductor
Email:          dharris@parallaxsemiconductor.com
Licensing:      MIT License - see end of file for terms of use.

Description:
This driver, once started, implements a serial port in one cog.

Revision History:
v1.2.1 - 5/1/2011 Added extra comments and demonstration code to bring up
                   to gold standard.
v1.2 - 5/7/2009 Fixed bug in dec method causing largest negative value
                (-2,147,483,648) to be output as -0.
v1.1 - 3/1/2006 First official release.

 
=============================================
        Connection Diagram
=============================================

        +---------+   
        ¦         ¦         
        ¦    rxPin+---? TTL level RX line
        ¦    txPin+---? TTL level TX line
        ¦         ¦   
        +---------+           
         Propeller
            MCU
          (P8X32A)

Components:
N/A

=============================================                  
}}


VAR

  'Global variable declarations

  long  cog           'cog flag/id

  '9 longs, MUST be contiguous
  long  rx_head                 
  long  rx_tail
  long  tx_head
  long  tx_tail
  long  rx_pin
  long  tx_pin
  long  rxtx_mode
  long  bit_ticks
  long  buffer_ptr
                     
  byte  rx_buffer[16]           'transmit and receive buffers
  byte  tx_buffer[16]           '16 bytes each


PUB Start(rxPin, txPin, mode, baudrate) : okay
{{
   Start serial driver - starts a cog
   

   Parameters: rxPin    = Propeller pin to set up as RX-ing pin.  Range = 0 - 31
               txPin    = Propeller pin to set up as TX-ing pin.  Range = 0 - 31
               mode     = bitwise mode configuration variable, see mode bit description below.
               baudrate = baud rate to transmit bits at.
   
   mode bit 0 = invert rx
   mode bit 1 = invert tx
   mode bit 2 = open-drain/source tx
   mode bit 3 = ignore tx echo on rx

   return: Numeric value of the cog(1-8) that was started, false(0) if no cog is available.

   example usage: serial.start(31, 30, %0000, 9_600)

   expected outcome of example usage call: Starts a serial port on Propller pins 30 and 31.
                                           The serial port does not invert the RX and TX data,
                                           no open-drain/source on the TX pin, does not ignore
                                           data echoed on RX pin, at 9,600 baud.
}}

  Stop                                                  'make sure the driver isnt already running
  longfill(@rx_head, 0, 4)                              'zero out the buffer pointers
  longmove(@rx_pin, @rxpin, 3)                          'copy the start parameters to this objects pin variables
  bit_ticks := clkfreq / baudrate                       'number of clock ticks per bit for the desired baudrate
  buffer_ptr := @rx_buffer                              'save the address of the receive buffer
  okay := cog := cognew(@entry, @rx_head) + 1           'start the new cog now, assembly cog at "entry" label.


PUB Stop
{{
   Stop serial driver if it has already been started - frees the cog

   Parameters: none
   return:     none

   example usage: serial.stop

   expected outcome of example usage call: Stops an already started serial port.
}}

  if cog
    cogstop(cog~ - 1)                                   'if the driver is already running, stop the cog
  longfill(@rx_head, 0, 9)                              'zero out configuration variables


PUB RxFlush
{{
   Continuously pops the head of the receive buffer until no bytes remain.
   
   Parameters: none
   return:     none

   example usage: serial.RxFlush

   expected outcome of example usage call: Receive bffer will be cleared.
}}

  repeat while RxCheck => 0                             'Call RxCheck until buffer is empty
  
    
PUB RxCheck : rxByte
{{
   Check if a byte is waiting in the receive buffer and return the byte if one is there,
   does NOT block (never waits).

   Parameters: none
   return:     If no byte, then return(-1).  If byte, then return(byte).

   example usage: serial.RxCheck

   expected outcome of example usage call: Return a byte if one is available, but dont wait
                                           for a byte to come in.
}}


  rxByte--                                              'make rxbyte = -1
  if rx_tail <> rx_head                                 'if a byte is in the buffer, then
    rxByte := rx_buffer[rx_tail]                        '  grab it and store in rxByte
    rx_tail := (rx_tail + 1) & $F                       '  advance the buffer pointer


PUB RxTime(ms) : rxByte | t
{{
   Wait ms milliseconds for a byte to be received 

   Parameters: ms = number of milliseconds to wait for a byte to be received.
   return:     If no byte, then return(-1).  If byte, then return(byte).

   example usage: serial.RxTime(500)

   expected outcome of example usage call: Wait half a second (500 ms) for a byte to be received.
}}

  t := cnt                                              'take note of the current time
  repeat until (rxByte := RxCheck) => 0 or (cnt - t) / (clkfreq / 1000) > ms
  

PUB Rx : rxByte
{{
   Receive byte (may wait for byte)
   returns $00..$FF

   Parameters: none
   return:     received byte

   example usage: serial.Rx

   expected outcome of example usage call: Wait until a byte has been received, then return that byte.
}}

  repeat while (rxByte := RxCheck) < 0                  'return the byte, wait while the buffer is empty


PUB Tx(txByte)
{{
   Places a byte into the transmit buffer for transmission (may wait for room in buffer).

   Parameters: txByte = the byte to be transmitted
   return:     none

   example usage: serial.Tx($0D)

   expected outcome of example usage call: Transmits the byte $0D serially on the txPin
}}

  repeat until (tx_tail <> (tx_head + 1) & $F)          'wait until the buffer has room                        
  tx_buffer[tx_head] := txByte                          'place the byte into the buffer
  tx_head := (tx_head + 1) & $F                         'advance the buffer's pointer

  if rxtx_mode & %1000                                  'if ignoring rx echo
    Rx                                                  '   receive the echoed byte and discard


PUB Str(stringPtr)
{{
   Transmit a string of bytes

   Parameters: stringPtr = the pointer address of the null-terminated string to be sent
   return:     none

   example usage: serial.Str(@test_string)

   expected outcome of example usage call: Transmits each byte of a string at the address some_string.
}}

  repeat strsize(stringPtr)
    Tx(byte[stringPtr++])                                                       'Transmit each byte in the string
    

PUB Dec(value) | i, x
{{
   Transmit the ASCII string equivalent of a decimal value

   Parameters: dec = the numeric value to be transmitted
   return:     none

   example usage: serial.Dec(-1_234_567_890)

   expected outcome of example usage call: Will print the string "-1234567890" to a listening terminal.
}}

  x := value == NEGX                                    'Check for max negative
  if value < 0
    value := ||(value+x)                                'If negative, make positive; adjust for max negative
    Tx("-")                                             'and output sign

  i := 1_000_000_000                                    'Initialize divisor

  repeat 10                                             'Loop for 10 digits
    if value => i                                                               
      Tx(value / i + "0" + x*(i == 1))                  'If non-zero digit, output digit; adjust for max negative
      value //= i                                       'and digit from value
      result~~                                          'flag non-zero found
    elseif result or i == 1
      Tx("0")                                           'If zero digit (or only digit) output it
    i /= 10                                             'Update divisor


PUB Hex(value, digits)
{{
   Transmit the ASCII string equivalent of a hexadecimal number

   Parameters: value = the numeric hex value to be transmitted
               digits = the number of hex digits to print                 
   return:     none

   example usage: serial.Hex($AA_FF_43_21, 8)

   expected outcome of example usage call: Will print the string "AAFF4321" to a listening terminal.
}}

  value <<= (8 - digits) << 2
  repeat digits                                         'do it for the number of hex digits being transmitted
    Tx(lookupz((value <-= 4) & $F : "0".."9", "A".."F"))'  Transmit the ASCII value of the hex characters


PUB Bin(value, digits)
{{
   Transmit the ASCII string equivalent of a binary number
   
   Parameters: value = the numeric binary value to be transmitted
               digits = the number of binary digits to print                 
   return:     none

   example usage: serial.Bin(%1110_0011_0000_1100_1111_1010_0101_1111, 32)

   expected outcome of example usage call: Will print the string "11100011000011001111101001011111" to a listening terminal.
}}

  value <<= 32 - digits
  repeat digits
    Tx((value <-= 1) & 1 + "0")                         'Transmit the ASCII value of each binary digit


DAT

'***********************************
'* Assembly language serial driver *
'***********************************

                        org
'
'
' Entry
'
entry                   mov     t1,par                'get structure address
                        add     t1,#4 << 2            'skip past heads and tails

                        rdlong  t2,t1                 'get rx_pin
                        mov     rxmask,#1
                        shl     rxmask,t2

                        add     t1,#4                 'get tx_pin
                        rdlong  t2,t1
                        mov     txmask,#1
                        shl     txmask,t2

                        add     t1,#4                 'get rxtx_mode
                        rdlong  rxtxmode,t1

                        add     t1,#4                 'get bit_ticks
                        rdlong  bitticks,t1

                        add     t1,#4                 'get buffer_ptr
                        rdlong  rxbuff,t1
                        mov     txbuff,rxbuff
                        add     txbuff,#16

                        test    rxtxmode,#%100  wz    'init tx pin according to mode
                        test    rxtxmode,#%010  wc
        if_z_ne_c       or      outa,txmask
        if_z            or      dira,txmask

                        mov     txcode,#transmit      'initialize ping-pong multitasking
'
'
' Receive
'
receive                 jmpret  rxcode,txcode         'run a chunk of transmit code, then return

                        test    rxtxmode,#%001  wz    'wait for start bit on rx pin
                        test    rxmask,ina      wc
        if_z_eq_c       jmp     #receive

                        mov     rxbits,#9             'ready to receive byte
                        mov     rxcnt,bitticks
                        shr     rxcnt,#1
                        add     rxcnt,cnt                          

:bit                    add     rxcnt,bitticks        'ready next bit period

:wait                   jmpret  rxcode,txcode         'run a chuck of transmit code, then return

                        mov     t1,rxcnt              'check if bit receive period done
                        sub     t1,cnt
                        cmps    t1,#0           wc
        if_nc           jmp     #:wait

                        test    rxmask,ina      wc    'receive bit on rx pin
                        rcr     rxdata,#1
                        djnz    rxbits,#:bit

                        shr     rxdata,#32-9          'justify and trim received byte
                        and     rxdata,#$FF
                        test    rxtxmode,#%001  wz    'if rx inverted, invert byte
        if_nz           xor     rxdata,#$FF

                        rdlong  t2,par                'save received byte and inc head
                        add     t2,rxbuff
                        wrbyte  rxdata,t2
                        sub     t2,rxbuff
                        add     t2,#1
                        and     t2,#$0F
                        wrlong  t2,par

                        jmp     #receive              'byte done, receive next byte
'
'
' Transmit
'
transmit                jmpret  txcode,rxcode         'run a chunk of receive code, then return

                        mov     t1,par                'check for head <> tail
                        add     t1,#2 << 2
                        rdlong  t2,t1
                        add     t1,#1 << 2
                        rdlong  t3,t1
                        cmp     t2,t3           wz
        if_z            jmp     #transmit

                        add     t3,txbuff             'get byte and inc tail
                        rdbyte  txdata,t3
                        sub     t3,txbuff
                        add     t3,#1
                        and     t3,#$0F
                        wrlong  t3,t1

                        or      txdata,#$100          'ready byte to transmit
                        shl     txdata,#2
                        or      txdata,#1
                        mov     txbits,#11
                        mov     txcnt,cnt

:bit                    test    rxtxmode,#%100  wz    'output bit on tx pin according to mode
                        test    rxtxmode,#%010  wc
        if_z_and_c      xor     txdata,#1
                        shr     txdata,#1       wc
        if_z            muxc    outa,txmask        
        if_nz           muxnc   dira,txmask
                        add     txcnt,bitticks        'ready next cnt

:wait                   jmpret  txcode,rxcode         'run a chunk of receive code, then return

                        mov     t1,txcnt              'check if bit transmit period done
                        sub     t1,cnt
                        cmps    t1,#0           wc
        if_nc           jmp     #:wait

                        djnz    txbits,#:bit          'another bit to transmit?

                        jmp     #transmit             'byte done, transmit next byte
'
'
' Uninitialized data
'
t1                      res     1
t2                      res     1
t3                      res     1

rxtxmode                res     1
bitticks                res     1

rxmask                  res     1
rxbuff                  res     1
rxdata                  res     1
rxbits                  res     1
rxcnt                   res     1
rxcode                  res     1

txmask                  res     1
txbuff                  res     1
txdata                  res     1
txbits                  res     1
txcnt                   res     1
txcode                  res     1


DAT
{{
+------------------------------------------------------------------------------------------------------------------------------+
¦                                                   TERMS OF USE: MIT License                                                  ¦                                                            
+------------------------------------------------------------------------------------------------------------------------------¦
¦Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    ¦ 
¦files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    ¦
¦modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software¦
¦is furnished to do so, subject to the following conditions:                                                                   ¦
¦                                                                                                                              ¦
¦The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.¦
¦                                                                                                                              ¦
¦THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          ¦
¦WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         ¦
¦COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   ¦
¦ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         ¦
+------------------------------------------------------------------------------------------------------------------------------+
}}