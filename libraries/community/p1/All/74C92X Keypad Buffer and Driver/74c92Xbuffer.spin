{{
74C92X Keypad Driver and Buffer
by Clive Wakeham
Version 2.1 -- 1st May 2011
This is an updated version of my 74C922 Keypad Driver and Buffer.
It also works with the 74C923 20 key keypad chip as well as the 74C922 16 key keypad chip.
(By adding four 1N914 diodes and a 74C20 4-input NAND gate the 74C922 can become a 32 key keypad chip -- see datasheet for details)

This consists of two objects;
An object that takes the output of a 74C92X Keypad IC and stores the results in a 8 key buffer
and another object that interfaces with the user program and has the following functions;

Start(KeyChip922, BasePin, Feedback) -- starts the Keypad_Scan object
Stop                                 -- stops the Keypad_Scan object  
ReadBuffer                           -- reading, returning and clearing the next available key and then reducing the rest of the keys in the buffer
Read                                 -- reading and returning the last key pressed without any changes
ReadSize                             -- returning the current number of keys in buffer
ClearBuffer                          -- clearing the whole buffer with the hex value of $FF and resetting count
Search(KeyID)                        -- search current buffer for a specific numeric value of keyid and return the first location in the buffer or 0 if not there

Version History
0.5 03/03/2011 Initial Object 
1.0 11/03/2011 Minor Bug fixes
1.5 15/03/2011 Changed Buffer handling routine
1.6 16/03/2011 Changed from fixed pins to variable pins in object call
1.7 19/03/2011 Changed pin allocation to allow use of 74C923 as well as 74C922 chips
1.8 20/03/2011 Added Search routine and updated documentation
1.9 21/03/2011 Changed the Init method to a Start method and added a Stop method
2.0 26/04/2011 Changed the KeyScan method to allow for a feedback signal. -- ie a LED or buzzer or both. (Remember the inline resistor!!!)
2.1 01/05/2011 Fixed bug in the search method that found the last location of the searched key not the first location.
}}

var
  long KeyStack[20]
  byte buffer[9]
  byte SemID
  byte buffer_num
  byte buffer_num2
  byte currentkey
  byte CogKeyID
  byte bufkey, bufkey2, bufkey3
  byte SearchKey
  
pub Start(KeyChip922, BasePin, Feedback)                                              ' If KeyChip922 is true then a 74C922 else if false then a 74C923
SemID := Locknew                                                                      ' Lets get a lock
ClearBuffer                                                                           ' Lets clear all locations
CogKeyID := cognew(Keypad_Scan(SemID, KeyChip922, BasePin, Feedback), @KeyStack)      ' Now launch the keypad scan and store routine
{{
KeyChip922 is TRUE for a 74C922 and FALSE for a 74C923
BasePin is the Prop pin number which is the starting pin for the sequence pins
Pins are allocated as BasePin is Data Available signal from 74C92X
                      BasePin+1 is Output Enable signal to 74C92X
                      BasePin+2 to BasePin+5 is Output signals from 4 bit signal (74C922)
                      BasePin+2 to BasePin+6 is Output signals from 5 bit signal (74C923 or expanded 74C922)
                      
Allocates a Lock resource ID.  Clears the buffer to all $FF values. Runs the Key_Scan object in another cog.
}}

pub Stop                                                              ' Stop method
if CogKeyID > -1                                                      ' Did the object get started?
 cogstop(CogKeyID)                                                    ' Lets stop it then.
{{
Stops the Cog running the Key_Scan object.
}}

pub ReadBuffer : currentkey2                                          ' Get current key value
if buffer_num == 0                                                    ' No key?
 currentkey := $FF                                                    ' Error code!
 return currentkey                                                    ' Return
currentkey := byte[@buffer][1]                                        ' Get the value from the first buffer location
if buffer_num == 1                                                    ' Was last key value?
 buffer_num := 0                                                      ' Decrement the value
 return currentkey                                                    ' Return
repeat until not lockset(SemID)                                       ' Lets lock the memory
repeat buffer_num2 from 1 to buffer_num                               ' Lets move the stored keys down one
 byte[@buffer][buffer_num2] := byte[@buffer][buffer_num2 + 1]         ' location
buffer_num -= 1                                                       ' Reset buffer holding
lockclr(SemID)                                                        ' Clear the resource lock
return currentkey                                                     ' Return
{{
Routine that pulls the buffer location 1 if data is available otherwise the value is $FF
(due to the fact that the 74C92X outputs $00 for key pressed at location Row1/Column1)
and then moves all the remaining key strokes down one location
}}

pub Read : currentkey2                                                ' Read the last key entered
return byte[@buffer][buffer_num]                                      ' Pull the data
{{
Pulls the last key entered without any change to the buffer
}}

pub ReadSize : buffer_num3                                            ' Get number of keys in buffer
return buffer_num
{{
Pulls the current number of keys in the buffer
}}

pub ClearBuffer                                                       ' Clear the whole buffer
repeat until not lockset(SemID)                                       ' Lock it
repeat buffer_num2 from 1 to 8                                        ' Lets clear all the buffer to the value of hex $FF
 byte[@buffer][buffer_num2] := $FF                                    ' location
buffer_num := 0                                                       ' Reset counter
lockclr(SemID)                                                        ' Clear the lock
return
{{
Clears all the buffer to $FF values and resets the counter
}}

pub Search(KeyID) : RSearchKey                                         ' Key value to search for.
SearchKey := 0                                                         ' Default value
if buffer_num == 0                                                     ' Is buffer = 0?
 return SearchKey                                                      ' Then return 0
repeat until not lockset(SemID)                                        ' Lets lock the resource
repeat buffer_num2 from 1 to buffer_num                                ' Lets check only the current buffer size
 ifnot KeyID == byte[@buffer][buffer_num2]                             ' Examine each buffer location for the key value
  next                                                                 ' If not then next location
 else                                                                  ' Else then return the location value       
  SearchKey := buffer_num2                                             ' Then its True and the location of key is
 lockclr(SemID)                                                        ' Clear the resource lock
 Return SearchKey                                                      ' Return True or False
{{
Gives the ability to search through the current buffer for a certain key press (eg like an allocated ESC or Abort key)
and return the location in the buffer if TRUE or 0 if not there or the buffer empty.
}}
   
pri Keypad_Scan(LockNum, KeyChip922, BasePin, Feedback)
if KeyChip922                                                                         'True for 74C922
 dira[BasePin..BasePin+5] := %010000                                                  'Set pins to correct direction for 74C922
else                                                                                  'else if false for 74C923
 dira[BasePin..BasePin+6] := %0100000                                                 'Set pins to correct direction for 74C923 (or expanded 74C922)
outa[BasePin+1]~~                                                                     'Set OE pin to high
if (Feedback > 0) and (Feedback < 31)                                                 'Feedback selected?
 dira[Feedback] := %1                                                                 'Feedback pin set to output
 outa[Feedback]~                                                                      'Feedback pin set to low
 
repeat                                                          
 bufkey := ina[BasePin]                                                               ' Check to see if data available
 if bufkey == 0                                                                       ' 0? = No data
  next                                                                                ' Go back to the repeat statement
 repeat while buffer_num == 8                                                         ' Okay is the buffer full? Then lets wait until there is some room.
 outa[BasePin+1]~                                                                     ' Make enable low so the 74C92X will put the data on the lines
 if (FeedBack > 0) and (Feedback < 31)                                                ' Feedback selected?
  outa[Feedback]~~                                                                    ' Make the Pin high
 waitcnt(clkfreq / 3 + cnt)                                                           ' Wait for the data
 if KeyChip922                                                                        ' 74C922 ?
  bufkey2 := INA[BasePin+2..BasePin+5]                                                ' Load the data 
 else                                                                                 ' 74C923 ?
  bufkey2 := INA[BasePin+2..BasePin+6]                                                ' Load the data
 outa[BasePin+1]~~                                                                    ' Out high so the 74C92X can check for more key presses
 bufkey3 := lookupz(bufkey2: 1, 2, 3, 10, 4, 5, 6, 11, 7, 8, 9, 12, 15, 0, 14, 13, 16, 17, 18, 19)    ' Determine the correct key from matrix
 if (FeedBack > 0) and (Feedback < 31)                                                ' Feedback selected?
  outa[Feedback]~                                                                     ' Make Pin low
 repeat until not lockset(LockNum)                                                    ' Lock the resource
 buffer_num += 1                                                                      ' Increment the buffer
 byte[@buffer][buffer_num] := bufkey3                                                 ' Store the latest key
 lockclr(LockNum)                                                                     ' Clear the resource
{{

Keypad_Scan private object
Keypad scanning routine and storing the resultant keys in buffer.
Some 4x4 (and 4x5) keypads have different layouts/pin assignments so the lookupz routine might need to be changed to match values from the 74C92X
eg The truth table for the 74C92X shows the value of $00 for the keypress at location Row1/Column1 but the keypad I have has the 0 key at location
Row4/Column2

The feedback signal is within the storage loop of the pri method. So the led will not light unless the key being pressed is actually
being stored in the buffer.
}}

{{
********************************************************************************************************************************
*                                                   TERMS OF USE: MIT License                                                  *                                                            
********************************************************************************************************************************
*Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    * 
*files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    *
*modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software*
*is furnished to do so, subject to the following conditions:                                                                   *
*                                                                                                                              *
*The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.*
*                                                                                                                              *
*THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          *
*WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         *
*COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   *
*ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         *
********************************************************************************************************************************
}}      
 