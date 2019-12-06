# ZyTemp Infrared Thermometer Driver

By: DogP

Language: Spin

Created: Apr 17, 2013

Modified: April 17, 2013

This demonstrates reading object and ambient temperatures with a ZyTemp (http://www.zytemp.com/) infrared  
thermometer. Embedded modules can be purchased, or they are commonly found as rebranded low cost handheld  
devices. This has been tested with TN105i2 (1:1 distance to spot) and TN203 (6:1 distance to spot, plus laser).  
These were rebranded as CEN-TECH #93983 and #93984 respectively, from Harbor Freight.

These modules communicate using an SPI-like protocol. The thermometer must be the Master though, so I modified  
the SPI engine to support Slave operation (and included it with this demo). The pins are accessible by opening  
the case of either thermometer. There's a 0.1" header at the bottom of both PCBs with labels.

The pins are labeled:

*   A: Action
*   G: Ground
*   C: Clock 
*   D: Data
*   V: Vdd

This demo connects Clock to P0, Data to P1, Action to P2, and of course Ground to Vss.

To take readings, the Action pin is grounded by pressing the button. This demo watches that pin to determine  
when to read temperatures. This can also be pulled down at the pin if you'd like Propeller control. You must  
be careful though... the button does short this to ground, so I recommend putting in a series resistor (1k or so)  
to prevent shorting the output from the Propeller in case you press the button while connected. On the TN203,  
the laser seems to be grounded through this pin as well, so there's ~10mA sunk when grounded. If you have the  
series resistor, you'll still get readings, but the laser won't light. This demo displays the object and ambient  
temperatures to the debug RS232 port.

While I haven't tried it, I believe you can power the thermometer through the Vdd pin. I've always left the  
internal battery installed and left Vdd disconnected though. I believe the laser on the TN203 is powered  
seperately though. You should remove the battery if powering from Vdd.

The modules have an EEPROM to store emissivity values, which can be changed, though this demo doesn't use that  
functionality. More information on the protocol, messages, and features can be found by downloading the manuals  
on the ZyTemp website.

This code was based on Beau Schwabe's SPI Spin Demo.

See forum post for more info/pics: http://forums.parallax.com/forums/default.aspx?f=25&m=453982 .
