                CLib - C Library written in Spin
                       Version 1.0.1
                        May 3, 2010
                         Dave Hein

 
CLib provides standard C library functions that are written in Spin.
There are three main types of functions -- string manipulation,
formatted I/O and memory allocation.  This module contains the following
files:

  readme.txt     - This file
  clib.spin      - The object that contains the main routines
  cmalloc.spin   - This object contains memory allocation routines.
  cserial.spin   - This object contains serial I/O routines.
  testclib.spin  - A test program that exercises most of the clib routines.
  cfloatstr.spin - This object contains routines for converting between
                   floating point numbers and strings.

C supports functions that use a variable number of arguments, such as
printf and scanf.  These functions are supported in two ways.  The first
way uses unique function names for each number of arguments that is used,
such as printf3 for a printf with three arguments.  The second way uses an
argument list, such as vprintf.  The argument list consists of an array of
longs that holds the values of the arguments.  In the case of vscanf the
argument list consists of an array of pointers.

The start function must be called before using any of the serial I/O or
memory allocation functions.  It will setup a a serial port that transmits on
pin 30 and receives on pin 31 at 57600 baud.  It will also establish a stack
space of 200 longs for the top object.  The malloc heap begins immediately
after the stack space, and extends to the end of the RAM.

Serial I/O and stack space parameters can be specified by calling start1
instead of start.  The first four parameters of start1 are the same as those
used in a call to the FullDuplexSerial start function.  The fifth parameter,
stacksize, defines the size in longs of the stack space.

Additional serial ports can be created by calling the openserial routine.
In additional to rxpin, txpin, mode and baudrate the receive and transmit
buffer sizes are also specified.  A fileinfo pointer is returned, which
is used when calling fputc, fgetc and all of the other I/O routines that begin
with the letter "f".

The functions puts, putchar and getchar use the str1, tx1 and rx1 methods
of a modified FullDuplexSerial object.  This object, cserial, allows for multiple
serial ports through the use of a structer pointer called a handle.  See
cserial.spin for more information.

clib uses a file info structure to access I/O devices, such as the serial port.
The I/O routines that start with the letter "f" require a pointer to the file info
struction, wich is normally named pfileinfo.  Currently, only serial I/O and
string I/O are supported.  Future releases will also support file I/O.

cfloatstr provides floating point string conversion without the need of any other
floating point objects.  To save some space the four places where clib references
items in cfloatstr can be commented out, and cfloatstr will not be used.
Refer to cfloatstr.spin, cserial.spin and cfloatstr.spin for more information.

CLib releases
-------------
v1.0   - Original Release
v1.0.1 - Fixed a bug in memcpy and memset

CLib Functions
--------------

Initialization
--------------
PUB  start
PUB  start1(rxpin, txpin, mode, baudrate, stacksize)
PUB  openserial(rxpin, txpin, mode, baudrate, rxsize, txsize)

String Routines
---------------
PUB  strcmp(str1, str2)
PUB  strncmp(str1, str2, n)
PUB  memcpy(dest, src, n)
PUB  memset(dest, val, n)
PUB  strcat(dst, src)
PUB  strcpy(dst, src)
PUB  strncpy(dst, src, len)
PUB  isdigit(char)
PUB  itoa(number, str, base)

Character Output
-------------
PUB  puts(str)
PUB  putchar(char)
PUB  fputc(char, pfileinfo)
PUB  fputs(str, pfileinfo)

Formated Output
---------------
PUB  printf0(format)
PUB  printf1(format, arg1)
PUB  printf2(format, arg1, arg2)
PUB  printf3(format, arg1, arg2, arg3)
PUB  printf4(format, arg1, arg2, arg3, arg4)
PUB  printf5(format, arg1, arg2, arg3, arg4, arg5)
PUB  printf6(format, arg1, arg2, arg3, arg4, arg5, arg6)
PUB  vprintf(format, arglist)
PUB  sprintf0(str, format)
PUB  sprintf1(str, format, arg1)
PUB  sprintf2(str, format, arg1, arg2)
PUB  sprintf3(str, format, arg1, arg2, arg3)
PUB  sprintf4(str, format, arg1, arg2, arg3, arg4)
PUB  sprintf5(str, format, arg1, arg2, arg3, arg4, arg5)
PUB  sprintf6(str, format, arg1, arg2, arg3, arg4, arg5, arg6)
PUB  vfprintf(pfileinfo, format, arglist)
PUB  vsprintf(str, format, arglist)

Character Input
---------------
PUB  getchar
PUB  gets(str)
PUB  fgetc(pfileinfo)
PUB  fgets(str, size, pfileinfo)

Formated Input
--------------
PUB  scanf1(format, parg1)
PUB  scanf2(format, parg1, parg2)
PUB  scanf3(format, parg1, parg2, parg3)
PUB  scanf4(format, parg1, parg2, parg3, parg4)
PUB  vscanf(format, arglist)
PUB  sscanf1(str, format, parg1)
PUB  sscanf2(str, format, parg1, parg2)
PUB  sscanf3(str, format, parg1, parg2, parg3)
PUB  sscanf4(str, format, parg1, parg2, parg3, parg4)
PUB  vsscanf(str, format, arglist)

Memory Allocation
-----------------
PUB  malloc(size)
PUB  free(ptr)
PUB  calloc(size)

