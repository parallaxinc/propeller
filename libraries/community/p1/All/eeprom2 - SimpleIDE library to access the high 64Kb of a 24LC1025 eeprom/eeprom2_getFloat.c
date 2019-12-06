/*
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
 * @file eeprom.c
 *
 * @author Andy Lindsay
 *
 * @version 0.85
 *
 * @copyright Copyright (C) Parallax, Inc. 2013.  See end of file for
 * terms of use (MIT License).
 *
 * @brief eeprom functions source, see simpletools.h for documentation.
 *
 * @detail Please submit bug reports, suggestions, and improvements to
 * this code to editor@parallax.com.
 */

#include "eeprom2.h"                      // simpletools function prototypes

i2c *st2_eeprom;
int st2_eeInitFlag;

void ee2_init();

float ee2_getFloat32(int addr)
{
  if(!st2_eeInitFlag) ee2_init();
  unsigned char value[4] = {0, 0, 0, 0};
  i2c_in(st2_eeprom, EEPROM2_ADDR, addr, 2, value, 4);
  float fpVal;
  memcpy(&fpVal, &value, sizeof value);
  return fpVal;
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
