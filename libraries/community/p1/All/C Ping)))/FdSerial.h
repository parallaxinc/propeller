/**
 * @file FdSerial.h
 * Full Duplex Serial adapter API definition.
 *
 * Copyright (c) 2008, Steve Denson
 * See end of file for terms of use.
 */
#ifndef __FDSerial__
#define __FDSerial__

/**
 * Defines buffer length. hard coded in asm driver ... s/b bigger
 */
#define FDSERIAL_BUFF_MASK 0xf

/**
 * Defines mode bits
 *   mode bit 0 = invert rx
 *   mode bit 1 = invert tx
 *   mode bit 2 = open-drain/source tx
 *   mode bit 3 = ignore tx echo on rx
 */
#define FDSERIAL_MODE_INVERT_RX 1
#define FDSERIAL_MODE_INVERT_TX 2
#define FDSERIAL_MODE_OPENDRAIN_TX 4
#define FDSERIAL_MODE_IGNORE_TX_ECHO 8

/**
 * Defines FdSerial interface struct
 * 9 contiguous longs + buffers
 */
typedef struct FdSerial_struct
{
    int rx_head;   // receive queue head
    int rx_tail;   // receive queue tail
    int tx_head;   // transmit queue head
    int tx_tail;   // transmit queue tail
    int rx_pin;    // recieve pin
    int tx_pin;    // transmit pin
    int mode;      // interface mode
    int ticks;     // clkfreq / baud
    int buffptr;   // pointer to rx buffer
} FdSerial_t;

/**
 * start initializes and starts native assembly driver in a cog. 
 * @param rxpin is pin number for receive input
 * @param txpin is pin number for transmit output
 * @param mode is interface mode
 * @param baudrate is frequency of bits ... 115200, 57600, etc...
 * @returns non-zero on success
 */
int FdSerial_start(int rxpin, int txpin, int mode, int baudrate);
/**
 * stop stops the cog running the native assembly driver 
 */
void FdSerial_stop(void);
/**
 * rxflush empties the receive queue 
 */
void FdSerial_rxflush(void);
/**
 * rxcheck gets a byte from the receive queue if available
 * function does not block.
 * @returns receive byte 0 to 0xff or -1 if none available 
 */
int FdSerial_rxcheck(void);
/**
 * rxtime gets a byte from the receive queue if available by timeout
 * function blocks if no recieve for ms timeout.
 * @param ms is number of milliseconds to wait for a char
 * @returns receive byte 0 to 0xff or -1 if none available 
 */
int FdSerial_rxtime(int ms);
/**
 * rx waits for a byte from the receive queue. blocks until somehting is ready
 * @returns received byte 
 */
int FdSerial_rx(void);
/**
 * tx sends a byte on the transmit queue.
 * @param txbyte is byte to send. 
 * @returns waits for and returns received byte if mode is 8 
 */
int FdSerial_tx(int txbyte);
/**
 * tx sends a string on the transmit queue.
 * @param stringptr is the null terminated string to send. 
 */
void FdSerial_str(char* stringptr);
/**
 * dec prints a string representation of a decimal number to output
 * @param value is number to print. 
 */
void FdSerial_dec(int value);
/**
 * dec prints a string representation of a hexadecimal number to output
 * @param value is number to print. 
 * @param digits is number of characters to print. 
 */
void FdSerial_hex(int value, int digits);
/**
 * dec prints a string representation of a binary number to output
 * @param value is number to print. 
 * @param digits is number of characters to print. 
 */
void FdSerial_bin(int value, int digits);

#endif 

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