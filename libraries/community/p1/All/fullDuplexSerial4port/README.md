# fullDuplexSerial4port

![4port.png](4port.png)

By: Tracy Allen

Language: Spin, Assembly

Created: Apr 9, 2013

Modified: April 9, 2013

*   Can open up to 4 independent serial ports, using only one pasm cog for all 4.
*   Supports flow control and open and inverted baud modes
*   Individually configurable tx and rx buffers for all 4 ports, any size up to available memory, set in CONstants section at compile time
*   Part of the buffer fits within the object's hub footprint, but even so the object is restartable (inspired by Duane Degn's thread).
*   Buffers are DAT type variables, therefore a single instance of the object can be accessed throughout a complex project.
*   Includes companion object in zip, dataIO4port, to handle numeric output and also numeric and string input from any of the four ports.
*   Includes 2 demos. Demo1 simply shows how to set up a single serial port for debugging. Demo 2 implements three serial ports, the first to send data to the second at high baud rate using flow control, and a loop to send the data out at a lower baud rate to a terminal screen, showing the use of various methods from fullDuplexSerial4port and dataIO4port.

*   Modified from Tim Moore's pcFullDuplexSerial4fc. Changes and bug fixes include:
*   Flow control is now operational when called for, with correct polarity (bug correction)
*   Jitter is reduced, unused ports are properly skipped over (bug correction), operation speed is increased.
*   Stop bit on reception is now checked, and if there is a framing error, the byte is not put in the buffer.
*   Buffer sizes are flexible, set in CONstants, each port separate rx & tx up to available memory
*   Changes in pasm and in Spin methods to accommodate larger buffers, major reorganization of DAT section.
*   Added strn method for counted string, and rxHowFull method for buffer size.
*   Moved the numeric format methods such as DEC and HEX to companion object dataIO4port.spin. It is included in the .zip. Use that in order to maintain compatibility with methods in the original pcFullDuplexSerial4fc. Can be re-merged if desired. DataIO4port.spin also includes numeric and string input methods borrowed from PST (Parallax\_Serial\_Terminal.spin).
