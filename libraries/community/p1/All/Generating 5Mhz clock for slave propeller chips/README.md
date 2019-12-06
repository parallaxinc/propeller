# Generating 5Mhz clock for slave propeller chips

By: Mark Owen

Language: Spin

Created: Nov 23, 2015

Modified: November 23, 2015

These snippets demonstrate how to use a system counter to generate a 5Mhz signal for use in driving one or more secondary (slave) propeller chips.  It is based on several hours of dredging the forums and documentation for the technique, which turns out to be in fact trivial.  It has been tested with three prop chips wired up as a master and two slaves.  Testing included using a secondary counter as a positive edge detector to monitor the output signal frequency for 244.140625¬µS over 100 repetitions with the result being that the generated signal was observed to be at ~5.086Mhz, a ~1.7% error.  Good enough for my purposes.  Hopefully this will save someone else some time.

Wiring the props together amounts to nothing more than connecting an output pin driven by a counter on the master propeller (which has a crystal installed) to the XI pin(s) of the other propeller chip(s) (without crystal(s) installed); adding a 1Meg ohm pulldown resistor to each slave(s) RESn pin to keep it from starting initially and connecting the slave(s) RESn pin(s) to an output pin on the master which will be driven high once the clock is running.

Contents of attached file:

Snippet 1 : Code for the master propeller to generate the clock;

Snippet 2 : Code for the slave propeller(s);

Snippet 3 : Code for timing test application using Parallax Serial Terminal for output and clock signal on pin 27.
