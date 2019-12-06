# Modbus RTU Master

By: Albert Emanuel Milani

Language: Spin

Created: Apr 30, 2016

Modified: August 30, 2016

Implements Read Multiple Holding Registers, Read Multiple Input Registers, and Write Single Holding Register.

This uses and comes with Duane Degn's 512 byte buffer version of Tim Moore's original 4 port serial driver.  Anything descended from Tim Moore's driver should work fine, but I've only tested it with Duane Degn's version.  Duane Degn also has a 128 byte rx buffer per port version, if you need the ram for other things.

I somehow ended up with two versions of this driver.  I merged them and posted the result here.  The two versions that went into the merge both worked, but I haven't tested the result, so please PM me (Electrodude) on the Parallax Forums if you have any problems.  
