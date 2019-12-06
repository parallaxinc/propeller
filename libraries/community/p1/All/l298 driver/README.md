# l298 driver

By: m.k. borri

Language: Spin

Created: Apr 10, 2013

Modified: April 10, 2013

A very simple driver for the popular L298 chip. Uses one cog if the chip is actively being driven. Can auto-turnoff using a timer, useful in case of remotely driven systems where the connection is unreliable. Based on the dual PWM driver from Kyle Love, I mostly just added the direction pins.
