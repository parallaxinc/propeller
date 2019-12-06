/**
 * @file ping.c
 * Ping driver implementation. See ping.h for API descriptions.
 * Distance functions return rounded one-way distances.
 * Copyright (c) 2009, Steve Denson
 * See end of file for MIT license terms.
 */
#include <propeller.h>
#include "ping.h"

/*
 * Measure ping distance in clock ticks.
 * See header for API description.
 */
long ping_clockc(int pin)
{
    long t0,t1;
    int mask = 1 << pin;
    asm("or outa, %mask");      // make sure bit is high
    asm("or dira, %mask");      // set bit to output
    msleep(1);                  // send 1ms pulse ... minimum pw = 2.0us
    asm("andn outa, %mask");    // make sure bit is low
    asm("andn dira, %mask");    // clear bit to input
    asm("waitpeq %mask, %mask");
    asm("mov %t0, cnt");        // bit high now
    asm("waitpne %mask, %mask");
    asm("mov %t1, cnt");        // bit low now
    return (t1-t0)>>1;          // number of clock ticks passed one way
}

/*
 * private conversion function
 */
static long ping_convert(int pin, long units)
{
    long rc;
	long clocks;
    long clkdiv  = (CLKFREQ/PING_CLK_PER_CONST);

	clocks = ping_clocks(pin);	// use asm version
	//clocks = ping_clockc(pin); // use c version
	rc = clocks/clkdiv;
    rc = rc*units/PING_CLK_PER_CONST;
    return rc;
}

/*
 * Measure ping distance in milli-meters.
 * See header for API description.
 */
long ping_mm(int pin)
{
    return ping_convert(pin, PING_SOS_MM_PER_SEC); 
}

/*
 * Measure ping distance in centi-meters.
 * See header for API description.
 */
long ping_cm(int pin)
{
    return ping_convert(pin, PING_SOS_CM_PER_SEC); 
}

/*
 * Measure ping distance in deci-meters.
 * See header for API description.
 */
long ping_dm(int pin)
{
    return ping_convert(pin, PING_SOS_DM_PER_SEC); 
}

/*
 * Measure ping distance in inches.
 * See header for API description.
 */
long ping_inch(int pin)
{
    return ping_convert(pin, PING_SOS_IN_PER_SEC); 
}

/*
 * Measure ping distance in feet.
 * See header for API description.
 */
long ping_foot(int pin)
{
    return ping_convert(pin, PING_SOS_FT_PER_SEC); 
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