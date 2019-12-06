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

int SPUTC(int c, char *buf)
{
  *buf++ = c;
  return 1;
}

int SPUTS(char *s, char *obuf)
{
  char *buf = obuf;
    while (*s) {
      buf += SPUTC(*s++, buf);
    }
    return buf-obuf;
}


int SPUTL(unsigned long u, int base, int width, int fill_char, char *obuf)
{
  int r = 0;
  static char outbuf[32];
  char *t;
  char *buf = obuf;

  t = outbuf;

  do {
    *t++ = "0123456789abcdef"[u % base];
    u /= base;
    width--;
  } while (u > 0);

  while (width-- > 0) {
    buf += SPUTC(fill_char,buf);
    r++;
  }
  while (t != outbuf) {
    buf += SPUTC(*--t, buf);
    r++;
  }
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
