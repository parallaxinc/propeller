# RN-XV Wifly Web Server V01

By: Ben Thacker

Language: Spin

Created: Apr 16, 2013

Modified: April 16, 2013

The Propeller chip interfaces with a RN-XV Wifly via the serial port. The RN-XV Wifly provides Wi-Fi connectivity using 802.11 b/g standards. In this simple configuration that I am using, the RN-XV hardware only requires four connections (Pwr, Tx, Rx and Gnd) to create a wireless data connection.

If the RN-XV Wifly does not connect to a network the propeller will execute a setup procedure and request your ssid name and password during the setup of the RN-XV Wifly.

Connect to the RN-XV Wifly via your favorite web browser using the ip address displayed after it has joined your wireless network and a HTML web page will be returned. Be sure to include index.html in the url. For example http://192.168.1.118/index.html

When the RN-XV receives the "GET /index.html" message a simple HTML page is returned by the propeller. Enter data in the username field of the HTML page, click submit and the data is sent back to the Wifly/propeller in a POST message. The Wifly/propeller will then return the data along with another HTML page to display the data received.
