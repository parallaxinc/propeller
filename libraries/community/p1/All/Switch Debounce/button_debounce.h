//*********************************************************************************
// State Button Debouncer - Platform Independent
// 
// Revision: 1.6
// 
// Description: Debounces buttons on a single port being used by the application.
// This module takes what the signal on a GPIO port is doing and removes
// the oscillations caused by a bouncing button and tells the application if
// the button(s) are debounced. This algorithm is robust against noise if the 
// amount of allowable debouncing states is adequate. Below is an example of how 
// the button debouncer would work in practice in relation to a single button:
// 
// Real Signal:     0011111111111110000000000000011111111111111111110000000000
// Bouncy Signal:   0010110111111111010000000000001010111011111111110101000000
// Debounced Sig:   0000000000000011000000000000000000000000000001110000000000
// 
// The debouncing algorithm used in this library is based partly on Jack
// Ganssle's state button debouncer example shown in, "A Guide to Debouncing" 
// Rev 4. http://www.ganssle.com/debouncing.htm
// 
// Revisions can be found here:
// https://github.com/tcleg
// 
// Copyright (C) 2014 Trent Cleghorn , <trentoncleghorn@gmail.com>
// 
//                                  MIT License
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//*********************************************************************************/

// 
// Header Guard
// 

#ifndef BUTTON_DEBOUNCER_H
#define BUTTON_DEBOUNCER_H

                        // Binary Equivalent
#define BUTTON_PIN_0 (0x0001) // 00000001
#define BUTTON_PIN_1 (0x0002) // 00000010
#define BUTTON_PIN_2 (0x0004) // 00000100
#define BUTTON_PIN_3 (0x0008) // 00001000
#define BUTTON_PIN_4 (0x0010) // 00010000
#define BUTTON_PIN_5 (0x0020) // 00100000
#define BUTTON_PIN_6 (0x0040) // 01000000
#define BUTTON_PIN_7 (0x0080) // 10000000

//*********************************************************************************
// Headers
//*********************************************************************************/
#include <propeller.h>  // Added to original to accommodate Parallax Propeller .
                        // converts UINT_8t etc


// 
// C Binding for C++ Compilers
// 
#ifdef __cplusplus
extern "C"
{
#endif

//*********************************************************************************
// Macros and Globals
//*********************************************************************************/

// NUM_BUTTON_STATES should be greater than 0 and less than or equal to 255.
// The default of 8 is a roundabout good number of states to have. At a practical 
// minimum, the number of button states should be at least 3. Each button state 
// consumes 1 byte of RAM.
// If this number is large, the Debouncer instantiation will consume 
// more RAM and take more time to debounce but will reduce the chance of having an 
// incorrectly debounced button. If this is small, the Debouncer instantiation 
// will consume less RAM and take less time to debounce but will be more prone 
// to incorrectly determining button presses and releases.

#ifndef NUM_BUTTON_STATES
#define NUM_BUTTON_STATES       8
#endif

typedef struct
{
    // 
    // Holds the states that the particular port is transitioning through
    // 
    uint8_t state[NUM_BUTTON_STATES];
    
    // 
    // Keeps up with where to store the next port info in the state array
    // 
    uint8_t index;
    
    // 
    // The currently debounced state of the pins
    // 
    uint8_t debouncedState;
    
    // 
    // The pins that just changed debounced state
    // 
    uint8_t changed;
    
    // 
    // Pullups or pulldowns are being used 
    // 
    uint8_t pullType;
}
Debouncer;

//*********************************************************************************
// Prototypes
//*********************************************************************************/

// 
// Button Debouncer Initialize
// Description:
//      Initializes the Debouncer instantiation. Should be called at least once
//      on a particular instantiation before calling ButtonProcess on the
//      instantiation.
// Parameters:
//      port - The address of a Debouncer instantiation.
//      pulledUpButtons - Specifies whether pullups or pulldowns are being used on 
//          the port pins. This is the ORed BUTTON_PIN_* 's that are being
//          pulled up. Otherwise, the debouncer assumes that the other
//          buttons are being pulled down. A 0 bit means pulldown.
//          A 1 bit means pullup. For example, 00010001 means that
//          button 0 and button 4 are both being pulled up. All other
//          buttons have pulldowns if they represent buttons.
// Returns:
//      None
// 
extern void ButtonDebounceInit(Debouncer *port, uint8_t pulledUpButtons);

// 
// Button Process
// Description:
//      Does the calculations on debouncing the buttons on a particular
//      port. This function should be called on a regular interval by the
//      application such as every 0.5 milliseconds or 5 milliseconds. 
// Parameters:
//      port - The address of a Debouncer instantiation.
//      portStatus - The particular port's status expressed as one 8 bit byte.
// Returns:
//      None
// 
extern void ButtonProcess(Debouncer *port, uint8_t portStatus);

// 
// Button Pressed
// Description:
//      Checks to see if a button(s) were immediately pressed. 
// Parameters:
//      port - The address of a Debouncer instantiation.
//      GPIOButtonPins - The particular bits corresponding to the button pins.
//          The ORed combination of BUTTON_PIN_*.
// Returns:
//      The port pin buttons that have just been pressed. For example, if
//      (BUTTON_PIN_5 | BUTTON_PIN_0) is passed as a parameter for 
//      GPIOButtonPins and if the byte that is returned expressed in binary is 
//      00000001, it means that button 0 (bit 0) has just been pressed while
//      button 5 (bit 5) has not been at the moment though it may have been
//      previously.
// 
extern uint8_t ButtonPressed(Debouncer *port, uint8_t GPIOButtonPins);

// 
// Button Released
// Description:
//      Checks to see if a button(s) were immediately released. 
// Parameters:
//      port - The address of a Debouncer instantiation.
//      GPIOButtonPins - The particular bits corresponding to the button pins.
//          The ORed combination of BUTTON_PIN_*.
// Returns:
//      The port pin buttons that have just been released. For example, if
//      (BUTTON_PIN_5 | BUTTON_PIN_0) is passed as a parameter for 
//      GPIOButtonPins and if the byte that is returned expressed in binary is 
//      00000001, it means that button 0 (bit 0) has just been released while
//      button 5 (bit 5) has not been at the moment though it may have been
//      previously.
// 
extern uint8_t ButtonReleased(Debouncer *port, uint8_t GPIOButtonPins);

// 
// Button Current
// Description:
//      Gets which buttons are currently being pressed.
// Parameters:
//      port - The address of a Debouncer instantiation.
//      GPIOButtonPins - The particular bits corresponding to the button pins.
//          The ORed combination of BUTTON_PIN_*.
// Returns:
//      The port pins the are currently being debounced. For example, if
//      (BUTTON_PIN_5 | BUTTON_PIN_1) is passed as a parameter for 
//      GPIOButtonPins and if this function returns 00100000 in binary then 
//      button 1 (bit 1) is not currently being pressed and button 5 (bit 5) 
//      is currently being pressed while the other buttons (if they are 
//      buttons) are being masked out.
// 
extern uint8_t ButtonCurrent(Debouncer *port, uint8_t GPIOButtonPins);
                                       
int input(int pin);                            // input function definition
                                       

// 
// End of C Binding
// 
#ifdef __cplusplus
}
#endif

#endif  // BUTTON_DEBOUNCER_H
