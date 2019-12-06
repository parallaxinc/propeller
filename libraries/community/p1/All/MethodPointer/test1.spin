'******************************************************************************
' Spin Method Pointer Test Routines
' Copyright (c) 2010 - 2014 Dave Hein
' See end of file for terms of use.
'******************************************************************************
obj
  ser : "fds1"
  mp : "MethodPointer"

var
  long instance

pub SetInstance(instnum)
  instance := instnum

pub Func1(parm1)
  ser.str(string("Hello from test1["))
  ser.dec(instance)
  ser.str(string("].Func1", 13))

pub Func2(parm1)
  ser.str(string("Hello from test1["))
  ser.dec(instance)
  ser.str(string("].Func2", 13))


pub Func3(parm1)
  ser.str(string("Hello from test1["))
  ser.dec(instance)
  ser.str(string("].Func3", 13))

pub Func4(callback)
  mp.CallMethod1(string("Callback test", 13), callback)

{{
+--------------------------------------------------------------------
|  TERMS OF USE: MIT License
+--------------------------------------------------------------------
Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files
(the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge,
publish, distribute, sublicense, and/or sell copies of the Software,
and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
+------------------------------------------------------------------
}}