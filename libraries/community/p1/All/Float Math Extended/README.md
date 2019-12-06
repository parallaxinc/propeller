# Float Math Extended

By: Marty Lawson

Language: Spin

Created: Aug 30, 2013

Modified: August 30, 2013

Float Math Extended is a Spin only floating point library that supports all the trig and exponential functions that F32 and Float32full support. ( Fcmp, exp, exp2, exp10, pow, log, log10, log2, logB, sin, cos, tan, atan2, atan, asin, acos, frac, FMod, seed, random, isNaN, isInf) The code only uses stack variables, so one object can be safely used by multiple cogs. (except for random() but thread contention is helpful there) Current testing has focused on accuracy. The trig and exponential functions are about as accurate as a single precision number can be. Which is about 10-80x more accurate than the F32 exponential functions or the Float32full trig and exponential functions. (they use the Hub tables) Everything else has the same accuracy. Code speed is unoptimized. Many sections of the code will likely run 2-3x faster when optimized. Development thread http://forums.parallax.com/showthread.php/149233-integer-or-floating-point-LOG-functions-in-spin
