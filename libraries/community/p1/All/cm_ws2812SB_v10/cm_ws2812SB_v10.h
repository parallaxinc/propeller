
#ifndef NOT_ZIGZAG
#define NOT_ZIGZAG (0)
#endif

#ifndef ZIGZAG
#define ZIGZAG (1)
#endif

#ifndef TIMING_WS2812S
#define TIMING_WS2812S (0)
#endif

#ifndef TIMING_WS2812B
#define TIMING_WS2812B (1)
#endif

typedef struct WS2812_st{
    char outPin;
    int LEDmask;
    int cog;
    int ZeroHi;
    int ZeroLo;
    int OneHi;
    int OneLo;
    char numLEDs;
    int WS2812LEDValues[200];
    int WS2812LEDBuffer[200];
} WS2812;

/*
 WS2812init
  pinNumber: Which pin to send WS2812 data out.
  numLEDs: How many leds will we be driving.  Tested up to 127.
  timing: 
      0: ws2812/S (Works for B also due to tolerance of +-150ns)
      1: ws2812B  (incase S timing doesnt work.  OneLo is a little off of ideal.) 
  cogInit:
      0: Set Values but dont init cog
      1: Set Values and init cog > WS2812_s.cog
*/
void WS2812init(char pinNumber, char _numLEDs, char timing, WS2812* inLEDString, char cogInit); 

/*
  WS2812ClearLEDBuffer
  Wipes the integer array used as a buffer canvas to all 0's.
*/
void WS2812ClearLEDBuffer(WS2812 *inLEDString);

/*
  WS2812Update
  copies the canvas buffer to the live colorValues array used by WS2812UpdateLoop.
*/
void WS2812Update(WS2812 *inLEDString);

/*
  WS2812SetLEDInBuffer
  Shifts red, green, and blue into their spots in the buffer integer array.
*/
void WS2812SetLEDInBuffer(char ledIndex, char red, char green, char blue, WS2812 * inLEDString);

/*
  WS2812PutPixel
  Handles the positioning math for the buffer when LEDs are chained in a matrix.
  zigZag 0 or 1 specifies if the leds reverse direction every other row - typical with WS2812 strips.
  matrixWith specifies how many pixels per row.
*/
void WS2812PutPixel(char matrixWidth, char zigZag, char ppx, char ppy, char ppred, char ppgreen, char ppblue, WS2812 * inLEDString);

/*
  copyRGBArrayToIntArray
  Moves 3 char arrays, red, blue, green, into WS2812LEDBuffer 
*/
void copyRGBArrayToIntArray(char * redArray, char *greenArray, char *blueArray, WS2812 * inLEDString);

/*
  clearRGBArray
  Moves 3 char arrays, red, blue, green, into WS2812LEDBuffer 
*/
void clearRGBArray(char * redArray, char *greenArray, char *blueArray, char arraySize);


/*
  WS2812ManualDataSend
  Manual update - sends bits out data pin.
*/
void WS2812ManualDataSend(WS2812* inLEDString);

/*
  WS2812DataSendLoop
  Auto update - same as sendColors but intended to be put in a cog.
*/
void WS2812DataSendLoop(void * dummy);

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