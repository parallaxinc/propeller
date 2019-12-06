# Augmented Assembly Code (PreSpin ver)

By: Bob Anderson

Language: Assembly

Created: Nov 7, 2009

Modified: May 2, 2013

Version 1.01 adds a very useful beginBlock endBlock formatting feature that cleanly separates AAC lines from emitted PASM lines. It makes the AAC lines look like pseudo code. The result is very easy to read. See the manual for examples.

This program works in conjunction with PreSpin and the Propeller Tool as an aid for people who write assembly code for the Parallax Propeller¬© chip. It is a preprocessor to the Propeller Tool.

PreSpin is a preprocessor that adds a macro capability, comprehensive conditional compilation, and "include" files. The version supplied in this distribution (PreSpinAAC) then calls AAC to do its preprocessing.

The AAC (Augmented Assembly Code) preprocessor looks for "tagged" lines in DAT blocks and emits a second file for subsequent processing by the Propeller Tool.

AAC provides: indexing and indirection for all standard opcodes; a loop structure that can be nested; a case control structure that can be nested; conditional execution of the if...elseif...elseif...else...endif type that can be nested; simple substitution statements of the form sum += y\[k\]; a convention for declaring and using subroutines that allows for nesting of subroutine calls; a rudimentary conditional compilation feature.

Note: the Context help feature of PreSpin has an index for "Propeller Manual v1.01.pdf". That document is available from Parallax and is alo provided as an auxiliary file for this object. That pdf file is almost 5MB, so I didn't want to put it in the primary distribution.

Note: if you want to use the latest (nice) Propeller Manual, you will have to rename it from "Propeller Manual v1.1.pdf" to "Propeller Manual v1.01.pdf" and load a new index file. I have supplied the index file to use (PropellerManual1.1.txt). It will have to be renamed to PropellerManual.txt for PreSpin to find and use.

AAC is written in C# and built using Microsoft Visual Studio 2008. It uses .NET Framework 2.0 (and above)

The distribution contains some sample files and a revision history.

There is a complete manual built into the program. See ReadInstallation.txt for further instructions.

Tip: if you can't see the manual, open the .chm file manually and tell it to always trust the program.

Note: The download file is 2.1MB. Of that, 2.0MB is due to the .chm manual
