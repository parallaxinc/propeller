# Numbers

![Numbers.png](Numbers.png)

By: Jeff Martin

Language: Spin

Created: Nov 27, 2006

Modified: May 20, 2013

Converts values in variables (longs) to strings and vice-versa in any base from 2 to 16. Some features include:

*   Supports full 32-bit signed values, 
*   Converts using any base from 2 to 16 (binary to hexadecimal), 
*   Defaults to variable widths (outputs entire number, regardless of size) and optionally uses fixed widths, left/right justification (zeros/spaces), 
*   Optional digit groupings (2 to 8 characters) with customizable separators; ex: 1000000 becomes 1,000,000 and 7AB14B9C becomes 7AB1\_4B9C.

v1.1 - 5/5/2009 fixed formatting bug caused by specifying field width smaller than location of first grouping character.
