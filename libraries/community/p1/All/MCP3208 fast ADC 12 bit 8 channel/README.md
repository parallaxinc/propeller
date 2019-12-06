# MCP3208 fast ADC 12 bit 8 channel

By: Jim

Language: Spin, Assembly

Created: Apr 11, 2013

Modified: April 11, 2013

Modified version of Chip's original MCP3208 code. Designed to speed up the ADC process by doing all of the calculations in assembly code. Use for single and average ADC samples. A 10 sample average of ADC samples is six times faster than the original code. Same calling sequence as original code. Used for single mode ADC only. Does not provide DAC output. Deterministic output in the sense that it always takes the same number of clock cycles per sample(s). License added 2/27/08.
