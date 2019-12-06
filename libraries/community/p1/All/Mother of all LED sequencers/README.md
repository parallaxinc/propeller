# Mother of all LED sequencers

By: Ray Tracy

Language: Spin

Created: Apr 11, 2013

Modified: August 25, 2013

This module is a modified copy of my module "Mother of all LED Sequencers" In simple terms this software takes bit patterns from memory and passes them to the I/O ports. It will work with the Propeller demo Board, The Quickstart board and the PropBOE board. It also works with an led driver based on a 74HC595 shift register of my own design (See MyLed object for details).  
The differences between this and the original OBEX module is that first this is all spin, second this uses a circular list, and third this is modified to be able to wait for an input rather than being strictly timed sequences.
