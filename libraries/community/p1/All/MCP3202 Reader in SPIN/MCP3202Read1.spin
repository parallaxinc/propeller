{{03 Nov 09   Harprit Sandhu
MCP3202Read1.Spin
Propeller Tool 1.2.6
This is part of the effort for the book for absolute beginners.

EVERY THING IS IN SPIN IN THIS PROGRAM
Rock solid, no jitter.

This program reads channel 0 of the MCP3202 and displays the results
on the LCD both as a decimal value and as a binary value so that you
can see the bits flip as you turn the potentiometer.

The 3202 chip is connected as follows:
1 Chip select                                          P21
2 Channel 0 for voltage input from Pot                 Pot wiper
3 Channel 1 for voltage input from Pot, not used       Not connected
4 Ground Vss                                           Ground
5 Data into 3202 for setup                             P19
6 Data out from 3202 to be read into Propeller         P22
7 Clock to read in the data                            P20
8 Power 5 volts Vdd                                    5 volts

The Potentiometer is connected as follows:
Left    Ground
Center  To pin 2 of the 3202
Right   Power  5 volts
I used a 50K Pot

The connections to the LCD are as follows:
1   Ground
2   Power 5 volts
3   Ground
4   P16
5   P17
6   P18
7   Not connected, using 4 bit mode for data Xfer
8   Not connected, using 4 bit mode for data Xfer
9   Not connected, using 4 bit mode for data Xfer
10  Not connected, using 4 bit mode for data Xfer
11  Data  high nibble
12  Data  high nibble
13  Data  high nibble
14  Data  high nibble

STANDARD EDUCATION KIT SET UP.  Used as base

Revisions:



Error Reporting:
Please report errors to harprit.sandhu@gmail.com

}}
OBJ
  LCD     : "LCDRoutines4" 'for the LCD methods
                                                     
CON                                                                   
  _CLKMODE=XTAL1+ PLL2X         'The system clock spec
  _XINFREQ = 5_000_000          
   chipDin =19    'to pin  5     
   chipClk =20    'to pin  7   
   chipSel =21    'to pin  1    
   chipDout=22    'to pin  6
   BitsRead=12
   
VAR
  long stack2[25]
  word PotReading               
  word DataRead
                                                        
PUB Go
  cognew(Cog_LCD, @stack2)        
  DIRA[chipDin]~~     '19 data set up to the chip   
  DIRA[chipClk]~~     '20 oscillates to read in data from internals                     
  DIRA[chipSel]~~     '21 osc once to set up 3202                                     
  DIRA[chipDout]~     '22 data from the chip to the Propeller                               
  repeat        
    DataRead:=0             'Clear out old data
    waitcnt(1000+cnt)       'Wait for things to settle down, but not needed
    outa[chipSel]~~         'Chip select has to be high to start off                        
    outa[chipSel]~          'Go low to start process
                                   
    outa[chipClk]~          'Clock needs to be low to lead data     
    outa[chipDin]~~         'must start with Din low to set up 3202                   
    outa[chipClk]~~         'Clock low to read data in
                                   
    outa[chipClk]~          'Low to load      
    outa[chipDin]~~         'High single mode                  
    outa[chipClk]~~         'High to read
                                           
    outa[chipClk]~          'Low to load               
    outa[chipDin]~          'Odd = channel 0          
    outa[chipClk]~~         'High to read
                                    
    outa[chipClk]~          'Low to load       
    outa[chipDin]~~         'msbf high = MSB first                
    outa[chipClk]~~         'High to read
    
    outa[chipDin]~          'making line low for rest of cycle
    
    outa[chipClk]~          'Low to load 
                            'Read the null bit, we dont need to store it
    outa[chipClk]~~         'High to read
   
    repeat BitsRead          'Reads the data into DataRead in 12 steps
      outa[chipClk]~         'Low to load 
      DataRead:=DataRead+ina[chipDout]  'Xfer the data from pin chipDout                           
      outa[chipClk]~~        'High to read  
      DataRead <<= 1         'Move data by shifting left 1 bit. Ready for next bit
        
    outa[chipSel]~~          'Put chip to sleep, low power
      DataRead >>= 1         'Shift data right 1 bit to cancel last "bad" shift
      PotReading:=DataRead   'Finished data read for display
      
PRI cog_LCD                      'manage the LCD   
  LCD.INITIALIZE_LCD             'initialize the LCD
  repeat     
    LCD.POSITION (1,1)           'Go to 1st line 1st space
    LCD.PRINT(STRING("Pot=" ))   'Print Label 
    LCD.PRINT_DEC(PotReading)    'print decimal value 
    LCD.SPACE(4)                 'erase over old data       
    LCD.POSITION (2,1)           'Go to 2nd line 1st space
    LCD.PRINT_BIN(PotReading,BitsRead)   'Print it as bits.
 