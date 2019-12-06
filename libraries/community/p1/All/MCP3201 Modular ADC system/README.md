# MCP3201 Modular A/D system

By: frank freedman

Language: Spin, Assembly

Created: Apr 11, 2013

Modified: April 11, 2013

This is a modular controller for 1 or more paralleled MCP3201 ADC chips. Currently sampling about 100Ksps, it is intended to run as many ADCs as there are open cogs. On a single prop, that is N-2 for 6 parallel devices. with some trickery and using the common timing from the initial clockgenmodule, multiple props could be ganged together indefinitely using all 8 cogs in each. (assuming the acqmod is replacing cog 0).

Or you could use a couple per prop and use remaining cogs for high speed pipeline processing of the sampled data in a real time syncronous fashion. Don't let my imagination limit you.
