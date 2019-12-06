# Single Pin Sigma Delta ADC Driver v1

By: Parallax Inc

Language: Spin

Created: Jan 22, 2015

Modified: January 22, 2015

Theory of Operation:

A key feature with this sigma-delta ADC is that the drive pin is only an output for a brief amount of time, while the remainder of the time it is an input and used as the feedback pin. 

A Typical Sigma Delta configuration will have the Drive pin always set as an output and driven either HIGH or LOW while another pin is always an input and used as Feedback.  This technique combines the two methods so that only one pin is necessary.
