# SPIDriver

By: Erlend Fjosna

Language: Spin

Created: Dec 17, 2016

Modified: December 17, 2016

 SPIdriver. Provide bus-level and chip-level methods for SPI bus communication.  
 Erlend Fj.  
  
 Revisions:  
 -  Changed decoding of SPI mode to: iIdleCLK:=   iMode >> 1               thanks to Seairth  
 -  Changed main routine to correct for too early writes                   thanks to Seairth  
 -  Added flag to keep tally of initialization  
 -  Changed Init variables into type DAT in order to preserve values across multiple instances  
 -  Added object instance id
