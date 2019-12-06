/*
 * @file floatToString.c
 *
 * Copyright (c) 2013 Parallax Inc.
 * Author Andy Lindsay
 * Clamp to 6 decimal digits by Steve - buffer must be at least 10 chars.
 *
 * See end of file for terms of use.
 */

#include "simpletext.h"

#ifndef S_ISNAN
#define S_ISNAN(x) (x != x)
#endif  /* !defined(S_ISNAN) */
#ifndef S_ISINF
#define S_ISINF(x) (x != 0.0 && x + x == x)
#endif  /* !defined(S_ISINF) */

char* float2string(float f, char *s, int ccount, int digits)
{
  union convert  {
    float v;
    int   w; 
  } fval;

  int m = 0;
  int k = 0;

  int j = 0;
  int sign = 0;
  int g = 0;

  int reps = 0;
  float scale = 0.0;
  int ctr = 0;

  int offset;
  int p;
  int q;
  int n;

  if(S_ISNAN(f)) {
    strcpy(s, "nan");
    return s;
  }
  if(S_ISINF(f)) {
    if(((int)f) & 0x80000000)
      strcpy(s, "-inf");
    else
      strcpy(s, "inf");
    return s;
  }
        
  /* clamp the digits. */
  int clamp = 6; /* a buffer must be at least clamp + 4 digits */
  digits = (digits > clamp) ? clamp : digits;

  if(f < 0.0) 
  {
    sign = 1;
    f = -f;
  }

  if (sign)
  {
    s[j++] = '-';
  }

  /* Find resonable starting value for scale.
  // Using 2^10x has similar values to 10^3x. */
  fval.v = f;
  g = fval.w;
  
  g >>= 23;
  g &= 0xFF;
  g -= 127;

  reps = (g / 10);
  scale = 1.0;
  for(ctr = 0; ctr <= reps; ctr++)
  {
    scale *= 1000.0;
  }

  /* If integer is zero, 0 */
  if(f < 1.0)
  {
    s[j++] = '0';
  }
  else
  {
    char c = '0';
    for ( ; scale >= 1.0; scale /= 10.0)
    {
      if (f >= scale)
      {
        break;
      }
    }
    for ( ; scale >= 1.0; scale /= 10.0)
    {
      c = (char)(f/scale);
      f -= ((float)c*scale);
      c += 48;
      s[j++] = c;
    }
  }  

  /* If digits > current size, move right, then pad with spaces
  // if(digits < 0) digits = 0; */
  offset = ccount - j - digits - 1;
  if(digits == 0)
    offset++;

  p = j + offset;
  q = j;
  n = p;

  if(offset > 0) 
  { 
    for( ; j >= 0; )
    {
      s[n--] = s[j--];      
    }
    for( ; n >= 0; )
    {
      s[n--] = ' ';      
    }
    j = p;
  }
  else
  {
    j = q;
  }

  /* Append with fractional */
  if(digits>0) s[j++] = '.';

  k = j;
  k += digits;
  for( ; j <= k; )
  {
    f *= 10.0;
    s[j++] = (char)f + '0';
    f -= ((int) f);
  }

  m = j-1;
  j--;
  if(s[j] >= '5') 
  {
    j--;
    for( ; (j >= 0); j--)
    {
      if((s[j] < '0')||(s[j] > '9')) continue;
      if(s[j] < '9') 
      {
        s[j]++;
        break;
      }
      else 
      {
        s[j] = '0';
      }
    }
  }

  s[m] = 0;
  return s;
}

#if 0
char* float2string(float f, char *s, int ccount, int digits)
{
  union convert  {
    float v;
    int   w; 
  } fval;

  int m = 0;
  int k = 0;

  int j = 0;
  int sign = 0;
  int g = 0;

  int reps = 0;
  float scale = 0.0;
  int ctr = 0;

  int offset;
  int p;
  int q;
  int n;

  /* clamp the digits. */
  int clamp = 6; /* a buffer must be at least clamp + 4 digits */
  digits = (digits > clamp) ? clamp : digits;

  if(f < 0.0) 
  {
    sign = 1;
    f = -f;
  }

  if (sign)
  {
    s[j++] = '-';
  }

  /* Find resonable starting value for scale.
  // Using 2^10x has similar values to 10^3x. */
  fval.v = f;
  g = fval.w;
  
  g >>= 23;
  g &= 0xFF;
  g -= 127;

  reps = (g / 10);
  scale = 1.0;
  for(ctr = 0; ctr <= reps; ctr++)
  {
    scale *= 1000.0;
  }

  /* If integer is zero, 0 */
  if(f < 1.0)
  {
    s[j++] = '0';
  }
  else
  {
    int started = 0;
    char c = '0';
    for ( ; scale >= 1.0; scale /= 10.0)
    {
      if (f >= scale)
      {
        c = (char)(f/scale);
        f -= ((float)c*scale);
        c += 48;
        s[j++] = c;
        started++;
      }
      else if(started) {
        s[j++] = '0';
      }
    }
  }  

  /* If digits > current size, move right, then pad with spaces
  // if(digits < 0) digits = 0; */
  offset = ccount - j - digits - 1;
  if(digits == 0)
    offset++;

  p = j + offset;
  q = j;
  n = p;

  if(offset > 0) 
  { 
    for( ; j >= 0; )
    {
      s[n--] = s[j--];      
    }
    for( ; n >= 0; )
    {
      s[n--] = ' ';      
    }
    j = p;
  }
  else
  {
    j = q;
  }

  /* Append with fractional */
  if(digits>0) s[j++] = '.';

  k = j;
  k += digits;
  for( ; j <= k; )
  {
    f *= 10.0;
    s[j++] = (char)f + '0';
    f -= ((int) f);
  }

  m = j-1;
  j--;
  if(s[j] >= '5') 
  {
    j--;
    for( ; (j >= 0); j--)
    {
      if((s[j] < '0')||(s[j] > '9')) continue;
      if(s[j] < '9') 
      {
        s[j]++;
        break;
      }
      else 
      {
        s[j] = '0';
      }
    }
  }

  s[m] = 0;
  return s;
}
#endif

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
