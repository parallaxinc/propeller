# Quad quadrature encoder object

By: MarkT

Language: Spin, Assembly

Created: Mar 20, 2014

Modified: March 20, 2014

PASM object to handle one to four AB quadrature encoders in one cog.  Uses WAITPNE instruction to minimize power consumption when idle.

All transitions are accounted for and the input pins are read simultaneously avoiding possibility of faulty accounting unless the rate is too high a frequency.  Expected throughput is one encoder at upto 1M counts/second (250k pulses/sec) and four encoders at about a quarter that rate if simultaneously active.

Errors (when both A and B change within one loop of the driver) are detected and an error count is updated.  The object provides a simple 32 bit encoder count and an error count per encoder.  Unused channels are marked by giving $FF as pin numbers for that channel.  There is no restriction on pin numbering at all.

A simple example is provided.
