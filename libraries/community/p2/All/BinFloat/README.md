
# Binary Floating Point Routines (IEEE-32 subset) 

By: Eric R. Smith

Language: Spin2

Created:  31-MAR-2021
Modified: 19-DEC-2021

Category: math

Description:

These are functions for performing floating point math in Spin2. To use, include a `BinFloat` object in your code, e.g.:
```
OBJ
  flt : "BinFloat"

' silly example that calculates (x +. y) /. 2.0
PUB calcAverage(x, y) : r
  r := flt.F_Div( flt.F_Add(x, y) , 2.0 )
```

The routines available are:

Basic Math:

`F_Neg(x)`:    return negative of floating point number `x`  (or use -. operator)
`F_Abs(x)`:    return absolute value of floating point number `x` 
`F_Add(x, y)`: return `x + y` (floating point) (or use +. operator)
`F_Sub(x, y)`: return `x - y`                  (or use -. operator)
`F_Mul(x, y)`: return `x * y`                  (or use *. operator)
`F_Div(x, y)`: return `x / y`                  (or use /. operator)
`F_Sqrt(x)`:   return floating point square root of float `x`


Trignometry:

These functions all can operate in degrees, radians, or with angles specified as fractions of a complete circle. Before calling any of the trig functions, set the angle format with one of the following calls:

`SetDegrees()`:  specifies that angles are in degrees
`SetRadians()`:  specifies that angles are in radians
`SetFraction()`: specifies that angles are in fractions of a circle

`F_Sin(angle)`:  returns sine of `angle`
`F_Cos(angle)`:  returns cosine of `angle`
`F_Tan(angle)`:  returns tangent of `angle`
`F_Asin(x)`:     returns inverse sine (angle such that `FSin(angle)` is `x`)
`F_ACos(x)`:     returns inverse cosine
`F_ATan(x)`:     returns inverse tangent
`F_ATan2(x, y)`: returns angle that the vector `(x,y)` makes with the x axis. *Note*: the order of parameters is different from the similar C function!

Exponentials and logs:

`F_Log2(x)`    : calculates log base 2 of x
`F_Log10(x)`   : calculates log base 10 of x
`F_Log(x)`     : calculates log base e (natural logarithm) of x
`F_Exp2(x)`    : calculates 2^x
`F_Exp10(x)`   : calculates 10^x
`F_Exp(x)`     : calculates e^x
`F_Pow(x, y)`  : calculates x^y, where both x and y are floats
`F_PowInt(x, n)`: calculates x^n, where x is a float and n is a signed integer

Conversions to/from integer:

`FromInt(n)`:   returns floating point number closest to the signed integer `n`
`FromUInt(n)`:  returns floating point number closest to the unsigned integer `n`
`F_Trunc(x)`:    returns signed integer truncated to float `x`. If `x` is too large/small, returns `$7fff_ffff` or `$8000_0000`
`F_Round(x)`:    returns signed integer closest to float `x`, with rounding. If `x` is too large/small, returns `$7fff_ffff` or `$8000_0000`

Conversion from string:

`FromString(ptr)`: reads a float from a string. The string may represent the float in ordinary or in scientific notation, in which case the exponent is specified by `E` (so e.g. "100" may be written "1E02").

Display using SEND:

`SendFloatSci(x)`:   uses SEND to output float `x` in scientific notation like 1.000000E+02
`SendFloatPlain(x)`: uses SEND to output float `x` in ordinary notation
`SendFloat(x)`:      uses SEND to output float `x`; selects between scientific and ordinary notation based on the size of the float

License: MIT
