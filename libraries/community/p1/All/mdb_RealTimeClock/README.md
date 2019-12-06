# mdb_RealTimeClock

By: mathew boorman

Language: Spin

Created: Jan 27, 2010

Modified: May 2, 2013

Low resource RTC spin object.

No dedicated COG. Single instance is shared by multiple Objects. This version simply uses CNT and a pair of longs to track rollovers. It also uses one Lock. 99 Longs (with bst).

To operate correctly it needs to be polled at least twice per CNT rollover period. At 80Mhz this is about 30 seconds.

This includes its dependency on Bob Belleville's date\_time\_epoch (in Obex) It was loosley based on Mathew Brown's RealTimeClock.spin V1.01

I have plan to eventually implement methods to change the Propeller clock speed. This is required to keep a accurate time when the clock speed changes.
