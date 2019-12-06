/*
  
  =================================================================================================
 
    File....... cm_ws2812SB.c
    Purpose.... WS2812, WS2812S, and WS2812B LED Control
    Author..... Chad D McFall
                Copyright (c) 2014 Chad D McFall
                -- Written entirely from scratch, probably poorly. I welcome suggestions.
                -- see below for terms of use
    E-mail..... packetrider gmail
    Versions... 1.0: Nov/21/2014
 
    Getting Started: 
                      // This sample code will light the first 3 leds red, green, and blue:
                          char outputPin=0;
                          char numberOfLEDs=10;
                          char initCog=1;    
                          
                          WS2812 myLedArray;
                          WS2812init(outputPin, numberOfLEDs, TIMING_WS2812B, &myLedArray, initCog);
                          
                          while(1)
                          {
                            WS2812SetLEDInBuffer(0, 20, 00, 00, &myLedArray); //LED 0 Red
                            WS2812SetLEDInBuffer(1, 00, 20, 00, &myLedArray); //LED 1 Green
                            WS2812SetLEDInBuffer(2, 00, 00, 20, &myLedArray); //LED 2 Blue
                            WS2812Update(&myLedArray);
                          }  

  =================================================================================================
  
*/

#include "cm_ws2812SB_v10.h"
#include <propeller.h>

//GLOBALS Used by ASM Functions

void WS2812init(char pinNumber, char _numLEDs, char timing, WS2812* inLEDString, char cogInit){ 
  switch (timing){
    case 0://ws2812/S (Works for B also)
    //Spec allows for +-150ns
      inLEDString->ZeroHi= 19;   //19   350ns
      inLEDString->ZeroLo= 30;   //30   800ns
      inLEDString->OneHi=  47;   //47   700ns  Out of tolerance for B
      inLEDString->OneLo=  16;   //16   600ns 
      break;
     case 1://ws2812B (incase S timing doesnt work)
      //Spec allows for +-150ns
      inLEDString->ZeroHi= 19;   //19   350ns
      inLEDString->ZeroLo= 40;   //37   900ns
      inLEDString->OneHi=  63;   //63   900ns
      inLEDString->OneLo=  9;   //16    should be 350ns. 500ns is as quick as I could go without breaking waitcnt.   
      break;
  }    
  inLEDString->outPin=pinNumber;
  inLEDString->LEDmask = 1 << pinNumber;
  inLEDString->numLEDs=_numLEDs;
	WS2812ClearLEDBuffer(inLEDString);  
  if (cogInit==1){
	   unsigned int stack[800];
	   inLEDString->cog=cogstart(&WS2812DataSendLoop, inLEDString, stack, sizeof(stack));
  }
}

  char ws2812_cpyctr=0;
  char ws2812_tmpred;
  char ws2812_tmpgreen;
  char ws2812_tmpblue;
void WS2812ClearLEDBuffer(WS2812 *inLEDString){
  memset(inLEDString->WS2812LEDBuffer, 0, sizeof(inLEDString->WS2812LEDBuffer));
}

void WS2812Update(WS2812 *inLEDString){
  memcpy(inLEDString->WS2812LEDValues,inLEDString->WS2812LEDBuffer,sizeof(inLEDString->WS2812LEDBuffer)) ;
}

void WS2812SetLEDInBuffer(char ledIndex, char red, char green, char blue, WS2812 * inLEDString){
  __asm__ volatile(
            "mov %[_LEDBuffer],%[_blue]  \n\t"        
            "shl %[_LEDBuffer],#8 \n\t"
            "xor %[_LEDBuffer],%[_red] \n\t"
            "shl %[_LEDBuffer],#8 \n\t"
            "xor %[_LEDBuffer],%[_green] \n\t"
            "shl %[_LEDBuffer],#8 \n\t"

          : [_LEDBuffer]    "+r" (inLEDString->WS2812LEDBuffer[ledIndex])
          : [_blue]         "r" (blue),
            [_red]          "r" (red),
            [_green]        "r" (green)  
          );    
}  

void copyRGBArrayToIntArray(char * redArray, char *greenArray, char *blueArray, WS2812 * inLEDString){
  char ws2812_cpyctr=0;
  char ws2812_tmpred;
  char ws2812_tmpgreen;
  char ws2812_tmpblue;
  for(ws2812_cpyctr=0; ws2812_cpyctr<inLEDString->numLEDs; ws2812_cpyctr++){
       ws2812_tmpred=redArray[ws2812_cpyctr];
       ws2812_tmpgreen=greenArray[ws2812_cpyctr];
       ws2812_tmpblue=blueArray[ws2812_cpyctr];
      __asm__ volatile(
            "mov %[_LEDBuffer],%[_blue]  \n\t"        
            "shl %[_LEDBuffer],#8 \n\t"
            "xor %[_LEDBuffer],%[_red] \n\t"
            "shl %[_LEDBuffer],#8 \n\t"
            "xor %[_LEDBuffer],%[_green] \n\t"
            "shl %[_LEDBuffer],#8 \n\t"

          : [_LEDBuffer]    "+r" (inLEDString->WS2812LEDBuffer[ws2812_cpyctr])
          : [_blue]         "r" (ws2812_tmpblue),
            [_red]          "r" (ws2812_tmpred),
            [_green]        "r" (ws2812_tmpgreen)  
          );   
  }    
}  

void clearRGBArray(char * redArray, char *greenArray, char *blueArray, char arraySize){
  memset(redArray,0,arraySize);
  memset(greenArray,0,arraySize);
  memset(blueArray,0,arraySize);
}  

void WS2812PutPixel(char matrixWidth, char zigZag, char ppx, char ppy, char ppred, char ppgreen, char ppblue, WS2812 * inLEDString){  
  if (((ppy % 2)==0) | (zigZag==0)){
    WS2812SetLEDInBuffer(ppy*matrixWidth+ppx, ppred, ppgreen, ppblue, inLEDString);
  } else {
    WS2812SetLEDInBuffer(ppy*matrixWidth+((matrixWidth-1)-ppx), ppred, ppgreen, ppblue, inLEDString);
  }        
}  

void WS2812ManualDataSend(WS2812* inLEDString){
    int LED1mask = 1 << inLEDString->outPin;
    int * outBits=0;
    char highDelay=0;
    char lowDelay=0;
    char tmpByte=0;
    int * cValues;
    int LEDCtr=0; 
    int delayCtr=0;
    int bitCounter=0;  

      cValues=inLEDString->WS2812LEDValues;
    
          __asm__ volatile(
            "fcache #(aPutByteEnd - aSetLEDCtr)\n\t"     //Must use fcache to use jump calls
            ".compress off \n\t"
            "aSetLEDCtr: "                              //How many leds to drive
            "or dira,%[_mask]\n\t"                     //Set pin as output.
            "mov %[_LEDCtr],%[_ledCount]  \n\t"        //Sets loops for leds.. errr u32int array elements.
            "aPutByteStart: "
            "mov %[_ctr],#24 \n\t"                     //How many bits in a tootsiepop
            "mov %[_outBits],#0 \n\t"                  //Make a stream for the LED, start with 0 value.
            "add %[_cValues],#1 \n\t"                  //Move that 32 bit int over one byte to get to the colors
            "rdbyte %[_tmpByte],%[_cValues] \n\t"      //Read a color
            "xor %[_outBits],%[_tmpByte] \n\t"         //Add the color to our out stream
            "shl %[_outBits],#8 \n\t"                  //Shift the outstream over to make room for the next color

            "add %[_cValues],#1 \n\t"                  //Do it again
            "rdbyte %[_tmpByte],%[_cValues] \n\t"
            "xor %[_outBits],%[_tmpByte] \n\t"
            "shl %[_outBits],#8 \n\t"
            
            "add %[_cValues],#1 \n\t"                  //Do it again
            "rdbyte %[_tmpByte],%[_cValues] \n\t"
            "xor %[_outBits],%[_tmpByte] \n\t"
            "shl %[_outBits],#8 \n\t"
            "add %[_cValues],#1 \n\t"
            "aPutByteLoop: "                             //Send our outstream
            "rol %[_outBits], #1 wc\n\t"                //Take the first bit, set delays depending on hi/lo
            "if_c mov %[_highDelay], %[_OneHi] \n\t"    //Move OneHi into highDelay
            "if_c mov %[_lowDelay], %[_OneLo] \n\t"     //Move OneLo into lowDelay 
            "if_nc  mov %[_highDelay], %[_ZeroHi] \n\t" //Move OneHi into highDelay 
            "if_nc  mov %[_lowDelay], %[_ZeroLo] \n\t"  //Move ZeroLo into lowDelay 
            "or outa, %[_mask] \n\t"                    //xor outa  - pin Hi
            "mov %[_delayCtr],cnt \n\t"                 //Delay for Hi
            "add %[_delayCtr],%[_highDelay] \n\t"
            "waitcnt %[_delayCtr],%[_highDelay] \n\t"
            "andn outa, %[_mask] \n\t"                  //andn outa - pin Lo
            "mov %[_delayCtr],cnt \n\t"                 //Delay for Lo
            "add %[_delayCtr],%[_lowDelay] \n\t"
            "waitcnt %[_delayCtr],%[_lowDelay] \n\t"
            "djnz %[_ctr], #__LMM_FCACHE_START+(aPutByteLoop-aSetLEDCtr) \n\t"      //Get the next Bit
            "djnz %[_LEDCtr], #__LMM_FCACHE_START+(aPutByteStart-aSetLEDCtr) \n\t"  //Get the next uint32
            "jmp __LMM_RET \n\t"                                                  //Done
            "aPutByteEnd: "
            ".compress default \n\t"
          : [_highDelay]  "+r"(highDelay),   
            [_outBits]    "+r"(outBits),   
            [_cValues]    "+r"(cValues),
            [_LEDCtr]    "+r" (LEDCtr)
          : [_tmpByte]    "r" (tmpByte),   
            [_lowDelay]   "r" (lowDelay),   
            [_ctr]        "r" (bitCounter),   
            [_ledCount]   "r" (inLEDString->numLEDs),
            [_delayCtr]   "r" (delayCtr),   
            [_mask]       "r" (inLEDString->LEDmask),
            [_OneHi]      "r" (inLEDString->OneHi),
            [_OneLo]      "r" (inLEDString->OneLo),
            [_ZeroHi]     "r" (inLEDString->ZeroHi),
            [_ZeroLo]     "r" (inLEDString->ZeroLo)
          ); 
}   
    int delayCtr=0;
    int bitCounter=0; 
    int LEDCtr=0;  

void WS2812DataSendLoop(void *par){
  
  WS2812 *ThisWS2812= (WS2812 *) par;
    int loopctr=0;
    int * ccValues;
    int * outBits=0;
    char tmpByte=0;
    char highDelay=0;
    char lowDelay=0;

    while (1==1){
    //  ledCount=16;
          ccValues=ThisWS2812->WS2812LEDValues;
            
          __asm__ volatile(
            "fcache #(PutByteEnd - SetLEDCtr)\n\t"     //Must use fcache to use jump calls
            ".compress off \n\t"
            "SetLEDCtr: "                              //How many leds to drive
            "or dira,%[_mask]\n\t"                     //Set pin as output.
            "mov %[_LEDCtr],%[_ledCount]  \n\t"        //Sets loops for leds.. errr u32int array elements.
            "PutByteStart: "
            "mov %[_ctr],#24 \n\t"                     //How many bits in a tootsiepop
            "mov %[_outBits],#0 \n\t"                  //Make a stream for the LED, start with 0 value.
            "add %[_cValues],#1 \n\t"                  //Move that 32 bit int over one byte to get to the colors
            "rdbyte %[_tmpByte],%[_cValues] \n\t"      //Read a color
            "xor %[_outBits],%[_tmpByte] \n\t"         //Add the color to our out stream
            "shl %[_outBits],#8 \n\t"                  //Shift the outstream over to make room for the next color

            "add %[_cValues],#1 \n\t"                  //Do it again
            "rdbyte %[_tmpByte],%[_cValues] \n\t"
            "xor %[_outBits],%[_tmpByte] \n\t"
            "shl %[_outBits],#8 \n\t"
            
            "add %[_cValues],#1 \n\t"                  //Do it again
            "rdbyte %[_tmpByte],%[_cValues] \n\t"
            "xor %[_outBits],%[_tmpByte] \n\t"
            "shl %[_outBits],#8 \n\t"
            "add %[_cValues],#1 \n\t"
            "PutByteLoop: "                             //Send our outstream
            "rol %[_outBits], #1 wc\n\t"                //Take the first bit, set delays depending on hi/lo
            "if_c mov %[_highDelay], %[_OneHi] \n\t"    //Move OneHi into highDelay
            "if_c mov %[_lowDelay], %[_OneLo] \n\t"     //Move OneLo into lowDelay 
            "if_nc  mov %[_highDelay], %[_ZeroHi] \n\t" //Move OneHi into highDelay 
            "if_nc  mov %[_lowDelay], %[_ZeroLo] \n\t"  //Move ZeroLo into lowDelay 
            "or outa, %[_mask] \n\t"                    //xor outa  - pin Hi
            "mov %[_delayCtr],cnt \n\t"                 //Delay for Hi
            "add %[_delayCtr],%[_highDelay] \n\t"
            "waitcnt %[_delayCtr],%[_highDelay] \n\t"
            "andn outa, %[_mask] \n\t"                  //andn outa - pin Lo
            "mov %[_delayCtr],cnt \n\t"                 //Delay for Lo
            "add %[_delayCtr],%[_lowDelay] \n\t"
            "waitcnt %[_delayCtr],%[_lowDelay] \n\t"
            "djnz %[_ctr], #__LMM_FCACHE_START+(PutByteLoop-SetLEDCtr) \n\t"      //Get the next Bit
            "djnz %[_LEDCtr], #__LMM_FCACHE_START+(PutByteStart-SetLEDCtr) \n\t"  //Get the next uint32

            "jmp __LMM_RET \n\t"                                                  //Done
            "PutByteEnd: "
            ".compress default \n\t"
          : [_highDelay]  "+r"(highDelay),   
            [_outBits]    "+r"(outBits),   
            [_cValues]    "+r"(ccValues),
            [_LEDCtr]    "+r" (LEDCtr)
          : [_tmpByte]    "r" (tmpByte),   
            [_lowDelay]   "r" (lowDelay),   
            [_ctr]        "r" (bitCounter),   
            [_ledCount]   "r" (ThisWS2812->numLEDs),
            [_delayCtr]   "r" (delayCtr),   
            [_mask]       "r" (ThisWS2812->LEDmask),
            [_OneHi]      "r" (ThisWS2812->OneHi),
            [_OneLo]      "r" (ThisWS2812->OneLo),
            [_ZeroHi]     "r" (ThisWS2812->ZeroHi),
            [_ZeroLo]     "r" (ThisWS2812->ZeroLo)
          ); 
         
    }              
}   

/* 
Copyright (c) 2014 Chad McFall

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/