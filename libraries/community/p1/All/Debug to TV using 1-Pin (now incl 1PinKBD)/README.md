# Debug to TV using 1-Pin (now incl 1PinKBD)

By: Cluso99

Language: Spin, Assembly

Created: Feb 28, 2010

Modified: May 2, 2013

Use debug calls in your spin program to output debug messages to a TV/LCD composite video. Supports chr/out/tx, str, hex, dec, bin, clear, home, gotoxy, cr. Screen size 40x25, 60x25, 64x25 (80\*25 with overclocking), NTSC or PAL, B&W, Text only.

Can also be used as a B&W TV Text terminal in your program, and can be in addition to any other output device(s) connected including TV and/or VGA.

Simple interface uses a single prop pin and 100R-1K1 (270R preferred) series resistor.

Font and a simple terminal program also reside within the cog. The screen buffer overlays the hub code after it is loaded into the cog, so it is a small footprint.

Now also includes optional 1-pin Keyboard Driver which uses 3 resistors.

v1.25 allows user selection of columns and rows.

v1.20 adds automatic parameters and faster terminal mode.

Thread http://forums.parallax.com/forums/default.aspx?f=25&m=431556

...includes how to make a cable, etc.
