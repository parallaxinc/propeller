# ADC0838 Channel Debug

By: Bryan Kobe

Language: Spin

Created: Jul 23, 2007

Modified: June 17, 2013

This series of objects is used to communicate with the ADC 0838 vis a serial interface. After one channel is read by the ADC, then the Propeller, it is sent out to the serial port to the host computer. I used this object to test all of the channels of the chip to make sure the chip was in working order. This code can also be modified for the ADC0 0832 and the ADC 0834 chips with some simple modifications to the code and the chip register data.
