# tsl230_pi_demo

By: BR

Language: Spin, Assembly

Created: Apr 17, 2013

Modified: April 17, 2013

TAOS TSL230 light to frequency sensor driver. Uses the PULSE INTEGRATION method to estimate light intensity (i.e. pulse outputs from TSL230 are accumulated for a fixed period of time). Based on the original object by Paul Baker, with various modifications including use of a moving average filter in the assembly routine to smooth the output.

For high bandwidth, less precise measurements of light intensity, try the ‚Äúip‚Äù (interpulse) object, tsl230\_ip\_demo, instead.
