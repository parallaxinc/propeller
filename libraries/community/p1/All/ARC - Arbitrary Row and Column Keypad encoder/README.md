# ARC - Arbitrary Row and Column Keypad encoder

By: Peter Jakacki

Language: Spin

Created: Oct 5, 2011

Modified: June 17, 2013

Here is a keyboard scanner that is not limited by the number or positions of the rows and columns in a keyboard matrix. Essentially you can take a bunch of unused pins from your Prop, even though they may be scattered here and there, and use these to scan a keyboard/keypad.

Any combination of row and column pins can be used, therefore any port pins that are non-sequential can be used. This also means a change of keypad which has different row and column conections can easily be accommodated. Matrix size is only limited by the number of port pins available so it is possible for instance to use 28 pins for scanning a 14x14 matrix of 196 keys and still have I2C and RXD/TXD lines available.
