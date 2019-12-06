# Basic Unipolar Stepper Driver Object with Limit Switches

By: Mark Owen

Language: Spin

Created: Feb 10, 2016

Modified: February 10, 2016

Basic driver object for a unipolar stepper motor with two limit switches using  a FIFO command queue and separate cogs for the motor driver and switch  monitor processes.

Nothing fancy, no acceleration / deceleration code is provided.  Such  code can be accomplished by the client process.  For example to  accelerate from minimum speed to maximum one may simply enqueue single step motor commands inside a dimishing time duration loop.

Tested using various salvaged unipolar stepper motors (5 and 12 volts) and custom driver boards for various "hobby" projects (eg: solar panel tracker, etc.)

Example usage code:

*   `` `CON` ``
*   `` `  _CLKMODE = XTAL1 + PLL16X   'Setting up the clock mode` ``
*   `` `  _XINFREQ = 5_000_000        'Setting up the frequency` ``

*   `` ` {Limit Switches}` ``
*   `` `  LSWLpin          = 0             ' 220≈í¬© in series to 10k pullup to Vdd and SPST NO switch, active low` ``
*   `` `  LSWRpin          = 1             ' 220≈í¬© in series to 10k pullup to Vdd and SPST NO switch, active low` ``
*   `` ` {Unipolar Stepper Motor Driver}` ``
*   `` `  SMphApin      = 2             ' 220≈í¬© output to MOSFET gate   A` ``
*   `` `  SMphBpin      = 3             ' 220≈í¬© output to MOSFET gate   B` ``
*   `` `  SMphA_pin     = 4             ' 220≈í¬© output to MOSFET gate  /A` ``
*   `` `  SMphB_pin     = 5             ' 220≈í¬© output to MOSFET gate  /B` ``

*   `` `OBJ` ``
*   `` `  SM    : "Stepper"` ``

*   `` `PUB Main | delay` ``
*   `` `  SM.Start(SMphApin,SMphB_pin)` ``
*   `` `  SM.StartWatchLSws(LSWLpin,LSWRpin)` ``
*   `` `  delay := (CLKFREQ/1000)* 8 ' mS` ``
*   `` `  SM.EnqueueCmdArg(SM#REVERSE,false)` ``
*   `` ` ' run until either limit switch is triggered` ``
*   `` `  repeat while not SM.LSwStates` ``
*   `` `      SM.EnqueueCmd(SM#SINGLE_STEP_AND_HOLD)` ``
*   `` `      waitcnt(delay + cnt)` ``
