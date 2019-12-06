FloatString v1.1
July 14, 2006

FloatString
-----------
- modified to add FloatToFormat routine
- FloatToString(single, width, numberOfDecimals)
- e.g. FloatToFormat(pi, 5, 2) would return the string " 3.14"
       FloatToFormat(0,  6, 1) would return the string "   0.0"
- see example of use in SensirionDemo


Notes

1) By default FloatString is coded to use the FloatMath object.
If you're already using the Float32 or Float32Full object in your
program, you can save space by changing the F : "FloatMath" definition
to use Float32 or Float32Full, since all of the functions in FloatMath
are already available in Float32 and Float32Full.

2) Just a reminder that Float32 and Float32Full both use cogs and
therefore require a start call at the beginning of a program. If you
change FloatString to use Float32 or Float32Full, any program that
uses the modified FloatString will need a start call.


