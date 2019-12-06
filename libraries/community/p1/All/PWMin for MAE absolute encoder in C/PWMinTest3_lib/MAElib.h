/* Header file for MAE absolute encoder pulse width measurement V1.0
 * H.J. Kiela Opteq Mechatronics Mar 2015
 * Implementation of MEA pulse widt measurement
 * Uses a modified version of the simple tools pwmin as PWM time 
 * of the MAE as the 4ms cycle of the MAE really goes from 0 to 4000 us width.
 * The standard pwmin is not able to handle this.
 * 
 * The use of teh state engine is a simpel way to implement this measurement. 
 * Nested if then else could work as well and probable gain a few us. 
 * The state engine is easyer to understand and robust
 * 
 * The record holds some extra data to monitor measuring time
 * As resources in a cog are finite, we have not made an object, just a fixed structure.
 * To speed up meaurement, a second state engine could be implemented for CNTRB
*/

#define MAEcycletime 4000   // The MAE has a 4 ms cycle time and 0% to 100% pwm per rotation
#define MAEpinstate 1;      // Pin high value should be detected 

typedef struct pulsein_s {  // puls width measurement record
  int meastime;             // measure time un us
  int maxmeastime;          // Max measuring time since reset
  int meascntr;             // Counter to signal life
  int pulsetime;            // Actual pulse time in 0.1 us. Same as return result
  int cycletime;            // The cycle time of the PWM
} pulsin_t;

struct pulsein_s mae1;  

long pulse_in_timeout(int pin, int state, int cycletime);


/*
////////////////////////////////////////////////////////////////////////////////////////////
//                                TERMS OF USE: MIT License
////////////////////////////////////////////////////////////////////////////////////////////
// Permission is hereby granted, free of charge, to any person obtaining a copy of this 
// software and associated documentation files (the "Software"), to deal in the Software 
// without restriction, including without limitation the rights to use, copy, modify, merge,
// publish, distribute, sublicense, and/or sell copies of the Software, and to permit 
// persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
// PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
// FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
// DEALINGS IN THE SOFTWARE.
////////////////////////////////////////////////////////////////////////////////////////////
*/