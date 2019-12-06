# Keyboard driver for both Hydra and Demo Board

By: Michael Green

Language: Spin, Assembly

Created: Apr 10, 2013

Modified: April 10, 2013

This is a slightly modified version of the keyboard driver included with the Propeller Tool. Rather than being passed the pin numbers of the clock and data pins the 1st even pin number of the group of pins used is passed see the comments in the source. For the Hydra the 2nd odd pin number is passed. The driver handles the differences between the Hydra and DemoProto Board conventions. Now provides for a configurable break key.
