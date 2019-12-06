# PCF8583 Real Time Clock Driver

By: photomankc

Language: Spin

Created: Mar 28, 2013

Modified: April 12, 2013

**Driver for the NXP PCF8583 Real Time Clock.**

*   I2C communication with chip.
*   Get/Set functions for RTC time registers.
*   v0.95 - Burst Read for full date or full time and other sequential RAM.
*   v0.95 - Faster I2C code.
*   Augments the RTC's 4 year counter with YYYY format date storage in free RAM and simple periodic correction function to keep it in sync. Correction should be called at least once per year to keep the free RAM year updated.
*   Can use COG counter/pin to track running seconds using the RTC's square wave output.
*   Access to 238 bytes of free RAM.
*   Access to all alarm registers for advanced use.

This RTC is not battery backed but a simple capacitor and a diode to gate it from the rest of the circuit will allow it continue counting through brief outages. 1000uF will provide a couple minutes. A 1F supercap should provide for 17-20 hours.

Use the TV\_Text object from the archive file. I have added several helper functions to it so the standard TV\_Text will not work.
