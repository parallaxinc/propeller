# Linear Interpolation for CNC or Graphics

By: DDS

Language: Assembly

Created: Apr 10, 2013

Modified: April 10, 2013

This code generates a linear interpolation motion profile as intended for a home-brew CNC machine. _(CNC Codes G00 & G01)_

I use Bresenham's algorithm calculates X,Y & Z steps to accurately approximate a straight line between two points in 3D Space.

I have not implemented a controlling feed rate so it is just a starting point.
