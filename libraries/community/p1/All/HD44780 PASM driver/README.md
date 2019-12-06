# HD44780 PASM driver

By: Benky aka MagIO2

Language: Assembly

Created: Apr 9, 2013

Modified: May 20, 2013

This is a PASM driver for HD44780 based text LCDs for 4 bit mode. Of course text LCD itself is not time critical, but maybe your application needs to write data fast to have enough time to do the important things ;o)

As there was (and still is) much COG-RAM free some special functions have been implemented:

*   blinking characters (e.g. for status symbols)
*   scrolling lines (e.g. for long texts \[up to HUB RAM length ;o\])
*   with scrolling lines/scroll rate set to 0 a screenbuffer mode is possible. Simply write your text in that buffer and it will appear on the display
*   special scrolling settings support menus
*   wanna do 40x16 pixel graphics with a text display? Don't miss the small\_pic demo

The package contains 4 demo programs for 16x2 or 16x4, showing the possibilities.

It's version 0.99 because I did not get negative feedback so far, but no positive as well. From my point of view it's fully functional and I had no problems so far with several displays.

For discusion use this thread: http://forums.parallax.com/forums/default.aspx?f=25&m=396005
