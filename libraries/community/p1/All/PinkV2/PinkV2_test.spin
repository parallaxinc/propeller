{{
***************************
* Pink V2 object test     *
* Coded by Peter Verkaik  *
* Date: December 19, 2007 *
***************************
}}


CON
  'clock settings for spin stamp
  _clkmode = xtal1+pll8x
  _xinfreq = 10_000_000
  
  debugPort = 2 '0=none, 1=propeller TX/RX, 2=spin stamp SOUT/SIN
  
  '//Spin stamp pin assignments
  stampSOUT = 16 'serial out (pin 1 of spin stamp)
  stampSIN  = 17  'serial in  (pin 2 of spin stamp)
  stampATN  = 18  'digital in (pin 3 of spin stamp, when activated, do reboot)

  '//Propeller system pin assignments
  propSCL = 28 'external eeprom SCL
  propSDA = 29 'external eeprom SDA
  propTX  = 30 'programming output
  propRX  = 31 'programming input

  'Application pin assignments
  pinkRX = 10
  pinkTX = 11


OBJ
  myPink:  "PinkV2"                 '//Pink declaration
  debug:   "MultiCogSerialDebug"    '//debug serial driver

  
VAR
  byte buf[64]       'buffer size equals maximum Pink variable size, holds asciiz string
  byte debugSemID    'lock to be used by debug
  long atnStack[10]  'stack for monitoring ATN pin
  
PUB main | pinkstat
  'get lock for debug
  debugSemID := locknew
  'start debug
  case debugPort
    1: debug.start(propRX,propTX,0,9600,debugSemID)
    2: debug.start(stampSIN,stampSOUT,0,9600,debugSemID)
  waitcnt(clkfreq + cnt) 'wait 1 second
  'monitor ATN pin (optional)
  if debugPort == 2
    cognew(atnReset,@atnStack)

  'initialize Pink
  myPink.PinkV2("0",pinkTX,pinkRX)  'the id "0" is currently the only one available

  'send welcome message
  debug.cprintf(string("PinkV2 test program\r"),0,false)

  'check for network connection
  repeat
    myPink.getStatus
    if myPink.noResponse
      debug.cprintf(string("No response from Pink\r"),0,false)
    else
      if myPink.isConnected
        debug.cprintf(string("Pink network connection established\r"),0,false)
  until myPink.isConnected  

  'test write and read variable
  myPink.writeVar(myPink#Nb_var00,string("[Just some value]"))
  myPink.readVar(myPink#Nb_var00,@buf)
  debug.cprintf(string("After writing [Just some value] to Nb_var00, it reads %s\r"),@buf,false)
  
  '//send email message
  debug.cprintf(string("Sending email...\r"),0,false)
  repeat
    waitcnt(clkfreq + cnt) 'wait 1 second
    myPink.getStatus
  until myPink.isReady
  '//set TO address
  myPink.writeVar(myPink#Nb_varET,string("someone@somewhere.com"))
  '//set FROM address
  myPink.writeVar(myPink#Nb_varEF,string("PINK@parallax.com"))
  '//set SUBJECT
  myPink.writeVar(myPink#Nb_varES,string("Test Message From PINK"))
  '//set MESSAGE CONTENT
  myPink.writeVar(myPink#Nb_varEC,string("Message Content Goes Here!"))
  '//set SMTP server
  myPink.writeVar(myPink#Nb_varEV,string("smtp.server.com"))
  '//set smtp USERNAME (optional on some servers)
'  myPink.writeVar(myPink#Nb_varEU,string("username"))
   '//set smtp PASSWORD (optional on some servers)
'  myPink.writeVar(myPink#Nb_varEP,string("password"))
  '//set smtp AUTHENTICATION on/off (optional on some servers)
'  myPink.writeVar(myPink#Nb_varEA,string("1"))
  '//send email
  myPink.sendEmail
  '//check email busy
  repeat 'wait for Pink to become ready to send email again
    waitcnt(clkfreq + cnt) 'wait 1 second
    pinkstat := myPink.getStatus
    debug.cprintf(string("Pink status %08.8b\r"),pinkstat,false)
  until myPink.isSent OR myPink.isReady
  '//check email status
  if myPink.isSent
    debug.cprintf(string("Email sent succesfully\r"),0,false)
  else
    waitcnt(clkfreq + cnt) 'wait 1 second
    pinkstat := myPink.getStatus
    debug.cprintf(string("Pink status %08.8b\r"),pinkstat,false)
    if myPink.isSent
      debug.cprintf(string("Email sent succesfully\r"),0,false)
    else
      debug.cprintf(string("Email send failure\r"),0,false)

  '//send udp message
  '//set DESTINATION ip address
  myPink.writeVar(myPink#Nb_varBI,string("192.168.1.7"))
  '//set MESSAGE CONTENT
  myPink.writeVar(myPink#Nb_varBM,string("Please Send Me A Reply To Port 10000!"))
  '//set udp port
  myPink.writeVar(myPink#Nb_varBP,string("10000"))
  '//send udp
  myPink.sendUdp
  debug.cprintf(string("UDP message sent\r"),0,false)
    
  '//receive udp message
  '//check udp receive status
  repeat
    waitcnt(clkfreq + cnt) 'wait 1 second
    myPink.getStatus
  until myPink.isUdp
  '//read SOURCE ip address
  myPink.readVar(myPink#Nb_varSU,@buf) 
  debug.cprintf(string("UDP message received from %s\r"),@buf,false)
  '//read received udp message
  myPink.readVar(myPink#Nb_varBM,@buf) 
  debug.cprintf(string("Message: %s\r"),@buf,false)
  
  debug.cprintf(string("Program finished\r"),0,false)
  repeat 'loop endlessly


PUB atnReset
  repeat  'loop endlessly
    if INA[stampATN] == 1
      reboot

      