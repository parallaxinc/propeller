# DMX_Dimmer24

By: Rick Asche

Language: Spin, Assembly

Created: Oct 12, 2013

Modified: October 12, 2013

This object uses 24 pins of the Propeller to drive SSR's to get a full range AC dimmer. It uses 4 cogs, including the jm\_dmxin driver. The dimmers can be any type of SSR that is optically isolated from AC power. I expanded Jon McPhalan's 4 channel dimmer from the Prop Controller project to handle 12 channels and duplicated the code in two cogs to get the total of 24. Pins 1 thru 24 are the dimmer channels, Pin 0 is used for the DMX input. Phase angle control is done by adding to the DMX level and getting the number to roll over. If the carry flag is set, that channels output bit is set. The controllers built with this code are driving my animated christmas light display. Simply change the first address constant to change the range of DMX address space. Sorry, there are no external address selector switches. AgingBeaver aka Rick Asche.
