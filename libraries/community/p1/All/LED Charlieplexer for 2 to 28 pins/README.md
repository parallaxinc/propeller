# LED Charlieplexer for 2 to 28 pins

By: Drew Walton

Language: Spin

Created: Apr 10, 2013

Modified: April 10, 2013

This is a charlieplexing object for using a few pins on the propeller to control a lot of LEDs. The number of LEDs controlled ranges between 6 LEDs using 3 pins to 756 LEDs using 28 pins (though I have not tested that many). The number of LEDs can be determined by the following formula:

pins \* pins - pins = LEDs that can be controlled

A demo is included.
