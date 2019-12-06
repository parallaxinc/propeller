# Pasm I2C Driver

By: Dave Hein

Language: Spin, Assembly

Created: Apr 12, 2013

Modified: April 12, 2013

Pasm I2C Driver - This is an assembly version of Mike Green's Basic I2C Driver. This object uses the same calling interface so that it can be used in any project that currently uses the Basic I2C Driver. It provides a substantial improvement in speed over the Spin-only driver, and is usefull for accessing EEPROMs at higher speed. The constant, DELAY\_CYCLES should be adjusted to provide the desired bus clocking speed.
