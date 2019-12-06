'' --------------------------
''
'' USB Flash Drive Reader Demo
''
'' --------------------------
CON

  _clkmode  = xtal1 + pll16x                            ' use crystal x 16
  _xinfreq  = 5_000_000
  clk_freq   = 80_000_000
  
'--------IO Pins-----------
  rxUSB   = 10    ' Receive Data    <-- 27937.5 (TXD) white
  txUSB   = 11    ' Transmit Data   --> 27937.4 (RXD) green

  LF            = 10                                    ' line feed
  CR            = 13                                    ' carriage return

VAR         
' none
  
OBJ  
  USB           : "Paul_USBdrive"     ' COM 8 USB (USB Flash Drive)  

  
PUB main | i
  USB.start(txUSB,rxUSB)                    ' start USB drive
'  LCD.str(USB.getErrorMessage)      

  if USB.checkErrorCode == 0
    USB.OpenForWrite(string("Test.txt"))
    USB.WriteLine(string("Hello World!"))
    USB.Close(string("Test.txt"))
        
