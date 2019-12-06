'' *****************************
'' *  Simple Async Driver      *
'' *  (c) 2006 Parallax, Inc.  * 
'' *****************************
''
'' Bit-bang serial driver for low baud rate (~19.2K) devices
''
'' Authors... Chip Gracey, Phil Pilgrim, Jon Williams
'' Updated... 29 APR 2006
''
'' This driver is designed to be method-compatible with the FullDuplex serial object, allowing
'' it to be used when high speed comms or devoting an independent cog for serial I/O is not
'' necessary. 
''
'' To specify inverted baud (start bit = 1), use a negative baud value:
''
''     serial.start(0, 1, -9600)
''
'' If bi-directional communication is desired on the same pin, the serial line should be pulled-up
'' for true mode, or pulled-down for inverted mode as the tx pin will be placed into a hi-z (input)
'' state at the end of transmition to prevent an electrical conflict.
''
'' If only one side is required (e.g., just serial output), use -1 for the unused pin:
''
''     serial.start(-1, 0, 19_200)
''
'' Tested to 19.2 kbaud with clkfreq of 80 MHz (5 MHz crystal, 16x PLL)


VAR

  long  sin, sout, inverted, bitTime, started, rxOkay, txOkay   


PUB start(rxPin, txPin, baud)

  stop                                                  ' clean-up if restart
  sin := sout := -1
  
  if lookdown(rxPin : 0..31)                            ' qualify rx pin
    sin := rxPin                                        ' save it
    rxOkay := started := true                           ' set flags

  if lookdown(txPin : 0..31)                            ' qualify tx pin
    sout := txPin                                       ' save it   
    txOkay := started := true                           ' set flags 

  if started
    inverted := (baud < 0)                              ' set inverted flag
    bitTime := clkfreq / ||baud                         ' calculate serial bit time  
  
  return started
  

PUB stop

  if started
    if txOkay                                           ' if tx enabled
      dira[sout]~                                       '   float tx pin
    rxOkay := txOkay := started := false


PUB rxCheck

'' Always returns -1 as there is no buffer

  return -1


PUB rx | t, b

'' Receive a byte; blocks program until byte received

  if started and rxOkay
    dira[sin]~                                          ' make rx pin an input
    waitpeq(inverted & |< sin, |< sin, 0)               ' wait for start bit
    t := cnt + bitTime >> 1                             ' sync + 1/2 bit
    repeat 8
      waitcnt(t += bitTime)                             ' wait for middle of bit
      b := ina[sin] << 7 | b >> 1                       ' sample bit 
    waitcnt(t + bitTime)                                ' allow for stop bit 

    return (b ^ inverted) & $FF                         ' adjust for mode and strip off high bits


PUB tx(txByte) | t

'' Transmit a byte

  if started and txOkay
    outa[sout] := !inverted                             ' set idle state
    dira[sout]~~                                        ' make tx pin an output        
    txByte := ((txByte | $100) << 2) ^ inverted         ' add stop bit, set mode 
    t := cnt                                            ' sync
    repeat 10                                           ' start + eight data bits + stop
      waitcnt(t += bitTime)                             ' wait bit time
      outa[sout] := (txByte >>= 1) & 1                  ' output bit (true mode)  
    
    if sout == sin
      dira[sout]~                                       ' release to pull-up/pull-down

    
PUB str(strAddr)

'' Transmit z-string at strAddr

  if started and txOkay
    repeat strsize(strAddr)                             ' for each character in string
      tx(byte[strAddr++])                               '   write the character

       