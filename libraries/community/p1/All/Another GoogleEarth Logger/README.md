# Another GoogleEarth Logger

By: Walter Mosscrop

Language: Spin, Assembly

Created: Aug 22, 2010

Modified: June 17, 2013

New - Version 1.2 - see additions and corrections at end.

A GoogleEarth logger based upon Paul Hubner's "Google Earth KML Logger V1.0". It should be able to create KML files from any GPS with a RS-232 interface that outputs $GPGGA sentences.

My first object submission, it was developed on a Propeller demo board, which has only 8 GPIO pins available. It demonstrates how to use a MAX 6957 as a GPIO expander (driving LED's, reading switches, and using the same ports for both input and output). A MAX DS 17285 (or equivalent) functions as a RTC and is accessed via the 6957.

Of note is the ability to reliably monitor the input from a MAX 3232 (the low voltage version of the MAX 232) via a port on the 6957 at 9600 baud.

Also, several fixes and improvements have been made to the original code, mainly to ensure the accuracy of the data being logged.

V1.2 adds:

*   Automatic save per the value of SAVE\_EVERY\_SECONDS. This is in case of power or other failure; at least the data since the last save will be retained. Note that you will have to manually append the contents of FOOTER.TXT to the file for Google Earth to accept the file.
*   Biasing of monitor commands vs. user commands (40-to-1) to improve the accuracy of the GPS input, especially at 9600 bps.
*   We now check the RTC to see if it's time to save only once per second (approximately). This greatly reduces the number of commands needed to be processed by the 6957.
*   The first sentence to be logged is no longer the sentence used to detect the GPS unit. It is now (correctly) the first sentence issued after the start of logging.
*   Some GPS sentences can be over 200 bytes in length. We now allow for sentences of 256 characters, just to be safe.
*   Increased the size of the RS-232 input buffer to 32 characters.
*   If no altitude is received, don't write the value to the card. The Garmin 35 doesn't write out the altitude until the unit has a fix. You may need to comment out this code if your unit does not supply an altitude reading.
