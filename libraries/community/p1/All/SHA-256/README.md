# SHA-256

By: MarkT

Language: Spin, Assembly

Created: Feb 3, 2012

Modified: May 2, 2013

SHA-256.spin - The Secure Hash Algorithm SHA-256, mainly written in PASM. About 230kB/s throughput.

SHA-256 is a cryptographic hash function that maps arbitrary bit strings to a 256 bit (32 byte) hash value. This version (like many) is limited to byte strings (a multiple of an octet).

Due to collision attacks a 256 bit hash function has a strength of 2^128, not 2^256.

Example/test file provided _("SHA-test.spin")_ to demonstrate use. Bytes can be input individually or as byte vectors up to a maximum of over 10^18 bytes. When the hash is calculated and returned the state is reset automatically for the next use.
