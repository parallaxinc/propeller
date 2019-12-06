# Seven segment display driver, and Charlieplex driver

By: Chris Gadd

Language: Spin, Assembly

Created: Jul 16, 2014

Modified: July 18, 2014

The segments are also required to be on contiguous pins, but the order can be re-arranged by editing a lookup table.
Reads characters from a text string to write to the display, numbers "0" through "9", minus "-", decimal point ".", and space " " are recognized.
Includes methods for creating a string from integer values, or from an integer with a divider to a specified number of decimal places.

Works with common-anode and common-cathode displays, and also with transistor-driven displays.

Just added a Charlieplex driver, requires a minimum of 9 contiguous pins for seven-segments plus decimal point.
Drives any number of displays, the first nine are free, each additional display requires an additional pin.
Has the same functionality as the regular driver."
754:"
Simple but complete hamradio repeater logic. Detects input carrier, CTCSS and Echolink if any. Controls transmitter PTT, roger beep, CW identification and talkthrough relay.

CW keyer is included as well as DTMF decoder to remote control some repeater functions. Pse contact ON5TE@UBA.BE for any question or comment.
