# Shift Register in and out

By: Karman

Language: Spin

Created: Apr 16, 2013

Modified: April 16, 2013

Shift in - out object to work with the 74x165 parallel to serial input and 74x595 serial to parallel output shift registers.

This is the first version of code, tested on 16 inputs and 16 outputs and seem to work fine.

Uses only 3 pins for up to 32 inputs and 32 outputs. (32bit)

Currentley polling at ~15Khz (15 000 reads writes / second) so please be aware of slight delays between clicking and input reading. (will recode in assembler to make faster in next version). Inputs are read first, then outputs are shifted out in same routine.

No seperate cog or crystal needed.

version 0.02 --> corrected (i hope) connection diagram
