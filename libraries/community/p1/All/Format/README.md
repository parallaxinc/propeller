# Format

By: Peter Verkaik

Language: Spin

Created: Dec 14, 2007

Modified: May 2, 2013

This library object provides formatted string output and scan methods based on the standard C sprintf and sscanf functions. With this object you can convert byte, word and long types into binary, octal, decimal or hexadecimal formatted strings. You can specify the minimum and maximum number of columns to display your values, and these values can be left or right justified, with or without padded zeros.

Methods are included for the following C library functions: itoa, atoi, sprintf and sscanf. This implementation defines the functions bprintf and bscanf that take one, and only one, variable parameter. The original format string must be split into pieces that all have one format specifier. This normally is not a problem since most format strings consists of fixed text with format specifiers for values.
