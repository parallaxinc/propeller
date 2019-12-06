# Dynamic Math Lib

By: m.k. borri

Language: Spin, Assembly

Created: Apr 5, 2013

Modified: April 5, 2013

A modified version of Float32Full that allocates cogs dynamically. Somewhat slower than the original, but only uses up one cog, and can be shared between multiple objects. Just call it from all the objects you need to do floating point math, and it'll handle itself. If all cogs are busy at a given moment, it falls back to FloatMath routines.
