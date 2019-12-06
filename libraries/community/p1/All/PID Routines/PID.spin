VAR
long cur_pos        'Real Position
long set_pos        'Set Point
long K              'PID Gain
long cur_error      'Current Error
long pre_error      'Previous Error
long output         'PID Output
long stack[30]      'COG Stack
byte cog            'cog number
long dt             'Integral Time

PUB Start(Current_Addr, Set_Addr, Gain, Integral_Time, Output_Addr) 
''Starts PID controller.  Starts a new cog to run in.
           ''Current_Addr  = Address of Long Variable holding actual position
           ''Set_Addr      = Address of Long Variable holding set point
           ''Gain          = PID Algorithm Gain, ie: large gain = large changes faster, though less precise overall
           ''Integral_Time = PID Algorithm Integral_Time
           ''Output_Addr   = Address of Long Variable wich holds output of PID algorithm

cur_pos := Current_Addr
set_pos := Set_Addr
K := Gain
dt := Integral_Time
output := Output_Addr

pre_error := 0
cur_error := 0

cog := cognew(Loop, @stack)

PUB Stop
''Stops the Cog and the PID controller
cogstop(cog)

PRI Loop | e, P, I, D

repeat
  long[cur_error] := long[set_pos] - long[cur_pos]
  P := K * long[cur_error]
  
  I := I + K * long[cur_error] * dt
  
  e := long[cur_error] - long[pre_error]
  D := K * e / dt
  
  long[pre_error] := long[cur_error]

  long[output] := P + I + D

  waitcnt(clkfreq / 1000 * dt + cnt)



{{
Copyright (c) 2008 Craig Weber

Permission is hereby granted, free of charge, to any person obtaining a copy of this
software and associated documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights to use, copy, modify, merge,
publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons
to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in allcopies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}}
 