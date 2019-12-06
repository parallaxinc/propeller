# 640 x 480 2-4 Color VGA Bitmap Driver

![vga.jpg](vga.jpg)

By: Kwabena W. Agyeman

Language: Spin, Assembly

Created: Nov 1, 2009

Modified: June 17, 2013

A 640 x 480 2-4 Color VGA bitmap driver that runs on one cog. The code has been fully optimized with a super simple spin interface for maximum speed and is also fully commented.

Provides full support for:

*   Plotting characters in spin, in both 2 and 4 color mode.
*   Plotting pixels in spin, in both 2 and 4 color mode.

The horizontal resolution may be any value that satisfies these rules:

*   The value is between 1 and 640.
*   The value is a factor of 640.
*   The value is divisible by 16 if in 1 color mode.
*   The value is divisible by 32 if in 2 color mode.

The vertical resolution may be any value that satisfies these rules:

*   The value is between 1 and 480.
*   The value is a factor of 480.

In two color mode the driver needs a display buffer in longs that is ((horizontalResolution \* verticalResolution) / 32). The entire screen may have only two colors. Those two colors may be choosen from a 64 color palette.

In four color mode the driver needs a display buffer in longs that is ((horizontalResolution \* verticalResolution) / 16). The entire screen may have only four colors. Those four colors may be choosen from a 64 color palette.

This list of features is not comprehensive. Please download the source code and run the included demo to gain a better understanding of this driver.
