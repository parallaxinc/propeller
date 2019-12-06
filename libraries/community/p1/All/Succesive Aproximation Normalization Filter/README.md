# Succesive Aproximation Normalization Filter

By: Parallax Inc

Language: Spin

Created: Jan 22, 2015

Modified: January 22, 2015

Purpose: Take a data value where you know the upper and lower limits and "normalize" the data so that it proportionally scales to a binary weighted value.

For instance, say you have a potentiometer that reads 204 on one extreme and 8453 on the other extreme.  ...And the current value is 2834. You want to scale that to a 12-Bit number?  Simply load the Data, BitResolution, RefLOW, RefHIGH variables and call the function.  The returned value will contain the result. 1306 in this case.
