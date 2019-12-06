                              SpinLMM
                            Version 1.0

SpinLMM is an enhancement to the Spin interpreter that provides an LMM interpreter.
This enables LMM PASM routines to be executed directly from Spin program in a single
cog.  The program demo.spin demonstrates the use of SpinLMM to implement a half duplex
serial port and floating point functions in LMM PASM.

The demo program is run by compiling and loading the top object, demo.spin.  This
includes the objects HalfDuplexSerial and float_lmm.  These objects use the SpinLMM
object to execute LMM PASM code.  The object floatstr is also included to provide
conversions between floating point numbers and ASCII strings.

SpinLMM uses special operators that are not supported by the Parallax Propeller Tool.
It must be compiled with BST or  Homespun.  The serial port is set to operate at 57,600
baud.

For more information, please refer to the SpinLMM document.