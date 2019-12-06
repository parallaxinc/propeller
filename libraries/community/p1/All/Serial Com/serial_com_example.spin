{
                                *****************|| SERIAL COMMUNICATION LOGIC EXAMPLE||*********************
                                
  This routine is used to demonstrate the communication logic of the serial_com and serial_com_slave routines. In essence,
  the system is based on I2C in that the master drives the CLK line of the system to indicate when to sample the SDA line
  for data. A CS pin allows multiple slave devices to share the same CLK and SDA pins, provided that each has a separate
  CS pin for identification. This example quickly scrolls through 100 cycles of transmission and receiving a byte between
  a slave and master device. The fastest communication so far clocked is approximately 40 bytes per second, 20 cycles. This
  is measured implementing the Spin Stamp which utilizes a 10 MHz external crystal with a 4x PLL mode. After every 100 cycles
  the program pauses to let a number between 1 and 255 be displayed. The matching slave program uses a very basic counter to
  track the cycles, and to send this value back to the master which, via this program, displays it on the LCD. Feel free to
  add pause(...) commands in the indicated line of the program to slow down the transfer to view each individual cycle                                      
}
con
  sda = 5
  clk = 6
  cs =  1
  _clkmode = xtal1 + pll4x
  _xinfreq = 10_000_000
       
var
  long monitor
  
obj
  lcd : "LCD"
  ser : "serial_com"
  
pub main
  lcd.start(4, 2400)                                                        'starts the LCD screen
  ser.initialize(sda, clk, cs)
  lcd.cls                                                                       'clears the LCD screen
  lcd.print(320)                                                                'writes the number 320 to the LCD as a test           
  pause(30_000_000)
  repeat
    pause(30_000_000)
    repeat 100       
      lcd.cls                                                                   'clear the LCD                                                                                 
      ser.start                                                                 'open the terminal for communication
      ser.tx($12)                                                               'transmit a byte to the slave device
      monitor := ser.rx                                                         'receives a byte from the slave device
      ser.checkstop                                                             'checks for the slave to signal end of communication
      lcd.print(monitor)                                                        'print received byte to LCD
      '*******| Add pause(...) routine here to slow down the program. Match indentation with the line immediately above |******                           
      
pub pause(delay)
  waitcnt(delay + cnt)
  