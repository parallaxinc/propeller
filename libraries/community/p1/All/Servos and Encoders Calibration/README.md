# Servos and Encoders Calibration

By: Richard Brockmeier

Language: Spin

Created: Apr 16, 2013

Modified: April 16, 2013

Generates correction factors for the PropBOE-Bot Servo Drive.spin object.  
For each target speed, this object will adjust the faster motor to match the slower motor speed. When the testing is completed, the routine will write the code to be pasted into the DAT block of the PropBOE-Bot Servo Drive.spin object to a microSD card.  
Used a microSD card, as I could not copy the results from the Parallax Serial Terminal, this also allows the routine to be run without the PropBOE being connected to a Computer.
