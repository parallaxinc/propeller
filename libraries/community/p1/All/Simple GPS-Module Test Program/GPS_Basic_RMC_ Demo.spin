''****************************************************
'' File....... GPS_Basic_RMC_ Demo.spin, Rev. 2, 11-19-2015
'' Purpose.... Demonstrate operation of the PAM-7Q GPS
''   receiver. This software reads and displays the National
''   Marine Electronics Association (NMEA) RMC string of
''   characters that give the recommended, minimum GPS info.
''   Requires connection with a PAM-7Q module via a serial port
''   interface connections as shown below for a P8X32A board.
'' Author..... Jon Titus, KZ1G
'' Requires... Extended_FDSerial.spin
''             FullDuplexSerial.spin
''             Timing.spin
''
'' Connections:      PAM-7Q                  P8X32A Board
''                   GND-------------------> GND
''                   VDD-------------------> 3.3 (volts)
''                   TXD-------------------> P8 (input)
''                   RXD-------------------> P9 (optional)
''
'' No license, no terms and conditions; use as you wish. 
'' For NMEA sentence-parsing information, please visit:
''   http://www.gpsinformation.org/dale/nmea.htm#GSV
'' The PAM-7Q module produces the VTG, GGA, GSA, GSV, and GLL
''   sentences as well, but this program does not display them,
''   although the GPS module transmits them along with the RMC information.
''   You may write additional code to display them and decode them.
'' Have fun with your GPS system. --Jon
'' =================================================================================================

CON

  _clkmode = xtal1 + pll16x         'Standard timing information here
  _xinfreq = 5_000_000              '5-MHz external crystal
  
   LF  = 10                         'Line-feed character value (decimal)
   CR  = 13                         'Carriage-return character value
   CLS = 16                         'Clear-screen command

OBJ

  pst  : "Extended_FDSerial"        'Set up Parallax Serial Terminal port
  gps  : "Extended_FDSerial"        'Set serial port for GPS module
  delay : "Timing"                  'Establish timing for short delays
VAR
   byte PropPin_SerOut              'PST serial output pin
   byte PropPin_SerIn               'PST serial input pin
   byte PropPin_SerMode             'Serial mode (set to 0)
   word SerPort_BaudRate            'Bit rate for PST comms

   byte GPS_SerOut                  'GPS serial-output pin
   byte GPS_SerIn                   'GPS serial-input pin
   byte GPS_SerMode                 'GPS serial mode (set to 0)
   word GPS_BaudRate                'GPS serial bit rate
         
   byte GPS_Char                    'Variable for GPS input byte
   byte GPS_Flag                    'Variable for GPS flag bit
   
pub main

   PropPin_SerOut    := 30          'P30 for USB transmit connection with host PC
   PropPin_SerIn     := 31          'P31 for USB receive connection with host PC
   PropPin_SerMode   := 0           'Standard mode. See FullDuplexSerial.spin.
   SerPort_BaudRate  := 9600        'Set baud rate at 9600 per second'Configure Propeller serial port to communicate with host PC via

   GPS_SerOut        := 9           'P9 for receiving data output from GPS module
   GPS_SerIn         := 8           'P8 for data sent to GPS module (not used)+
   GPS_SerMode       := 0           'Standard mode
   GPS_BaudRate      := 9600        'GPS module default bit rate, 9600 bits/sec.
   
   'Parallax Serial Terminal (PST) setup
    pst.Start(PropPin_SerIn, PropPin_SerOut, PropPin_SerMode, SerPort_BaudRate)
    
    'GPS serial port setup
    gps.Start(GPS_SerIn, GPS_SerOUT, GPS_SerMode, GPS_BaudRate)

    delay.pause1s(10)               '10-sec delay to let user switch to PST window
    
  pst.tx(CLS)                       'Clear PST display
  pst.rxflush                       'Clean old data out of PST serial input
  GPS_Flag := 1                     'Flag to note detection of "R" in input from GPS
  repeat until GPS_Flag < 1         'Test flag. Continue if flag is 1
     GPS_Char := gps.rx             'Get a character
     if GPS_Char == "$"             'Is it a dollar sign
        GPS_Char := gps.rx          'Yes, Discard following G
        GPS_Char := gps.rx          'Discard following P                     
        GPS_Char := gps.rx          'Get the 4th char in GPS message
        if GPS_Char == "R"          'Is it "R"? Yes, set flag to 0 to stop looking
            GPS_Flag := 0
            pst.str(String("$GPR"))         'Print the characters $GPR
            repeat until GPS_Char == CR     'Repeat to end of RMC sentence
              GPS_Char := gps.rx            'Get next character... 
              pst.tx(GPS_Char)              ' and print it
       
        else                                'If not an "R" continue here
     else                                   'Get out of if-else code here
     
    '----- End of Program GPS_Basic_RMC_ Demo.spin -----
  