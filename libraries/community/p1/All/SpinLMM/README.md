# SpinLMM

By: Dave Hein

Language: Spin, Assembly

Created: Apr 16, 2013

Modified: May 20, 2013

SpinLMM is an enhancement to the Spin interpreter by integrating an LMM PASM interpreter. This enables PASM routines to be run in the same cog that is executing Spin code. A demo program is included that implements a serial port and basic floating pointer routines in LMM PASM. These rouines run in a single cog along with the main program, which is written in Spin.

Note: There is an error in the SpinLMM.pdf document that uses pcurr instead of dcurr when referring to the Spin stack pointer. This is corrected in the document SpinLMM10a.html.
