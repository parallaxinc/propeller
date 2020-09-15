### KNOWN BUGS

Intervening ALTx/AUGS/AUGD instructions between SETQ/SETQ2 and RDLONG/WRLONG/WMLONG-PTRx instructions will cancel the special-case block-size PTRx deltas. The expected number of longs will transfer, but PTRx will only be modified according to normal PTRx expression behavior:

	setq	#16-1		'ready to load 16 longs
	altd	start_reg	'alter start reg (ALTD cancels block-size PTRx deltas)
	rdlong	0,ptra++	'ptra will only be incremented by 4, not 16*4 as anticipated!!!

## OVERVIEW

The Propeller 2 is a microcontroller architecture consisting of 1, 2, 4, 8, or 16 identical 32-bit processors, called cogs, which connect to a common hub. The hub provides up to 1 MB of shared RAM, a CORDIC math solver, and housekeeping facilities. The architecture supports up to 64 smart I/O pins, each capable of many autonomous analog and digital functions.

The P2X8C4M64P Engineering Sample Rev B silicon contains 8 cogs, 512 KB of hub RAM, and 64 smart I/O pins in an exposed-pad 100-pin TQFP package.

|P2X|8C|4M|64P|ES|
|---|--|--|---|--|
|Propeller 2|8 cogs (processors)|4 Mb hub RAM (512 KB)|64 smart I/O pins|Engineering Sample|


Each cog has:

<ul>
  <li>Access to all I/O pins, plus four fast DAC output channels and four fast ADC input channels</li>
  <li>512 longs of dual-port register RAM for code and fast variables</li>
  <li>512 longs of dual-port lookup RAM for code, streamer lookup, and variables</li>
  <li>Ability to execute code directly from register RAM, lookup RAM, and hub RAM</li>
  <li>~350 unique instructions for math, logic, timing, and control operations</li>
  <li>2-clock execution for all math and logic instructions, including 16 x 16 multiply</li>
  <li>6-clock custom-bytecode executor for interpreted languages</li>
  <li>Ability to stream hub RAM and/or lookup RAM to DACs and pins or HDMI modulator</li>
  <li>Ability to stream pins and/or ADCs to hub RAM</li>
  <li>Live colorspace conversion using a 3 x 3 matrix with 8-bit signed/unsigned coefficients</li>
  <li>Pixel blending instructions for 8:8:8:8 data</li>
  <li>16 unique event trackers that can be polled and waited upon</li>
  <li>3 prioritized interrupts that trigger on selectable events</li>
  <li>Hidden debug interrupt for single-stepping, breakpoint, and polling</li>
  <li>8-deep stack for subroutine call return address + flags or data (32 bits wide)</li>
  <li>Carry and Zero flag</li>
