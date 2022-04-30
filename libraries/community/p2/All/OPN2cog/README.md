# OPN2cog

By: Ada Gottensträter

Language: Spin2 & PASM2

Created: 09-May-2021

Category: speech and sound

License: MIT (see source code)

---
![](https://forums.parallax.com/uploads/editor/q4/of0b4rf2ehbf.png "")

_(or SEGA Genesis if you're in yankland...)_

This is an emulation of the Yamaha "OPN2" YM2612 FM synth chip that runs in one P2 cog.

## Features:
- 6 channels of 4-operator phase-modulation synthesis
- All 24 oscillators updated at the same rate as the real chip (~53 kHz)
- Channels are not mixed, but multiplexed onto the DAC, like in the real chip.
- Emulates DAC distortion
- Emulates output lowpass filter
- Supports SSG-EG
- Mostly supports CH3 special mode (rate scaling doesn't account for it)
- Supports CH6 raw DAC mode
- Bonus: SEGA PSG (SN76489 variant) emulation!

## Misfeatures:
- Envelope generators are updated at 1/12 the real rate (~1.5kHz instead of ~18 kHz)
    This causes slight clicking on certain envelope rates and other artifacts.
    The Ultra version runs at 1/2 real EG rate and doesn't exhibit this issue.
- Timers and CSM mode are not implemented.
- PSG sound is somewhat aliased due to relatively low update rate (~53 kHz) (~159 kHz in Ultra version)
- Requires at least 250 MHz P2 clock to run properly (300 MHz for Ultra version).
    (Too low clock speed -> low and/or inconsistent pitch)
- Some instruments sound a little off, but maybe I'm just going insane.
    Still orders of magnitude better than those silly AtGames units, haha

## Videos

MEGA JUKE: https://youtu.be/f650rmtDxW8

Spin API example: https://youtu.be/JRQW2tkkO0E

(Note: the spectrograph in these is not running on the P2, it's just there so it's more than a still image)

## What's included
|File name|Purpose|
|-|-|
|`OPN2cog.spin2`|OPN2 emulation core|
|`OPN2cog_ultra.spin2`|OPN2 emulation core (higher quality version)|
|`OPN2_ROM.DAT`|OPN2 logsin/exponent ROM|
|`megajuke.c`|MEGA JUKE program.|
|`MEGAJUKE.DAT`|MEGA JUKE data file.|
|`megajuke_builder.rb`|Script for building `MEGAJUKE.DAT`|
|`megajuke_tracks.yml`|Track list for MEGA JUKE. Add your own favorite tunes!|
|`ExampleSpinAPI.spin2`|Example that plays a weird little tune using the Spin API and VGI patch files|
|`*.vgi`|VGI patch files used by the Spin API example|
|`ExampleVGMPlay.spin2`|In-memory VGM player. Copy a VGM file from the tunes directory and load it!|
|`ExampleSSG-EG.spin2`|Example/test that plays a note normally and then with all 8 SSG-EG modes|
|`tunes.zip`|Folder of lots of VGM dumps! But zipped to not pollute the Git repo as much.|
|`romgen.rb`|Script for building `OPN2_ROM.DAT`|
|`eg_analyzer.rb`|Script for computing the EG rate lookup tables|
|`lfo_analyzer.rb`|Script for computing the LFO FM lookup table|
|`logo.gal`|GraphicsGale layered file for the logo|

## Running MEGA JUKE

The MEGA JUKE program streams register dumps from a file, using the 9P server in loadp2 (in theory, replacing `_vfs_open_host` with `_vfs_open_sdcard` should make it run from SD card, too, but in practice it hangs after reading the track text, IDK why. SD code is probably not quite thread safe)

- Have the latest flexspin/flexprop (5.4.3) installed
- Unzip `tunes.zip`
- Open `megajuke.c` and edit the pin constants near the top.
- Compile with `flexspin -2 megajuke.c -D_BAUD=2000000`
- Load with `loadp2 -p [your port here] -t -9 . -b 2000000 megajuke.binary`


