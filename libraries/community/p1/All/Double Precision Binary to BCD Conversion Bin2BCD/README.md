# Double Precision Binary to BCD Conversion Bin2BCD

By: Tom Crawford

Language: Spin, Assembly

Created: Sep 9, 2016

Modified: September 14, 2016

This PASM object converts a double precision binary positive integer to BCD.  The spin module passes the address of a 2-entry long binary integer, and the address of a 20-byte vector.  The pasm program converts the input integer to binary-coded-decimal and writes the 20-digit result into the vector.  The worst-case number (99...999) require just less than 50 usec, including transferring the result to hub memory.  Updated Sept 14, 2016 to reduce inner loop to three instructions, as well as other clean-ups.
