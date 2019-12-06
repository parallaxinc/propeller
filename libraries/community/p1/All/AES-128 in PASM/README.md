# AES-128 in PASM

By: Eric Ball

Language: Assembly

Created: Sep 10, 2010

Modified: June 17, 2013

Attached is a functioning AES-128 implementation in PASM (with just enough SPIN to set the pointer to the SBox & InvSBox lookup tables).

1\. I have tested it (successfully) against the FIPS-197 example using GEAR V09\_10\_26. (Note: this is the Data and Key in the file, output in istate.)  
2\. It is not a complete driver, it just encrypts & decrypts data loaded with the PASM and leaves that data in the COG. Adding data movement (along with the steps needed to support multi-block modes) is left to the implementor.

Performance: Key Expansion ~4.4K cycles, Cipher ~16.1K cycles/block, Inverse Cipher ~18K cycles/block.
