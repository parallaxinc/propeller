# RN-XV Wifly FTP Client V01

By: Ben Thacker

Language: Spin

Created: Apr 16, 2013

Modified: April 16, 2013

The Propeller chip interfaces with a RN-XV Wifly via the serial port. The RN-XV Wifly provides Wi-Fi connectivity using 802.11 b/g standards. In this simple configuration that I am using, the RN-XV hardware only requires four connections (Pwr, Tx, Rx and Gnd) to create a wireless data connection.

If the RN-XV Wifly does not connect to a network the propeller will execute a setup procedure and request your password and ssid name during the setup of the RN-XV Wifly.

Once the RN-XV Wifly has joined your wireless network it will try and download "ftp get" a text file called README.TXT from the Parallax FTP site containing the source tree for the Propeller C3 at ftp.propeller-chip.com in the /PropC3/Docs directory. A lookup is used to perform a DNS query on the hostname in case the location to the resource has changed in order to get the correct URL (or is it URI?).

The RN-XV WiFly module acts as a transport and passes the file over it"s uart interface as the file is being transferred. The Propeller simply outputs the data received to Term.

This works quite fine for text however if you wish to "ftp get" a binary file you will need to prevent displaying the data and provide some method of saving the Wifly\_Buffer.

To upload a file (put) to a FTP site simply change the "ftp get" to "ftp put", change the ftp address, directory, username and password. Of course you will need to upload to a FTP site that you have write privileges on. Data sent to the RN-XV Wifly uart will be written to the file.

See Wifly manual for info on the "ftp put" command on how to close the file after a "ftp put" command.
