/*
* @file libfdserial.c
*
* @author Steve Denson
*
* @copyright
* Copyright (C) Steve Denson 2008-2013. All Rights MIT Licensed.
*
* @brief Project and test harness for the fdserial library.
*/
#include "fdserial.h"

int main(void)
{
  int   n;
  char  ch;
  char  buffer[80];
  int   buflen=80;
  char  sval[80];
  int   xval = 0;
  int   ival = 0x55;
  float fval = 355/113.0;
  float fval2 = 0.0;
  float e = 2.71828184590;

  /* start device */
  fdserial *term = fdserial_open(31,30,0,115200);

  /* traditional hello message. */
  writeStr(term, "Hello fdserial!\n\n");

  writeStr(term, "Press keys for 10 seconds to enter chars in buffer.");
  waitcnt(CLKFREQ*10+CNT);

  writeStr(term, "\nKeys pressed ");
  writeDec(term,fdserial_rxAvailable(term));
  writeLine(term, " times.");
  fdserial_rxFlush(term);
  writeLine(term, "");
  
  writeFloatPrecision(term, e, 8, 8);
  writeStr(term, "\n");
  writeFloatPrecision(term, e, 8, 2);
  writeStr(term, "\n");

  writeStr(term, "\nDecimal  ");
  sprint(buffer, "%2d %4d %6d %8d %10d %15d", 2, 4, 6, 8, 10, 15);
  writeLine(term, buffer);
  writeStr(term, "Hex      ");
  sscan(buffer, "%2x %4x %6x %8x %10x %15x", 2, 4, 6, 8, 10, 15);
  writeLine(term, buffer);
  writeStr(term, "Binary   ");
  sprint(buffer, "%2b %4b %6b %8b %10b %15b", 2, 4, 6, 8, 10, 15);
  writeLine(term, buffer);
  writeStr(term, "Float(e) ");
  sprint(buffer, "%2.0f %4.1f %6.2f %8.3f %10.4f %15.6f\n", e, e, e, e, e, e);
  writeLine(term, buffer);

  for(n = 0; n < 2; n++) {
    float f;
    writeStr(term, "\nEnter two floating point numbers");
    if(!n)
      writeStr(term, ": ");
    else
      writeStr(term, " again: ");
    readStr(term, buffer, buflen);
    sscan(buffer, "%f %f", &f, &fval2);
    writeFloatPrecision(term, f, 8, 2);
    writeChar(term, ' ');
    writeFloatPrecision(term, fval2, 8, 2);
  }

  writeStr(term, "\nEnter a floating point number: ");
  writeFloatPrecision(term, readFloat(term), 8, 2);

  sprint(buffer, "\nHello again!\n");
  writeStr(term, buffer);

  writeChar(term, 'T');
  writeChar(term, 'o');
  writeChar(term, 'o');
  writeChar(term, 't');

  writeStr(term, "\n");
  writeDec(term, ival);
  writeChar(term, ' ');
  writeHex(term, ival);
  writeChar(term, ' ');
  writeBin(term, ival);

  writeStr(term, "\n");
  writeStrLen(term, "Woot\n", 8);
  writeDecLen(term, ival, 8);
  writeChar(term, ' ');
  writeHexLen(term, ival, 8);
  writeChar(term, ' ');
  writeBinLen(term, ival, 8);

  writeLine(term, "");
  writeFloat(term, fval);
  writeChar(term, ' ');
  writeFloat(term, fval*100.0);

  writeLine(term, "");
  writeFloatPrecision(term, fval, 12, 7);
  writeFloatPrecision(term, fval*100.0, 12, 7);

  writeStr(term, "\nfdserial RX Ready? ");
  writeDec(term, fdserial_rxReady(term));
  writeStr(term, "\nPress any key:  ");

  while(fdserial_rxReady(term) == 0) {
    writeChar(term, '\3');
    writeChar(term, ']');
    waitcnt(CLKFREQ/4+CNT);
    writeChar(term, '\3');
    writeChar(term, '[');
    waitcnt(CLKFREQ/4+CNT);
  }

  ch = readChar(term);
  writeChar(term, ch);

  writeStr(term, "Press any key: ");
  writeChar(term, readChar(term));

  writeStr(term, "\nEnter a decimal number: ");
  writeDecLen(term, readDec(term),8);
  writeStr(term, "\nEnter a hexadecimal number: ");
  writeHexLen(term, readHex(term),8);
  writeStr(term, "\nEnter a binary number: ");
  writeBinLen(term, readBin(term),8);
  writeStr(term, "\nEnter a floating point number: ");
  writeFloatPrecision(term, readFloat(term), 8, 8);

  writeStr(term, "\nEnter values as: decimal hex float float string\n");
  readStr(term, buffer, buflen);
  writeLine(term, buffer);
  sscan(buffer, "%d %x %f %f %s", &ival, &xval, &fval, &fval2, sval);
  sprint(buffer, "%s %d %x %f %f\n", sval, ival, xval, fval, fval2);
  writeLine(term, "");
  writeFloat(term, fval);
  writeLine(term, "");
  writeFloat(term, fval2);
  writeStr(term, "\nAll done.\n");

  return 0;
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
