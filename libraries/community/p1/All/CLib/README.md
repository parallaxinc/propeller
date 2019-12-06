# CLib

By: Dave Hein

Language: Spin, Assembly

Created: Apr 2, 2010

Modified: May 2, 2013

CLib - Standard C library functions written in Spin. Contains string, formatted I/O and memory allocation routines such as strcpy, strcat, printf, scanf, malloc and free. Includes a serial I/O driver that allows multiple instances and multi-cog access. Also contains routines that convert between floating point and strings without additional floating point objects.

Version 1.0.1 fixes a bug in the memcpy and memfill routines. It also improves the efficiency of these routines when the byte count is around 200 or less.
