''RFID_Demo.spin
''Author: Gavin Garner  
''This program demonstrates how a Parallax RFID scanner can be interfaced with a Propeller chip. A serial, 4-line, Parallax
'' LCD screen is implemented to display an RFID tag's data codes and whether or not they match predetermined tag IDs.

CON
  _xinfreq=5_000_000
  _clkmode=xtal1+pll16x                            '80MHz system clock is recommended for stable data transfer

  LCD_pin=0                                        'Propeller pin connected to LCD's "RX" pin
  RFID=1                                           'Propeller pin connected to RFID's "SOUT" pin (through a 1k resistor)
  RFID_EN=2                                        'Propeller pin connected to RFID's "/ENABLE" pin
                                                        
OBJ
  Debug : "Debug_Lcd"                              'This object is available in the Propeller Library

VAR
  byte i,RFIDdata[12]                              'The RFIDdata array stores ID byte codes read from the RFID
 
PUB Main
  Debug.init(LCD_pin,19200,4)                      'Initialize the Debug_Lcd object
  Debug.cursor(0)                                  'Make the cursor invisible
  Debug.backlight(true)                            'Turn on the backlight  

  repeat
    ReadRFID                                       'This method gets the RFID tag's data from the scanner
    DisplayRFID                                    'This method displays the RFID tag's data on the LCD screen
    Debug.gotoxy(0,3)                              'Set the LCD screen's cursor to start of the bottom line
    if CheckRFID                                   'If the return value from the CheckRFID method is one, then the
      Debug.str(string("Access Granted!"))         ' tag's ID matched one of the preprogrammed codes 
    else                                           'If the return value from the CheckRFID method is zero, then the   
      Debug.str(string("Access Denied!"))          ' tag's ID did not match any of the preprogrammed codes                
                                                   
PUB ReadRFID | bit,time,deltaT                                                                                    
  dira[RFID]~                                      'Set direction of RFID to be an input          
  dira[RFID_EN]~~                                  'Set direction of RFID_EN to be an output                             
  deltaT:=clkfreq/2400                             'Set deltaT to 1/2400th of a second for 2400bps "Baud" rate

  outa[RFID_EN]~                                   'Enable the RFID reader
  repeat i from 0 to 11                            'Fill in the 12 byte arrays with data sent from RFID reader                 
    waitpeq(1 << RFID,|< RFID,0)                   'Wait for a high-to-low signal on RFID's SOUT pin, which
    waitpeq(0 << RFID,|< RFID,0)                   ' signals the start of the transfer of each packet of 10 data bits
    time:=cnt                                      'Record the counter value at start of each transmission packet
    waitcnt(time+=deltaT+deltaT/2)                 'Skip the start bit (always zero) and center on the 2nd bit
    repeat 8                                       'Gather 8 bits for each byte of RFID's data       
      RFIDdata[i]:=RFIDdata[i]<<1 + ina[RFID]      'Shift RFIDdata bits left and add current bit (state of RFID pin)
      waitcnt(time+=deltaT)                        'Pause for 1/2400th of a second (2400 bits per second)
    RFIDdata[i]><=8                                'Reverse the order of the bits (RFID scanner sends LSB first)
  outa[RFID_EN]~~                                  'Disable the RFID reader

PUB DisplayRFID
  Debug.cls                                        'Clear the LCD screen                                     
  if RFIDdata[0]<>10 or RFIDdata[11]<>13           'All cards should have the same start byte and end byte   
      Debug.str(string("Error! Try Again."))
      ReadRFID                                     'Try running the "ReadRFID" method again
  else                                                                                             
    repeat i from 1 to 10                          'Display each of the 10 unique identification bytes             
      Debug.dec(RFIDdata[i])                                                                      
      Debug.str(string(" ")) 

PUB CheckRFID
  repeat i from 0 to 9                             'Compare tag's 10 unique ID #s against ID #s stored in data table
    if RFIDdata[i+1]<>Tag1[i] and RFIDdata[i+1]<>Tag2[i] and RFIDdata[i+1]<>Tag3[i]
      if RFIDdata[i+1]<>Tag4[i] and RFIDdata[i+1]<>Tag5[i] and RFIDdata[i+1]<>Tag6[i]  'etc.
        return 0                                   'If one of the IDs does not match, return a zero
  return 1                                         'If one of the ID sequences matched, return a one
       
DAT
          'i=  0, 1, 2, 3, 4, 5, 6, 7, 8, 9
Tag1    byte  48,70,48,51,48,50,56,53,55,53        '<-- Enter your own RFID tag ID numbers here
Tag2    byte  48,70,48,50,65,54,55,48,69,48
Tag3    byte  48,52,49,54,50,66,66,53,55,54
Tag4    byte  48,70,48,50,65,54,55,50,51,66
Tag5    byte  48,70,48,50,65,54,55,50,51,66
Tag6    byte  48,52,49,54,50,66,66,53,53,54
'etc.

'________________________________________________________________________________________________________________________
{{ Notes:

Data Transfer:
The RFID reader's data is transferred from its embedded PIC microcontroller to the Propeller using an 8-N-1 asynchronous
serial protocol, which means that there are 8 data bits, no parity bits, and 1 stop bit. The data is transferred in
10-bit packets consisting of a start bit (which is always a zero), 8 data bits sent LSB first, and a stop bit (which
is always a one). The RFID reader always sends out twelve of these 10-bit data packets. The first packet always carries
the decimal value 10 in its data byte, which corresponds to a line feed ($0A) in ASCII. The initial bit stream out of
the RFID reader is therefore 0 01010000 1 (where 01010000 is the decimal value 10 sent LSB first). The next 10 packets
sent from the RFID reader transfer the 10 unique data bytes that have been read from an RFID transponder tag. For example,
0 00001100 1 would represent the decimal number 48. The final (12th) packet always carries the decimal value 13 in its
data byte, which corresponds to a carriage return ($0D) in ASCII. The data is sent at 2400 bits per second. I found that
with the system clock running at 80MHz, the asynchronous serial data transfer could be handled by this Spin code. If
you don't mind using an additional cog, the FullDuplexSerial object that is available in the Propeller Library can also
be used to read the data bytes sent from the RFID scanner by calling its "rx" method. For example,
FullDuplexSerial.start(RFID,30,2,2400) , RFIDdata[i]:=FullDuplexSerial.rx 

Equipment:
The Parallax RFID reader module (Parallax part# 28140) is available from the Parallax website for about $40 and is also
available at most local Radio Shack stores as a kit for about $50. Parallax offers an assortment of RFID transponder
tags that are compatible with this RFID reader such as part#s 28141, 28148, 28142 for $2.75 each. The serial, 4-line, LCD
screen that I incorporated was Parallax part#27979 ($40).

Wiring:
Connect the Vcc pin on the RFID reader to +5V (it will not run off of 3.3V)
Connect the Vss pin on the RFID reader to 0V (common with the Propeller's Vss)
Connect the /ENABLE pin on the RFID reader directly to the Propeller's I/O pin assigned to the "RFID_EN" constant 
Connect the SOUT pin on the RFID reader through a 1k resistor to the Propeller's I/O pin assigned to the "RFID" constant

}}

{Copyright (c) 2008 Gavin Garner, University of Virginia
MIT License: Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit
persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and
this permission notice shall be included in all copies or substantial portions of the Software. The software is provided
as is, without warranty of any kind, express or implied, including but not limited to the warrenties of noninfringement.
In no event shall the author or copyright holder be liable for any claim, damages or other liablility, out of or in
connection with the software or the use or other dealings in the software.} 