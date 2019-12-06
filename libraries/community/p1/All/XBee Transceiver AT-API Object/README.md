# XBee Transceiver AT-API Object

By: Martin Hebel

Language: Spin Spin

Created: Apr 17, 2013

Modified: July 1, 2013

An object for communicating with Digi's XBee (designed/tested with Series 1 - 802.15.4) transceivers in both transparent (AT) and API mode. API mode involves framed data with information such as sender's address and RSSI levels. Example use file available. Also allows reception of remote unit sending periodic digital/analog data directly from XBee I/O (XBee firmware 10A2/3 required for ADC feature) and remote configuration (Firmware 10CD of higher).

Version 1.6 Updates:

*   Fixed issues with local/remote configuration
*   Changes data passing for local/remote data
*   Other small tweaks

Version 1.5 Updates:

*   Added automatic parsing of API analog data.
*   Added remote configuration API for firmware 10CD.
*   Added multiple methods for ease of use.
*   Modified certain methods to accept/parse on commas in data.

Demos? Please see the "Getting Started with XBee RF Modules" for multiple examples and uses of this object.   
http://www.parallax.com/go/xbee
