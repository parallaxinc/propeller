# Lock-Bit Demo

By: Jon Titus

Language: Spin

Created: Oct 2, 2015

Modified: October 2, 2015

This code demonstrates the use of a lock bit to "protect" the USB serial port on a Propeller I QuickStart board so two new cogs can run programs and both can have exclusive use of the _Parallax Serial Terminal.spin_ object to display information in the Parallax Terminal window. Each cog routine waits for the lock bit to become "open." Then it closes the lock and uses the serial communications. At the end of its task, the cog opens the lock so the other cog may then lock it and have exclusive use of the serial communications.  At the end of its task, the second cog "opens" the lock bit.  The Terminal window displays information about the progress of the code in each cog.
