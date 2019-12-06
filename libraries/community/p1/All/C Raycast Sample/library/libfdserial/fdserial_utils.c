/**
 * @file fdserial.c
 * Full Duplex Serial adapter module.
 *
 * Copyright (c) 2008-2013, Steve Denson
 * See end of file for terms of use.
 */
#include <propeller.h>
#include "fdserial.h"

/*
 * rxflush empties the receive queue 
 */
void fdserial_rxFlush(fdserial *term)
{
  while(fdserial_rxCheck(term) >= 0)
      ; // clear out queue by receiving all available 
}

/*
 * Check if a byte is available in the buffer.
 * Function does not block.
 * @returns non-zero if a byte is available.
 */
int fdserial_rxReady(fdserial *term)
{
  volatile fdserial_st* fdp = (fdserial_st*) term->devst;
  return (fdp->rx_tail != fdp->rx_head);
}

/*
 * Get a byte from the receive queue if available within timeout period.
 * Function blocks if no recieve for ms timeout.
 * @param ms is number of milliseconds to wait for a char
 * @returns receive byte 0 to 0xff or -1 if none available 
 */
int fdserial_rxTime(fdserial *term, int ms)
{
  int rc = -1;
  int t1 = 0;
  int t0 = CNT;
  do {
      rc = fdserial_rxCheck(term);
      t1 = CNT;
      if((t1 - t0)/(CLKFREQ/1000) > ms)
          break;
  } while(rc < 0);
  return rc;
}

void fdserial_txFlush(fdserial *term)
{
  while(!fdserial_txEmpty(term));
}

/*
 * Get a byte from the receive buffer without changing the pointers.
 * The function does not block.
 * returns non-zero if a valid byte is available.
 */
int  fdserial_rxPeek(fdserial *term)
{
  int rc = 0;
  volatile fdserial_st* fdp = (fdserial_st*) term->devst;
  volatile char* rxbuf = (volatile char*) fdp->buffptr;  // rx buff starts at offset 0

  if(fdp->rx_tail != fdp->rx_head) {
      rc = rxbuf[fdp->rx_tail];
  }
  return rc;
}

/*
 * Get number of bytes available in the receive buffer.
 * Queue overflows can not be detected.
 * The function does not block.
 * returns less than 1 if no bytes are available.
 */
int  fdserial_rxAvailable(fdserial *term)
{
  int rc = 0;
  volatile fdserial_st* fdp = (fdserial_st*) term->devst;
  volatile char* rxbuf = (volatile char*) fdp->buffptr;  // rx buff starts at offset 0

  if(fdp->rx_tail == fdp->rx_head) {
      rc = 0;
  }
  else {
      if(fdp->rx_head > fdp->rx_tail) {
          rc = fdp->rx_head - fdp->rx_tail;
      }
      else {
          // [.....H.........T....]
          rc = FDSERIAL_BUFF_MASK+1;
          rc -= fdp->rx_tail; // buffer size - tail mark
          rc += fdp->rx_head; // plus head mark
      }                    
  }      
  return rc;
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

