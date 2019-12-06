{{
74C922 Buffer Demo
Mar 2011 by Clive Wakeham
Version 1.2

Pin assignments for Propeller
p1 -- bit0 of 74C922 chip
p2 -- bit1 of 74C922 chip
p3 -- bit2 of 74C922 chip
p4 -- bit3 of 74C922 chip
p5 -- output enable input (driven low) of 74C922
p0 -- data available high output of 74C922

A simple demo program that uses the 74C922 Object.
Displays the current number of keys in buffer, and once the buffer is full it prints them all out.
}}

OBJ

pst               :              "Parallax Serial Terminal"
keypad            :              "74c922buffer"

var
                byte  key
                byte  key2
                byte  key3
                byte  key4

con
                DApin = 0                           ' DA (Data Available) pin of 74C922 (output active high) connected to Prop.
                OEpin = 5                           ' OE (Output Enable) pin of 74C922 (input active low) connected to Prop.
                Keypin0 = 1                         ' Keypad Key sequence Data Out 0 of 74C922 connected to Prop.
                Keypin3 = 4                         ' Keypad Key sequence Data Out 3 of 74C922 connected to Prop.
                     
pub Start
pst.Start(115200)                                   ' Start Serial Terminal
pst.Clear                                           ' Clear screen
pst.str(String(" 74C922 Keypad Reader "))           ' Message
                                              
keypad.init (OEpin, DApin, Keypin0, Keypin3)        ' Get the keypad scanning running
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
                           