# Max7219 8x8 Column-oriented Stick with scrolling

By: Tom Crawford

Language: Spin, Assembly

Created: Aug 3, 2016

Modified: August 3, 2016

This is a driver for MAX7219 8x8 LED matrixes arranged in a linear stick.  It assumes the 7219's are wired so that a write to a data register affects a COLUMN of LEDs.  It can be configured as to the number of matrixes in the stick.  It can also be configured to swap the order of matrixes, swap the order of columns in each matrix, and swap the order of bits in each columns.  It starts a PASM cog for acceptable scroll speed. It includes a 7 x 5 plus descenders font.
