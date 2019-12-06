# Event Driven LSA (Logic State Analyzer) ViewPort

By: Bob Anderson

Language: Spin, Assembly

Created: Dec 20, 2009

Modified: May 2, 2013

This add-on only works properly with version 4.2.5 of ViewPort (see www.HannoWare.com).

This program is particularly useful during the development of SPI and I2C drivers for the Propeller Chip. It provides a stable display that makes it easy for precise measurements to be taken.

One of the minor miracles of the Propeller chip is that all 8 cogs can "see" the state of all 32 I/O pins at the same time and can read and modify locations in Hub memory at any time. This makes it possible to "self-test" during development on a Propeller by using one or more cogs to "watch" what's going on in Hub memory with variables and read the state of I/O pins. This is the approach that ViewPort takes. In order to see/modify variables, one cog is loaded with a program (Conduit.spin) that streams at up to 2 Mbps the value of selected variables to the ViewPort GUI. Conduit.spin provides a bi-directional link that allows variable values to be changed while the program-under-test is running. It also provides a mechanism for the setting of breakpoints and single stepping through a SPIN program.

ViewPort has a second program (QuickSample.spin) that can be loaded into a cog (or optionally 4 cogs). This program continually samples all 32 I/O pins at a fixed rate and streams their values back to the ViewPort GUI where a logic state analyzer (LSA) displays the results. QuickSample can be configured from the ViewPort GUI to take samples at a rate as fast as one sample every 4 instruction times, which is every 200 ns when the Propeller is running at 80 Mhz. 360 samples are taken in a burst, then streamed to the GUI for display.

The Event Logger program is an add-on that communicates with ViewPort via the DDE (Dynamic Data Exchange) protocol and provides an event oriented LSA as opposed to the sampling LSA that ViewPort includes. The EventLogger.spin program is loaded into a cog (either instead of QuickSample or in addition to). After a specified trigger condition is satisfied, this cog records the time (via the CNT register) of changes of state on a specified set of I/O pins. Up to 99 events will be recorded and then sent via Conduit.spin running in the Propeller chip to ViewPort and on to the Event Logger Client.exe where a GUI displays the results in a plot that can be zoomed, scrolled, measured, printed, etc.

An event driven LSA is better able to deal with "bursty" data where some events of interest take a relatively long period of time, but are then followed by much faster events. On a sampling LSA, the sample rate would have to be set low enough to allow the long events to be seen, but then there would be insufficient resolution to see the fast events accurately. Sometimes ways can be found to work around this conflict, but an event driven LSA is easier to use in such a case.

The EventLogger.spin program uses a 4 instruction sequence to capture each event. That sets a lower limit of 200 ns on the shortest pulse that it can reliably detect. This is the same as QuickSample running at its highest speed. But EventLogger can capture a 250 ns "runt" pulse and continue to accurately detect much much longer pulses.

QuickSample runs continuously and always shows what's happening on all 32 I/O pins. EventLogger only shows what's happening on selected pins and only for 98 state changes past the trigger point. They are different tools with different strengths. Sometimes you need both, and you can run QuickSample and EventLogger at the same time!
