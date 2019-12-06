/*
 * Super-simple text I/O for PropGCC, stripped of all stdio overhead.
 * Copyright (c) 2012, Ted Stefanik. Concept inspired by:
 *
 *     very simple printf, adapted from one written by me [Eric Smith]
 *     for the MiNT OS long ago
 *     placed in the public domain
 *       - Eric Smith
 *     Propeller specific adaptations
 *     Copyright (c) 2011 Parallax, Inc.
 *     Written by Eric R. Smith, Total Spectrum Software Inc.
 *
 * MIT licensed (see terms at end of file)
 */
#include <ctype.h>

static int charToInt(char ch)
{
    ch -= '0';
    if (ch >= 10)
        ch -= 'A' - '9' - 1;
    if (ch > 15)
        ch -= 'a' - 'A';
    return ch;
}

static inline int binChar(char ch)
{
  return (ch == '0' || ch == '1');
}

static inline int decChar(char ch)
{
  return (ch == '-' || ch == '+' || isdigit(ch));
}

const char* _scanf_getl(const char *str, int* dst, int base, unsigned width, int isSigned)
{
  int isNegative = 0;
  unsigned num = 0;
  int foundAtLeastOneDigit = 0;
  int ch;

  switch(base) {
    case 2: while(!binChar(*str)) str++;
    break;
    case 10: while(!decChar(*str)) str++;
    break;
    case 16: while(!isxdigit(*str)) str++;
    break;
    default: while(*str == ' ' || *str == '\t') str++;
    break;
  }

  if (isSigned)
  {
      isNegative = (*str == '-');
      if (*str == '+' || *str == '-')
          str++;
  }

  while (width--)
  {
    ch = *str;
    str++;
    if(!((ch >= '0' && ch <= '9') ||
         (base ==  2 && ((ch >= '0' && ch <= '1') || (ch == '.') || (ch == '_')) ) ||
         (base == 16 && ((ch >= 'A' && ch <= 'F') || (ch >= 'a' && ch <= 'f')) )
      )) {
      if (!foundAtLeastOneDigit)
          return 0;
      break;
    }

    /* allow in integer numbers */
    if(ch == '.' || ch == ',' || ch == '_')
      continue;

    foundAtLeastOneDigit = 1;
    num = base * num + charToInt(ch);
  }

  if (isNegative)
    *dst = -num;
  else
    *dst = num;

  return str;
}


/* +--------------------------------------------------------------------
 * |  TERMS OF USE: MIT License
 * +--------------------------------------------------------------------
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files
 * (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge,
 * publish, distribute, sublicense, and/or sell copies of the Software,
 * and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * +--------------------------------------------------------------------
 */
