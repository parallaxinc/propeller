{{ BitManipulator.spin, v1.1
   Copyright (c) 2009 Austin Bowen
   *See end of file for terms of use*
   Use to view and manipulate bits, see subroutines for details. To include object:

    OBJ
      BIT : "BitManipulator"
}}

PUB VIEW (VALUE, BIT)
{{ Views the specified bit (0-31) of the specified value and returns the state (0-1)
  MYNUM  := %0100              '                        'Set MYNUM to %0100
  NUMBIT := BIT.VIEW(MYNUM, 2)                          'Change NUMBIT to 2nd bit of MYNUM which is 1
}}                                                              
  RETURN VALUE >> BIT >< 1      'Return the bit

PUB CHANGE (VALUE, BIT, STATE)
{{ Changes the specified bit (0 - 31) of the value to the specified state (-1 to 1) & returns the new value
   STATE: -1 - Invert, 0 - Set low, 1 - Set high

  MYNUM := %1110_0011                                   'Set MYNUM to %1110_0011
  MYNUM := BIT.CHANGE(MYNUM, 6, 0)                      'Change MYNUM to %1010_0011
}}                                                                                                        
  IF (STATE <> -1)                                      'If state non-invert
    IF (VIEW(VALUE, BIT) <> STATE)
      IF STATE                                          'Return with stated bit 1
        RETURN VALUE + |< BIT
      ELSE                                              'Return with stated bit 0
        RETURN VALUE - |< BIT
  ELSE
    IF VIEW(VALUE, BIT)                                 'Invert bit
      RETURN VALUE - |< BIT                             'Return with stated bit 0 if 1
    ELSE
      RETURN VALUE + |< BIT                             'Return with stated bit 1 if 0
  RETURN VALUE                                          'Return value without editing if already state

PUB FILL (VALUE, START, FINISH, STATE)
{{ Fills the specified bits (0-31) of the value with the specified state (-1 to 1)
   STATE: -1 - Invert, 0 - Set low, 1 - Set high

  MYNUM := %1010_0110                                   'Set MYNUM to %1010_0110
  MYNUM := BIT.FILL(MYNUM, 1, 6, -1)                    'Change MYNUM to %1101_1010
}}                                                                          
  REPEAT UNTIL (START => FINISH + 1)
    VALUE := CHANGE(VALUE, START++, STATE)
  RETURN VALUE

    
{{Permission is hereby granted, free of charge, to any person obtaining a copy of this software
  and associated documentation files (the "Software"), to deal in the Software without restriction,
  including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
  and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
  subject to the following conditions: 
   
  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. 
   
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
  PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
  FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}}