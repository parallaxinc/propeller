/*
 * @file serial.c
 * Defines the serial receive and transmit routines.
 *
 * Copyright (c) 2013, Parallax Inc.
 * Written by Steve Denson
 */
#include <propeller.h>
#include "serial.h"

__attribute__((fcache)) static int _inbyte(int bitcycles, int cycle1, int rxmask, int value)
{
  int waitcycles;
  int j = 8;

  cycle1 += cycle1 >> 2;

  /* wait for a start bit */
  waitpeq(0, rxmask);
  waitcycles = cycle1 + CNT;

  /* index initialized above */
  while(j-- > 0) {
    /* C code is too big for fcache in xmm memory models.
    // waitcycles = waitcnt2(waitcycles, bitcycles); */
    __asm__ volatile("waitcnt %[_waitcycles], %[_bitcycles]"
                     : [_waitcycles] "+r" (waitcycles)
                     : [_bitcycles] "r" (bitcycles));

    /* value = ( (0 != (INA & rxmask)) << 7) | (value >> 1); */
    __asm__ volatile("shr %[_value],# 1\n\t"
                     "test %[_mask],ina wz \n\t"
                     "muxnz %[_value], #1<<7"
                     : [_value] "+r" (value)
                     : [_mask] "r" (rxmask));
  }
  return value; /* fcached 0x40 or 64 bytes */
}

int  serial_rxChar(serial *device)
{
  Serial_t *sp = (Serial_t*) device->devst;
  int value = 0;

  /* set input */
  unsigned int rxmask = 1 << sp->rx_pin;

  if(sp->tx_pin < SERIAL_MIN_PIN && sp->tx_pin > SERIAL_MAX_PIN)
    return 0; /* don't receive on pins out of range */

  DIRA &= ~rxmask;

  value = _inbyte(sp->ticks, sp->ticks, rxmask, 0);
  /* wait for the line to go high (as it will when the stop bit arrives) */
  waitpeq(rxmask, rxmask);
  return value & 0xff;
}

__attribute__((fcache)) static void _outbyte(int bitcycles, int txmask, int value)
{
  int j = 10;
  int waitcycles;

  waitcycles = CNT + bitcycles;
  while(j-- > 0) {
    /* C code is too big and not fast enough for all memory models.
    // waitcycles = waitcnt2(waitcycles, bitcycles); */
    __asm__ volatile("waitcnt %[_waitcycles], %[_bitcycles]"
                     : [_waitcycles] "+r" (waitcycles)
                     : [_bitcycles] "r" (bitcycles));

    /* if (value & 1) OUTA |= txmask else OUTA &= ~txmask; value = value >> 1; */
    __asm__ volatile("shr %[_value],#1 wc \n\t"
                     "muxc outa, %[_mask]"
                     : [_value] "+r" (value)
                     : [_mask] "r" (txmask));
  }
}


int serial_txChar(serial *device, int value)
{
  Serial_t *sp = (Serial_t*) device->devst;
  int txmask = (1 << sp->tx_pin);

  if(sp->tx_pin < SERIAL_MIN_PIN && sp->tx_pin > SERIAL_MAX_PIN)
    return 0; /* don't transmit on pins out of range */

  DIRA |= txmask;

  _outbyte(sp->ticks, txmask, (value | 0x100) << 1);

  return value;
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
