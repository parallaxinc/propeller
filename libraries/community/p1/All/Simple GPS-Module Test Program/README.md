# Simple GPS-Module Test Program

By: Jon Titus

Language: Spin

Created: Nov 20, 2015

Modified: November 20, 2015

A simple program used with a PAM-7Q GPS module. The software reads the RMC (recommended minimum) "sentence" once from the GPS module and displays it on the Parallax Serial Terminal window. The PAM-7Q module also transmits the VTG, GGA, GSA, GVS, and GLL sentences in standard National Marine Electronics Association (NMEA) format. This software ignores those sentences.
