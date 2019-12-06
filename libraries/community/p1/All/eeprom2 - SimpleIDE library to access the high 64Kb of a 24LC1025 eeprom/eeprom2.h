/**
 * The following file, as part of the libeeprom2 simpleIDE library, is simply a copy of 
 * each of the eeprom files as found in the Simple Libraries/Utility/libsimpletools
 * directory. I have altered the originals to make minor changes which will allow the
 * same functionalities... but for the high 64Kb locations of a 24LC1025 eeprom which has
 * been installed in the boot eeprom socket of parallax boards.
 *
 * Usage... the commands you find as part of this library match the same names and
 *			functionality as their simpletools counterparts.... the names have been
 * 			changed to protect the innocent (and make it useful).
 *
 *			For instance... the simpletools command ee_config has an ee2_config
 *			counterpart in this library that will allow access to the high 64Kb.
 *
 *			simply add a '2' to the end of the 'ee' prefix of the simpletools commands
 *				ie. ee_putStr --> ee2_putStr
 *
 * Alterations by TJ - tj4shee@icloud.com - I have left the original copyright in place
 * 			below.
 *
 ****************************************************************************************
 *
 * @file eeprom2.h
 *
 * @author Andy Lindsay
 *
 * @copyright
 * Copyright (C) Parallax, Inc. 2014. All Rights MIT Licensed.
 *
 */

#ifndef EEPROM2_H
#define EEPROM2_H

#if defined(__cplusplus)
extern "C" {
#endif

//#include <propeller.h>
#include "simpletext.h"
//#include <driver.h>
//#include <stdio.h>
//#include <stdlib.h>
//#include <string.h>
//#include <cog.h>
//#include <ctype.h>
//#include <unistd.h>
//#include <sys/stat.h>
//#include <dirent.h>
//#include <sys/sd.h>
//#include <math.h>
#include "simplei2c.h"

extern i2c *st2_eeprom;
extern int st2_eeInitFlag;

#ifndef EEPROM2_ADDR
#define EEPROM2_ADDR	 0x54
#define EEPROM2_POLLADDR 0xA8
#endif

void ee2_putByte(unsigned char value, int addr);
char ee2_getByte(int addr);
void ee2_putInt(int value, int addr);
int ee2_getInt(int addr);
void ee2_putStr(unsigned char *s, int n, int addr);
unsigned char* ee2_getStr(unsigned char* s, int n, int addr);
void ee2_putFloat32(float value, int addr);
float ee2_getFloat32(int addr);
void ee2_config(int sclPin, int sdaPin, int sclDrive);

#if defined(__cplusplus)
}
#endif
/* __cplusplus */  
#endif
/* EEPROM2_H */  

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
