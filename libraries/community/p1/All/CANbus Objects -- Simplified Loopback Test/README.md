# CANbus Objects -- Simplified Loopback Test

By: Jon Titus

Language: Spin

Created: Jun 3, 2016

Modified: June 3, 2016

This archive contains methods that send and receive CANbus frames; that is, formatted messages.  
The two demonstrations included in this folder simplify those in the "CANbus Objects" code also posted in the OBEX.  The demos give novices more information about what happens in the various operations. No loops that alter data, no Remote Transmission Requests, etc... The bus operates at 1 Mbits/sec and sends data to a receiver within the same Propeller IC. The receiver sends information to the Parallax Serial Terminal on your PC to display a CAN identifier and data in a frame (message) as hex values. These demos do not include 29-bit (extended) addressing, nor do they test for errors.  You will find those capabilities in the included "CANbus Writer 1 mbps" and "CANbus Reader 1 mbps" files included in the zip file.  Thanks go to Chris Cadd who created the reader and writer files and methods.  Nicely done, Chris.

I aimed to keep the examples easy to use and easy to understand.  They provide for basic CAN communications.

Includes:  
A stand-alone writer, requiring one cog  
A stand-alone reader that reads up to 1Mbps but requires two cogs  
Two demonstrations of basic CAN operations
