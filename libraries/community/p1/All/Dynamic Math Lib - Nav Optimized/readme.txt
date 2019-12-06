Object: Dynamic Math Lib v2
Author: Matteo Borri


This is an update of my dynamic math lib. It breaks FLOAT32A compatibility with respect to the other one, but is a lot smaller and keeps all the functions that are used in navigation. It's also somewhat faster.

Essentially, it dynamically allocates one or more cogs (if they are available) to act as FPUs, like in Float32. You don't need to call the start and stop methods because that's been automated; this allows multiple objects to share a FPU cog, on a first come first serve basis.

If no cog is available at that time, the object acts as a souped up FloatMath (for example, you can do sin, cos, tan and atan2). Functions specific to navigation such as going from arcminutes to meters also exist.

An interesting feature is the DoParallelOp capability that has the FPU cog do one math operation while the local cog does another. I recommend only using this after you know your function works sequentially, but if used properly it speeds things a lot if a FPU cog is available while not slowing anything down if it's not.

If you want a version that is fully compatible with FLOAT32A get my other library. I have every plan to eventually optimize this further so that the FPU cog code stays resident and other objects can just call it, but not now.

You can just call the operations in this library like you would call math routines on a home computer, it tracks cog usage internally (you can force it to request a cog or to never ask for one, if you want, though). Just have your other objects load this and call its operations normally -- you are guaranteed to not run out of cogs if doing so.

If you use this in your project, drop me a line at mkb@libero.it as if enough people use my work, I can put that in my curriculum and this will help me get into grad school.
