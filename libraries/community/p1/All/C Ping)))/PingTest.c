/**
 * @file PingTest.c
 * Ping driver test application.
 * Copyright (c) 2009, Steve Denson
 * See end of file for MIT license terms.
 */

#include <stdio.h>
#include <propeller.h>
#include "FdSerial.h"
#include "ping.h"

/**
 * start serial port
 * print ping measurements
 */
void main(void)
{
    int time = 0;
    int dist = 0;
    int pingpin = 19;

    FdSerial_start(31,30,0,115200);
    msleep(500); // wait for user console to start

    while(1) {
        printf("\r\nPing Measurements ... ");
        printf("%d mm, ", ping_mm(pingpin));
        printf("%d cm, ", ping_cm(pingpin));
        printf("%d dm, ", ping_dm(pingpin));
        printf("%d in, ", ping_inch(pingpin));
        printf("%d ft", ping_foot(pingpin));
        msleep(5);
    }

    while(1);
}

/**
 * define putchar for printf to use
 */
int putchar(char val)
{
    FdSerial_tx(val);
    return 0;
}


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