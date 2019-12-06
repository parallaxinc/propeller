{***************************************************************************
 ShellSort.spin

 Copyright (c) 2008 Andrew Walton
 See end of file for terms of use.

 This file implements a shell sort.  Shell sorts are particularly useful
 in embedded code because they are a relatively fast in-place sort. In-
 place means that the array(s) do not need to be copied to another array
 to be sorted. 

*****************************************************************************}  
PUB Sort(ArrayToSortAddr, SisterArrayAddr, size) | i, j, increment, temp, temp2

  increment := size / 2
  
  repeat while increment > 0 
    repeat i from increment to size-1
      j := i

      temp  := LONG[ArrayToSortAddr][i]
      temp2 := LONG[SisterArrayAddr][i]
      
      repeat while (j => increment AND LONG[ArrayToSortAddr][j - increment] > temp)
        LONG[ArrayToSortAddr][j] := LONG[ArrayToSortAddr][j - increment]
        LONG[SisterArrayAddr][j] := LONG[SisterArrayAddr][j - increment]
        j := j - increment
              
      LONG[ArrayToSortAddr][j] := temp
      LONG[SisterArrayAddr][j] := temp2
      
    if increment == 2
      increment := 1
    elseif increment == 1
      increment := 0
    else 
      increment := increment / 2




{{
                            TERMS OF USE: MIT License                                                           

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
}}