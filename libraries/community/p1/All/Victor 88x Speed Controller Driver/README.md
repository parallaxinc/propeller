# Victor 88x Speed Controller Driver

![victor_thumbnail.JPG](victor_thumbnail.JPG)

By: Bryan Kobe

Language: Spin

Created: Apr 17, 2013

Modified: April 17, 2013

This object is used to interface to the Victor 880 series speed controllers from IFI Robotics. These are high amperage controllers, reasonably priced, and interface easily to projects (To drive the motors, simply use the range -1000 to 1000, with the motor centered at 0. -1000 to 0 will drive the motor reverse, and 0 to 1000 will drive the motor forward.) The object was mocified from the Servos Object developed by Andy Lindsay (Parallax), and supplies a longer pulse period to drive the signal pin on the motor controller.
