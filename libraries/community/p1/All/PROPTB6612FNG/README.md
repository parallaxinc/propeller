# PROPTB6612FNG

By: Stefan Wendler

Language: Spin, Assembly

Created: Dec 11, 2013

Modified: December 11, 2013

**Introduction**
----------------

PROPTB6612FNG is a simple library to use the Thosiba TB6612FNG dual motor controller on the Parallax Propeller.

The driver offers methods to operate each motor individually or both motors together (by sending the same command to each, or sending a different command to each).

It optinally allows to adjust the speed for each motor in %. The Speed adjustment is done through the TB6612FNG PWM input. For each motor (A or B) speedcontrol through PWM is used, a Cog is reserved to generate the PWM.

Usage
-----

To demonstrate the usage, a examples is provided:

*   `SimpleExample`: shows the basic usage of the library
