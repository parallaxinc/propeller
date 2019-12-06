# 4x4 Keypad Reader DEMO

By: Parallax Inc

Language: Spin

Created: Jan 22, 2015

Modified: January 22, 2015

DEMO displays on a VGA monitor.

Uses a capacitive pin approach to read a 4x4 keypad.

*   PRO's - No resistors, capacitors, or external IC's required.
*   CON's - requires 8 I/O's

The keypad decoding routine only requires two subroutines and returns the entire 4x4 keypad matrix into a single WORD variable indicating which buttons are pressed. Multiple button presses are allowed with the understanding that ‚ÄúBOX‚Äù entries can be confused. An example of a BOX entry... 1,2,4,5 or 1,4,3,6 or 4,6,\*,# etc. where any 3 of the 4 buttons pressed will evaluate the non pressed button as being pressed, even when they are not. There is no danger of any physical or electrical damage, that's just the way this sensing method happens to work.
