# VGA_640x240_Bitmap

By: William Henning

Language: Spin, Assembly

Created: Apr 17, 2013

Modified: April 17, 2013

I wanted a high resolution graphics mode that would work on my 8.4" TFT LCD monitor - which can only sync to 640x480. Since the propeller does not have enough memory for a bitmap that size, I decided to modify the 512x384 driver to make a 640x240 bitmap mode.I also modified the color tiles to be 32x16 so that the color blocks appear square on the monitor.

Memory usage:

*   4,800 longs for the bitmap
*   300 words for the color map

As this is only a minor mod of the Parallax driver, the copyright ofcourse stays with Parallax!  
 

Enjoy!  
Bill  
http://www.mikronauts.com
