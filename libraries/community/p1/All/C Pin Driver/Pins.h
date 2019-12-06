#ifndef __SI_PINS_H
#define __SI_PINS_H
#include "propeller.h"
#include <stdbool.h>

/*
BY:            RYAN STARK, Stark Informatics LLC
DATE:        7/8/2013
VERSION:    2.2

View the README.TXT for function information.

Version 1.0
Initial Release

Version 1.1
Improved documentation

Version 2.0
Adds functionality for ranged tasks(1..4)

Version 2.1
Adds Pre-Processor statements allowing including of either Pins.h or Pins.c and prevents multiple declarations

Version 2.2
Fixes bug in void pinOutLow(PIN_MASK * msk)
*/

typedef struct {
    unsigned int mask;
    unsigned char shift;
    unsigned char length;
} PIN_MASK;

void createMask(PIN_MASK * msk, unsigned int start, unsigned char length);
void pinSetD(PIN_MASK * msk, unsigned int value);
void pinSetOut(PIN_MASK * msk);
void pinSetIn(PIN_MASK * msk);
void pinSetS(PIN_MASK * msk, unsigned int value);
void pinSetHigh(PIN_MASK * msk);
void pinSetLow(PIN_MASK * msk);
void pinOutS(PIN_MASK * msk, unsigned int value);
void pinOutHigh(PIN_MASK * msk);
void pinOutLow(PIN_MASK * msk);
unsigned int pinRead(PIN_MASK * msk);
unsigned int pinInRead(PIN_MASK * msk);
unsigned int pinStatus(PIN_MASK * msk);
unsigned int pinDirection(PIN_MASK * msk);

#include "pins.c"
#endif

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                  TERMS OF USE: MIT License
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
// Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
