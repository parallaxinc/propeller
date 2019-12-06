# Motor Minder

By: Thomas Doyle

Language: Spin

Created: Apr 11, 2013

Modified: April 11, 2013

Motor\_Minder monitors the speed and revolution count of a motor using a shaft encoder. It was tested with the Melexis 90217 Hall-Effect Sensor (Parallax 605-00005) and a single magnet mounted (Parallax 605-00006) on the motor shaft. It should work with any type of sensor that puts out one pulse per revolution. The object runs in a new cog updating varibles in the calling cogs address space.
