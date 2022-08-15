# OPNAcog

By: Ada Gottensträter

Language: Spin2 & PASM2

Created: 14-August-2022

Category: speech and sound

License: MIT (see source code)

---

This is an emulation of the Yamaha "OPNA" YM2608 FM synth chip
  (and by extension, also "OPN" YM2203)
  (and by further extension, also "SSG" YM2149F)
  that runs in one P2 cog.


## Features:
- 6 channels of 4-operator phase-modulation synthesis
- All 24 oscillators updated at the same rate as the real chip (~56 kHz)
- 6 Rhythm sounds
- 3 SSG channels
- Emulates output lowpass filter
- Supports SSG-EG
- Mostly supports CH3 special mode (rate scaling doesn't account for it)

## Misfeatures:
- Envelope generators are updated at 1/8 the real rate (~2.25kHz instead of ~18 kHz)
    This causes slight clicking on certain envelope rates and other artifacts.
    The Ultra version runs at 1/2 real EG rate and doesn't exhibit this issue.
- Timers and CSM mode are not implemented.
- SSG sound is somewhat aliased due to relatively low update rate (~56 kHz) (~112 kHz in Ultra version)
- Requires at least 270 MHz P2 clock to run properly (320 MHz for Ultra version).
    (Too low clock speed -> low and/or inconsistent pitch)
- Some instruments sound a little off, but maybe I'm just going insane.


## What's included
|File name|Purpose|
|-|-|
|`OPNAcog.spin2`|OPNA emulation core|
|`OPNAcog_ultra.spin2`|OPNA emulation core (higher quality version)|
|`OPN2_ROM.DAT`|OPN logsin/exponent ROM|
|`RHYTHM.DAT`|OPNA rhythm samples|
|`ExampleSpinAPI.spin2`|Example that plays a weird little tune using the Spin API and VGI patch files|
|`*.vgi`|VGI patch files used by the Spin API example|
|`ExampleVGMPlay.spin2`|In-memory VGM player. Copy a VGM file from the tunes directory and load it!|
|`ExampleAyDumpPlay.spin2`|In-memory AY/YM player. Mostly to demonstrate that the SSG component is equivalent to AYcog|
|`tunes.zip`|Folder of handful of VGM/YM dumps! But zipped to not pollute the Git repo as much.|


