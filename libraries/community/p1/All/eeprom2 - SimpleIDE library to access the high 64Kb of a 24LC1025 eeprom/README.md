# eeprom2 - SimpleIDE library to access the high 64Kb of a 24LC1025 eeprom

By: TJ Forshee

Language: C

Created: Jan 21, 2015

Modified: January 21, 2015

The simpletools eeprom commands make it very easy to access the extra 32Kb on a 24LC512... which is included on many Parallax boards.... but if you replace the boot eeprom with a higher storage size chip, the eeprom commands will not work.... the reason is that the system sees the higher 64Kb of the 24LC1025 as a different i2c address ($A8)

To make it easier to access the high side of the eeprom, I have basically made a copy of the eeprom files/commands, renamed everything by adding a "2", and altered the i2c address to use the $A8 address ($54 after conversion to a 7-bit address).

The commands should be familiar... just add a "2" to the "ee" prefix.... for example... ee\_putStr --> ee2\_putStr, ee\_config --> ee2\_config, etc

Hopefully someone finds this useful....

TJ
