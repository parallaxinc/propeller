# i2cDriver

By: Erlend Fjosna

Language: Spin

Created: Dec 17, 2016

Modified: December 17, 2016

 Supports standard 7 bit chip addressing, and both 8bit, 16bit, and 32bit register addressing. Use of 32bit is rare.  
 Assumes the caller uses the chip address 7 bit format, onto which a r/w bit is added by the code before being transmitted.  
 Signalling "Open Collector Style" is achieved by setting pins OUTA := 0 permanent, and then manipulate on DIRA to either  
 float the output, i.e. let PU resistor pull up to "1" -or- unfloat the output (which was set to 0) to bring it down to "0"
