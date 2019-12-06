/**
 * @file fdserial.h
 *
 * @author Steve Denson, with naming conventions supplied by Parallax.
 *
 * @copyright
 * Copyright (c) 2008-2013, Steve Denson, all Rights MIT Licensed.
 *
 * @brief This library supports creating and managing one or more full duplex
 * serial connections with peripheral devices.  The pointer returned when a
 * connection is opened can be used to identify the connection for other
 * calls with fdserial parameter types in this library.  The identifier can
 * also be used to identify the serial connection for higher level formatted
 * text transmit/receive functions with text_t parameter types in the
 * simpletext library.  
 * 
 * @par Core Usage 
 * Each call to fdserial_open launches an additional cog that can support
 * an additional UART communication process.
 *
 * @par Memory Models
 * Use with CMM, LMM, or XMMC. 
 *
 * @version 0.85
 *
 * @par Help Improve this Library
 * Please submit bug reports, suggestions, and improvements to this code to
 * editor@parallax.com.
 */
 
 
#ifndef __FDSerial_H
#define __FDSerial_H

#include "simpletext.h"

#ifdef __cplusplus
extern "C"
{
#endif

typedef text_t fdserial;

/**
 * Defines buffer length. hard coded into asm driver ... s/b bigger
 */
#define FDSERIAL_BUFF_MASK 0x3f

/**
 * All mode bits set to 0 for non-inverted asynchronous serial communication.
 */
#define FDSERIAL_MODE_NONE 0

/**
 * Mode bit 0 can be set to 1 for inverted signal to rxpin.
 */
#define FDSERIAL_MODE_INVERT_RX 1

/**
 * Mode bit 1 can be set to 1 for inverted signal from txpin.
 */
#define FDSERIAL_MODE_INVERT_TX 2

/**
 * Mode bit 2 can be set to 1 to open collector/drain txpin communication with a
 * pull-up resistor on the line.
 */
#define FDSERIAL_MODE_OPENDRAIN_TX 4

/**
 * Mode bit 3 can be set to 1 to ignore copy of txpin's signal if received by rxpin.
 */
#define FDSERIAL_MODE_IGNORE_TX_ECHO 8

/**
 * Defines fdserial interface struct of 9 contiguous longs + buffers
 */
typedef struct fdserial_struct
{
    int  rx_head;   /* receive buffer head */
    int  rx_tail;   /* receive buffer tail */
    int  tx_head;   /* transmit buffer head */
    int  tx_tail;   /* transmit buffer tail */
    int  rx_pin;    /* recieve pin */
    int  tx_pin;    /* transmit pin */
    int  mode;      /* interface mode */
    int  ticks;     /* clkfreq / baud */
    char *buffptr;  /* pointer to rx buffer */
} fdserial_st;

/**
 * @brief Open a full duplex serial connection. 
 *
 * @param rxpin Serial receive input pin number.
 *
 * @param txpin Serial transmit output pin number. 
 *
 * @param mode Set/clear bits to define mode:
 *   mode bit 0 = invert rx
 *   mode bit 1 = invert tx
 *   mode bit 2 = open-drain/source tx
 *   mode bit 3 = ignore tx echo on rx
 * 
 * @param baudrate Rate binary values are transmitted, like 115200, 57600,..., 
 * 9600 etc.
 *
 * @returns fdserial pointer for use as an identifier for fdserial 
 * and simpletext library functions that have fdserial or text_t 
 * parameter types.  
 */
fdserial *fdserial_open(int rxpin, int txpin, int mode, int baudrate);

/**
 * @brief Stop stops the cog running the native assembly driver 
 * 
 * @param *term Device ID returned by fdserial_open. 
 */
void fdserial_close(fdserial *term);

/**
 * @brief Gets a byte from the receive buffer if available, but does
 * not wait if there's nothing in the buffer.
 * 
 * @param *term Device ID returned by fdserial_open. 
 * 
 * @returns Oldest byte (0 to 255) in receive buffer, or -1 if buffer is
 * empty. 
 */
int  fdserial_rxCheck(fdserial *term);

/**
 * @brief Empties the receive buffer.
 * 
 * @param *term Device ID returned by fdserial_open. 
 */
void fdserial_rxFlush(fdserial *term);

/**
 * @brief Check if a byte is ready in the receive buffer.
 * 
 * @param *term Device ID returned by fdserial_open. 
 * 
 * @returns Non-zero if one or more bytes are waiting in the receive buffer, 
 * or 0 if it's empty.  
 */
int  fdserial_rxReady(fdserial *term);

/**
 * @brief Gets a byte from the receive buffer if available, or wait for
 * up to timeout ms to receive a byte. 
 * 
 * @param *term Device ID returned by fdserial_open. 
 * 
 * @param ms is number of milliseconds to wait for a char
 * 
 * @returns receive byte 0 to 0xff or -1 if none available 
 */
int  fdserial_rxTime(fdserial *term, int ms);

/**
 * @brief Get a byte from the receive buffer, or if it's emtpy, wait until 
 * a byte is received. 
 * 
 * @param *term Device ID returned by fdserial_open. 
 * 
 * Oldest byte (0 to 255) in receive buffer
 */
int  fdserial_rxChar(fdserial *term);

/**
 * @brief Get number of bytes available in the receive buffer,
 * however queue overflows can not be detected at this time.
 * @returns less than 1 if no bytes are available.
 */
int  fdserial_rxAvailable(fdserial *term);

/**
 * @brief Get a byte from the receive buffer without changing the pointers.
 * The function does not block.
 * @returns non-zero if a valid byte is available.
 */
int  fdserial_rxPeek(fdserial *term);

/**
 * @brief Send a byte by adding it to the transmit buffer.
 * 
 * @param *term Device ID returned by fdserial_open. 
 * 
 * @param txbyte is byte to send. 
 * 
 * @returns The byte that was sent, or returns the byte that was received
 * if mode bit 3 was set in the fdserial_open call.  
 */
int  fdserial_txChar(fdserial *term, int txbyte);

/**
 * @brief Check if the transmit buffer is empty.
 * 
 * @param *term Device ID returned by fdserial_open. 
 * 
 * @returns non-zero if transmit buffer is empty.
 */
int  fdserial_txEmpty(fdserial *term);

/**
 * @brief Remove any bytes that might be waiting in the transmit buffer.
 */
void fdserial_txFlush(fdserial *term);

#ifdef __cplusplus
}
#endif

#endif 
/* __FDSerial_H */


/**
 * @par TERMS OF USE: MIT License
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
