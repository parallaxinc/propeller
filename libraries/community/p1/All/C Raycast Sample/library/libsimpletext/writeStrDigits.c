/**
 * @file writeStrDigits.c
 * Function to print a string of specified width to the pointer.
 *
 * Copyright (c) 2013, Parallax Inc.
 * Written by Steve Denson
 */
#include <ctype.h>
#include "simpletext.h"

int writeStrLen(text_t *p, char *str, int width)
{
  int n;
  for(n = 0; isalnum(*(str+n)); n++)
    ;
  for( ; n < width; n++)
    writeChar(p, ' ');
  while(*str && width--) {
    if(*str == '\n')
      writeChar(p, '\r');
    writeChar(p, *str);
    str++;
  }
  return n;
}

/*
+--------------------------------------------------------------------
| TERMS OF USE: MIT License
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
+--------------------------------------------------------------------
*/

