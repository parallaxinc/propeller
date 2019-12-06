# Commodore 64 Four Color VGA Display

By: Mike Christle

Language: Spin, Assembly, Other

Created: Oct 23, 2018

Modified: November 16, 2018

Drives a VGA display using the Commodore 64's funky 8x8 pixel graphics character set.

Supported screen resolutions:

      160x120 Pixels, 20x15 Chars,   4800 Byte Buffer.

      192x120 Pixels, 24x15 Chars,   5760 Byte Buffer.

      224x120 Pixels, 28x15 Chars,   6720 Byte Buffer.

      256x120 Pixels, 32x15 Chars,   7680 Byte Buffer.

      256x240 Pixels, 32x30 Chars, 15360 Byte Buffer.

      288x240 Pixels, 36x30 Chars, 17280 Byte Buffer.

      320x240 Pixels, 40x30 Chars, 19200 Byte Buffer.

      384x240 Pixels, 48x30 Chars, 23040 Byte Buffer.

Includes a Python 3 program to customize the character bitmaps.

Version 1.x uses one cog to drive the VGA output, and Spin routines to draw on the bitmap. Version 2.x uses two cogs, one to drive the VGA output and one to draw on the bitmap. Obviously, version 2.x runs much faster. The F in the file names stands for fast.

History:

 1.0.0 - 10/10/2018 - Original release.

 1.0.1 - 10/21/2018 - Fix errors in the character bit maps.

 1.1.0 - 10/31/2018 - Add CChar routine to better control character colors.

 1.2.0 - 11/02/2018 - Add blinking cursor.

 1.2.1 - 11/05/2018 - Fix errors in Line routine.

 1.3.0 - 11/12/2018 - Add LineTo routine to draw a series of lines.

 1.4.0 - 11/14/2018 - Add four new resolutions.

 1.5.0 - 11/15/2018 - Add support for back space char.

 2.0.0 - 11/16/2018 - Add assembly routines to replace Pixel, Char and Line functions.
