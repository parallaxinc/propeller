''*****************************
''*  Hydra Sound System v1.2  *
''*  (C)2007 Andrew Arsenault * 
''*****************************
''http://www.andrewarsenault.com/hss/
''e-mail: ym2413a@yahoo.com
''
'' Cogs used: 2
'' HUB-RAM: ~2.7k

'' Please visit the website for the latest version, documentation, examples and media files.
'' Thank you! --Ym2413a

'' This version modified by Micah Dowty <micah@navi.cx> for SPDIF digital audio output
'' at a full 48 KHz sampling rate.  This adds one additional cog.

VAR                     

'Sound Engine Stack
  long hsnd_stack[18]
  long cog1, cog2

'WavSynth Parameters
  long snd_regs[48]    'Regs for Sound Hardware (8x6)+5dpcm
  long dpcm_regs[5]

' Output sample for SPDIF cog
  long spdif_out
  
'DPCM Command Variables
  word dpcmreg_ptr

'Global Hmus Player Vars
  word tempo
  word song_pc
  word song_div
  word song_ptr
  word chfre[4]   
  byte chfx[4]  
  byte chvol[4]
  byte hmus_state
  byte hmvol
  byte fxphs 

'Sound FX Variables
  word runlen[2]
  word envamp[2]
  word sfx_ptr[2]
  byte envphs[2]
  byte fmcnt[2], fmfreq[2]
  byte loadsfx[2]

OBJ
  spdif : "spdifOut"

CON

'' Hss Master Control

PUB start(pin) : okay

  stop

  ' Configure the SPDIF cog to repeatedly read
  ' a sample from a single hub address. We'll use
  ' the SPDIF cog's sample counter to keep the
  ' mixer cog running in lockstep with the SPDIF
  ' sample rate. The mixer does this by repeatedly
  ' waiting until the SPDIF cog's sample counter
  ' matches spdif_cnt. We'll start by giving the
  ' SPDIF cog a 1000-sample head start.
  '
  ' Also, configure the SPDIF output for 48 KHz.
  ' Because we can.

  spdif_out_addr := @spdif_out
  spdif_cnt_addr := spdif.getCountAddr
  spdif_cnt := 1000

  spdif.setChannelStatus(spdif#ALLOW_COPIES | spdif#HZ_48000)
  spdif.setBuffer(spdif_out_addr, 1)
  spdif.start(pin)

  okay := cog1 := cognew(@entry, @snd_regs) + 1
  okay := cog2 := cognew(hsound, @hsnd_stack) + 1

PUB stop
  spdif.stop

  if cog1
    cogstop(cog1~ - 1) 
  if cog2
    cogstop(cog2~ - 1)
    
PUB peek(addrptr) : var1

  var1 := LONG[@snd_regs][addrptr]

CON

'' Hydra Music Commands

PUB hmus_load(songptr) | z

  hmvol := 15
  song_div := 0
  song_ptr := songptr
  song_pc := WORD[songptr][8]
  tempo := WORD[songptr][12]
  repeat z from 0 to 3
    chfx[z] := 0
    
PUB hmus_play

  hmus_state := 1
  
PUB hmus_stop | z

  hmus_state := 0
  repeat z from 0 to 3
    chvol[z] := 0
    
PUB hmus_pause

  hmus_state := 0  

PUB hmus_tempo(var1)

  tempo := var1

PUB get_hmus_tempo : var1

  var1 := tempo
  
PUB hmus_vol(var1)

  hmvol := var1 <# 15 #> 0

PUB get_hmus_vol : var1

  var1 := hmvol

CON

'' FXsynth Commands

PUB sfx_play(chan, soundptr)

  if(chan == 1)
    sfx_ptr[0] := soundptr
    loadsfx[0] := 0
  if(chan == 2)
    sfx_ptr[1] := soundptr
    loadsfx[1] := 0

PUB sfx_stop(chan)

  if(chan == 1) 
    sfx_ptr[0] := 0
  if(chan == 2)
    sfx_ptr[1] := 0

PUB sfx_keyoff(chan)

  if(chan == 1)
    envphs[0] := 3
  if(chan == 2)
    envphs[1] := 3
           
CON

'' Hydra DPCM Commands

PUB dpcm_play(soundptr)

  dpcmreg_ptr := soundptr

PUB dpcm_stop

  dpcmreg_ptr := 1

CON
''*****************************
''*  Hss Sound Engine         *
''*****************************
PRI Hsound
repeat 
 'Update Music Engine
  UpdateMus(song_ptr, Hmus_state) 'Update Music Player
  VolumeInterpol 'Delay and Interpolate Volume to Remove Pops and Clicks.

 'Update DPCM Engine
  if(dpcmreg_ptr)
    DpcmUpdate 'Update the DPCM registers
 
 'Update SoundFX Engine

 'FX channel A
  FXSynth(0,32)
 'FX channel B
  FXSynth(1, 40)

PRI VolumeInterpol | z, channelmul, musvar, freqval

  fxphs += 5

'Volume Interpolation
  repeat z from 0 to 3 step 1
    channelmul := 4+(8*z)
    musvar := (chvol[z]*(hmvol+1))&$F0
    snd_regs[channelmul] := (snd_regs[channelmul] & 15)+musvar

   'Freq Interpolation
    channelmul -= 1 'Jump down a REG to Freq
    musvar := chfre[z]<<16

    if(chfx[z] == 0) 'None
      snd_regs[channelmul] := musvar

    elseif(chfx[z] < 3) 'Vibrato (light/hard)
      if(fxphs < 128)
        snd_regs[channelmul] := musvar+(chfre[z]<<(7+chfx[z]))
      else
        snd_regs[channelmul] := musvar-(chfre[z]<<(7+chfx[z]))

    elseif(chfx[z] == 3) 'Tremolo
      if(fxphs < 128)
        snd_regs[channelmul] := musvar
      else
        snd_regs[channelmul] := musvar<<1

    else 'Portamento
      freqval := snd_regs[channelmul]>>16
      if(freqval & $F000 == chfre[z] & $F000)
        snd_regs[channelmul] := musvar
      elseif(freqval < chfre[z])
        snd_regs[channelmul] := snd_regs[channelmul]+(chfx[z]<<22)
      else
        snd_regs[channelmul] := snd_regs[channelmul]-(chfx[z]<<22)

PRI UpdateMus(songptr, state) | channel, channelmul, scrdat, freq, freqoct, flag

  if(state == 0)
    return ''Song is not playing.

  song_div++

  if(song_div => tempo) 'Tempo Divider
    song_div := 0
    flag := 0
    
    repeat 'Score Decoder and Processor
      scrdat := BYTE[song_ptr][song_pc]
      channel := scrdat & 3
      channelmul := channel<<3
      song_pc++ 

    ''Base Commands
      if(scrdat == 0) 'End Row
        quit

      if(scrdat == 1) 'Repeat Song
        song_pc := WORD[songptr][9]
        quit

      if(scrdat == 2) 'End Song
        hmus_stop
        quit

      if(scrdat == 3) 'Set Flag
        flag := 1
        next

      if((scrdat & $3C) == $20) 'Patch HI Note
        flag := 2
        scrdat := scrdat>>3
        scrdat += 64+channel

      if(scrdat & 4) 'Change Note
        freq := scrdat>>3
        freqoct := freq/12
        freq -= freqoct*12
        case flag
          1 : freqoct += 2
          2 : freqoct += 6
          other : freqoct += 4
        flag := 0
          snd_regs[4+channelmul] := snd_regs[4+channelmul] & $FE
          chfre[channel] := NoteFreqs[freq]>>(6-freqoct)
          snd_regs[4+channelmul] := (snd_regs[4+channelmul] & $FE)+1
        next 'Repeat To Next Datum

      if(scrdat & 8) 'Change Evelope / Channel Effect
        if(flag)
          chfx[channel] := scrdat>>4
          flag := 0
        else
          chvol[channel] := scrdat>>4
        next 'Repeat To Next Datum

      if(scrdat & 16) 'Change Instrument 
          freq := (scrdat & $E0)>>3
          freq += flag<<5
          flag := 0
          snd_regs[0+channelmul] := songptr+WORD[songptr+32][freq]
          snd_regs[1+channelmul] := WORD[songptr+32][freq+1]
          snd_regs[2+channelmul] := WORD[songptr+32][freq+2]
          snd_regs[4+channelmul] := WORD[songptr+32][freq+3] & $0F
        next 'Repeat To Next Datum

      if(scrdat & 64) 'Detune
        chfre[channel] := chfre[channel]+(chfre[channel]>>8)      

      
                            
PRI DpcmUpdate

 if(dpcmreg_ptr > 15) 'Play Sample.
  dpcm_regs[2] := 65535 'End sample if one was playing
  dpcm_regs[0] := dpcmreg_ptr+8
  dpcm_regs[4] := 128
  dpcm_regs[3] := LONG[dpcmreg_ptr][1] 'Get sampling rate
  dpcm_regs[1] := WORD[dpcmreg_ptr][1] 'Get length
  dpcm_regs[2] := 0 'Reset play counter
 elseif(dpcmreg_ptr == 1) 'Stop Sample
  dpcm_regs[2] := 65535 'End sample
  dpcm_regs[4] := 128

 dpcmreg_ptr := 0

PRI FXSynth(SoundVars, ChannelFX) | TimeCnt, SoundFX, Modwav, FMwav, AMwav
 TimeCnt := Cnt
 SoundFX := sfx_ptr[SoundVars]

 if(loadsfx[SoundVars] == 0)
  'Setup OSC WaveForm
   case BYTE[SoundFX][0]
      $00: 'Sine
        snd_regs[ChannelFX] := @SineTable
        snd_regs[1+ChannelFX] := 64
      $01: 'Fast Sine
        snd_regs[ChannelFX] := @FastSine
        snd_regs[1+ChannelFX] := 32
      $02: 'Sawtooth
        snd_regs[ChannelFX] := @Sawtooth
        snd_regs[1+ChannelFX] := 64
      $03: 'Square
        snd_regs[ChannelFX] := @SqrTable
        snd_regs[1+ChannelFX] := 32
      $04: 'Fast Square
        snd_regs[ChannelFX] := @FastSqr
        snd_regs[1+ChannelFX] := 8      
      $05: 'Buzz
        snd_regs[ChannelFX] := @NoteFreqs
        snd_regs[1+ChannelFX] := 24
      $06: 'Noise
        snd_regs[ChannelFX] := $F002
        snd_regs[1+ChannelFX] := 3000
            
   snd_regs[2+ChannelFX] := 0
   snd_regs[4+ChannelFX] := $01

   loadsfx[SoundVars] := 1
   runlen[SoundVars] := 0
   fmcnt[SoundVars] := 0
   fmfreq[SoundVars] := 0
   envamp[SoundVars] := 0
   envphs[SoundVars] := 0

''Modulation Code
 fmfreq[SoundVars]++
 if(fmfreq[SoundVars] => BYTE[SoundFX][4])
   fmfreq[SoundVars] := 0
   fmcnt[SoundVars]++
 fmcnt[SoundVars] := fmcnt[SoundVars] & $3F
 
 case BYTE[SoundFX][5]
      $00:
        Modwav := BYTE[@SineTable][fmcnt[SoundVars]]
      $01:
        Modwav := BYTE[@FastSine][fmcnt[SoundVars] & 31]
      $02:
        Modwav := fmcnt[SoundVars]<<2
      $03:
        Modwav := !fmcnt[SoundVars]<<2
      $04:
        if(fmcnt[SoundVars] & 8)
          Modwav := $ff
        else
          Modwav := $00
      $05:
        Modwav := BYTE[$F002][fmcnt[SoundVars]]
      $FF:
        Modwav := BYTE[SoundFX+12][fmcnt[SoundVars] & 15]

 fmwav := Modwav/(BYTE[SoundFX][6]) 'FM amount 
 amwav := 256-(Modwav/(BYTE[SoundFX][7])) 'AM amount 
 amwav := (BYTE[SoundFX][3]*amwav)>>8

''Envelope Generator
 if(envphs[SoundVars] == 0) 'Attack
   envamp[SoundVars] += BYTE[SoundFX][8]
   if(envamp[SoundVars] > 8191)
     envamp[SoundVars] := 8191
     envphs[SoundVars] := 1
   if(BYTE[SoundFX][8] == $ff)
     envamp[SoundVars] := 8191
 if(envphs[SoundVars] == 1) 'Decay
   envamp[SoundVars] -= BYTE[SoundFX][9]
   if(envamp[SoundVars] & $8000)
     envphs[SoundVars] := 2    
   if(envamp[SoundVars] =< (BYTE[SoundFX][10]<<5))
     envphs[SoundVars] := 2
 if(envphs[SoundVars] == 2) 'Sustain
   envamp[SoundVars] := (BYTE[SoundFX][10]<<5)
 if(envphs[SoundVars] == 3) 'Release
   envamp[SoundVars] -= BYTE[SoundFX][11]
   if(envamp[SoundVars] & $8000)
     envamp[SoundVars] := 4

 amwav := ((envamp[SoundVars]>>9)*(amwav+1))>>4

''Run Length and Outputing
 if(SoundFX > 15)
   runlen[SoundVars]++
   snd_regs[3+ChannelFX] := (BYTE[SoundFX][2]+fmwav)<<24 'Update Frequency
   snd_regs[4+ChannelFX] := (amwav<<4)+(snd_regs[4+ChannelFX] & $0F) 'Update Amplitude
 else
   snd_regs[4+ChannelFX] := $00 'Mute

 if(BYTE[SoundFX][1] == $ff) '$ff = never stop
   runlen[SoundVars] := 0
  
 if(runlen[SoundVars] > (BYTE[SoundFX][1]<<5)) 'Duration KeyOff
   envphs[SoundVars] := 3
   
WaitCnt(TimeCnt + 52_000) ''Delay for Synth Engine Update.
                  
DAT

SineTable               byte    $80, $8c, $98, $a5, $b0, $bc, $c6, $d0
                        byte    $da, $e2, $ea, $f0, $f5, $fa, $fd, $fe
                        byte    $ff, $fe, $fd, $fa, $f5, $f0, $ea, $e2
                        byte    $da, $d0, $c6, $bc, $b0, $a5, $98, $8c
                        byte    $80, $73, $67, $5a, $4f, $43, $39, $2f
                        byte    $25, $1d, $15, $0f, $0a, $05, $02, $01
                        byte    $00, $01, $02, $05, $0a, $0f, $15, $1d
                        byte    $25, $2f, $39, $43, $4f, $5a, $67, $73

Sawtooth                byte    $ff, $fb, $f7, $f3, $ef, $eb, $e7, $e3
                        byte    $df, $db, $d7, $d3, $cf, $cb, $c7, $c3
                        byte    $bf, $bb, $b7, $b3, $af, $ab, $a7, $a3
                        byte    $9f, $9b, $97, $93, $8f, $8b, $87, $83
                        byte    $80, $7c, $78, $74, $70, $6c, $68, $64
                        byte    $60, $5c, $58, $54, $50, $4c, $48, $44
                        byte    $40, $3c, $38, $34, $30, $2c, $28, $24
                        byte    $20, $1c, $18, $14, $10, $0c, $08, $04

FastSine                byte    $80, $98, $b0, $c6, $da, $ea, $f5, $fd
                        byte    $ff, $fd, $f5, $ea, $da, $c6, $b0, $98
                        byte    $80, $67, $4f, $39, $25, $15, $0a, $02
                        byte    $00, $02, $0a, $15, $25, $39, $4f, $67

SqrTable                byte    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
                        byte    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
                        byte    $00, $00, $00, $00, $00, $00, $00, $00
                        byte    $00, $00, $00, $00, $00, $00, $00, $00

FastSqr                 byte    $ff, $ff, $ff, $ff, $00, $00, $00, $00
                                            
'Note LookupTable.             
NoteFreqs               word    $85F3, $8DEA, $965B, $9F4B, $A8C4, $B2CD, $BD6F, $C8B3, $D4A2, $E147, $EEAC, $FCDE 'Top Octave Lookup

CON
''*****************************
''*  WaveTable Synth v1.2     *
''*  DPCM Synth v1.1          * 
''*  (C)2006 Andrew Arsenault *
''*****************************
DAT
                        org
entry
                        mov     ChlA_wave,#256          'Set channel signals.
                        mov     ChlA_offset,#0          'Set channel's offset.
                        mov     ChlA_counter,#0     

                        mov     Time,#10
                        add     Time,cnt                'Prepare for asm type WAITCNT loop. 

'MAIN LOOP
update                  rdlong  x, spdif_cnt_addr       ' Wait for SPDIF cog
                        cmp     x, spdif_cnt wz
              if_z      jmp     #update
                        add     spdif_cnt, #1

        'Transfer Sound Registers
                        mov     addrregs,par
                        mov     y,NumberOfChannels

        'Fetch Channel's Registers
transferchl             rdlong  ChlAp_sampptr,addrregs
                        add     addrregs,#4 
                        rdlong  ChlAp_sampend,addrregs
                        add     addrregs,#4
                        rdlong  Ch1Ap_samplpp,addrregs
                        add     addrregs,#4
                        rdlong  Ch1Ap_freq,addrregs
                        add     addrregs,#4
                        rdlong  ChlAp_keyon,addrregs

        'Fetch Channel's Static Variables
                        add     addrregs,#8
                        rdlong  ChlA_offset,addrregs
                        add     addrregs,#4
                        rdlong  ChlA_counter,addrregs

        'Run Synth Engine on Channel                        
                        call    #wvsynth

        'Store Channel's Static Variables (Tucked Center X move to Wave)
                        wrlong ChlA_counter,addrregs
                        sub    addrregs,#4
                         sub   x,#256
                        wrlong ChlA_offset,addrregs
                        sub    addrregs,#4
                         mov   ChlA_wave,x 'Doesn't Waste anything doing this.
                        wrlong ChlA_wave,addrregs
                        add    addrregs,#12
                        
        'Loop Until All Channel's Are Done.
                        djnz    y,#transferchl

        'Run DPCM Engine
                        call    #dpcm

        'Mix Channels Together
                        mov     addrregs,par
                        mov     ChlA_wave,#0
                        add     addrregs,#5*4
                        mov     y,NumberOfChannels
                        
mixchls                 rdlong  x,addrregs
                        add     ChlA_wave,x
                        add     addrregs,#8*4
                        djnz    y,#mixchls
                        
                        mov     x,DPCM_wave           'Add DPCM
                        shl     x,#2
                        add     ChlA_wave,x
                
                        shl     ChlA_wave,#20         'Convert 12bit singal into a 32bit one.

        'Update output Channels then repeat again.

                        sub     ChlA_wave, h80000000  ' Convert to signed                        
                        mov     x, ChlA_wave          ' Duplicate on left and right channels
                        shr     x, #16
                        or      ChlA_wave, x
                        wrlong  ChlA_wave, spdif_out_addr

                        jmp     #update




'-------------------------Dpcm Engine-------------------------' 

dpcm                    mov     addrregs,par
                        add     addrregs,#192

                        rdlong  DPCM_address,addrregs   'Start Address
                        add     addrregs,#4
                        rdlong  DPCM_runlen,addrregs    'File Lenght
                        add     addrregs,#4
                        rdlong  DPCM_offset,addrregs    'File Offset
                        add     addrregs,#4
                        rdlong  DPCM_freq,addrregs      'Playback Speed
                        add     addrregs,#4
                        rdlong  DPCM_wave,addrregs      'Waveform Amp

        'Check for if keyon/length is set.
                        cmp     DPCM_offset,DPCM_runlen         wc
         if_ae          jmp     #mute_dpcm              'End of file

        'Freq Timer/Divider and Increase sampling offset                       
                        add     DPCM_counter,DPCM_freq          wc
         if_nc          jmp     #done_dpcm

        'Decode DPCM
                        add     DPCM_address,DPCM_offset
                        rdbyte  x,DPCM_address           'Fetch Datum

                        mov     DPCM_delta,x
                        shr     DPCM_delta,#6
                        mov     y,#1
                        shl     y,DPCM_delta
                        mov     DPCM_delta,y
   
                        mov     y,#1
                        shl     y,DPCM_phs
                        test    x,y             wc
        if_c            add     DPCM_wave,DPCM_delta                                                   
        if_nc           sub     DPCM_wave,DPCM_delta

                        add     DPCM_phs,#1
                        cmp     DPCM_phs,#6     wc
        if_b            jmp     #done_dpcm

                        mov     DPCM_phs,#0
                        add     DPCM_offset,#1
                        jmp     #done_dpcm

mute_dpcm               mov     DPCM_wave, #128

done_dpcm               mov     addrregs,par
                        add     addrregs,#200
                        wrlong  DPCM_offset,addrregs    'File Offset
                        add     addrregs,#8
                        wrlong  DPCM_wave,addrregs      'Wave
dpcm_ret                ret

'-----------------------Dpcm Engine End-----------------------'



'-------------------------Sound Engine-------------------------'

        'Freq Timer/Divider and Increase sampling offset                       
wvsynth                 add     ChlA_counter,Ch1Ap_freq         wc
         if_c           add     ChlA_offset,#1

        'Reset sample position and lock at zero if Keyoff.
                        test    ChlAp_keyon,#%0001              wc
         if_nc          mov     ChlA_offset,#0

        'Reset(loop) if needed 
                        cmp     ChlA_offset,ChlAp_sampend       wc
         if_ae          mov     ChlA_offset,Ch1Ap_samplpp

        'Check BitRate and Set Offset
                        mov     x,ChlA_offset
                        test    ChlAp_keyon,#%0010              wc
         if_c           shr     x,#1

        'Fetch WaveTable
                        mov     ChlA_wave,ChlAp_sampptr
                        add     ChlA_wave,x
                        rdbyte  ChlA_wave,ChlA_wave

        'Check BitRate and Skip if 8bit
                        test    ChlAp_keyon,#%0010              wc
         if_nc          jmp     #skip_4bitsam           

        'Convert 4bit to 8bit
                        test    ChlA_offset,#%0001              wc
         if_c           shr     ChlA_wave,#4
         if_nc          and     ChlA_wave,#%00001111

                        mov     x,ChlA_wave
                        shl     ChlA_wave,#4
                        add     ChlA_wave,x

        'Center Amplitude and mute if Keyoff.
skip_4bitsam            test    ChlAp_keyon,#%0001              wc
         if_nc          mov     ChlA_wave,#128

        'Volume Multiply
                        mov     x,#0
                        test    ChlAp_keyon,#%10000000          wc
         if_c           add     x,ChlA_wave
         if_nc          add     x,#128

                        shr     ChlA_wave,#1
                        test    ChlAp_keyon,#%01000000          wc
         if_c           add     x,ChlA_wave
         if_nc          add     x,#64
                        add     x,#64
         
                        shr     ChlA_wave,#1
                        test    ChlAp_keyon,#%00100000          wc
         if_c           add     x,ChlA_wave
         if_nc          add     x,#32
                        add     x,#96

                        shr     ChlA_wave,#1
                        test    ChlAp_keyon,#%00010000          wc
         if_c           add     x,ChlA_wave
         if_nc          add     x,#16
                        add     x,#112

'Return Audio as X.
wvsynth_ret             ret

'-----------------------Sound Engine End-----------------------' 

h80000000               long      $80000000

NumberOfChannels        long      6

spdif_out_addr          long      0
spdif_cnt_addr          long      0
spdif_cnt               long      0

Time          res       1
addrregs      res       1
x             res       1
y             res       1

'WaveTable Synth Accumulators
ChlA_wave     res       1
ChlA_offset   res       1
ChlA_counter  res       1
ChlAp_sampptr res       1
ChlAp_sampend res       1
Ch1Ap_samplpp res       1  
Ch1Ap_freq    res       1
ChlAp_keyon   res       1

'DPCM Accumulators
DPCM_wave     res       1
DPCM_address  res       1
DPCM_offset   res       1
DPCM_counter  res       1
DPCM_freq     res       1
DPCM_runlen   res       1
DPCM_phs      res       1
DPCM_delta    res       1