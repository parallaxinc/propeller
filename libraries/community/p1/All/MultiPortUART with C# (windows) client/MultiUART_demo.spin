CON
  
  'clock settings for Propellor
  _clkmode = xtal1+pll16x
  _xinfreq = 5_000_000
  
  'Propeller system pin assignments
 
  propTX  = 30 'serial output pin
  propRX  = 31 'serial input  pin

OBJ
  uart: "MultiUARTFullDuplexSerial"
  cogHelloWorld: "CogTestOfMultiUART"

VAR
  long  i
  long  inputChar
  long cogStarted
  
PUB main

  'Start MultiUART cog code
  
  uart.start(propRX,propTX,0,115200)
  
  waitcnt(clkfreq + cnt) 'wait 1 second

  'Send the usual "Hello world" (with CR) to all 8 channels
  
  repeat i from 1 to 8
    uart.writeLineToUARTn( i, string("Hub says: Hello world"))


  'We're going to deliberately try to start too many cogs with the test code
  repeat i from 1 to 8
    cogStarted := cogHelloWorld.start( uart.AddressOfTxregn( i+1 ), uart.AddressOfRxregn( i+1) )
    if cogStarted
      uart.writeLineToUARTn( 1, string("cog started") )      'should succeed 6 times
    else
      uart.writeLineToUARTn( 1, string("cog start failed") ) 'should fail 2 times

  'Now execute an infinite loop that simply echoes any characters received
  'from channel 1 or 8 back to that channel
  
  repeat
    if uart.charAvailUARTn( 1 )
      uart.writeByteToUARTn( 1, uart.getByteFromUARTn( 1 ) )
    if uart.charAvailUARTn( 8 )
      uart.writeByteToUARTn( 8, uart.getByteFromUARTn( 8 ) )
  