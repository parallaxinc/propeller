''Three_Servo_Assembly
''Author: Gavin Garner
''November 17, 2008   
''This program demonstrates how to control three RC servomotors by dedicating a cog to output signal pulses using a simple
''assembly program. Once the assembly program is loaded into a new cog, it continuously checks the value of the "position1",
''"position2", and "position 3" variables in the main RAM (the values of which code running on any other cogs can change at
''any time) and creates a steady stream of signal pulses with high parts that are equal to the position values times the
''clock period (1/80MHz) in length and low parts that are about 10ms in length. (This low part may need to be changed to 20ms
''depending on the brand of motor being used, but 10ms seems to work fine for Parallax/Futaba Standard Servos and gives a
''quicker response time than 20ms.) With an 80MHz system clock the servo signal's pulse resolution is between 12.5-50ns,
''however, the control circuitry inside most analog servomotors will probably not be able to distinguish between such small
''changes in the signal.
'Notes:
' -To use this in your own Spin code, simply declare "position1", "position2" and "position3" variables as longs, create the
'  "p1", "p2" and "p3" address pointers to store the main Hub RAM locations of "position1", "position2" and "position3"
'  respectively, start the assembly code running in a cog with the "cognew(@ThreeServos,0)" line and copy and paste my DAT
'  section into the DAT section of your own code. Note that you must change the numbers "6", "7" and "8" in the ServoPin1,
'  ServoPin2 and ServoPin3 constant declarations in the assembly code to select pins other than Pins 6,7, and 8 to be the
'  output pins for the three servo signals.
' -If you are using a Parallax/Futaba Standard Servo, the range of signal pulse widths is typically between 0.5-2.25ms, which
'  corresponds to "position" values between 40_000 (full clockwise) and 180_000 (full counterclockwise). In theory, this
'  provides you with 140_000 units of position resolution across the full range of motion. You may need to experiment with
'  changing the "position" values a little to take advantage of the full range of motion for the specific RC servo motor that
'  you are using. However, you must be careful not to force the servo to try to move beyond its mechanical stops.
' -If you find that your propeller chip or servomotors stop working for no apparent reason, it could be that the motors are
'  sending inductive spikes back into the power supply or they are simply drawing too much current and resetting the
'  propeller chip. Adding a large capacitor (e.g.,1000uF) across the power leads of the servo motor or using separate power
'  sources for the propeller chip's 3.3V regulator and the servomotor's power supply will help to fix this.
 
CON
  _xinfreq=5_000_000            
  _clkmode=xtal1+pll16x                    'The system clock is set at 80MHz (this is recommended for optimal resolution)                                             
                                                                                                                         
VAR                                                                                                                      
  long  position1, position2, position3    'The assembly program will read these variables from the main Hub RAM to determine
                                           ' the high pulse durations of the three servo signals                                            
                                                                                                                           
PUB Demo                                                                                                                 
  p1:=@position1                           'Stores the address of the "position1" variable in the main Hub RAM as "p1"
  p2:=@position2                           'Stores the address of the "position2" variable in the main Hub RAM as "p2"
  p3:=@position3                           'Stores the address of the "position3" variable in the main Hub RAM as "p3"
  cognew(@ThreeServos,0)                   'Start a new cog and run the assembly code starting at the "ThreeServos" cell         

  'The new cog that is started above continuously reads the "position1", "position2", and "position3" variables as they are
  ' changed by the example Spin code below
  repeat                                                                                                                 
    position1:=180_000                     'Start sending 2.25ms servo signal high pulses to servomotor 1  (CCW position)                                                 
    position2:=110_000                     'Start sending 1.375ms servo signal high pulses to servomotor 2 (Center position)
    position3:=40_000                      'Start sending 0.5ms servo signal high pulses to servomotor 3   (CW position)
    waitcnt(clkfreq+cnt)                   'Wait for 1 second (pulses continue to be generated by the other cog)                                                                
    position1:=110_000                     'Start sending 1.375ms servo signal high pulses to servomotor 1 (Center position)                                                  
    position3:=110_000                     'Start sending 1.375ms servo signal high pulses to servomotor 3 (Center position)
                                           'Note: 1.375ms servo signal high pulses continue to be sent to servomotor 2
    waitcnt(clkfreq+cnt)                   'Wait for 1 second (pulses continue to be generated by the other cog)                                                                  
    position1:=40_000                      'Start sending 0.5ms servo signal high pulses to servomotor 1   (CW position)                                              
    position2:=40_000                      'Start sending 0.5ms servo signal high pulses to servomotor 2   (CW position)
    position3:=180_000                     'Start sending 2.25ms servo signal high pulses to servomotor 3  (CCW position)
    waitcnt(clkfreq+cnt)                   'Wait for 1 second (pulses continue to be generated by the other cog)
                                                     
DAT
'The assembly program below runs on a parallel cog and checks the value of the "position1", "position2" and "position3"
' variables in the main Hub RAM (which other cogs can change at any time). It then outputs three servo high pulses (back to
' back) each corresponding to the three position variables (which represent the number of system clock ticks during which
' each pulse is outputed) and sends a 10ms low part of the pulse. It repeats this signal continuously and changes the width
' of the high pulses as the "position1", "position2" and "position3" variables are changed by other cogs.

ThreeServos   org                         'Assembles the next command to the first cell (cell 0) in the new cog's RAM                                                                                                                     
Loop          mov       dira,ServoPin1    'Set the direction of the "ServoPin1" to be an output (and all others to be inputs)  
              rdlong    HighTime,p1       'Read the "position1" variable from Main RAM and store it as "HighTime"
              mov       counter,cnt       'Store the current system clock count in the "counter" cell's address 
              mov       outa,AllOn        'Set all pins on this cog high (really only sets ServoPin1 high b/c rest are inputs)               
              add       counter,HighTime  'Add "HighTime" value to "counter" value
              waitcnt   counter,0         'Wait until cnt matches counter (adds 0 to "counter" afterwards)
              mov       outa,#0           'Set all pins on this cog low (really only sets ServoPin1 low b/c rest are inputs)

              mov       dira,ServoPin2    'Set the direction of the "ServoPin2" to be an output (and all others to be inputs)  
              rdlong    HighTime,p2       'Read the "position2" variable from Main RAM and store it as "HighTime"
              mov       counter,cnt       'Store the current system clock count in the "counter" cell's address 
              mov       outa,AllOn        'Set all pins on this cog high (really only sets ServoPin2 high b/c rest are inputs)               
              add       counter,HighTime  'Add "HighTime" value to "counter" value
              waitcnt   counter,0         'Wait until cnt matches counter (adds 0 to "counter" afterwards)
              mov       outa,#0           'Set all pins on this cog low (really only sets ServoPin2 low b/c rest are inputs)
              
              mov       dira,ServoPin3    'Set the direction of the "ServoPin3" to be an output (and all others to be inputs)  
              rdlong    HighTime,p3       'Read the "position3" variable from Main RAM and store it as "HighTime"
              mov       counter,cnt       'Store the current system clock count in the "counter" cell's address    
              mov       outa,AllOn        'Set all pins on this cog high (really only sets ServoPin3 high b/c rest are inputs)            
              add       counter,HighTime  'Add "HighTime" value to "counter" value
              waitcnt   counter,LowTime   'Wait until "cnt" matches "counter" then add a 10ms delay to "counter" value 
              mov       outa,#0           'Set all pins on this cog low (really only sets ServoPin3 low b/c rest are inputs)
              waitcnt   counter,0         'Wait until cnt matches counter (adds 0 to "counter" afterwards)
              jmp       #Loop             'Jump back up to the cell labled "Loop"                                      
                                                                                                                    
'Constants and Variables:
ServoPin1     long      |<      6 '<------- This sets the pin that outputs the first servo signal (which is sent to the white
                                          ' wire on most servomotors). Here, this "6" indicates Pin 6. Simply change the "6" 
                                          ' to another number to specify another pin (0-31).
ServoPin2     long      |<      7 '<------- This sets the pin that outputs the second servo signal (could be 0-31). 
ServoPin3     long      |<      8 '<------- This sets the pin that outputs the third servo signal (could be 0-31).
p1            long      0                 'Used to store the address of the "position1" variable in the main RAM
p2            long      0                 'Used to store the address of the "position2" variable in the main RAM  
p3            long      0                 'Used to store the address of the "position2" variable in the main RAM
AllOn         long      $FFFFFFFF         'This will be used to set all of the pins high (this number is 32 ones in binary)
LowTime       long      800_000           'This works out to be a 10ms pause time with an 80MHz system clock. If the
                                          ' servo behaves erratically, this value can be changed to 1_600_000 (20ms pause)                                  
counter       res                         'Reserve one long of cog RAM for this "counter" variable                     
HighTime      res                         'Reserve one long of cog RAM for this "HighTime" variable
              fit                         'Makes sure the preceding code fits within cells 0-495 of the cog's RAM


{Copyright (c) 2008 Gavin Garner, University of Virginia
MIT License: Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit
persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and
this permission notice shall be included in all copies or substantial portions of the Software. The software is provided
as is, without warranty of any kind, express or implied, including but not limited to the warrenties of noninfringement.
In no event shall the author or copyright holder be liable for any claim, damages or other liablility, out of or in
connection with the software or the use or other dealings in the software.}                 