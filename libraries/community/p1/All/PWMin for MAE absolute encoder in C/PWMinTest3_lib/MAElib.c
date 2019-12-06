/* MAE absolute encoder pulse width measurement V1.0
 * H.J. Kiela Opteq Mechatronics Mar 2015
 * Implementation of MEA pulse width measurement for the magnetic absolute encoder of US digital
 * Uses a modified version of the simple tools pwmin as PWM time 
 * of the MAE as the 4ms cycle of the MAE really goes from 0 to 4000 us width.
 * The standard pwmin is not able to handle this.
 * 
 * NB: Has been made for 80 MHz only so far
*/

#include "simpletools.h"                      // Include simple tools
#include "MAElib.h" 

// ******************** pulse_in_timeout *********************** 
// Measurement is able to deal with pwm times between 0 us and 4000 us (cycletime).
 
long pulse_in_timeout(int pin, int state, int cycletime)     // pulseIn function definition
{
  
int PulseState = 1; 

  int debugindex = 0;
  int OK = 1;    // boolean set True for a start
  
  unsigned int tf = cycletime * 1.4 * 80; // _clkfreq/1000;  // Calc time out freq
  
  long tPulse;
  int ctr = ((8 + ((!state & 1) * 4)) << 26) + pin;  // CNTR as Pos detector

  input(pin);  // pin as input
  
 
  long unsigned NextCNT;         // sample clock counter for time out
  long unsigned cntr=0;
  long unsigned t1=0;
  long unsigned t2=0;
  

  PulseState = 2; 
// =================
  t1 = CNT;
  NextCNT = CNT + tf;                      // sample clock counter for time out


  while((get_state(pin) == state) && OK) {  // wait till pin 0 and no timeout
    OK = (CNT < NextCNT);  // check if time out occurred
    cntr++;
  } // while

  if (OK) {
      PulseState = 4;  // Pin changed to 0 or is 0, move to next stage
      
      CTRA = ctr;      // Setup counter
      FRQA = 1;        // timer increment
      PHSA = 0;        // reset counter

    } // if (OK)     
  else PulseState = 14;          // Time out, signal at 1 at 100% 

// =================
  if (PulseState == 4) {          // Get pulse width 
//    t1 = CNT;
    NextCNT = CNT + tf;           // sample clock counter for time out
    cntr=0;

    while((PHSA == 0) &&  OK) {    // check is counter started on pin = 1
      OK = (CNT < NextCNT);       // check if time out occurred
      cntr++;
    } // while      
  
    if (OK) PulseState = 5;       // Pin changed to 1
    else PulseState = 15;         // Time out, signal stayed at 0 at 0% 
  } // (PulseState = 4)    


  if (PulseState == 5) {          // Wait for pin to become 0 again
//    t1 = CNT;
    cntr=0;
    NextCNT = CNT + tf;                      // sample clock counter for time out
    while((get_state(pin) == state) && OK) {  // Wait for pin to become 0 again
//      OK = (CNT - t < tf);
      OK = (CNT < NextCNT);
      cntr++;
    } // while     

    if (OK) {
      PulseState = 6;         // Pin changed to 0 again, valid measurement
      CTRA = 0;               // Stop counter
      tPulse = PHSA / 8;      // Read actual count in 0.1 us
    } // if      
    else PulseState = 16;     // Time out, signal stayed at 1 at 100% 

  } // (PulseState = 5)     

 // t1 = CNT;
  if (PulseState == 14) {PulseState = 24; tPulse = 40000;}
  if (PulseState == 16) {PulseState = 26; tPulse =  40000;}
  if (PulseState == 15) {PulseState = 25; tPulse =  1;}

  mae1.meascntr++;
  mae1.meastime = CNT - t1;
  mae1.pulsetime = tPulse; // Actual pulse time in 0.1 us.
  if (mae1.maxmeastime < mae1.meastime) mae1.maxmeastime = mae1.meastime;
  

  return tPulse;          // return value to caller. Actual pulse time in 0.1 us.
   
     
}  // pulse_in_timeout

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