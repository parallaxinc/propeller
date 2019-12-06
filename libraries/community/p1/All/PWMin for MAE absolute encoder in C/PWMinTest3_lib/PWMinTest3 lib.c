/*
  Test program for MAE PWM measurement
  
*/
#include "simpletools.h"                      // Include simple tools
#include "MAElib.h" 


// screen functions
home(){ printf("%c",1);}    // home cursor
cls(){ printf("%c",0);}     // clear screen
gotoxy(int x, int y) {
  printf("%c%c%c",2,x,y);
}  
  
int main() {
  int PulseLen;
  int state = MAEpinstate;       // detect pin state 1 in pwm
  int cycletime = MAEcycletime;  // 4000 us
  int pin = 5;                   // the pin where the MAE is connected   
 
  cls();

  while(1) {
    home();
    PulseLen =  pulse_in_timeout(pin, state, cycletime);
    printf(" MAE %d %d MAEtime %d MAEmaxtm %d MAEcntr %d %c\n", 
             PulseLen, mae1.pulsetime, mae1.meastime, mae1.maxmeastime, mae1.meascntr ,11);  
  } // while{1)
} // main  

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