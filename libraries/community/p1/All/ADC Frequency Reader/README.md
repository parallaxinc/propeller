# ADC Frequency Reader

![adcthumb.jpg](adcthumb.jpg)

By: Brandon Nimon

Language: Spin, Assembly

Created: Jul 15, 2009

Modified: June 17, 2013

The ADC Input Driver (http://obex.parallax.com/objects/488/) does this object's frequency reading and a lot more. It is also compatible with all MCP3X0X ADCs.

ADC Frequency Reader:

This PASM-driven object reads values off of shifted inputs from ADCs like the 10-bit MCP3008 or a 12-bit MCP3208 and determines the channel's frequency. "Low" and "high" edge thresholds can be easily set in the program. Frequency is determined by multiple edge measurements which can be customized for speed or accuracy. The program can operate up to about 148 thousand ADC samples per second (at 10-bits or 133ksps for 12-bits).

This object could be used for anything from simple frequency reading to audio recognition and multi-input signal processing.

Version 1.1 allows for the RX and TX pins to be on the same IO pin.

Known supported ADCs:

MCP3208, MCP3204, MCP3008, and MCP3004
