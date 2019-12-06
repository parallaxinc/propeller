# mixingboard3.1.spin

By: Larry W. Schoolcraft

Language: Spin

Created: Apr 11, 2013

Modified: April 11, 2013

Gives an eight value readout to a 50K ohm potientiometer utilizing the Parallax P8X32A Quick Start Development Board, Parallax 2x16 Serial LCD (optional), & using the FullDuplexSerial.spin object in the Propellar Library (optional). As you turn the Pot, LED's(P16-P23) light up/ shutdown in ascending/descending order along with the value "Velocity" on the display increasing/decreasing in decimal and binary. If you are not using the display, just run the object as is and it should work just fine.

**Added Note on 8/29/2012:** The Value for resistor R2 is incorrect as shown on schematic diagram, the correct value should be 20k ohms.

**Also needed:**

*   50K Ohm Potientiometer
*   An Assortment of Resistors and Capacitors(Values shown in
*   schematic daigram at the top of the object.)
*   1 LED
*   +5V Supply for LCD display(optional)

**Pro's:**

*   Gives a pretty acurate reading

**Con's:**

*   Uses 10 I/O pins.
*   Only gives Eight Values
