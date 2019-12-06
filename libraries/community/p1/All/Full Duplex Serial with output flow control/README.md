# Full Duplex Serial with output flow control

By: Mark Owen

Language: Spin, Assembly

Created: Feb 14, 2015

Modified: December 4, 2015

A slightly modified version of FullDuplexSerial incorporating a clear to send (CTS) pin for output flow control.

The  modifications to FullDuplexSerial are transparent to any process which does not need or want to use the CTS function. 

To use the CTS function, call the public SetCTSpin(ctsPin) method specifying the propeller IO pin to be used for output flow control.  

Although differently named here (FullDuplexSerial-wCTS.spin versus FullDuplexSerial.spin) it can be freely substituted for the original.  

This variant also includes BUFFERSIZE and BUFFER\_MASK constants set for 128 byte buffers rather than the 16 byte buffers in the original (concept borrowed from Parallax Serial Terminal).

This mechanism useful when transmitting data to 4D Systems displays which tend to bog down during certain text and graphic operations which causes their serial communication driver's input buffer to fill up. Said driver (according to its documentation and verification tests) discards incoming information once its buffer is full. In the case of these displays, the propeller IO pin can be wired to one of the display's 3.3 volt IO pins with suitable code on the display to set and reset the pin at some buffer thresholds.  This connection should be only be output from the display and input to the propeller hence the propeller's high impedance input state provides any necessary current limiting.

Revised Start method12/03/2015 to correct erroneous use of P0 as CTS when SetCTSpin has not been called prior to Start.
