/**
 * libi2ceasy.c
 *
 * TJ Forshee
 * tj4shee@icloud.com.
 *
 * Copyright (C) Bluegrass Digital Inc. All Rights MIT Licensed, see end of file.
 *
 * This is yet another C I2C library for SimpleIDE.... it came about when I spent 2 days
 * trying to get an 20x4 lcd to work with the propeller.  I decided to start from
 * scratch... so I knew what was going on under the code.
 * 
 * This is based on a Spin project by Craig Weber - "PCF8574 Driver Test.spin" and his
 * modified version "PCF8574_Driver.spin" of Raymond Allen's PCF8574 I2C Driver code
 * which is a modified version of Michael Green's Basic_i2c_driver found on OBEX
 * 
 */

#ifndef __I2CEASY_H
#define __I2CEASY_H

#include "simpletools.h"

#ifdef __cplusplus
extern "C"
{
#endif

typedef text_t i2ceasy;

#define ACK 0

i2ceasy *i2c__init(long SCLpin, long SDApin);
void i2c__start();
void i2c__stop();
uint8_t i2c__read(long address);
long i2c__in(int ackbit);
int i2c__writeStr(long address, char *string, int length);
int i2c__write(long address, long data);
int i2c__out(long data);

#ifdef __cplusplus
}
#endif

#endif


/**
 * TERMS OF USE: MIT License
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

