{{
74C922 Keypad Driver and Buffer
by Clive Wakeham
Version 1.5 -- 16th March 2011

This consists of two objects;
An object that takes the output of a 74C922 Keypad IC and stores the results in a 8 key buffer
and another object that interfaces with the user program and has four functions;
ReadBuffer -- reading and clearing the next available key and then reducing the rest of the keys in the buffer
Read -- reading the last key pressed without any changes
ReadSize -- getting the current number of keys in buffer
ClearBuffer -- clearing the whole buffer with the hex value of $FF and resetting count
If no keys are available (buffer empty) then the $FF value is the error code.

                                    74C922
                                 +----\/----+
                          Row Y1 |1       18| VCC
                          Row Y2 |2       17| Data Out A     
                          Row Y3 |3       16| Data Out B      
                          Row Y4 |4       15| Data Out C      
                      Oscillator |5       14| Date Out D      
                  Keybounce Mask |6       13| Output Enable
                          COL X4 |7       12| Data Available
                          COL X3 |8       11| COL X1
                             GND |9       10| COL X2
                                 +----------+
                        See datasheet for more information.
                        
Version History
0.5 03/03/2011 Initial Object
0.7 11/03/2011 Minor Bug fixes
1.0 15/03/2011 Changed Buffer handling routine
1.5 16/03/2011 Changed from fixed pins to variable pins in object call
}}

var
  long KeyStack[20]
  byte buffer[9]
  byte SemID
  byte buffer_num
  byte buffer_num2
  byte currentkey
  byte bufkey, bufkey2, bufkey3, bufkey4

pub init(OEpin, DApin, Keypin0, Keypin3)
SemID := Locknew                                                      ' Lets get a lock
ClearBuffer                                                           ' Lets clear all locations
cognew(Keypad_Scan(SemID, OEpin, DApin, Keypin0, Keypin3), @KeyStack) ' Now launch the keypad scan and store routine

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

pri Keypad_Scan(LockNum, OEpin, DApin, Keypin0, Keypin3)
dira[Keypin0..Keypin3] := %0000                                                       'Set pins to input
dira[DApin]~
dira[OEpin]~~                                                                         'Set pin to output
outa[OEpin]~~                                                                         'Set pin to high

repeat                                                          
 bufkey := ina[DApin]                                                                 ' Check to see if data available
 if bufkey == 0                                                                       ' 0? = No data
  next                                                                                ' Go back to the repeat statement
 repeat while buffer_num == 8                                                         ' Okay is the buffer full? Then lets wait until there is some room.
 outa[OEpin]~                                                                         ' Make enable low so the 74C922 will put the data on the lines
 waitcnt(clkfreq / 3 + cnt)                                                           ' Wait for the data
 bufkey2 := INA[Keypin0..Keypin3]                                                     ' Load the data and debounce
 outa[OEpin]~~                                                                        ' Out high so the 74C922 can check for more key presses
 bufkey4 := lookupz(bufkey2: 1, 2, 3, 10, 4, 5, 6, 11, 7, 8, 9, 12, 15, 0, 14, 13)    ' Determine the correct key from matrix
 bufkey3 := bufkey2                                                                   ' Lets load key2 variable into key3
 repeat until not lockset(LockNum)                                                    ' Lock the resource
 buffer_num += 1                                                                      ' Increment the buffer
 byte[@buffer][buffer_num] := bufkey4                                                 ' Store the latest key
 lockclr(LockNum)                                                                     ' Clear the resource
{{
Keypad scanning routine and storing the resultant keys in buffer
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
 