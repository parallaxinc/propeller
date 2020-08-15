
# VGA Text routines

By: Eric R. Smith

Language: Spin2

Created: 14-AUG-2020

Category: display

Description:

The ansi.spin2 file provides a VGA text driver that supports standard ANSI escape codes for text effects (like changing colors, flashing, etc.). Resolutions of 640x480, 800x600, 1024x768, and 1280x800 are supported, as well as fonts at a variety of sizes (8x8, 8x16, and 16x32 ones are included).

The default configuration is 1280x800 with a 16x32 font and 8bpp color; edit ansi.spin2 to modify this.

demo.spin2 is a simple demo using the VGA tile driver directly as well as using the ANSI text object

basdemo.bas is a demo in BASIC

License: MIT
