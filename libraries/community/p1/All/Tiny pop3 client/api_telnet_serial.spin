OBJ
  tcp : "driver_socket"
  
VAR
  long handle
  word listenport
  byte listening

PUB start(cs, sck, si, so, int, xtalout, macptr, ipconfigptr)

  tcp.start(cs, sck, si, so, int, xtalout, macptr, ipconfigptr)

PUB stop

  tcp.stop

PUB connect(ip1, ip2, ip3, ip4, remoteport, localport)

  listening := false
  return (handle := tcp.connect(ip1, ip2, ip3, ip4, remoteport, localport))

PUB listen(port)

  listenport := port
  listening := true
  return (handle := tcp.listen(listenport))

PUB isConnected

  return tcp.isConnected(handle)

PUB resetBuffers

  tcp.resetBuffers(handle)

PUB waitConnectTimeout(ms) | t

  t := cnt
  repeat until isConnected or (((cnt - t) / (clkfreq / 1000)) > ms)

PUB close

  tcp.close(handle)

PUB rxflush

  repeat while rxcheck => 0

PUB rxcheck

  if listening
    ifnot tcp.isValidHandle(handle)
      listen(listenport)

  return tcp.readByteNonBlocking(handle)

PUB rxtime(ms) : rxbyte | t

  t := cnt
  repeat until (rxbyte := rxcheck) => 0 or (cnt - t) / (clkfreq / 1000) > ms

PUB rx : rxbyte

  repeat while (rxbyte := rxcheck) < 0

PUB txcheck(txbyte)

  if listening
    ifnot tcp.isValidHandle(handle)
      listen(listenport)

  return tcp.writeByteNonBlocking(handle, txbyte)

PUB tx(txbyte)

  repeat while txcheck(txbyte) < 0

PUB str(stringptr)                

  repeat strsize(stringptr)
    tx(byte[stringptr++])    

PUB dec(value) | i

'' Print a decimal number

  if value < 0
    -value
    tx("-")

  i := 1_000_000_000

  repeat 10
    if value => i
      tx(value / i + "0")
      value //= i
      result~~
    elseif result or i == 1
      tx("0")
    i /= 10


PUB hex(value, digits)

'' Print a hexadecimal number

  value <<= (8 - digits) << 2
  repeat digits
    tx(lookupz((value <-= 4) & $F : "0".."9", "A".."F"))


PUB bin(value, digits)

'' Print a binary number

  value <<= 32 - digits
  repeat digits
    tx((value <-= 1) & 1 + "0")