# tsl230_ip_demo

By: BR

Language: Spin, Assembly

Created: Apr 17, 2013

Modified: April 17, 2013

Demo of TAOS TSL230 light to frequency sensor driver with manual and auto scaling capabilities. This driver uses the INTER-PULSE method to estimate light intensity (i.e. counts ticks between falling edge-rising edge pairs in TSL230 output pulse train). Yields highest possible update bandwidth (>1M samples/sec in bright light) but also more susceptible to noise.

For low bandwidth, higher precision measurements of light intensity, try the ‚Äúpi‚Äù (pulse integration) object, tsl230\_pi\_demo, instead.
