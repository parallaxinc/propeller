# F32 - Concise floating point code for the Propeller.

By: lonesock

Language: Spin, Assembly

Created: Apr 5, 2013

Modified: October 16, 2013


F32 has all of the functionality of Float32Full in a single cog (except the user-defined function mechanism). Compared to Float32Full F32 is faster, and has some corner cases corrected. It also adds a few functions (Exp2, Log2, FloatTrunc, FloatRound, UintTrunc).

* v1.6 - found the bug in the ATan2 code (big thanks to Duane Degn)
* v1.5 - optimizations as suggested by kuroneko...THANKS!
* v1.4 - fixed bug in LOG due to _Table_Interp not handling table address overflow. 0 longs free [8^(  {mods by Marty Lawson...THANKS!}
* v1.3 - fixed a bug in FRound...THANKS John Abshier!! Faster wait loops.
* v1.2 - adds a more detailed PASM demo, fixes dispatch table offsets
* v1.1 - adds PASM calling to demo
* v1.0 - initial release
