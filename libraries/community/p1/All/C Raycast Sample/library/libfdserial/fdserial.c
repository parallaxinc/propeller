
/**
 * @file fdserial.c
 * Full Duplex Serial adapter module.
 *
 * Copyright (c) 2008-2013, Steve Denson
 * See end of file for terms of use.
 */
#include <stdlib.h>
#include "fdserial.h"

/*
 * start initializes and starts native assembly driver in a cog.
 * @param rxpin is pin number for receive input
 * @param txpin is pin number for transmit output
 * @param mode is interface mode. see header FDSERIAL_MODE_...
 * @param baudrate is frequency of bits ... 115200, 57600, etc...
 * @returns non-zero on success
 */
fdserial *fdserial_open(int rxpin, int txpin, int mode, int baudrate)
{
  extern int binary_pst_dat_start[];

  fdserial_st *fdptr;

  /* can't use array instead of malloc because it would go out of scope. */
  char* bufptr = (char*) malloc(2*(FDSERIAL_BUFF_MASK+1));
  fdserial* term = (fdserial*) malloc(sizeof(fdserial));
  memset(term, 0, sizeof(fdserial));

  fdptr = (void*) malloc(sizeof(fdserial_st));
  term->devst = fdptr;
  memset((char*)fdptr, 0, sizeof(fdserial_st));

  if(rxpin == 31 && txpin == 30) {
    simpleterm_close();
  }

  /* required for terminal to work */
  term->txChar  = fdserial_txChar;
  term->rxChar  = fdserial_rxChar;

  fdptr->rx_pin = rxpin; /* recieve pin */
  fdptr->tx_pin = txpin; /* transmit pin */
  fdptr->mode   = mode;  /* interface mode */

  /* baud from clkfreq (cpu clock typically 80000000 for 5M*pll16x) */
  fdptr->ticks   = CLKFREQ/baudrate;

  fdptr->buffptr = bufptr; /* receive and transmit buffer */

  /* now start the kernel */
#if defined(__PROPELLER_USE_XMM__)
  { unsigned int buffer[2048];
    memcpy(buffer, binary_pst_dat_start, 2048);
    term->cogid[0] = cognew(buffer, (void*)fdptr) + 1;
  }
#else
  term->cogid[0] = setStopCOGID(cognew((void*)binary_pst_dat_start, (void*)fdptr));
#endif
  waitcnt(CLKFREQ/2+CNT); // give cog chance to load
  return term;
}

/*
 * stop stops the cog running the native assembly driver 
 */
void fdserial_close(fdserial *term)
{
  int id = term->cogid[0];
  fdserial_st* fdp = (fdserial_st*) term->devst;

  while(fdserial_rxCheck(term) >= 0)
      ; // clear out queue by receiving all available 
  fdserial_txFlush(term);

  if(id > 0) cogstop(getStopCOGID(id));
  
  free((void*)fdp->buffptr);
  free((void*)fdp);
  free(term);
  term = 0;
}

/*
 * checks if anything is in the tx queue
 */
int fdserial_txEmpty(fdserial *term)
{
  volatile fdserial_st* fdp = (fdserial_st*) term->devst;
  return fdp->tx_tail == fdp->tx_head;
}

/*
 * Gets a byte from the receive queue if available
 * Function does not block. We move rxtail after getting char.
 * @returns receive byte 0 to 0xff or -1 if none available 
 */
int fdserial_rxCheck(fdserial *term)
{
  int rc = -1;
  volatile fdserial_st* fdp = (fdserial_st*) term->devst;
  volatile char* rxbuf = (volatile char*) fdp->buffptr;  // rx buff starts at offset 0

  if(fdp->rx_tail != fdp->rx_head)
  {
      rc = rxbuf[fdp->rx_tail];
      fdp->rx_tail = (fdp->rx_tail+1) & FDSERIAL_BUFF_MASK;
  }
  return rc;
}

/*
 * Wait for a byte from the receive queue. blocks until something is ready.
 * @returns received byte 
 */
int fdserial_rxChar(fdserial *term)
{
  int rc = fdserial_rxCheck(term);
  while(rc < 0)
      rc = fdserial_rxCheck(term);
  return rc;
}

/*
 * tx sends a byte on the transmit queue.
 * @param txbyte is byte to send. 
 */
int fdserial_txChar(fdserial *term, int txbyte)
{
  int rc = -1;
  volatile fdserial_st* fdp = (fdserial_st*) term->devst;
  volatile char* txbuf = (volatile char*) fdp->buffptr + FDSERIAL_BUFF_MASK+1;

  while(fdp->tx_tail == ((fdp->tx_head+1) & FDSERIAL_BUFF_MASK))
      ; // wait for queue to be empty
  txbuf[fdp->tx_head] = txbyte;
  fdp->tx_head = (fdp->tx_head+1) & FDSERIAL_BUFF_MASK;
  if(fdp->mode & FDSERIAL_MODE_IGNORE_TX_ECHO)
      rc = fdserial_rxChar(term); // why not rxcheck or timeout ... this blocks for char
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
