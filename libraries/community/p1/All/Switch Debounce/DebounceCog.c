///
/// Button Debouncer Example for a cog
/// 
// Description: 
// Program for a cog which places the debounced information in main memory to 
// be read by other processes
// 
// This example can be compiled and used 
//
// Written by Michael Forsyth and uses the libraries written by Trent Cleghorn 
// 
// See License at end of the file


// This file ,DebounceCog.c has been written to suit the Parallax Propeller processor.
// It is deliberatley verbose to make it easy for the beginner. (A habit acquired teaching IT)
// 
// Michael Forsyth  MichaelForsyth@protonmail.ch



#include "simpletools.h"  // Specific to Parallax
#include "simpletext.h"  // Specific to Parallax

#include "button_debounce.h"
// If you have trouble building the project because it can't find the header files either use the
// project->Add library button or add the include path(-I) and the library path (-L) in the project manager.
// Unfortunately simpletools calls other header files that are not required so it is necessary to add include
// and library paths for those too.  Sigh.....
// Hopefully in a future version of SimpleIDE it will not be necessary.

unsigned char PortReadStates(const int NoInPins,int InputArray[]);
extern int WhichButton(uint8_t a,int InputArray[]);
void DebounceInCog();
//Add additional Debouncer structs (ports) if you need more than 8 buttons
//eg Debouncer port2;
Debouncer port1;
volatile unsigned char PressedButtons,ReleasedButtons;  //for passing data from cog to core
int SemID;  //lock
//static int InputArray[8];

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
int InputArray[8];

////////Finally we come to Main()//////////////////////////////////////////////////
int
main()
{
    int InputArray[8] = {InPin_No1,InPin_No2,InPin_No3,InPin_No4,InPin_No5,InPin_No6,InPin_No7,InPin_No8}; 
    int *cog;
    int x;
    SemID = locknew(); // this is a shared lock
    // Modify the values below to suit.
    // add or delete as required
    set_direction(OutPin_No1,1);
    set_direction(OutPin_No2,1);             
    set_direction(OutPin_No3,1);
    low(OutPin_No1);
    low(OutPin_No2);
    low(OutPin_No3);
    
    cog = cog_run( &DebounceInCog, 100);
    while (1)
    {
      x = 0;
      if((x = WhichButton(PressedButtons,InputArray)))
      {
         print("Pressed button: %x\n",x);
         switch (x){
           case 2: high(OutPin_No1);  // on in this case
             break;
           case 3: high(OutPin_No2);
             break;
           case 4: high(OutPin_No3);
             break;
         }//end switch  
         x=0;
         // or whatever code
      }         
      if ((x = WhichButton(ReleasedButtons,InputArray)))
      {
         print("Released button: %x\n",x);  
         switch (x){
           case 2: low(OutPin_No1);  // off in this case
             break;
           case 3: low(OutPin_No2);
             break;
           case 4: low(OutPin_No3);
             break;
         }//end switch  
         
         x=0;
       // or whatever code
      }   
      pause(10);    
  } //end while   
}

void DebounceInCog(   )
{
     unsigned char x,y;    
    //Array used to convert InPin_No to BUTTON_PINs and vv.
    //This has to be repeated here because an Array cannot be passed to a cog
    int InputArrayCopy[8] = {InPin_No1,InPin_No2,InPin_No3,InPin_No4,InPin_No5,InPin_No6,InPin_No7,InPin_No8}; 
 
    //  useful variables

 
    // Initialize the button debouncer. Tell the debouncer which pins are pullups
    // For more than 1 pin has a pullup OR them together eg.(BUTTON_PIN_1 | BUTTON_PIN_2)
    // ButtonDebounceInit(&port1,BUTTON_PIN_1 | BUTTON_PIN_2 | BUTTON_PIN_3);  //these three are pullups
    ButtonDebounceInit(&port1,0);  // all are pull downs  
    SemID = locknew();
    
    while(1)
    {
              lockset(SemID);
              PressedButtons = 0;
              lockclr(SemID);
              lockset(SemID);              
              ReleasedButtons = 0;
              lockclr(SemID);                         
            // checks all the buttons             
            ButtonProcess(&port1,PortReadStates(NoInPins,InputArrayCopy));
              
           //ask about button state Buttons. Can be OR'd together
           
            if((x = ButtonPressed(&port1, BUTTON_PIN_0 | BUTTON_PIN_1 | BUTTON_PIN_2)))
            {
              lockset(SemID);
              PressedButtons = x;
              lockclr(SemID);
            }

           if ((y = ButtonReleased(&port1, BUTTON_PIN_0 | BUTTON_PIN_1 | BUTTON_PIN_2 )))
            {
              lockset(SemID);              
              ReleasedButtons = y;
              lockclr(SemID);
            }

       pause(10); // if this is too small e.g.1 it is not captured in main program. Adjust as necessary.    

    }//endwhile
}//end DebounceInCog


// 
//Reads the InPin registers declared in the input array and
//Returns the result in BUTTON_PIN No (binary)
//Written for the Parallax Propeller but may to useful to other processors.
unsigned char PortReadStates(const int NoInPins,int InputArray[])
     {
       int i;
       unsigned char result = 0;
       for (i = NoInPins ;i > 0 ;i--)
       {
         result |= input(InputArray[i-1]);// loaded in reverse order
         result <<= 1;
       } 
       return result >>= 1;      
     }//end PortReadStates 


// Uses the return from ButtonPress, ButtonReleased,ButtonCurrent
// Returns the pin number(s). It is unlikely that two buttons will be processed at the same time.
// However if they are then return would be E.g 13 meaning input pins 1 and 3 are high                 
int WhichButton(uint8_t a, int InputArray[])
   {
      int result =0 ;
      unsigned char mask = BUTTON_PIN_0;
      unsigned char b;
      int i;
      for (i=0;i < NoInPins;i++)
      {
        lockset(SemID);
        b = a;
        lockclr(SemID);        
       if(b & mask)
        {
          if (result ==0)
          {
           result = InputArray[i];
          }           
          else 
         {
            result *= 10;   // this only occurs if two buttons are pressed or released at exact same time
            result += InputArray[i];          //highly improbable occurrence.
         }
       }         
       mask = mask <<1; 
      }//end for         
      
      return result;         
 }  //end whichbutton    

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

