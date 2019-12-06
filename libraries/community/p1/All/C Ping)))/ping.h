/**
 * @file ping.h
 * Ping driver header & API descriptions.
 * Copyright (c) 2009, Steve Denson
 * See end of file for MIT license terms.
 */

#ifndef __PING_H__
#define __PING_H__

/**
 * Ping is an ultrasonic audio range detector produced by Parallax, inc.
 * Ping mm, cm, dm, inch, foot distance functions return one-way trip distances.
 *
 * Routines in this module measure the ping output pulse width to derive range.
 * Measurement precision varies with distance. Coarse measurements will be less accurate.
 * Interface between propeller and ping should have a 1.8K to 2.2K ohm resistor in series.
 * Propeller clock must be >= 1MHz for accurate measurements. 
 */

/**
 * Defines constant used to derive clock period PER ns = CLK_PER_CONST/CLKFREQ
 */
#define PING_CLK_PER_CONST 1000000
/**
 * Defines speed of sound at sea level in inches per second
 */
#define PING_SOS_IN_PER_SEC 13397
/**
 * Defines speed of sound at sea level in feet per second
 */
#define PING_SOS_FT_PER_SEC 1116
/**
 * Defines speed of sound at sea level in mm per second
 */
#define PING_SOS_MM_PER_SEC 340290
/**
 * Defines speed of sound at sea level in cm per second
 */
#define PING_SOS_CM_PER_SEC 34029
/**
 * Defines speed of sound at sea level in dm per second
 */
#define PING_SOS_DM_PER_SEC 3403


/**
 * Measure ping one way distance in clock ticks with C function
 * @param pin - propeller pin number
 * @return <= zero on error or positive number of clock ticks passed from tx to rx
 */
long ping_clockc(int pin);

/**
 * Measure ping one way distance in clock ticks with ASM function
 * @param pin - propeller pin number
 * @return <= zero on error or positive number of clock ticks passed from tx to rx
 */
long ping_clocks(int pin);

/**
 * Measure ping distance in milli-meters.
 * @param pin - propeller pin number
 * @return <= zero on error or positive number of mm
 */
long ping_mm(int pin);

/**
 * Measure ping distance in centi-meters.
 * @param pin - propeller pin number
 * @return <= zero on error or positive number of cm
 */
long ping_cm(int pin);

/**
 * Measure ping distance in deci-meters.
 * @param pin - propeller pin number
 * @return <= zero on error or positive number of dm
 */
long ping_dm(int pin);

/**
 * Measure ping distance in inches.
 * @param pin - propeller pin number
 * @return <= zero on error or positive number of inches
 */
long ping_inch(int pin);

/**
 * Measure ping distance in feet.
 * @param pin - propeller pin number
 * @return <= zero on error or positive number of feet
 */
long ping_foot(int pin);

#endif
// __PING_H__

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