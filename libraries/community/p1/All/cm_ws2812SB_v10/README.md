# cm_ws2812SB_v10

By: Chad McFall

Language: C

Created: Nov 23, 2014

Modified: November 23, 2014

A brand new ground-up C/ASM Driver for WS2811, WS2812S, and WS2812B addressible LEDs.  Thanks to \_\_red\_\_ for introducting me to the Propeller chip, and to JonnyMac for his prior SPIN Driver that sparked my interest in WS2812 LEDs.

This is the first driver I've published, so forgive me if I didn't format it properly.  It works though, I've tested it on dozens of devices and thousands of WS2812s.

Chad McFall- 2014-11-23

// This sample code will light the first 3 leds red, green, and blue:

char outputPin=0;

char numberOfLEDs=10;

char initCog=1;

WS2812 myLedArray;

WS2812init(outputPin, numberOfLEDs, TIMING\_WS2812B, &myLedArray, initCog);

while(1)

{

WS2812SetLEDInBuffer(0, 20, 00, 00, &myLedArray); //LED 0 Red

WS2812SetLEDInBuffer(1, 00, 20, 00, &myLedArray); //LED 1 Green

WS2812SetLEDInBuffer(2, 00, 00, 20, &myLedArray); //LED 2 Blue

WS2812Update(&myLedArray);

}

  
