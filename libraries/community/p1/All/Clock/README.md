# Clock

![clock_____.png](clock_____.png)

By: Jeff Martin

Language: Spin Spin

Created: Nov 27, 2006

Modified: August 23, 2013

**Provides clock timing functions to:**

*   Set clock mode and frequency at run-time using similar clock setting constants as with the _\_clkmode_ system constant; like the constant: _xtal1\_pll16x_
    
*   Pause execution in units of microseconds, milliseconds, or seconds, 
*   Synchronize code to the start of time-windows in units of microseconds, milliseconds, or seconds.

**Example of Use:**

`OBJ                                                 `

`  clk : "Clock"                  'Include Clock object in parent object`

`PUB Main`

`  clk.Init(5_000_000)            'Initialize Clock object with external frequency 5 MHz`

`  <...>`

`  clk.SetMode(XTAL1_PLL2X)       'Switch system clock to gain 1 and 2x wind-up (10 MHz)`

`  <...>`

`  clk.PauseMS(100)               'Pause for approximately 100 ms`

`  <...>`

**Clock Demo:**

The Clock Demo.spin object indicates the effects of clock source changes (speed changes) through the use of eight LEDs on the Propeller Demo Board; "scrolling" a lit LED back and forth across the eight-LED-display at a clock-dependant rate. The clock-dependant rate is created by using waitcnt with a fixed count, rather than relying on a factor of clkfreq (which changes according to clock speed).

When run, the eight-LED-display will flash when the clock source (and thus clock speed) has changed, and then will scroll the LEDs back and forth to demonstrate the relative speed of the clock.  The demo starts scrolling LEDs with a clock mode of xtal1+pll1x (5 MHz) then progressively increases up to xtal1+pll16x (80 MHz), then progressively decreases down to RCSLOW (‚âà20 MHz) and repeats the process again.
