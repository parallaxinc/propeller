{{ LinearConverter.spin, v1.7
   Copyright (c) 2009 Austin Bowen
   *See end of file for terms of use*

   If you remember learning the basics of graphing and rates of change
     from Algreba 1, that's what this program is. Just like using 2 sets
     of coordinates to graph a line, this program uses 2 sets of INs and OUTs
     (as you can see below).

   Linear conversion can be very useful for many things as you can imagine
     (ie scaling up/down sensory input). This object just does the
     heavy lifting for you :)

   Example:
   OBJ
     LC : "LinearConverter"

   PUB MAIN
     LC.SET(0, 1, 10, 5, 30)    'Set register 0 with values
     NUM := LC.CONVERT(0, 3)    'Convert the number 3 with register 0
                                '  Resulting output should be 20

   See subroutines below for details.
}}                                   

VAR
  LONG IN1[REGISTER_NUM], OUT1[REGISTER_NUM], IN2[REGISTER_NUM], OUT2[REGISTER_NUM]
  
CON
  REGISTER_NUM = 5              'Number of registers

PUB SET (REG_NUM, IN_REF1, OUT_REF1, IN_REF2, OUT_REF2) | X
{{ Set one of the registers with the given values.

   REG_NUM : The register number to set (0 through REGISTER_NUM-1)
   IN_REF1 : First input reference number (Equivalent to an X coordinate)
   OUT_REF1: First output reference number (Equivalent to a Y coordinate)
   IN_REF2 : Second input reference number (Equivalent to an X coordinate)
   OUT_REF2: Second output reference number (Equivalent to a Y coordinate)

   The CONVERT subroutine will use these two sets of coordinates in order
     to convert an input value (Equivalent to an X coordinate) to its
     corresponding output value (Equivalent to a Y coordinate).
}}
  REG_NUM := REG_NUM #> 0 <# REGISTER_NUM-1
  IN1[REG_NUM]  := IN_REF1
  OUT1[REG_NUM] := OUT_REF1
  IN2[REG_NUM]  := IN_REF2
  OUT2[REG_NUM] := OUT_REF2

PUB CONVERT (REG_NUM, INPUT)
{{ Uses the two sets of coordinates supplied in the SET subroutine to
     convert an input value (Equivalent to an X coordinate) to its
     corresponding output value (Equivalent to a Y coordinate).
}}
  REG_NUM := REG_NUM #> 0 <# REGISTER_NUM-1
  RETURN ((INPUT-IN1[REG_NUM])*(OUT1[REG_NUM]-OUT2[REG_NUM]))/(IN1[REG_NUM]-IN2[REG_NUM])+OUT1[REG_NUM]
  

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
