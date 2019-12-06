/*
 * @file floatToString.c
 *
 * Copyright (c) 2013 Parallax Inc.
 * Author Andy Lindsay
 * Optimized for size using pointers -vs- array by Steve Denson
 *
 * See end of file for terms of use.
 */
#include "simpletext.h"

static int ch2int(char ch)
{
    return ch - '0';
}

static inline int floatChar(char ch)
{
  return (ch == '-' || ch == '+' || ch == '.' || (ch >= '0' && ch <= '9'));
}

float string2float(char *s, char **end)
{
  float n = 0.0;
  float x = 1.0;
  float sign = 1.0;

  char *dp; /* decimal point position*/

  /* skip any leading non-float chars */
  while(!floatChar(*s))
    s++;

  if(*s =='-') {
    sign = -1.0;
    s++;
  }
  if(*s =='+')
    s++;

  /* get all integer digits */
  n = 0;
  while((*s >= '0') && (*s <= '9')) {
    n = 10.0 * n + ch2int(*s);
    s++;
  }

  dp = s;

  if(*dp != '.') {
    *end = dp; /* needed for scanf */
    return n * sign;
  }

  x = 0.1;
  s = dp+1;
  /* convert decimal part */
  for( ; (*s >= '0') && (*s <= '9'); s++) {
    n += (x * ch2int(*s));
    x /= 10.0;
  } 
  *end = s; /* need for scanf */
  return n * sign;
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
