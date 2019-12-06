/**
 * libi2ceasy.c
 *
 * TJ Forshee
 * tj4shee@icloud.com.
 *
 * Copyright (C) Bluegrass Digital Inc. All Rights MIT Licensed, see end of file.
 *
 * This is a C library for SimpleIDE to run an HD44780 type LCD via a PCF7584 port
 * expander.  This should work with any i2c library... but it was tested via my own
 * C i2c library named i2ceasy (also in OBEX)
 * 
 * This library is based on an Arduino library named "LiquidCrystal_I2C" that I use
 * for running a 20x4 LCD driven by a PCF7584.  I will always give credit... but in
 * this case, the only thing close to any signature was YWROBOT at the top of the
 * source files.
 * 
 */
#include "i2ceasy.h"
#include "simpletools.h"
#include "i2clcd.h"

i2ceasy *i2cbus;
i2clcd *lcd2004;

int main()
{
   i2cbus = i2c__init(4, 5);  // SCL pin, SDA pin
   
   lcd2004 = lcd_init(39, 4, 20);
   lcd_backlightOn();
   lcd_setCursor(0, 0);
   lcd_print("   Welcome to the");
   lcd_setCursor(1, 0);
   lcd_print("  Electronic World");
   lcd_setCursor(2, 0);
   lcd_print("of Bluegrass Digital");
   lcd_setCursor(3, 0);
   lcd_print("   copyright 2015");
   
   while (1)
   {
   }      
}


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

