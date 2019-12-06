# TSL3301 digital line sensor driver

By: Marty Lawson

Language: Spin, Assembly

Created: Apr 17, 2013

Modified: April 17, 2013

Includes a Spin and Assembly driver for the TSL3301 digital line image sensor. Spin can do line integration times longer than 1mS, while the assembly driver can do integration times as short as 2uS. The spin driver should be capable of ~10-20 lines per second, while the Assembly driver should work at up to 5000 lines per second. The assembly driver also includes the option to trigger capture with an input pin. _(minimum 500nS delay from the trigger to the electronic shutter opening)_
