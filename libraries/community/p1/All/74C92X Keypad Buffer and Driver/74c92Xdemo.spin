{{
74C92X Buffer Demo
1st May 2011 by Clive Wakeham
Version 1.4

Demo Pin assignments for Propeller
p0 -- DA (data available) high ouput of 74C92X chip
p1 -- OE (Output enable) low input of 74C92X chip
p2 -- bit1 of 74C92X chip
p3 -- bit2 of 74C92X chip
p4 -- bit3 of 74C92X chip
p5 -- bit4 of 74C92X chip
p6 -- bit5 of 74C923 chip or expanded 74C922


A simple demo program that uses the 74C92X Object.
Displays the current number of keys in buffer, and once the buffer is full it prints them all out.
}}

OBJ

pst               :              "Parallax Serial Terminal"
keypad            :              "74c92Xbuffer"

var
                byte  key
                byte  key2
                byte  key3
                byte  key4

con
                BasePin = 0                        ' Base pin of propeller which the DA of the 74C92X is attached
                KeyChip922 = True                  ' The chip is a 74C922 if True, otherwise it is a 74C923
                Feedback = 7                       ' Output line to drive an LED or buzzer (via a transistor)
                     
pub Start
pst.Start(115200)                                   ' Start Serial Terminal
pst.Clear                                           ' Clear screen
if KeyChip922
 pst.str(String(" 74C922 Keypad Reader "))          ' Message if 74C922
else
 pst.str(String(" 74C923 Keypad Reader "))          ' Message if 74C923                                    
keypad.Start (KeyChip922, BasePin, Feedback)        ' Get the keypad scanning running
pst.newline                                         ' Newline
pst.str(String("Press a few keys on the keypad "))  ' Another message
pst.newline                                         ' Newline

repeat                                              
 key4 := keypad.ReadSize                            ' Whats the buffer size?
 if (key4 == key3) OR (key4 == 0)                   ' Hold the display if the buffer size is the same
  next                                              ' Lets do the repeat statement again
 pst.dec(key4)                                      ' Display the size of the buffer
 pst.str(string(" "))                               ' Add a space
 key3 := key4                                       ' Lets keep the current value of the buffer to check the next time through
 if key4 == 8                                       ' Buffer full?
   repeat key from 1 to 8                           ' Lets print the whole buffer
    key2 := keypad.ReadBuffer                       ' Get the current buffer value (location 1)
    pst.str(string(" "))                            ' Space
    pst.hex(key2, 2)                                ' Print it in hex
    pst.str(string(" "))                            ' Another space
     next                                           ' Next buffer value
   pst.newline                                      ' Lets format it nice
    

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
                           