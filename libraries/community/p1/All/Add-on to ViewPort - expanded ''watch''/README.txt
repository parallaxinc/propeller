
Quick start:

   0) Unzip the distribution to any convenient directory.

   1) Open ViewPort V4.2.5 (or later) and run the demo program 

         "01_Four Bit Counter.spin"  (in the tutorials directory)

   2) Open ViewPortWatcher.exe

   3) Use the "File|Open main script file" menu and open (in distribution dir)...

        "01_Four Bit Counter main script.vpwScript"

   4) Click the Run button under the Main script text window.

   5) Use the "File|Open set variable script" menu and open...

        "01_Four Bit Counter set vars.vpwScript"

   6) Click the Run once button under the "Set variables" text box to modify freq.

   7) Read MainFormHelp.txt (also available through the Help menu item on the program GUI)

======================================================================================

This program is an extension to the basic "watch shared variable" capabilities of ViewPort.  It executes script statements that can deal with arrays and Spin floats and show variables in the following formats:

   int  uint  float  binary  hex  bit

There is a full expression evaluator that accepts the following operators:

   *  /  div  mod  &  |  ^  >>  <<  ~  

======================================================================================

Author: Bob Anderson  (bob.anderson@centurytel.net)   December 20, 2009

Credits: Hanno Sander, author of ViewPort (www.hannoware.com)
         Terence Parr, author of ANTLR (used to build <expr> evaluator using formal grammar)


