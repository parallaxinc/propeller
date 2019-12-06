''
'' Simple demo for playing a WAV file via SPDIF, with double-buffering.
'' This demo is really dumb, and it doesn't understand WAV headers at all-
'' we just treat the whole file like it's a raw 16-bit signed stereo PCM
'' file at 44.1 KHz.
''
'' -- Micah Dowty <micah@navi.cx>
''

'' Configure these parameters for your particular setup:

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  SPDIF_PIN     = 25
  SD_CARD_PIN   = 16

DAT
  filename byte "somerslt.wav", 0

OBJ
  sd : "fsrw"
  spdif : "spdifOut"

CON  
  BUFFER_SIZE = 128     ' Must be a power of two  

VAR
  long bufA[BUFFER_SIZE]
  long bufB[BUFFER_SIZE]
  
PUB main | f, c

  if sd.mount(SD_CARD_PIN)
    panic
  if sd.popen(@filename, "r")
    panic

  spdif.setBuffer(@bufA, constant(BUFFER_SIZE * 2))
  spdif.start(SPDIF_PIN)
  
  repeat
    ' Wait until the driver is using bufB, then read bufA
    repeat until spdif.getCount & BUFFER_SIZE
    sd.pread(@bufA, constant(BUFFER_SIZE * 4))

    ' Now the opposite...
    repeat while spdif.getCount & BUFFER_SIZE
    sd.pread(@bufB, constant(BUFFER_SIZE * 4))

PUB panic
  '' If an SD card error occurs, blink the SPDIF output LED forever.
  
  dira[SPDIF_PIN]~~
  repeat
    waitcnt(clkfreq/10 + cnt)
    !outa[SPDIF_PIN]
