# SPCcog

By: Ada Gottensträter

Language: Spin2 & PASM2

Created: 24-March-2022

Category: speech and sound

License: MIT (see source code)

---

This is an emulation of the Nintendo/Sony sound module used in the Super NES / Super Famicom (consisting of an SPC700 processor and a custom audio DSP) that runs in one P2 cog.

## Features:
- 8 channels of BRR sample playback
- 32kHz sample rate, accurate to real S-DSP
- SPC700 CPU emulation with instruction timings

## Misfeatures:
- Requires ~200 MHz P2 clock or higher
  (If clock isn't way too low, it fails gracefully by skipping SPC700 cycles)
- Some tunes exhibit minor clicking..
- Inaccurate Timer 2 emulation

## What's included
|File name|Purpose|
|-|-|
|`SPCcog.spin2`|SPC/DSP emulation core|
|`DSPGAUSS.DAT`|DSP gaussian lookup table|
|`ExampleSPCplay.spin2`|Simple SPC player. Copy a SPC file from the tunes directory and load it!|
|`tunes.zip`|Folder of lots of SPC dumps! But zipped to not pollute the Git repo as much.|
|`dsp_tablegen.rb`|Script for building `DSPGAUSS.DAT`|


