{{
  BS2 Command Object
  Author: Corbin Adkins (microcontrolled)
  Version: 1.0
  Description: This program is designed to help those who are starting on the Propeller that have
  BS2 experiance to get thier first programs working. It is not the most compleate BS2 object out there,
  but I have tryed to make it the simplist. If you have worked with any other BS2 object you will realize
  that this one is scanty, but I have tryed to provide plenty of commenting for you to read to help you
  get started with the Propeller! First, you will need this to get the object working:
  
  CON

    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000
  
  OBJ

    bs2  :  "BS2_object"

  PUB Start

    bs2.Start_Debug_Window
         
  Put this down before doing anything else. Every command you call from this object you will have to start
  with bs2. and then the command name followed by the parenthesis that house the variables. If there are
  multiple vars needed for a command then they are separated by commas. 
  The Propeller is a block-oriented language, and if you need to call a variable, you will have to do
  VAR

    byte myVariable
    
  You can put as many VARs under one VAR block as you want. You can also use BYTE, WORD, or LONG but not BIT.
  FOR THE TOTAL BEGINNER: Here I will give some code examples for replacements of common BS2 funtions that
  can not be put in this object because the object does not operate the way it would need to if the commands
  were to be implanted. Anything in brackets ([ ]) should be ignored.
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  DO..LOOP:
  Directly replacable with the REPEAT command as shown:

  repeat
    [code to be repeated goes here]

  Remember that SPIN is a SPACE DRIVEN LANGUAGE. A terminating "LOOP" is not needed because anything indented
  1 or more spaces from the repeat command line is in the loop. For example:

  repeat
  [code inside loop]

  will not work because "code inside loop" is actully OUTSIDE the loop. Get it? This is appliable to ALL loops.
  //////////////////////////////////////////////////////////////////////////////////////////////////
  FOR..NEXT:
  Basicly this is a special repeat loop. Shown below:

  repeat [counter var here] from [number to start on here] to [number to count to]
    [commands inside loop]

  This is equivilent to the BASIC command below:

  FOR [counter var here] = [number to start on here] TO [number to count to]
    [commands inside loop]
  NEXT
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  IF..THEN
  This is simply the IF without the THEN statement.

  if [statement here]
    [code inside loop]

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  If you need more definitions then please contact me so I can make this program better.   
         
}}

OBJ

  ser  :  "FullDuplexSerial"

PUB Start_Debug_Window
  ''You only need to call this if you are going to use the DEBUG command.
  ser.start(31,30,0,9600)

PUB Pause(time)
  ''Pause for the amount of time specified in milliseconds
  waitcnt((clkfreq/1000)*time + cnt)

PUB High(pin)
  ''Pull the pin high. This cannot terminate a program or it must be put in a repeat loop. 
  dira[pin]~~
  outa[pin]~~

PUB Low(pin)
  ''Pull the pin low. This cannot terminate a program or it must be put in a repeat loop
  dira[pin]~~
  outa[pin]~

PUB Input(pin)
  ''Set the specified pin to an input
  dira[pin]~

PUB Sleep(period)
  ''Have the Propeller go into sleep mode (low-power) for the specified number of seconds
  repeat period
    waitcnt(clkfreq + cnt)

PUB Count(pin,duration,variable) | counter
  ''Count the cycles on pin for the period of time specified by duration and increment variable for each cycle
  dira[pin]~
  byte[counter] := @variable
  repeat duration
    if ina[pin] == 1
      counter++
    waitcnt(clkfreq/1000 + cnt)  

PUB Debug(str)
  ''Str must be a string or a pointer to a string. The "debug" window is the Parallax serial terminal
  ''that downloads with every install of Propeller Tool from 1.2.6 and up. You must change the baud to
  ''9600 and the COM port accordingly, and click "Enable" to activate the terminal. To send a message the
  ''BS2 way, it must be
  ''bs2.Debug(string("Your message here"))
  ''if you do not understand how I got this then look up "declaring objects" and "strings" in the Propeller Manual
  ser.str(@str)

PUB Random | randomnumber
  ''Randomize the variable specified. Put in the program like this, assuming that variable will hold the random number:
  ''variable := bs2.Random
  return ?randomnumber

PUB Toggle(pin)
  ''Reverse the state on the pin.
  !outa[pin]
  