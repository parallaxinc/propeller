'******************************************************************************
' Spin Method Pointer Test Program
' Copyright (c) 2010 - 2014 Dave Hein
' See end of file for terms of use.
'******************************************************************************
con
  _clkfreq = 80_000_000
  _clkmode = xtal1+pll16x

obj
  ser : "fds1"
  mp : "MethodPointer"
  test1[3] : "test1"

pub main | methodstruct1[2], methodstruct2[2], methodstruct3[2]
  ' Wait two seconds so user can start prop terminal
  waitcnt(clkfreq*2 + cnt)

  ' Initialize serial I/O  
  ser.start(31, 30, 0, 115200)
  
  ' Initialize the method pointer routines
  mp.Initialize

  ' Initialize instance numbers in test1
  test1[0].SetInstance(0)
  test1[1].SetInstance(1)
  test1[2].SetInstance(2)

  ' Set up the method structs for local methods
  mp.SetMethodPtr(@methodstruct1, 0, 2)
  mp.SetMethodPtr(@methodstruct2, 0, 3)
  mp.SetMethodPtr(@methodstruct3, 0, 4)

  ' Call using the method structs
  mp.CallMethod1(1, @methodstruct1)
  mp.CallMethod1(1, @methodstruct2)
  mp.CallMethod1(1, @methodstruct3)
  ser.tx(13)
  
  ' Set up the method structs for methods in another object
  mp.SetMethodPtr(@methodstruct1, 7, 2)
  mp.SetMethodPtr(@methodstruct2, 8, 3)
  mp.SetMethodPtr(@methodstruct3, 9, 4)

  ' Call using the method structs
  mp.CallMethod1(1, @methodstruct1)
  mp.CallMethod1(1, @methodstruct2)
  mp.CallMethod1(1, @methodstruct3)
  ser.tx(13)
  
  ' Set up method structs using SetMethodPtrEx
  if mp.SetMethodPtrEx(@methodstruct1)
    test1[0].Func3(0)
  if mp.SetMethodPtrEx(@methodstruct2)
    test1[1].Func2(0)
  if mp.SetMethodPtrEx(@methodstruct3)
    test1[2].Func1(0)

  ' Call using the method structs
  mp.CallMethod1(1, @methodstruct1)
  mp.CallMethod1(1, @methodstruct2)
  mp.CallMethod1(1, @methodstruct3)
  ser.tx(13)
  
  ' Test callback by passing pointer for the ser.str method
  if mp.SetMethodPtrEx(@methodstruct1)
    ser.str(0)

  test1.Func4(@methodstruct1)

pub Func1(parm1)
  ser.str(string("Hello from Func1", 13))

pub Func2(parm1)
  ser.str(string("Hello from Func2", 13))

pub Func3(parm1)
  ser.str(string("Hello from Func3", 13))
  
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