# Pixel Driver (WS28xx / SK68xx)

By: Jon McPhalen

Language: Spin, Assembly

Created: Oct 26, 2017

Modified: April 30, 2018

This is a unified, 800kHz pixel driver that has direct support for:

*   WS2811
*   WS2812 
*   WS2812b
*   WS2813
*   SK6812
*   SK6812RGBW

The **startx**() method allows advanced programmers to specifiy parameters of the data stream.

This driver uses external pixel buffers to save memory on small projects, and allow advanced programmers to use multiple buffers for animation effects. The color buffer and output pin may be switched at any time. Output of the buffer auto-repeats so that the application can manipulate the buffer on-the-fly.

Note to users of my previous pixel drivers: this driver supports 24- (RGB) and 32-bit (RGBW) devices -- you may need to adjust custom color values for this new driver.

Added a method called **morph**() which facilitates a transition from one color to any other color.
