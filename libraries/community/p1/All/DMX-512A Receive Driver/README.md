# DMX-512A Receive Driver

By: Timothy D. Swieter

Language: Spin, Assembly

Created: Apr 5, 2013

Modified: April 5, 2013

This program receives and parses a DMX-512A data stream. DMX is a protocol for controlling lighting equipment and accessories. This program is based on information gathered around the web related to ANSI E1.11 ‚Äì 2004: Entertainment Technology - USITT DMX512-A - Asynchronous Serial Digital Data Transmission Standard for Controlling Lighting Equipment and Accessories. This program captures all 513 slots of data (1 start byte and 512 data bytes) but also recognizes if a short packet is transmitted. This is an assembly language driver that is highly commented. The program runs in its own cog. Included is a simple demo file, but the demo code is not all that functional and rather short.

Version 1.4 adds the ability to get timing statistics about the DMX packet. This is useful to verify how your receiver and transmitter stacks up to the standard.
