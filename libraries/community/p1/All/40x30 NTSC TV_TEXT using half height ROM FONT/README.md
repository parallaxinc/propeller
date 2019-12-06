# 40x30 NTSC TV_TEXT using half height ROM FONT

![DSC00114_222.jpg](DSC00114_222.jpg)

By: Baggers

Language: Spin, Assembly

Created: May 2, 2009

Modified: June 17, 2013

This is a quick small modification to Chip's TV\_TEXT.spin and TV.spin routines, that allow 40x30 tile text display in NTSC ( or PAL ) using the ROM FONT, which as a 16x16, by OR'ing each two pixel lines together, and using interlaced, to get the 640x480 resolution needed for 40x30 tiles.  
It's currently set up for HYBRID ( 6Mhz Clock, and tv on pins 24 ) but you can change that in "tv\_text\_half\_height\_demo.spin".

Baggers.

**Now updated to V1.3**

*   You can now specify interlaced mode or non-interlaced mode.
*   You can also set ink(pen) instead of doing two stage out($0c) and out(pen)
*   You can also set the attributes for an area of the screen, keeping the text intact inkblock(x,y,w,h,pen)
