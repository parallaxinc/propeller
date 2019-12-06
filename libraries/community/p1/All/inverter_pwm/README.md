# inverter_pwm

By: MarkT

Language: Spin, Assembly

Created: Aug 3, 2014

Modified: August 3, 2014


Options are 3 or 6 pin output (with two dead-time options in the latter case).

Period is anything you want although >100kHz would be pushing it, realistically.

3 cogs are needed to get switching accurate to one cycle (12.5ns) and allow
fine-grained control at high PWM frequencies.  At 16kHz there are over 2400
levels per channel (which you supply as a signed value in range -1200 -- +1200)"
756:"A single cog 3-phase inverter PWM object capable of programmable dead-time and driving 6 pins.

The limitation is that the frequency is fixed w.r.t. master clock.&nbsp; The granularity is 4 clock cycles as instructions are used to drive the pins rather than waitcnt.

The operating frequeency is Mclk / 3440 and the samples are read and used at twice this rate, Mclk / 1720, so that each edge of the symmetric, phase-correct, PWM signals is controlled.

The pins can be any 6 pins.

Example provided"
758:"
Features an easy to use Spin handler to access all of the commonly used features of the MCP2515 CAN controller.  Includes a Spin-based and a PASM-based SPI driver.
