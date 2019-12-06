/*
 * very simple printf, adapted from one written by me
 * for the MiNT OS long ago
 * placed in the public domain
 *   - Eric Smith
 * 32 bit mode only. %b, %e, %f, %g added by Steve Denson
 */
#include <ctype.h>
#include <stdarg.h>
#include "simpletext.h"

/*
 * very simple printf -- just understands a few format features
 */

int _dosprnt(const char *fmt, va_list args, char *obuf)
{
  char c, fill_char;
  char *s_arg;
  int i_arg;
  long l_arg;
  int width;
  int precision;
  char fstr[20];

  char *buf = obuf;
  while( (c = *fmt++) != 0 ) {

    if (c != '%') {
      buf += SPUTC(c, buf);
      continue;
    }
    c = *fmt++;
    width = 0;
    precision = 6;
    fill_char = ' ';
    if (c == '0') fill_char = '0';
    while (c && isdigit(c)) {
      width = 10*width + (c-'0');
      c = *fmt++;
    }
    if(c == '.') {
      precision = 0;
      c = *fmt++;
      while (c && isdigit(c)) {
        precision = 10*precision + (c-'0');
        c = *fmt++;
      }
    }
    if (!c)
      break;

    switch (c) {

      case '%':
        buf += SPUTC(c, buf);
        break;
  
      case 'b':
          l_arg = va_arg(args, int);
        buf += SPUTL(l_arg, 2, width, fill_char, buf);
        break;
  
      case 'c':
        i_arg = va_arg(args, int);
        buf += SPUTC(i_arg, buf);
        break;
  
      case 's':
        s_arg = va_arg(args, char *);
        buf += SPUTS(s_arg, buf);
        break;
  
      case 'd':
      case 'u':
        l_arg = va_arg(args, int);
        if (l_arg < 0 && c == 'd') {
          buf += SPUTC('-', buf);
          width--;
          l_arg = -l_arg;
        }
        buf += SPUTL(l_arg, 10, width, fill_char, buf);
        break;
#if 0
      case 'e':
      case 'g':
      {
        union { float f; int i; } a;
        a.i = va_arg(args, int);
        buf += SPUTS(floatToScientific(a.f), buf);
        break;
      }
#endif
      case 'f': {
        double d = va_arg(args, double);
        buf += SPUTS(float2string((float) d, fstr, width, precision), buf);
        break;
      }

      case 'x': {
        l_arg = va_arg(args, unsigned int);
        buf += SPUTL(l_arg, 16, width, fill_char, buf);
        break;
      }
    }
  }
  *buf = '\0';
  return buf-obuf;
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
