{{
2114_RAM_Write_Read_01.spin

Copyright (c) 2011 Greg Denson
See end of file for terms of use 


Created;
Greg Denson, 2014-05-02

Modified: 2014-05-09
-------------------------------------------------------------------------------------------------------------
This is, for me, a first attempt at sending data to a 2114 4K Static RAM chip,
and then reading the data that was sent.

I wrote this for beginners, and non-professional electronics lovers like myself.  It is intended
to be simple, easy to understand, and easy to expand.

Please note that, as shorthand, I've used HI to represent on, 1, high, etc., and used LO to represent off, 0, low,
etc., in the notes and comments, below.

So, to start, I set up a decimal number, in binary format, down in the program below.  I have outlined
the section where this is done, below, with comment lines that looks like this:
 '########################################################
These lines, with the hash marks, above and below these sections should make it easier to find the place
where you need to set up your data, and your memory address in the chip. For my first efforts, I'm just
hard-coding them into the program. Use the 'outa' command to set the various data lines to HI or LO in that section
of the program, below.

 
Here's the pinout for the 2114 chip that I used.  I think my chip is an older style that has 18 pins.
I've seen some newer ones that have only 16 pins, but they call for a more sophisticated power
supply than I had available on my breadboard (a -5V supply, for example), so I'm sticking with this 18 pin version
because it is easier to set up:
1 = A6                   18 = VCC (+5V)
2 = A5                   17 = A7
3 = A4                   16 = A8  (A0-A9 are the 10 address lines)
4 = A3                   15 = A9
5 = A0                   14 = IO1 (IO1-IO4 are the four data lines)
6 = A1                   13 = IO2
7 = A2                   12 = IO3
8 = CS (Chip Select)     11 = IO4
9 = GND(Ground)          10 = WE  (Write Enable)

NOTE:  CS and WE are normally high, and are enabled by bringing them low. If you want to experiment
with these chips more, be sure to download a datasheet and look at the pinout diagrams, truth table etc.


For my chip, the Truth Table looks like this:
CS      WE      IO              MODE
---     ---     ---             -----
H       X       Hi-Z            Not selected
L       L       H               Write a 1 to the chip
L       L       L               Write a 0 to the chip
L       H       Dout            Read from chip

So note that both Chip Select (CS) and Write Enable (WE) must go LO in order to write to the chip.
And, of course the IO line is set to 0 or 1 depending on what you want to
write to that particular data line.
To read from the chip, keep CS at LO, and bring WE to HI.


IMPORTANT NOTE:  There isn't much mention in all this about the Address Lines.  To do a simple experiment
like this one, you can just pick an address, and code it into the program below.  Later, if you expand on
this idea, you may want a programmatic method of selecting a memory location to write to, and read from.

Also in one of my hash mark comments ('########) below,you'll see where I hard coded my address to be 3
using these lines:
    outa[5]~~                  ' Set both to high for address = 3
    outa[6]~~
By hard-coding Address Line 0 and Address Line 1 (Prop Pins P05 and P06) to HI (1), the address is hard-coded
to be decimal 3.  I'm thinking of also experimenting with using a DIP switch to set the address so I don't
have to modify the code.  Setting some constants might also be a way to make this easier to make changes.


Here are the pin connections that I used between the 2114 chip and the Parallax Demo Board.
I have sorted it both ways, numerically by the 2114 pins, and by the Prop Board Pins.
One of the hardest parts of this project was getting all the connections correct.  So,
take your time and double check your work.

2114  --> PROP  |   PROP  -->    2114
01, A6    P03   |   P15          08, CS
02, A5    P04   |   P14          10, WE
03, A4    P05   |   P13          11, IO4
04, A3    P06   |   P12          12, IO3
05, A0    P09   |   P11          13, IO2
06, A1    P08   |   P10          14, IO1
07, A2    P07   |   P09          05, A0
08, CS    P15   |   P08          06, A1
09, GND   GND   |   P07          07, A2
10, WE    P14   |   P06          04, A3
11, IO4   P13   |   P05          03, A4
12, IO3   P12   |   P04          02, A5
13, IO2   P11   |   P03          01, A6
14, IO1   P10   |   P02          15, A7
15, A7    P02   |   P01          16, A8
16, A8    P01   |   P00          17, A9
17, A9    P00   |   +5V          18, VCC
18, VCC   +5V   |   GND          09, GND

I hope you enjoy playing with this program.  Maybe you'll post and share a great project based on
it sometime soon.  Have fun!
Greg

}}

CON
  _clkmode = xtal1 + pll16x             ' Set up the clock frequencies
  _xinfreq = 5_000_000
  
OBJ
  pst   : "Parallax Serial Terminal"       'I used the serial terminal to display the results.

VAR
  byte   PIN13           'A variable to hold the value when reading Prop Pin 13, IO4 on the chip. 
  byte   PIN12           'Same for Pins 12-10
  byte   PIN11
  byte   PIN10
  byte   EIGHT           'A variable to hold the value of the EIGHTs digit.
  byte   FOUR            'And so on for FOURs, TWOs, and ONEs.
  byte   TWO             'My method of calculating the decimal value stored on the chip is very
  byte   ONE             'simplistic, but I hope it will be easy to follow, and you can develop
  byte   SUM             'your own sophisticated method.
    
PUB demo
    pst.start(9600)

'Hold for a few seconds, time to start up Parallax Serial Terminal after running the program.
'I put in a few delays and some text output here and there so that I would have time to watch the
'program work, and to be able to tell where it was in the process.  You can remove this without
'causing any harm.

    waitcnt(clkfreq*4 + cnt)                         ' Increase the 4 if more time is required.

    pst.str(string("Setting up 2114 Chip...",13,10)) ' About to start setting up the Pins, etc.

'Set up Address Lines as output, Pull all to LO  (Just to be sue all is set up consistently)
    dira[0]~~                 
    dira[1]~~                 
    dira[2]~~                
    dira[3]~~                 
    dira[4]~~                 
    dira[5]~~                
    dira[6]~~                
    dira[7]~~             
    dira[8]~~                
    dira[9]~~                      

    outa[0]~                 
    outa[1]~                 
    outa[2]~                
    outa[3]~                 
    outa[4]~                 
    outa[5]~                
    outa[6]~                
    outa[7]~             
    outa[8]~                
    outa[9]~
          
'Set up Data Lines as output, Pull all to LO
    dira[10]~~                 
    dira[11]~~                 
    dira[12]~~                
    dira[13]~~

    outa[10]~                 
    outa[11]~                
    outa[12]~                
    outa[13]~

'Set up Control Lines as output. Pull all to HI                
    dira[14]~~                 'Set 14 to output (WE)
    dira[15]~~                 'Set 15 to output (CS)

    outa[14]~~                 'Set 14 HI
    outa[15]~~                 'Set 15 HI

    
'-------------------------------------------------------------------------------------
'Set up to WRITE the data.  Now with the Prop Pins and the chip set up, you're ready to write data.

   pst.str(string("Ready to Write...",13,10))


'HERE ARE THE AREAS WHERE YOU CAN CHANGE THE ADDRESS AND DATA YOU WANT TO WRITE
'####################################################################################################   
'And set up the Address Lines for the Write action  
    outa[9]~~                  'Address Line A0. Set to HI for address = 3
    outa[8]~~                  'Address Line A1, Also set to HI for address = 3
'Remember, you can add all the other Address Line Pins in here, and make even more changes to the
'addresses.  Ijust hard-coded it to 3 for my testing.
'####################################################################################################  
'Set up the Data Lines for the Write action.  This determines the value you send to and
'read from the 2114 chip. IO1 = ONEs digit, IO2 = TWOs digit, IO3 = FOURs digit, IO4 = EIGHTS digit.
'By setting these pins to HI or LO, you can represent decimal numbers from 0-15 in binary form.
    outa[10]~~  'IO1 is HI  1  'Set all IO lines to HI or LO (1 or 0) to indicate they are on or off.
    outa[11]~~  'IO2 is HI  1             
    outa[12]~~  'IO3 is HI  1            
    outa[13]~   'IO4 is LO  0  'These settings represent the binary number 0111, or decimal 7.
                               'Change these settings to send different numbers (0-15) to the chip.               
'####################################################################################################
    
'Now set up the Control Lines for writing.  This is what actually kicks of the WRITE action.
    outa[14]~                  'Set both low for the write action
    outa[15]~

'Hold for 1/10 second...    
    waitcnt(100_000 + cnt)     'Hold for about 1/10 second. May not be necessary, but I just wanted
                               'to be sure there was time for the WRITE operation to complete
                               'before doing anything else

'Reset the Control Lines after the Write action
    outa[14]~~                 'The WRITE is over, set Pin 14 back to HI
    outa[15]~~                 'And also set Pin 15 back to HI

'Reset the Data Lines after the Write Action
    outa[9]~                   'Set both to LO again
    outa[8]~

   pst.str(string("Write is complete...",13,10)) 
'------------------------------------------------------------------------------------------
'Prepare to read the data from the 2114 chip...

    pst.str(string("Starting to Read...",13,10))           

 'For reading, you need to set up the Data Lines as input,
    dira[10]~                 
    dira[11]~                 
    dira[12]~                
    dira[13]~

'Set up Control Lines as output, and set them to HI.                 
    dira[14]~~                 'Set 10 to output (WE)
    dira[15]~~                 'Set 08 to output (CS)

    outa[14]~~                 'Set 10 HI
    outa[15]~~                 'Set 08 HI

'And set up the Address Lines for the READ action  
    outa[9]~~                  'Set both these lines HI for address = 3
    outa[8]~~                  'Remember, you can add all lines from 0-9 in here if you wish.
                               'Then you'll need to set all of them to HI or LO to get the
                               'address you want. 
  
'Set up the Data Lines for the READ action (Set them to input mode)
    dira[10]~                  'Set as input
    dira[11]~                  'Set as input

'Now set up thhe Control Lines for the READ action.
    outa[14]~~                 'Set HI for READ action (Set WE to HI for reading)
    outa[15]~                  'Set LO for READ action (Set CS to LO for reading)

'Hold for 2 seconds...    
    waitcnt(clkfreq*2 + cnt)   'Another short delay.  Increase the 2 if more time is required.

'-----------------------------------------------------------------------------------------------
'Routine to display the results begins here.
    PIN13 := ina[13]    'ina[13] reads the state of Prop Pin, 13 connected to IO4 on the 2114
    PIN12 := ina[12]    'Each data line is read, and its state stored in the variables:
    PIN11 := ina[11]    'PIN10 - PIN13
    PIN10 := ina[10]
    
 
'Wait 2 seconds before reading the data
  waitcnt(clkfreq*2 + cnt)      'And another delay... Increase the 2 if more time is required.
                                                                    

      pst.str(string("Reading Four Data Lines:",13))  'Print a little header
      pst.str(string("------------------------",13))
                                                                            'For each data pin, determine
      if PIN13 == 0                                                         'if the state is HI or LO, and
         EIGHT := 0                                                         'add the value to a variable.
         pst.str(string("Prop Pin 13, reading chip IO4, is LO, or 0",13))   'Print status of Pin 13
      if PIN13 > 0                                                          'to the serial terminal
         EIGHT := 8                                                         'and add a carriage return
         pst.str(string("Prop Pin 13, reading chip IO4, is HI, or 1",13))
      if PIN12 == 0
         FOUR :=0
         pst.str(string("Prop Pin 12, reading chip IO3, is LO, or 0",13))   'Print status of Pin 12
      if PIN12 > 0
         FOUR := 4
         pst.str(string("Prop Pin 12, reading chip IO3, is HI, or 1",13))
      if PIN11 == 0
         TWO := 0
         pst.str(string("Prop Pin 11, reading chip IO2, is LO, or 0",13))   'Print status of Pin 11
      if PIN11 > 0
         TWO := 2
         pst.str(string("Prop Pin 11, reading chip IO2, is HI, or 1",13))
      if PIN10 == 0
         ONE := 0
         pst.str(string("Prop Pin 10, reading chip IO1, is LO, or 0",13))    'Print status of Pin 10
      if PIN10 > 0
         ONE := 1
         pst.str(string("Prop Pin 10, reading chip IO1, is HI, or 1",13,10))

      SUM := EIGHT + FOUR + TWO + ONE                                   'Add up the values in the
                                                                        'PIN variables. 
      pst.str(string("And this represents the decimal number:  "))
      pst.dec(SUM)                                                      'And print out the result
      pst.str(string(13,10))                                            'as a decimal number.
      
'Reset the Control Lines after the READ action                          'Just a little clean up at
    outa[14]~~                   'Set 10 back to HI                     'the end to set some things
    outa[15]~~                    'Set 8 back to HI                     'back to where we started.
                                                                        'Not really necessary, but 
'Reset the Data Lines after the READ Action                             'was thinking it might be 
    outa[9]~                    ' Set both to LO again                  'a good idea in case I decide
    outa[8]~                                                            'to add some more functionality
                                                                        'down here later.
'End the program    
     pst.str(string("The End",13,10))



{{   MIT License:
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: 

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. 

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
IN THE SOFTWARE.

}}             
       