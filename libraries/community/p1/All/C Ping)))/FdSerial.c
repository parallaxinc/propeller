/**
 * @file FdSerial.c
 * Full Duplex Serial adapter module.
 *
 * Copyright (c) 2008, Steve Denson
 * See end of file for terms of use.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <propeller.h>

#include "FdSerial.h"
#include "FdSerial_Array.h"

static long  gFdSerialCog = 0;  //cog flag/id
static long  gclkfreq;          // clock frequency

FdSerial_t gFdSerial;    // fdserial descriptor

/* 
 * These buffers must be contiguous. Their size must match the asm expectation.
 * Asm also expects the address of txbuff to be after rxbuff.
 * Apparently the C compiler "allocates" this memory in reverse order.
 * Using a struct would correct it, but for now let's just reverse the entry.
 */
char  gFdSerial_txbuff[FDSERIAL_BUFF_MASK+1];  // transmit buffer
char  gFdSerial_rxbuff[FDSERIAL_BUFF_MASK+1];  // receive buffer

/**
 * start initializes and starts native assembly driver in a cog.
 * @param rxpin is pin number for receive input
 * @param txpin is pin number for transmit output
 * @param mode is interface mode. see header FDSERIAL_MODE_...
 * @param baudrate is frequency of bits ... 115200, 57600, etc...
 * @returns non-zero on success
 */
int FdSerial_start(int rxpin, int txpin, int mode, int baudrate)
{
    int id = 0;
    // clkfreq is internal cpu clock frequency (80000000 for 5M*pll16x)
    int clkfreq = CLKFREQ;

    FdSerial_stop();
    memset(&gFdSerial, 0, sizeof(FdSerial_t));
    gFdSerial.rx_pin = rxpin; // recieve pin
    gFdSerial.tx_pin = txpin; // transmit pin
    gFdSerial.mode   = mode;  // interface mode
    gclkfreq = clkfreq;
    gFdSerial.ticks = clkfreq/baudrate; // baud
    gFdSerial.buffptr = (int)&gFdSerial_rxbuff[0];
    id = cognew_native((void*)FdSerial_Array, (void*)&gFdSerial) + 1;
    gFdSerialCog = id;
    wait(1000000); // give cog chance to load
    return id;
}

/**
 * stop stops the cog running the native assembly driver 
 */
void FdSerial_stop(void)
{
    int id = gFdSerialCog - 1;
    if(gFdSerialCog > 0) {
        asm("cogstop %id");
    }
}

/**
 * rxflush empties the receive queue 
 */
void FdSerial_rxflush(void)
{
    while(FdSerial_rxcheck() >= 0)
        ; // clear out queue by receiving all available 
}

/**
 * Gets a byte from the receive queue if available
 * Function does not block. We move rxtail after getting char.
 * @returns receive byte 0 to 0xff or -1 if none available 
 */
int FdSerial_rxcheck(void)
{
    int rc = -1;
    FdSerial_t* p = &gFdSerial;
    if(p->rx_tail != p->rx_head)
    {
        rc = gFdSerial_rxbuff[p->rx_tail];
        p->rx_tail = (p->rx_tail+1) & FDSERIAL_BUFF_MASK;
    }
    return rc;
}

/**
 * Get a byte from the receive queue if available within timeout period.
 * Function blocks if no recieve for ms timeout.
 * @param ms is number of milliseconds to wait for a char
 * @returns receive byte 0 to 0xff or -1 if none available 
 */
int FdSerial_rxtime(int ms)
{
    int rc = -1;
    int t0 = 0;
    int t1 = 0;
    asm("mov %t0, cnt");
    do {
        rc = FdSerial_rxcheck();
        asm("mov %t1, cnt");
        if((t1 - t0)/(gclkfreq/1000) > ms)
            break;
    } while(rc < 0);
    return rc;
}

/**
 * Wait for a byte from the receive queue. blocks until something is ready.
 * @returns received byte 
 */
int FdSerial_rx(void)
{
    int rc = FdSerial_rxcheck();
    while(rc < 0)
        rc = FdSerial_rxcheck();
    return rc;
}

/**
 * tx sends a byte on the transmit queue.
 * @param txbyte is byte to send. 
 */
int FdSerial_tx(int txbyte)
{
    int rc = -1;
    char* txbuff = gFdSerial_txbuff;
    FdSerial_t* p = &gFdSerial;

    while(p->tx_tail != p->tx_head) // wait for queue to be empty
        ;

    txbuff[p->tx_head] = txbyte;
    p->tx_head = (p->tx_head+1) & FDSERIAL_BUFF_MASK;

    if(p->mode & FDSERIAL_MODE_IGNORE_TX_ECHO)
        rc = FdSerial_rx(); // why not rxcheck or timeout ... this blocks for char

    return rc;
}

#ifndef FDS_DISABLE_OUTS
/**
 * tx sends a string on the transmit queue.
 * @param sp is the null terminated string to send. 
 */
void FdSerial_str(char* sp)
{
    while(*sp)
        FdSerial_tx(*(sp++));
}

/**
 * dec prints a string representation of a decimal number to output
 * @param value is number to print. 
 */
void FdSerial_dec(int value)
{
    char b[128];
    itoa(b, value, 10);
    FdSerial_str(b);
}

/**
 * hex prints a string representation of a hexadecimal number to output
 * @param value is number to print. 
 * @param digits is number of characters to print. 
 */
void FdSerial_hex(int value, int digits)
{
    int ndx;
    char hexlookup[] =
    {
        '0', '1', '2', '3', '4', '5', '6', '7',
        '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'
    };
    while(digits-- > 0) {
        ndx = (value >> (digits<<2)) & 0xf;
        FdSerial_tx(hexlookup[ndx]);
    }
}

/**
 * bin prints a string representation of a binary number to output
 * @param value is number to print. 
 * @param digits is number of characters to print. 
 */
void FdSerial_bin(int value, int digits)
{
    int bit = 0;
    while(digits-- > 0) {
        bit = (value >> digits) & 1;
        FdSerial_tx(bit + '0');
    }
}
#endif
// FDS_DISABLE_OUTS

/*
+------------------------------------------------------------------------------------------------------------------------------+
¦                                                   TERMS OF USE: MIT License                                                  ¦                                                            
+------------------------------------------------------------------------------------------------------------------------------¦
¦Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    ¦ 
¦files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    ¦
¦modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software¦
¦is furnished to do so, subject to the following conditions:                                                                   ¦
¦                                                                                                                              ¦
¦The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.¦
¦                                                                                                                              ¦
¦THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          ¦
¦WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         ¦
¦COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   ¦
¦ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         ¦
+------------------------------------------------------------------------------------------------------------------------------+
*/
