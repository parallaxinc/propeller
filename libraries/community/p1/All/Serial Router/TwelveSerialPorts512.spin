con ' This deals with having 3 cogs connected to 4 serial ports each in a more or less transparent way, so you have COM0 to COM11 to deal with instead.

SECONDARY_BUFFER_SIZE = 512

obj
        com0:"SerialPortBank0B"
        com1:"SerialPortBank1B"
        com2:"SerialPortBank2B"


var
long bb
PUB AddPortNoHandshake(port,rxpin,txpin,mode,baudrate) ' for compatibility with fullduplexserial
     return AddPort(port,rxpin,txpin,-1,-1,0,mode,baudrate)
PUB AddPort(port,rxpin,txpin,ctspin,rtspin,rtsthreshold,mode,baudrate)
    bb := (port >> 2)
  if (bb == 0)
        return com0.AddPort((port & 3),rxpin,txpin,ctspin,rtspin,rtsthreshold,mode,baudrate)
  if bb == 1
        return com1.AddPort((port & 3),rxpin,txpin,ctspin,rtspin,rtsthreshold,mode,baudrate)
  else
     return com2.AddPort((port & 3),rxpin,txpin,ctspin,rtspin,rtsthreshold,mode,baudrate)
PUB Start
    result:=com0.start
    result*=10
    result+=com1.start
    result*=10
    result+=com2.start ' last cog
PUB Stop
    reboot ' necessary because we're overwriting the buffer
    
PUB getCogID(port)
    bb := (port >> 2)
  if bb == 0
    return com0.getCogID
  if bb == 1
    return com1.getCogID
 return com2.getCogID
PUB rxflush(port)
    bb := (port >> 2)
  if bb == 0
    return com0.rxflush((port & 3))
  if bb == 1
    return com1.rxflush((port & 3))
 return com2.rxflush((port & 3))
PUB rxcheck(port) : rxbyte
    bb := (port >> 2)
  if bb == 0
    return com0.rxcheck((port & 3))
  if bb == 1
    return com1.rxcheck((port & 3))
 return com2.rxcheck((port & 3))
PUB rxtime(port,ms) : rxbyte 
    bb := (port >> 2)
  if bb == 0
    return com0.rxtime((port & 3),ms)
  if bb == 1
    return com1.rxtime((port & 3),ms)
 return com2.rxtime((port & 3),ms)
PUB rx(port) : rxbyte
    bb := (port >> 2)
  if bb == 0
    return com0.rx((port & 3))
  if bb == 1
    return com1.rx((port & 3))
 return com2.rx((port & 3))
PUB tx(port,txbyte)
    bb := (port >> 2)
  if bb == 0
    return com0.tx((port & 3),txbyte)
  if bb == 1
    return com1.tx((port & 3),txbyte)
 return com2.tx((port & 3),txbyte)
PUB txflush(port)
    bb := (port >> 2)
  if bb == 0
    return com0.txflush((port & 3))
  if bb == 1
    return com1.txflush((port & 3))
 return com2.txflush((port & 3))
PUB str(port,stringptr)
    bb := (port >> 2)
  if bb == 0
    return com0.str((port & 3),stringptr)
  if bb == 1
    return com1.str((port & 3),stringptr)
 return com2.str((port & 3),stringptr)
PUB dec(port,value) 
    bb := (port >> 2)
  if bb == 0
    return com0.dec((port & 3),value)
  if bb == 1
    return com1.dec((port & 3),value)
 return com2.dec((port & 3),value)
PUB hex(port,value, digits)
    bb := (port >> 2)
  if bb == 0
    return com0.hex((port & 3),value,digits)
  if bb == 1
    return com1.hex((port & 3),value,digits)
 return com2.hex((port & 3),value,digits)
PUB bin(port,value, digits)
    bb := (port >> 2)
  if bb == 0
    return com0.bin((port & 3),value,digits)
  if bb == 1
    return com1.bin((port & 3),value,digits)
 return com2.bin((port & 3),value,digits)
PUB newline(port)
    bb := (port >> 2)
  if bb == 0
    return com0.str((port & 3),@crlf)
  if bb == 1
    return com1.str((port & 3),@crlf)
 return com2.str((port & 3),@crlf)
dat
crlf byte 13,10,0