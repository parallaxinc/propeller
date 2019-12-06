'
' This is Andrew Arsenault's Hss_Demo, trivially modified for SPDIF digital audio output.
'
' Hook an LED up to pin 25 (you can change the pin definition at hss.start below),
' plug one end of a TOSLINK optical cable into your stereo, and point the other
' end at the LED. You should hear the HSS intro song playing as a 44.1 kHz PCM signal.
'
' Note that we don't actually run the HSS engine at 44.1 kHz, it's still running
' at the default 32 kHz. We end up duplicating those samples as necessary to generate
' a 44.1 kHz output signal.
'
' -- Micah Dowty <micah@navi.cx>
'

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  SPDIF_PIN = 25


OBJ

  text : "tv_text"
  hss  : "yma_hss_v1.2_spdif"
  
PUB start | i, a, b, TimeCnt

''Start terminal screen
  text.start(12)
  text.str(string("Hydra Sound System (Hss) v1.2",13))
  text.str(string("Song File: "))
  text.str(@bgmusic)
  text.str(string(13,$C,5,"-(Hss) OBJ and VAR require only 2.73KB",$C,1))   


''First load (Hss) into two free COGs by issuing a simple start command from within your program.
  hss.start(SPDIF_PIN) 'Start HSS Engine
''Now you can send whatever audio commands you want to it. :)


''This is how you play back music files:
  hss.hmus_load(@bgmusic) 'Load Hmus file into player.
  hss.hmus_play 'Play loaded file.


''Use these commands below to play back some sound effects:
''UnRemark these commands to hear the two FX channels
  'hss.sfx_play(1, @SoundFX1) 'Play a sound effect on FX channel (1)
  'hss.sfx_play(2, @SoundFX2) 'Play a sound effect on FX channel (2) 


''Compressed wave files can also be played back using the DPCM channel:
''This short clip was recorded in 22050Hz DPCM-1.
'  hss.dpcm_play(@dpcmfile) 'Play a wave clip on the DPCM channel.

'' **********************************************************
'' Everything (Music, SoundFXs and Compressed Samples) can all be played together without any channel stealing.
'' Please enjoy the music and feel free to use (Hss) in anyway you like! :)
'' Also be sure to visit the website for updates, documentation and media files.
'' http://www.andrewarsenault.com/hss/
'' --Andrew Arsenault.    
'' **********************************************************

  repeat 'Update screen with readings of music registers
    text.str(string($C,3,$A,2,$B,3,"(Channel A) F:"))
    i := hss.peek(3+0)
    text.hex(i>>16, 4)
    i := hss.peek(4+0)
    text.str(string(" V:"))
    text.hex(i, 2)

    text.str(string($C,3,$A,2,$B,4,"(Channel B) F:"))
    i := hss.peek(3+8)
    text.hex(i>>16, 4)
    i := hss.peek(4+8)
    text.str(string(" V:"))
    text.hex(i, 2)

    text.str(string($C,3,$A,2,$B,5,"(Channel C) F:"))
    i := hss.peek(3+16)
    text.hex(i>>16, 4)
    i := hss.peek(4+16)
    text.str(string(" V:"))
    text.hex(i, 2)

    text.str(string($C,3,$A,2,$B,6,"(Channel D) F:"))
    i := hss.peek(3+24)
    text.hex(i>>16, 4)
    i := hss.peek(4+24)
    text.str(string(" V:"))
    text.hex(i, 2)



DAT

bgmusic                 file    "yma-hssintro.hmus"

'dpcmfile                file    "beuler.hwav"

                                'Wav 'Len 'Fre 'Vol 'LFO 'LFW 'FMa 'AMa
SoundFX1                byte    $01, $FF, $80, $0F, $0F, $00, $07, $90  
                                'Att 'Dec 'Sus 'Rel
                        byte    $FF, $10, $00, $FF

                                'Wav 'Len 'Fre 'Vol 'LFO 'LFW 'FMa 'AMa
SoundFX2                byte    $05, $FF, $00, $0F, $04, $FF, $01, $05
                                'Att 'Dec 'Sus 'Rel
                        byte    $F1, $24, $00, $FF
                                '16step Sequencer Table
                        byte    $F1, $78, $3C, $00, $00, $00, $F1, $78, $3C, $00, $00, $00, $00, $00, $00, $00