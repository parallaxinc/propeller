///
/// Button Debouncer Example
// 
// Description: 
// Waits for a button press on pins 2,3,or 4 to toggle an LEDs on pins 8,9,10. 
// All the switches are pulldown but they can be pull up or mixed.
// It can handle 8 switches with minimum effort and more with addition of a struct
// 
// This example can be compiled and used. Michael Forsyth <MichaelForsyth@protonmail.ch>
//
// This example exists to show the general
// operation of the library it happens to utilize. It only displays one
// general use case although more use cases may exist.
// The Libraries and header files were written by Trent Cleghorn.
// Copyright (C) 2014 Trent Cleghorn <trentoncleghorn@gmail.com>
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

/// This file ,Debounce_Example.c has been modified to suit the Parallax Propeller processor.
// It is deliberatley verbose to make it easy for the beginner. (A habit acquired teaching IT)
// It took me some time to understand what Trent Cleghorn wrote and how it worked.
// The only change made to the button_debounce.h was to add "#include <propeller.h>" That says 
// Trent Cleghorn deserves an A+ for his work.
// Thank You Trent!
// Michael Forsyth  MichaelForsyth@protonmail.ch


// Rough circuit for LEDs (>|)
//     p---->|----240 ohm---Vss
//     P---->|----240 ohm---Vss
//     p---->|----240 ohm---Vss

// pull up switch circuit
//     p------10k  ---- vdd
//         ꟾ
//         /-
//         ꟾ
//        vss   

#include "simpletools.h"  // Specific to Parallax
#include "simpletext.h"  // Specific to Parallax
#include "mstimer.h"  // Specific to Parallax
#include "button_debounce.h"
// If you have trouble building the project because it can't find the header files either use the
// project->Add library button or add the include path(-I) and the library path (-L) in the project manager.
// Hopefully in a future version of SimpleIDE it will not be necessary.



//Add additional ports if you need more than 8 buttons
//eg Debouncer port2;
Debouncer port1;
//THIS IS WHERE YOU NEED TO CUSTOMIZE.////////////////////////////////////////
//Change this to match pin(s) attached to switch
const int NoInPins = 3;    // This is the total number of buttons you are using.
const int InPin_No1 = 2;   //this is known as BUTTON_PIN_0
const int InPin_No2 = 3;   //this is known as BUTTON_PIN_1
const int InPin_No3 = 4;   //this is known as BUTTON_PIN_2
const int InPin_No4 = 0;   //this is known as BUTTON_PIN_3
const int InPin_No5 = 0;   //this is known as BUTTON_PIN_4
const int InPin_No6 = 0;   //this is known as BUTTON_PIN_5
const int InPin_No7 = 0;   //this is known as BUTTON_PIN_6
const int InPin_No8 = 0;   //this is known as BUTTON_PIN_7

// Output pins for LEDs or whatever else. Change No as required.Comment or delete unused ones

const int OutPin_No1 = 8;   
const int OutPin_No2 = 9;
const int OutPin_No3 = 10;

// 
//Reads the InPin registers declared in the input array and
//Returns the result in BUTTON_PIN No (binary)
//Written for the Parallax Propeller but may to useful to other processors.
unsigned char PortReadStates(const int NoInPins,int InputArray[])
     {
       int i;
       unsigned char result = 0;
       for (i=NoInPins ;i >0 ;i--)
       {
         result |= input(InputArray[i-1]);// loaded in reverse order
         result <<= 1;
       } 
       return result >>= 1;      
     } 


// Uses the return from ButtonPress, ButtonReleased,ButtonCurrent
// Returns the pin number(s). It is unlikely that two buttons will be processed at the same time.
// However if they are then return would be E.g 13 meaning input pins 1 and 3 are high                 
int WhichButton(uint8_t a,int InputArray[])
   {
      int result =0 ;
      unsigned char mask = BUTTON_PIN_0;
      int i;
      for (i=0;i < NoInPins;i++)
      {
       if(a & mask)
        {
          if (result ==0)
          {
           result = InputArray[i];
          }           
          else 
         {
            result *= 10; 
            result += InputArray[i];          
         }
       }         
       mask = mask <<1; 
      }//end for         
      
      return result;         
 }  //end whichbutton    

////////Finally we come to Main()//////////////////////////////////////////////////
int
main()
{

    uint32_t currentTime;
    uint32_t initialTime;

    // Modify the values below to suit.
    // add or delete as required
    set_direction(OutPin_No1,1);
    set_direction(OutPin_No2,1);             
    set_direction(OutPin_No3,1);
    low(OutPin_No1);
    low(OutPin_No2);
    low(OutPin_No3);
    
    
    //Array used to convert InPin_No to BUTTON_PINs and vv.

    int InputArray[8] = {InPin_No1,InPin_No2,InPin_No3,InPin_No4,InPin_No5,InPin_No6,InPin_No7,InPin_No8}; 
    //  useful variables
     unsigned char x,y,z;
    
    // Setup timer to generate an interrupt on a regular interval.
    // In this case, it will be every 1 millisecond.
    mstime_start();
    initialTime = mstime_get();
    //...
    
    // Initialize the button debouncer. Tell the debouncer which pins are pullups
    // For more than 1 pin has a pullup OR them together eg.(BUTTON_PIN_1 | BUTTON_PIN_2)
    // ButtonDebounceInit(&port1,BUTTON_PIN_1 | BUTTON_PIN_2 | BUTTON_PIN_3);  //these three are pullups
    ButtonDebounceInit(&port1,0);  // all are pull downs  

    
    while(1)
    {
        
        //  function to return currentTime in milliseconds
        currentTime = mstime_get();
        
        // Check when 1 millisecond has passed
        if(currentTime - initialTime >= 1)
        {
            // Save the current time for the next go around
            initialTime = currentTime;
            
            // checks all the buttons             
            ButtonProcess(&port1,PortReadStates(NoInPins,InputArray));

           //ask about button state Buttons. Can be OR'd together
           
            if(x = ButtonPressed(&port1, BUTTON_PIN_0 | BUTTON_PIN_1 | BUTTON_PIN_2))
            {
              
                print("button pressed %d\n",WhichButton(x,InputArray));
                // Turn an LED on or off
                switch (WhichButton(x,InputArray)){
                 case 2: high(OutPin_No1);  // on in this case
                    break;
                 case 3: high(OutPin_No2);
                    break;
                 case 4: high(OutPin_No3);
                    break;
               }//end switch  
               //as alternative to the above: use ButtonPressed(&port1,BUTTON_PIN_?)
               // for each BUTTON_PIN.               
            }
           if (y = ButtonReleased(&port1, BUTTON_PIN_0 | BUTTON_PIN_1 | BUTTON_PIN_2 ))
           //if (ButtonReleased(&port1,0))
            {
                print("button released %d\n",WhichButton(y,InputArray));
                // Turn an LED on or off
                switch (WhichButton(y,InputArray)){
                 case 2: low(OutPin_No1);  // off in this case
                    break;
                 case 3: low(OutPin_No2);
                    break;
                 case 4: low(OutPin_No3);
                    break;
              } //end switch                             
            }
            if (ButtonCurrent(&port1, BUTTON_PIN_0 ))  
            {
                
           //     print("button(s) current being debounced\n");//in this case tells if BUTTON_PIN_0 is
                //being debounced.                    
             }            
        }//endif time loop

    }//endwhile
}
