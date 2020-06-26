# reSound

By: Johannes

Language: Spin2 & PASM2

Created: 19-June-2020

Category: speech and sound

Description:
The reSound object can mix up to 32 audiostreams at once and apply volume, panning, frequency control and different audio formats for each channel independently. All this in CD quality stereo mode (or even better) using a single cog.

I love the power of the P2, this performance was never possible on the P1.  The limiting factor REALLY is the SD card interface, so in reality we are talking 2 to 4 streams per physical SD interface.  You can also mix in samples over the audiostreams for sound effects as long as they fit in the remaining hub ram.  All this can be mixed in mono, stereo or up to 8 physical audio pins for surround sound.

The demos illustrate what the reSound driver can do.

License: MIT (see source code)
