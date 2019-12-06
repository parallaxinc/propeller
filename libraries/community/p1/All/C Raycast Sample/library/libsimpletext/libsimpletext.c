/*
 * @file libsimpletext.h
 * Project and Test harness for library simpletext
 *
 * Copyright (c) 2013, Parallax Inc. MIT license.
 * Written by Steve Denson
 */

#include "serial.h"

//#define MORETESTING

int main(void)
{
  int   n;
  char  buffer[80];
  char  sval[80];
  int   buflen = 80;
  int   xval = 0;
  int   ival = 0x55;
  float fval = 355/113.0;
  float fval2 = 1.4;
  float e = 2.71828184590;
  char bigtext[] = "abcdefghijklmnopqrstuvwxyz";
  
  /*
   * global serial module pointer - can be local.
   */
  serial *text;

  /* no need to wait for terminal startup.
   * delay is done in the default serial open function. */

  /* traditional hello message. */
  putln("Hello, world!");

  putStrLen(&bigtext[20],5);
  putln("");
  writeStrLen(simpleterm_pointer(),&bigtext[4],5);
  putln("");
  
  putLine("Reopen test");
  simpleterm_reopen(31,30,0,115200);
  putLine("Reopen Ok.");
  
#ifdef DIV0_NAN_TEST
  float fproblem;
  float f;

  for(f = 5.0; f > -5.0; f -= 1.0) {
    fproblem = 1.0 / f;
    print("f = %02.2f, fproblem = %02.2f\n", f, fproblem);
  }
  for(f = 5.0; f > -5.0; f -= 1.0) {
    fproblem = 1.0 / -f;
    putStr("f = "); putFloat(f); putStr(" fproblem = "); putFloat(fproblem); putLine("");
  }

   for(f = 5.0; f > -5.0; f -= 1.0) {
      fproblem = atan(0.0/f);
      print("f = %02.2f, fproblem = %02.2f\n", f, fproblem);
   }
   for(f = 5.0; f > -5.0; f -= 1.0) {
      fproblem = atan(0.0/-f);
      putStr("f = "); putFloat(f); putStr(" fproblem = "); putFloat(fproblem); putLine("");
   }
#endif
   
#ifdef MORETESTING

  putDec(1);
  putChar(' ');
  putDec(-1);
  putLine("");

  putLine("Hello, again!");

  sprint(sval,"Toast Test");
  putln(sval);

#if 1
  putStr("\nEnter scan float string : ");
  scan("%f %s", &fval, sval);
  print("%f %s\n", fval, sval);
  putFloat(fval);
  putStr("\n");
  putln(sval);

  putStr("\nEnter sscan float string: ");
  getStr(buffer, buflen);
  putln(buffer);
  sscan(buffer, "%f %s", &fval, sval);
  sprint(buffer, "%f %s", fval, sval);
  putln(buffer);
  putFloat(fval);
  putStr("\n");
  putln(sval);
#endif

  putFloat(101.3);
  putStr("\n");
  putFloat(e);
  putStr("\n");
  writeFloatPrecision(simpleterm_pointer(), e, 8, 4);
  putStr("\n");

  putStr("\nDecimal  ");
  sprint(buffer, "%2d %4d %6d %8d %10d %15d", 2, 4, 6, 8, 10, 15);
  putStr(buffer);
  putStr("\nHex      ");
  sprint(buffer, "%2x %4x %6x %8x %10x %15x", 2, 4, 6, 8, 10, 15);
  putStr(buffer);
  putStr("\nBinary   ");
  sprint(buffer, "%2b %4b %6b %8b %10b %15b", 2, 4, 6, 8, 10, 15);
  putStr(buffer);
  putStr("\nFloat(e) ");
  sprint(buffer, "%2.0f %4.1f %6.2f %8.3f %10.4f %15.6f\n", e, e, e, e, e, e);
  putln(buffer);

  for(n = 0; n < 1; n++) {
    float f;
    putStr("\nEnter two floating point numbers");
    if(!n)
      putStr(": ");
    else
      putStr(" again: ");
    getStr(buffer, buflen);
    sscan(buffer, "%f %f", &f, &fval2);
    putFloat(f);
    putChar(' ');
    putFloat(fval2);
  }

  putStr("\nEnter a floating point number: ");
  putFloat(getFloat());

  /* Close SimpleTerm so we can use port with FdSerial */
  putStr("\nClose default console.\n");
  simpleterm_close();

  /* restart device */
  text = serial_open(31,30,0,115200);
  writeStr(text, "SimpleSerial Started.\n");

  /* traditional hello message using buffer printf. */
  sprint(buffer, "Hello, world! Again!\n");
  writeStr(text, buffer);


#if 1
  writeStr(text, "\nEnter dscan float string: ");
  dscan(text, "%f %s", &fval, sval);
  dprint(text, "%f %s\n", fval, sval);
  writeFloat(text, fval);
  writeLine(text, "");
  writeLine(text, sval);
#endif

  writeChar(text, 'T');
  writeChar(text, 'o');
  writeChar(text, 'o');
  writeChar(text, 't');

  writeStr(text, "\n");
  writeDec(text, ival);
  writeChar(text, ' ');
  writeHex(text, ival);
  writeChar(text, ' ');
  writeBin(text, ival);

  fval = 355/113.0;
  writeStr(text, "\n");
  writeFloatPrecision(text, fval, 2, 10);
  writeChar(text, ' ');
  writeFloatPrecision(text, fval*100.0, 2, 10);

  writeLine(text, "");
  writeLine(text, "Press any key: ");
  writeChar(text, readChar(text));

  writeStr(text, "\nEnter a decimal number: ");
  writeDecLen(text, readDec(text),8);
  writeStr(text, "\nEnter a hexadecimal number: ");
  writeHexLen(text, readHex(text),8);
  writeStr(text, "\nEnter a binary number: ");
  writeBinLen(text, readBin(text),8);
  writeStr(text, "\nEnter a floating point number: ");
  writeFloatPrecision(text, readFloat(text),8,8);

  writeStr(text, "\nEnter values as: decimal hex float float string\n");
  readStr(text, buffer, buflen);
  writeStr(text, buffer);
  sscan(buffer, "%d %x %f %f %s", &ival, &xval, &fval, &fval2, sval);
  sprint(buffer, "%s %d %x %f %f\n", sval, ival, xval, fval, fval2);
  writeLine(text, "");
  writeLine(text, buffer);
  
  writeLine(text, "All done.");
  serial_close(text);

#endif

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
