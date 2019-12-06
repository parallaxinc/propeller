# Augmented Assembly Code (standalone ver)

By: Bob Anderson

Language: Assembly

Created: Oct 28, 2009

Modified: May 2, 2013

Version 1.01 adds a very useful beginBlock endBlock formatting feature that cleanly separates AAC lines from emitted PASM lines. It makes the AAC lines look like pseudo code. The result is very easy to read. See the manual for examples.

This program is meant to help people who write assembly code for the Parallax Propeller¬© chip. It is designed as a preprocessor to be used in conjunction with the Propeller Tool. It looks for "tagged" lines imbedded in normal PASM files and emits a second file for subsequent processing by the Propeller Tool.

It provides: indexing and indirection for all standard opcodes; a loop structure that can be nested; a case control structure that can be nested; conditional execution of the if...elseif...elseif...else...endif type that can be nested; simple substitution statements of the form sum += y\[k\]; a convention for declaring and using subroutines that allows for nesting of subroutine calls; a rudimentary conditional compilation feature.

This is a Windows program written in C# and built using Microsoft Visual Studio 2008. It uses .NET Framework 2.0 (and above) and is compiled for 32 bit targets (it will work fine in the 64 bit world - the opposite is unfortunately not always true).

The distribution now contains a sample file and a revision history.

There is a complete manual built into the program. Click on Help|AAC manual to bring it into view.

Note: The download file is 2.6MB Of that, 2.1MB is due to the built-in manual
