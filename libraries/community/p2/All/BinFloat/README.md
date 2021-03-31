
# Binary Floating Point Routines (IEEE-32 subset) 

By: Eric R. Smith

Language: Spin2

Created: 31-MAR-2021

Category: math

Description:

These are functions for performing floating point math in Spin2. To use, include a `BinFloat` object in your code, e.g.:
```
OBJ
  flt : "BinFloat"

' silly example that calculates (x + y) / 2.0
PUB calcAverage(x, y) : r
  r := flt.FDiv( flt.FAdd(x, y) , 2.0 )
```

The routines available are:

Basic Math:

`FNeg(x)`:    return negative of floating point number `x`
`FAbs(x)`:    return absolute value of floating point number `x`
`FAdd(x, y)`: return `x + y` (floating point)
`FSub(x, y)`: return `x - y`
`FMul(x, y)`: return `x * y`
`FDiv(x, y)`: return `x / y`
`FSqrt(x)`:   return floating point square root of float `x`


Trignometry:

These functions all can operate in degrees, radians, or with angles specified as fractions of a complete circle. Before calling any of the trig functions, set the angle format with one of the following calls:

`SetDegrees()`:  specifies that angles are in degrees
`SetRadians()`:  specifies that angles are in radians
`SetFraction()`: specifies that angles are in fractions of a circle

`FSin(angle)`:  returns sine of `angle`
`FCos(angle)`:  returns cosine of `angle`
`FTan(angle)`:  returns tangent of `angle`
`FAsin(x)`:     returns inverse sine (angle such that `FSin(angle)` is `x`)
`FACos(x)`:     returns inverse cosine
`FATan(x)`:     returns inverse tangent
`FATan2(x, y)`: returns angle that the vector `(x,y)` makes with the x axis. *Note*: the order of parameters is different from the similar C function!

Exponentials and logs:

`FLog2(x)`    : calculates log base 2 of x
`FLog10(x)`   : calculates log base 10 of x
`FLog(x)`     : calculates log base e (natural logarithm) of x
`FExp2(x)`    : calculates 2^x
`FExp10(x)`   : calculates 10^x
`FExp(x)`     : calculates e^x
`FPow(x, y)`  : calculates x^y, where both x and y are floats
`FPowInt(x, n)`: calculates x^n, where x is a float and n is a signed integer

Conversions to/from integer:

`FromInt(n)`:   returns floating point number closest to the signed integer `n`
`FromUInt(n)`:  returns floating point number closest to the unsigned integer `n`
`FTrunc(x)`:    returns signed integer truncated to float `x`. If `x` is too large/small, returns `$7fff_ffff` or `$8000_0000`
`FRound(x)`:    returns signed integer closest to float `x`, with rounding. If `x` is too large/small, returns `$7fff_ffff` or `$8000_0000`

Conversion from string:

`FromString(ptr)`: reads a float from a string. The string may represent the float in ordinary or in scientific notation, in which case the exponent is specified by `E` (so e.g. "100" may be written "1E02").

Display using SEND:

`SendFloatSci(x)`:   uses SEND to output float `x` in scientific notation like 1.000000E+02
`SendFloatPlain(x)`: uses SEND to output float `x` in ordinary notation
`SendFloat(x)`:      uses SEND to output float `x`; selects between scientific and ordinary notation based on the size of the float

License: MIT
