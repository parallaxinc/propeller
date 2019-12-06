{{//////////////////////////////////////////////////////////////////////

Sound Driver - 22KHz, 16-bit, 6 Channels
AUTHOR: Nick Sabalausky
LAST MODIFIED: 7.9.06
VERSION 5.1

start() and stop() code taken from Parallax's drivers
Sine/Cosine lookup function from Hydra Programmer's Manual
Multiplication functions adapted from Hydra Programmer's Manual

NOTE: This expects the system clock to be set at 80MHz

Detailed Change Log
--------------------
v5.1 (7.9.06)
- Added SetVolume()
- Eliminated a "click" that was heard when the driver started up
- Minor cleanups
  - Renamed sample_counter to sound_clock
  - Removed unused channel variable volume_delta
  - Added NO_ENVELOPE constant
  - Added VOLUME_MIN and VOLUME_MAX to both 11KHz and 22KHz versions
    (It was only in the 22KHz version before)
  - Cleaned up some of the comments and fixed a few inaccuracies

v5.0 (4.6.06)
- Added volume parameter
- Changed to use signed samples instead of unsigned
- Changed inline documentation to block-style for easier maintainability
- Added amplitude envelopes
- Split into alternate versions: 11KHz and 22KHz
- Increased maximum number of channels to 6 for 22KHz version, and 9 for 11KHz version
- "Atomic" SPIN-ASM communication

v4.0 (2.13.06)
- Added constants for musical note frequencies
- Added 8-bit unsigned 11KHz PCM playback via PlaySoundPCM()
- Renamed PlaySound() to PlaySoundFM()
- Improved mixer (Replaced strange-sounding and
  computationaly-expensive "sum_of_samples/active_channels"
  method with just plain "sum_of_samples")

v3.0 (2.9.06)
- Added Sawtooth Wave
- Configurable Audio Output Pin
- Multiple Channels (4 channels max)
- Changed samples from 32-bit to 16-bit

v2.1 (2.5.06)
- Fixed bug: Couldn't get full amplitude range from sine wave without introducing noise
- Added setting for sound duration
- Changed the API documentation to inline-style. Use the PIDE's "Documentation" view to view it.

v2.0 (2.5.06):
- Added PlaySound() and StopSound()
- Can now choose between waveform shapes: Sine, Square, Triangle, and Noise

v1.0 (2.2.06):
- Initial release
- Sine wave output
- Sweeping possible via repeated calls to SetFreq()

To do
------
- Make SPIN API easier and more powerful
- Provide an Asm API
- Add MIDI-playback (will require another COG)

Wish List
----------
- Provide an "any available channel" setting for PlaySound()
- More options for PCM
- Selectable One-shot vs. Repeating
- Configurable Noise Function
- Frequency Envelope
- "Sound Done" Notification
- Space and speed optimizations

Sound API
----------
See "Documentation" view in Propeller IDE.

NOTE: For now, there is no bounds-checking on parameters, so if you
set an invalid value (such as setting pending_shape to something other
than the SHAPE_* constants) then the behavior is undefined.

Caveats
--------
- Do NOT use a volume of 0 if you want "minimum" volume. The range for
  volume is 1-255 (inclusive), so if you want a minimum volume, use 1
  (ie. VOLUME_MINIMUM). A volume of 0 (ie. NOTHING_PENDING) tells the
  driver "don't change the volume for this channel". The same is also
  true for all parameters except "channel" (ie. "frequency",
  "envelope", "shape", etc.).
- Do NOT use a duration of less than 8, or else the envelope functionality
  will cause improper behavior.
- Do NOT use INFINITE_DURATION by itself as the duration as you did
  with version 4.0 of the sound driver. You MUST "or" it with a duration
  of AT LEAST 8 or else ReleaseSound will not properly end the sound.
- Do NOT pass SHAPE_PCM_8BIT_11KHZ to PlaySoundFM. Use PlaySoundPCM instead.

NOTE: These caveats will be automatically taken care of by either the driver
      or the API in the next version so you won't have to worry about them.
      But for now, you will will need to avoid these pitfalls yourself.

Notes on playing your own PCM samples
--------------------------------------
The standard process involves three steps:

1. Export your audio file to a *signed* 8-bit 11KHz RAW file.

You should be able to do this with just about any good sound
editing software. I recommend Audacity. It's free, it's powerful,
it's on any platform you could possibly want, and you can get it
here: http://audacity.sourceforge.net.

2. Use Colin Philips's xgsbmp tool to convert the RAW file
into a spin source file.

Use the command-line:
xgsbmp audiofile.raw audiofile.spin -op:copy -hydra

3. Minor manual touch-up to the spin source file.

The file will already have a label at the start of the data,
and a getter function to obtain that label's address. You
will need to add an additional label denoting the *end* of
the data, and provide a getter for that. See NS_hydra_sound_010.spin
for an example:

  PUB ns_hydra_sound
  RETURN @_ns_hydra_sound

  PUB ns_hydra_sound_end
  RETURN @_ns_hydra_sound_end

  DAT
  ' Data Type: RAW Data
  ' Size: 6946 Bytes
  ' Range: 0 -> 1B22
  _ns_hydra_sound
         byte    $7f, 'etc...
         'etc...
         byte    $7f, $7f, $7f, $7f '......
  _ns_hydra_sound_end

Explanation of Envelopes and Duration
--------------------------------------
The duration is specified in 11KHz or 22KHz "ticks" (depending on which
version of the sound driver you're using). So, use a duration of
SAMPLE_RATE to play for one second, 2*SAMPLE_RATE for two seconds,
SAMPLE_RATE/2 for a half-second, etc.

To make a sound play for an infinite duration, you must "or" the
duration with DURATION_INFINITE (which sets bit 31 to 1). You still
need to specify an amount of time for the duration because the sound
driver needs to know how long the amplitude envelope (explained below)
should take. For example, use INFINITE_DURATION | SAMPLE_RATE to play
a never-ending sound using an envelope length of one second.

The amplitude (ie. volume), envelope is a 32-bit value made up of eight
4-bit nybbles, with each nybble representing one of eight "segments"
of the envelope. Each segment plays for 1/8th of the sound's total
duration. Each segment specifies a percentage of the sound's desired
volume, with $0 representing 0%, and $F representing 100%. For instance,
if the sound is played at a volume of 200, then a segment of $0 means
"no volume", $8 means "volume 100", and $F means "volume 200". The eight
envelope segments are specified in reverse-order. The first segment to
be played (segment 0) is the least significant nybble and the final
segment (segment 7) is the most significant nybble. For example,
$1346_ACEF starts at full volume and ends at near-silence. An envelope
of $FFFF_FFFF is effectively no envelope.

Sounds with an infinite duration may also use envelopes. In this case,
the "attack" and "decay" (ie. the first few segments) will play, and
then the sound will remain indefinitely at the "sustain" segment
(segment 3 by default, but can be changed by adjusting the
AMP_ENV_SUSTAIN_SEG constant anywhere from 1 to 6 (0 and 7 are untested)).
When ReleaseSound is called, the "release" (ie. the last few segments)
will play for the rest of the specified envelope duration and then stop.

PCM sounds may also use an envelope, although for now you will have to
modify PlaySoundPCM to do this. The next version of the driver will have
this modification built-in.

Communication Protocol between SPIN and ASM
--------------------------------------------
An Asm API will be provided in the next version of the sound driver, but
for now, if you wish to use the driver from Asm code, you must understand
the communication protocol it uses:

The communication is done through the pending_* variables.

The pending_* variables are normally set to NOTHING_PENDING ($0). To change
a setting, write the desired new values to the appropriate pending_*
variables. Then set bit 31 of pending_shape* to 1. The ASM driver polls the
pending_shape* variables. When it sees a 1 in bit 31, it will poll the rest
of the pending_* variables for that particular channel. When it encounters
a value other than NOTHING_PENDING in any of those variables (including
bits 30..0 of pending_shape*), it will activate the new setting, clear bit 31
of pending_shape*, and write NOTHING_PENDING back to the variable to signal
it has received the new value.

//////////////////////////////////////////////////////////////////////}}

'///////////////////////////////////////////////////////////////////////
' CONSTANTS ////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////
CON

  'Approximately 22KHz. Do NOT change this value! The calculation of theta_delta
  'has an optimization (to avoid a division) that relies on this exact sample rate.
  SAMPLE_RATE = 21845

  #0, SHAPE_IGNORE, SHAPE_SILENT, SHAPE_SINE, SHAPE_SAWTOOTH, SHAPE_SQUARE, SHAPE_TRIANGLE, SHAPE_NOISE, SHAPE_PCM_8BIT_11KHZ, SHAPE_RELEASE
  DURATION_INFINITE = $8000_0000
  NOTHING_PENDING = $0

  'Channel Data Field Offsets
  #0, CHDAT_THETA, CHDAT_THETA_DELTA, CHDAT_THETA_CYCLED, CHDAT_SHAPE, CHDAT_STOP_TIME, CHDAT_VOLUME, CHDAT_AMP_ENV, CHDAT_ENV_SEG_DURATION, CHDAT_LFSR, CHDAT_PCM_START, CHDAT_PCM_END, CHDAT_PCM_CURR, SIZE_OF_CHDAT
  SIZE_OF_PARAM_CHDAT      = 7 'in longs: pending_shape, pending_freq, pending_duration, pending_volume, pending_amp_env, pending_pcm_start and pending_pcm_end
  INDEX_OF_CHANNEL0_PARAMS = 4 'in bytes: audio_pin 

  AMP_ENV_SUSTAIN_SEG = 3  'The # of the amplitude segment to "sustain" for infinite duration sounds
                           '(Use anything from 1 to 6, inclusive)

  NO_ENVELOPE = $FFFF_FFFF

  VOLUME_MIN = 1
  VOLUME_MAX = 255

  'Musical note frequencies
  NOTE_C0  = 16
  NOTE_Cs0 = 17
  NOTE_Db0 = NOTE_Cs0
  NOTE_D0  = 18
  NOTE_Ds0 = 19
  NOTE_Eb0 = NOTE_Ds0
  NOTE_E0  = 21
  NOTE_F0  = 22
  NOTE_Fs0 = 23
  NOTE_Gb0 = NOTE_Fs0
  NOTE_G0  = 25
  NOTE_Gs0 = 26
  NOTE_Ab0 = NOTE_Gs0
  NOTE_A0  = 28
  NOTE_As0 = 29
  NOTE_Bb0 = NOTE_As0
  NOTE_B0  = 31

  NOTE_C1  = 33
  NOTE_Cs1 = 35
  NOTE_Db1 = NOTE_Cs1
  NOTE_D1  = 37
  NOTE_Ds1 = 39
  NOTE_Eb1 = NOTE_Ds1
  NOTE_E1  = 41
  NOTE_F1  = 44
  NOTE_Fs1 = 46
  NOTE_Gb1 = NOTE_Fs1
  NOTE_G1  = 49
  NOTE_Gs1 = 52
  NOTE_Ab1 = NOTE_Gs1
  NOTE_A1  = 55
  NOTE_As1 = 58
  NOTE_Bb1 = NOTE_As1
  NOTE_B1  = 62

  NOTE_C2  = 65
  NOTE_Cs2 = 69
  NOTE_Db2 = NOTE_Cs2
  NOTE_D2  = 73
  NOTE_Ds2 = 78
  NOTE_Eb2 = NOTE_Ds2
  NOTE_E2  = 82
  NOTE_F2  = 87
  NOTE_Fs2 = 93
  NOTE_Gb2 = NOTE_Fs2
  NOTE_G2  = 98
  NOTE_Gs2 = 104
  NOTE_Ab2 = NOTE_Gs2
  NOTE_A2  = 110
  NOTE_As2 = 117
  NOTE_Bb2 = NOTE_As2
  NOTE_B2  = 123

  NOTE_C3  = 131
  NOTE_Cs3 = 139
  NOTE_Db3 = NOTE_Cs3
  NOTE_D3  = 147
  NOTE_Ds3 = 156
  NOTE_Eb3 = NOTE_Ds3
  NOTE_E3  = 165
  NOTE_F3  = 175
  NOTE_Fs3 = 185
  NOTE_Gb3 = NOTE_Fs3
  NOTE_G3  = 196
  NOTE_Gs3 = 208
  NOTE_Ab3 = NOTE_Gs3
  NOTE_A3  = 220
  NOTE_As3 = 233
  NOTE_Bb3 = NOTE_As3
  NOTE_B3  = 247

  NOTE_C4  = 262      '--- Middle C ---
  NOTE_Cs4 = 277
  NOTE_Db4 = NOTE_Cs4
  NOTE_D4  = 294
  NOTE_Ds4 = 311
  NOTE_Eb4 = NOTE_Ds4
  NOTE_E4  = 330
  NOTE_F4  = 349
  NOTE_Fs4 = 370
  NOTE_Gb4 = NOTE_Fs4
  NOTE_G4  = 392
  NOTE_Gs4 = 415
  NOTE_Ab4 = NOTE_Gs4
  NOTE_A4  = 440
  NOTE_As4 = 466
  NOTE_Bb4 = NOTE_As4
  NOTE_B4  = 494

  NOTE_C5  = 523
  NOTE_Cs5 = 554
  NOTE_Db5 = NOTE_Cs5
  NOTE_D5  = 587
  NOTE_Ds5 = 622
  NOTE_Eb5 = NOTE_Ds5
  NOTE_E5  = 659
  NOTE_F5  = 698
  NOTE_Fs5 = 740
  NOTE_Gb5 = NOTE_Fs5
  NOTE_G5  = 784
  NOTE_Gs5 = 831
  NOTE_Ab5 = NOTE_Gs5
  NOTE_A5  = 880
  NOTE_As5 = 932
  NOTE_Bb5 = NOTE_As5
  NOTE_B5  = 988

  NOTE_C6  = 1047
  NOTE_Cs6 = 1109
  NOTE_Db6 = NOTE_Cs6
  NOTE_D6  = 1175
  NOTE_Ds6 = 1245
  NOTE_Eb6 = NOTE_Ds6
  NOTE_E6  = 1319
  NOTE_F6  = 1397
  NOTE_Fs6 = 1480
  NOTE_Gb6 = NOTE_Fs6
  NOTE_G6  = 1568
  NOTE_Gs6 = 1661
  NOTE_Ab6 = NOTE_Gs6
  NOTE_A6  = 1760
  NOTE_As6 = 1865
  NOTE_Bb6 = NOTE_As6
  NOTE_B6  = 1976

'///////////////////////////////////////////////////////////////////////
' VARIABLES ////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////
VAR
  long cogon, cog

  'Communication paramaters. See above for explanation of protocol.
  long audio_pin

  long pending_shape
  long pending_freq
  long pending_duration
  long pending_volume
  long pending_amp_env
  long pending_pcm_start
  long pending_pcm_end

  long pending_shape_ch1
  long pending_freq_ch1
  long pending_duration_ch1
  long pending_volume_ch1
  long pending_amp_env_ch1
  long pending_pcm_start_ch1
  long pending_pcm_end_ch1

  long pending_shape_ch2
  long pending_freq_ch2
  long pending_duration_ch2
  long pending_volume_ch2
  long pending_amp_env_ch2
  long pending_pcm_start_ch2
  long pending_pcm_end_ch2

  long pending_shape_ch3
  long pending_freq_ch3
  long pending_duration_ch3
  long pending_volume_ch3
  long pending_amp_env_ch3
  long pending_pcm_start_ch3
  long pending_pcm_end_ch3

  long pending_shape_ch4
  long pending_freq_ch4
  long pending_duration_ch4
  long pending_volume_ch4
  long pending_amp_env_ch4
  long pending_pcm_start_ch4
  long pending_pcm_end_ch4

  long pending_shape_ch5
  long pending_freq_ch5
  long pending_duration_ch5
  long pending_volume_ch5
  long pending_amp_env_ch5
  long pending_pcm_start_ch5
  long pending_pcm_end_ch5

'///////////////////////////////////////////////////////////////////////
' OBJECTS //////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////
OBJ

'///////////////////////////////////////////////////////////////////////
' FUNCTIONS ////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////

'// PUB start //////////////////////////////////////////////////////////

PUB start(pin) : okay
{{
Starts the sound driver on a new cog.

    pin:      The PChip I/O pin to send audio to (always 7 on the Hydra)
    returns:  false if no cog available
}}

  audio_pin := pin

  stop
  okay := cogon := (cog := cognew(@entry,@audio_pin)) > 0


'///////////////////////////////////////////////////////////////////////

PUB stop
{{
Stops the sound driver. Frees a cog.
}}

  if cogon~
    cogstop(cog)

'///////////////////////////////////////////////////////////////////////

PUB PlaySoundFM(arg_channel, arg_shape, arg_freq, arg_duration, arg_volume, arg_amp_env) | offset
{{
Starts playing a frequency modulation sound. If a sound is already
playing, then the old sound stops and the new sound is played.

   arg_channel:   The channel on which to play the sound (0-5)
   arg_shape:     The desired shape of the sound. Use any of the
                  following constants: SHAPE_SINE, SHAPE_SAWTOOTH,
                  SHAPE_SQUARE, SHAPE_TRIANGLE, SHAPE_NOISE.
                  Do NOT send a SHAPE_PCM_* constant, use PlaySoundPCM() instead.
   arg_freq:      The desired sound frequncy. Can be a number or a NOTE_* constant.
                  A value of 0 leaves the frequency unchanged.
   arg_duration:  Either a 31-bit duration to play sound for a specific length
                  of time, or (DURATION_INFINITE | "31-bit duration of amplitude
                  envelope") to play until StopSound, ReleaseSound or another call
                  to PlaySound is called. See "Explanation of Envelopes and
                  Duration" for important details.
   arg_volume:    The desired volume (1-255). A value of 0 leaves the volume unchanged.
   arg_amp_env:   The amplitude envelope, specified as eight 4-bit nybbles
                  from $0 (0% of arg_volume, no sound) to $F (100% of arg_volume,
                  full volume), to be applied least significant nybble first and
                  most significant nybble last. Or, use NO_ENVELOPE to not use an envelope.
                  See "Explanation of Envelopes and Duration" for important details.
}}

  offset := arg_channel*SIZE_OF_PARAM_CHDAT

  repeat until pending_shape[offset] == NOTHING_PENDING

  pending_duration[offset]  := arg_duration
  pending_volume[offset]    := arg_volume
  pending_freq[offset]      := arg_freq
  pending_amp_env[offset]   := arg_amp_env
  pending_shape[offset]     := arg_shape | CONSTANT(1<<31)

'///////////////////////////////////////////////////////////////////////

PUB PlaySoundPCM(arg_channel, arg_pcm_start, arg_pcm_end, arg_volume) | offset
{{
Plays a signed 8-bit 11KHz PCM sound once. If a sound is already
playing, then the old sound stops and the new sound is played.

   arg_channel:   The channel on which to play the sound (0-8)
   arg_pcm_start: The address of the PCM buffer
   arg_pcm_end:   The address of the end of the PCM buffer
   arg_volume:    The desired volume (1-255)
   arg_amp_env:   The amplitude envelope, specified as eight 4-bit nybbles
                  from $0 (0% of arg_volume, no sound) to $F (100% of arg_volume,
                  full volume), to be applied least significant nybble first and
                  most significant nybble last. Or, use NO_ENVELOPE to not use an envelope.
                  See "Explanation of Envelopes and Duration" for important details.
}}

  offset := arg_channel*SIZE_OF_PARAM_CHDAT

  repeat until pending_shape[offset] == NOTHING_PENDING

  pending_pcm_start[offset] := arg_pcm_start
  pending_pcm_end[offset]   := arg_pcm_end
  pending_duration[offset]  := CONSTANT(DURATION_INFINITE | SAMPLE_RATE)
  pending_volume[offset]    := arg_volume
  pending_freq[offset]      := 400
  pending_amp_env[offset]   := NO_ENVELOPE

'  pending_amp_env[offset]   := $FC84_AF8F
'  pending_duration[offset]  := CONSTANT( Round(Float(SAMPLE_RATE) * 0.4))

  pending_shape[offset]     := CONSTANT(SHAPE_PCM_8BIT_11KHZ | (1<<31))

'///////////////////////////////////////////////////////////////////////

PUB StopSound(arg_channel) | offset
{{
Stops playing a sound.

   arg_channel:  The channel to stop.
}}

  offset := arg_channel*SIZE_OF_PARAM_CHDAT
  repeat until pending_shape[offset] == NOTHING_PENDING
  pending_shape[offset] := CONSTANT(SHAPE_SILENT | (1<<31))

'///////////////////////////////////////////////////////////////////////

PUB ReleaseSound(arg_channel) | offset
{{
"Releases" an infinite duration sound. Ie, starts the release portion
of the sound's amplitude envelope.

   arg_channel:  The channel to "release".
}}

  offset := arg_channel*SIZE_OF_PARAM_CHDAT
  repeat until pending_shape[offset] == NOTHING_PENDING
  pending_shape[offset] := CONSTANT(SHAPE_RELEASE | (1<<31))

'///////////////////////////////////////////////////////////////////////

PUB SetFreq(arg_channel, arg_freq) | offset
{{
Changes the frequency of the playing sound. If called
repetedly, it can be used to create a frequency sweep.

   arg_channel:  The channel to set the frequency of.
   arg_freq:     The desired sound frequncy. Can be a number or a NOTE_* constant.
                 A value of 0 leaves the frequency unchanged.
}}

  offset := arg_channel*SIZE_OF_PARAM_CHDAT

  repeat until pending_shape[offset] == NOTHING_PENDING

  pending_freq[offset]  := arg_freq
  pending_shape[offset] := CONSTANT(SHAPE_IGNORE | (1<<31))

'///////////////////////////////////////////////////////////////////////

PUB SetVolume(arg_channel, arg_volume) | offset
{{
Changes the volume of the playing sound. If called
repetedly, it can be used to manually create an envelope.

   arg_channel:  The channel to set the volume of.
   arg_volume:   The desired volume (1-255). A value of 0 leaves the volume unchanged.
}}

  offset := arg_channel*SIZE_OF_PARAM_CHDAT

  repeat until pending_shape[offset] == NOTHING_PENDING

  pending_volume[offset] := arg_volume
  pending_shape[offset]  := CONSTANT(SHAPE_IGNORE | (1<<31))

'///////////////////////////////////////////////////////////////////////
' DATA /////////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////

DAT

'// Assembly language sound driver /////////////////////////////////////

                    org
'---- Entry
entry
                    '---- Initialization ----
                    rdlong  temp,par                         'Get audio pin
                    mov     dira_init,#1
                    shl     dira_init,temp
                    or      dira,dira_init                   'Set audio pin's direction to output

                    mov     time_to_resume,cnt               'Setup delay
                    add     time_to_resume,delay_amount

                    mov     frqa,long_half                   'Setup counter A
                    add     ctra_init,temp
                    mov     ctra,ctra_init

                    '- Start of main processing loop -
loop
                    '---- Process Pending API Requests ----
                    mov     temp,sound_clock
                    and     temp,#%0111                 'Look at the low 3-bits of sound_clock
                    cmp     temp,curr_channel   wz      'Only process requests for one channel each 22KHz sound tick
        if_ne       jmp     #skip_pending_requests

                    '- Read params -
                    mov     param_index,curr_ch_param_index
                    call    #get_param
                    test    param_value,bit_31     wz
        if_z        jmp     #skip_pending_requests
                    andn    param_value,bit_31
                    mov     _pending_shape,param_value

                    call    #get_param
                    mov     _pending_freq,param_value
                    call    #get_param
                    mov     _pending_duration,param_value
                    call    #get_param
                    mov     _pending_volume,param_value
                    call    #get_param
                    mov     _pending_amp_env,param_value
                    call    #get_param
                    mov     _pending_pcm_start,param_value
                    call    #get_param
                    mov     _pending_pcm_end,param_value

                    '- Get pending shape -
                    cmp     _pending_shape,#NOTHING_PENDING  wz
        if_e        jmp     #skip_pending_shape

                    movd    set_new_shape,shape_ptr
                    sub     _pending_shape,#1
                    cmp     _pending_shape,#(SHAPE_RELEASE-1)  wz
set_new_shape if_ne mov     0,_pending_shape                 'Set new shape (unless it's SHAPE_RELEASE)
              if_ne jmp     #skip_shape_release              'If not SHAPE_RELEASE, skip the following section
                    
                    'Ignore SHAPE_RELEASE if no sound playing
                    movd    get_old_shape,shape_ptr
                    nop
get_old_shape       cmp     0,#(SHAPE_SILENT-1)  wz
        if_e        jmp     #skip_shape_release

                    'Handle "release"
                    'If infinite duration, set to first release segment and set stop_time to sound_clock
                    movs    shape_get_duration,env_seg_duration_ptr
                    movd    shape_save_duration,env_seg_duration_ptr
                    movd    shape_save_stop_time,stop_time_ptr
shape_get_duration  mov     temp,0
                    test    temp,bit_28  wz
        if_z        jmp     #skip_shape_release              'Skip the rest if not infinite duration

shape_save_stop_time mov    0,sound_clock                    'Set stop_time to now to end the current envelope segment
                    and     temp,duration_mask
                    or      temp,amp_env_sustain_set         'Ensure current segment is sustain 
shape_save_duration mov     0,temp
skip_shape_release
 
                    cmp     _pending_shape,#(SHAPE_PCM_8BIT_11KHZ-1)  wz
        if_ne       jmp     #skip_pending_shape

                    '- Get PCM addresses -
                    movd    get_pcm_start,pcm_start_ptr     'Setup cog pointers to pcm_start and pcm_curr
                    movd    get_pcm_curr,pcm_curr_ptr
                    movd    get_pcm_end,pcm_end_ptr
get_pcm_start       mov     0,_pending_pcm_start            'Get pcm_start
get_pcm_curr        mov     0,_pending_pcm_start            'Copy pcm_start into pcm_curr
get_pcm_end         mov     0,_pending_pcm_end
skip_pending_shape

                    '- Get pending frequency -
                    cmp   _pending_freq,#NOTHING_PENDING  wz
        if_e        jmp   #skip_pending_freq

                    movd  set_new_theta_delta,theta_delta_ptr
                    shr   _pending_freq,#2                 'Calculate new theta_delta using a trick to multiply by ($2000/21845 (Approx 22KHz))
                    mov   temp,_pending_freq
                    shr   temp,#1
                    add   _pending_freq,temp               'theta_delta = ($2000*frequency)/(21845 (Approx 22KHz))

set_new_theta_delta mov   0,_pending_freq                  'Set new theta_delta
skip_pending_freq

                    '- Get pending duration -
                    cmp     _pending_duration,#NOTHING_PENDING  wz
        if_e        jmp     #skip_pending_duration

                    movd    set_new_stop_time,stop_time_ptr
                    movd    set_new_duration,env_seg_duration_ptr
                    shr     _pending_duration,#3                   'Divide by 8
        
set_new_duration    mov     0,_pending_duration
                    andn    _pending_duration,bit_28
                    add     _pending_duration,sound_clock      wz  'Set new stop_time
        if_z        add     _pending_duration,#1                   'Ensure _pending_duration+sound_clock doesn't become "never stop" (ie. 0)
set_new_stop_time   mov     0,_pending_duration

skip_pending_duration

                    '- Get pending volume -
                    cmp     _pending_volume,#NOTHING_PENDING  wz
        if_z        jmp     #skip_pending_volume

                    movd    set_new_volume,volume_ptr
                    nop
set_new_volume      mov     0,_pending_volume
skip_pending_volume

                    '- Get pending amplitude envelope -
                    cmp     _pending_amp_env,#NOTHING_PENDING  wz
        if_z        jmp     #skip_pending_amp_env

                    movd    set_new_amp_env,amp_env_ptr
                    nop
set_new_amp_env     mov     0,_pending_amp_env
skip_pending_amp_env
skip_pending_requests

                    '---- Get State Data ----
channel_loop        movs  get_theta,theta_ptr
                    movs  get_theta_cycled,theta_cycled_ptr
                    movs  get_lfsr,lfsr_ptr

get_theta           mov   theta_temp,0                       'Get theta
get_theta_cycled    mov   theta_cycled_temp,0                'Get theta_cycled
get_lfsr            mov   lfsr_temp,0                        'Get lfsr

                    '---- Generate Sample ----
                    movs    jump_table_indexer,shape_ptr
                    mov     shape_jmp_ptr,#shape_jmp_table
jump_table_indexer  add     shape_jmp_ptr,0                  'Compute offset into shape_jmp_table
                    movs    shape_jmp,shape_jmp_ptr
                    nop                                      'Wait-out the pipelining
shape_jmp           jmp     0                                'Call shape routine to generate and output sample
return_from_shape

                    '---- Advance Theta ----
                    movs    advance_theta,theta_delta_ptr
                    nop
advance_theta       add     theta_temp,0                     'Advance theta
                    cmp     theta_temp,sin_360   wc          'Wrap from 360 degrees to 0 degrees
        if_ae       sub     theta_temp,sin_360

                    mov     theta_cycled_temp,#0             'Update theta_cycled
        if_ae       mov     theta_cycled_temp,#1

                    '---- Store State Data ----
                    movd    store_theta,theta_ptr
                    movd    store_theta_cycled,theta_cycled_ptr
                    movd    store_lfsr,lfsr_ptr

store_theta         mov     0,theta_temp                     'Store theta
store_theta_cycled  mov     0,theta_cycled_temp              'Store theta_cycled
store_lfsr          mov     0,lfsr_temp                      'Store lfsr

                    '---- Get/Update Envelope ----
                    'check if done with amplitude envelope segment
                    movs    get_amp_env,amp_env_ptr
                    movd    check_at_stop_time,stop_time_ptr
get_amp_env         mov     curr_env,0                       'Get the envelope
check_at_stop_time  cmp     0,sound_clock         wz         'Check if at end of envelope segment
        if_ne       jmp     #skip_update_env                 'If not at end of segment, skip the rest of this section

                    'update envelope and check if done with sound
                    movd    update_amp_env,amp_env_ptr       'Setup address to save new envelope segment to
                    shr     curr_env,#4           wz         'Move to next 4-bit envelope segment. Z = Done with sound?
update_amp_env      mov     0,curr_env                       'Save new envelope
        if_nz       jmp     #skip_stop_sound                 'If not done with sound (ie, the envelope is not 0), then skip "stop sound" section

                    'sound is done, stop sound
                    movd    end_sound,shape_ptr              'Get address of current channel's shape
                    nop                                      'Stall for the pipelining
end_sound           mov     0,#SHAPE_SILENT-1                'Stop sound by setting shape to "silent"
                    jmp     #skip_reset_stop_time
skip_stop_sound

                    'sound is not done, setup next stop_time
                    movs    get_duration,env_seg_duration_ptr
                    movd    reset_stop_time,stop_time_ptr
get_duration        mov     temp,0
                    
                    test    temp,bit_28   wz                   'Check if bit 28 is 0 (infinite duration)
        if_z        jmp     #set_new_finite_stop_time          'If infinite duration not set, skip the following section.

                    mov     temp2,temp                         'Update the current segment count
                    shr     temp2,#29
                    add     temp2,#1
                    cmp     temp2,#AMP_ENV_SUSTAIN_SEG  wz

                    and     temp,duration_mask                 'Mask off the "current envelope segment" bits
                    shl     temp2,#29
                    movd    store_new_curr_env_seg,env_seg_duration_ptr
                    add     temp2,temp
store_new_curr_env_seg  mov 0,temp2                            'Save the updated current segment count

        if_e        mov     temp,#0                            'If "e", then the "sustain" segment has been reached, so set stop_time to 0 (ie, never stop)
        if_e        jmp     #reset_stop_time

                    andn    temp,bit_28                        'Mask off the infinite duration bit

set_new_finite_stop_time
                    add     temp,sound_clock      wz           'Set new stop_time
        if_z        add     temp,#1                            'Ensure new stop_time doesn't become "never stop" (ie. 0)
reset_stop_time     mov     0,temp

                    'get current envelope segment's volume modifier
skip_reset_stop_time
skip_update_env
                    and     curr_env,#$F                  'Mask off all but the current envelope segment's volume modifier

                    '---- Adjust Volume of Sample ----
                    movs    get_volume,volume_ptr
                    mov     mult_y,curr_env
get_volume          mov     mult_x,0
                    call    #multiply_8_by_4_bit                'mult_y = volume * curr_env

                    mov     mult_x,sample_temp

                    test    mult_x,bit_31   wz                  'Z=0 if the multiplicand mult_y is negative
                    abs     mult_x,mult_x                       'Do the multiplication with positive multiplicands
                    call    #multiply_16_by_12_bit
        if_nz       neg     mult_y,mult_y                       'If multiplicand was negative, negate the result

                    '---- Add Into Mixer ----
                    adds    mixed_sample,mult_y                 'Add sample into mix (no need to load/store sample?)

                    '---- Next Channel ----
                    add     theta_ptr,           #SIZE_OF_CHDAT 'Update channel data pointers
                    cmp     theta_ptr,#end_of_channel_data  wz  'Was this the last channel?
        if_e        jmp     #mixer                              'If yes, jump to mixer
                    add     theta_delta_ptr,     #SIZE_OF_CHDAT 'Continue updating channel data pointers
                    add     theta_cycled_ptr,    #SIZE_OF_CHDAT
                    add     shape_ptr,           #SIZE_OF_CHDAT
                    add     stop_time_ptr,       #SIZE_OF_CHDAT
                    add     volume_ptr,          #SIZE_OF_CHDAT
                    add     amp_env_ptr,         #SIZE_OF_CHDAT
                    add     env_seg_duration_ptr,#SIZE_OF_CHDAT
                    add     lfsr_ptr,            #SIZE_OF_CHDAT
                    add     pcm_start_ptr,       #SIZE_OF_CHDAT
                    add     pcm_end_ptr,         #SIZE_OF_CHDAT
                    add     pcm_curr_ptr,        #SIZE_OF_CHDAT
                    add     curr_ch_param_index,#(SIZE_OF_PARAM_CHDAT*4)
                    add     curr_channel,#1
                    jmp     #loop                               'Goto next channel

                    '---- Average and Output Mixed Sample ----
mixer
                    shl     mixed_sample,#1           'Crank volume high as possible for 6 channels without clipping
                    add     mixed_sample,bit_31       'Adjust from signed [-max_amplitude, +max_amplitude] to unsigned [0,+2*max_amplitude]
                    mov     frqa,mixed_sample         'Output Mixed Sample

                    mov     mixed_sample,#0           'Clear mixed_sample
                    mov     active_channels,#0        'Clear active_channels

                    '---- Prepare For Next Iteration ----
                    mov     theta_ptr,           #channel_data+CHDAT_THETA
                    mov     theta_delta_ptr,     #channel_data+CHDAT_THETA_DELTA
                    mov     theta_cycled_ptr,    #channel_data+CHDAT_THETA_CYCLED
                    mov     shape_ptr,           #channel_data+CHDAT_SHAPE
                    mov     stop_time_ptr,       #channel_data+CHDAT_STOP_TIME
                    mov     volume_ptr,          #channel_data+CHDAT_VOLUME
                    mov     amp_env_ptr,         #channel_data+CHDAT_AMP_ENV
                    mov     env_seg_duration_ptr,#channel_data+CHDAT_ENV_SEG_DURATION
                    mov     lfsr_ptr,            #channel_data+CHDAT_LFSR
                    mov     pcm_start_ptr,       #channel_data+CHDAT_PCM_START
                    mov     pcm_end_ptr,         #channel_data+CHDAT_PCM_END
                    mov     pcm_curr_ptr,        #channel_data+CHDAT_PCM_CURR
                    mov     curr_ch_param_index,#INDEX_OF_CHANNEL0_PARAMS
                    mov     curr_channel,#0

                    add     sound_clock,#1           wz      'Increment Sound Clock
        if_z        add     sound_clock,#1                   'Skip zero, stop_time uses it to mean "never stop"

                    waitcnt time_to_resume,delay_amount      'Delay
                    jmp     #loop                            'Loop

' // Get Parameter Routine ////////////////////////////////////////////

get_param
                    mov     param_addr,par                  'Calculate Address:
                    add     param_addr,param_index          'param_addr = par + param_index

                    rdlong  param_value,param_addr  wz      'Read the parameter value
                    add     param_index,#4                  'Advance param_index to prepare for next call to get_param
        if_nz       wrlong  _nothing_pending,param_addr     'Signal that the parameter value has been received
                                                            'unless the parameter value was 0 (NOTHING_PENDING)
get_param_ret       ret

param_addr          long    0
param_index         long    0
param_value         long    0

' // Shape Generation Routines ////////////////////////////////////////
' Note: These use a JMP/JMP protocol instead of JMPRET/JMP or CALL/RET
'       because they are only called from one line of code
' Return: Returns the sample in sample_temp

generate_shape_silent
                    mov     sample_temp,#0                        'Add nothing to mixed_sample
                    jmp     #return_from_shape

generate_shape_sine
                    add     active_channels,#1                    'Increment number of active channels
                    mov     sin,theta_temp                        'Compute sample from sine wave
                    call    #getsin
                    mov     sample_temp,sin
                    shl     sample_temp,#15                       'Correctly place the sign bit by shifting to the high word
                    sar     sample_temp,#16                       'Shift down to 16-bit
                    jmp     #return_from_shape

generate_shape_sawtooth
                    add     active_channels,#1                    'Increment number of active channels
                    mov     sample_temp,theta_temp

                    shl     sample_temp,#19                       'Start with a triangle wave ranged [$0,$FFF8_0000]
                    add     sample_temp,theta_temp                'Adjust range to [$0,$FFF8_1FFF]
                    abs     sample_temp,sample_temp               'Turn triangle into sawtooth [0,$7FFF_FFFF]
                    shr     sample_temp,#15                       'Adjust from 31-bit to 16-bit
                    sub     sample_temp,bit_15                    'Convert to signed sample

                    jmp     #return_from_shape

generate_shape_square
                    add     active_channels,#1                    'Increment number of active channels
                    cmp     theta_temp,sin_180     wc             'Compute sample from square wave
                    negc    sample_temp,word_half                 'Negate amplitude for half of each cycle
                    jmp     #return_from_shape

generate_shape_triangle
                    add     active_channels,#1                    'Increment number of active channels
                    mov     sample_temp,theta_temp                'Compute sample from trangular wave
                    sub     sample_temp,bit_12                    'Convert to signed sample (ie, adjust range from [$0,$1FFF] to [-$1000,$0FFF])
                    shl     sample_temp,#3                        'Adjust from 13-bit to 16-bit (including sign bit)
                    jmp     #return_from_shape

generate_shape_noise
                    add     active_channels,#1                    'Increment number of active channels
                    mov     sample_temp,lfsr_temp
                    tjz     theta_cycled_temp,#return_from_shape  'Only generate a sample once per cycle

'                    add     sample_temp,#1         '(lfsr + 1)
                    mov     temp,lfsr_temp
{
                    rol     temp,#2
                    xor     sample_temp,temp       '^(lfsr << 2)
                    rol     temp,#4
                    xor     sample_temp,temp       '^(lfsr << 6)
                    rol     temp,#1
                    xor     sample_temp,temp       '^(lfsr << 7)
}
{
                    rol     temp,#15
                    xor     sample_temp,temp       '^(lfsr << 22)
                    rol     temp,#6
                    xor     sample_temp,temp       '^(lfsr << 28)
                    rol     temp,#1
                    xor     sample_temp,temp       '^(lfsr << 29)
                    rol     temp,#1
                    xor     sample_temp,temp       '^(lfsr << 30)
                    rol     temp,#1
                    xor     sample_temp,temp       '^(lfsr << 31)
                    rol     temp,#1
                    xor     sample_temp,temp       '^(lfsr << 32)
}

                    rol     temp,#6
                    xor     sample_temp,temp       '^(lfsr << 6)
                    rol     temp,#1
                    xor     sample_temp,temp       '^(lfsr << 7)
                    rol     temp,#22
                    xor     sample_temp,temp       '^(lfsr << 29)
                    rol     temp,#1
                    xor     sample_temp,temp       '^(lfsr << 30)
                    rol     temp,#1
                    xor     sample_temp,temp       '^(lfsr << 31)
                    rol     temp,#1
                    xor     sample_temp,temp       '^(lfsr << 32)

{
                    rol     temp,#2
                    xor     sample_temp,temp       '^(lfsr << 2)
                    rol     temp,#2
                    xor     sample_temp,temp       '^(lfsr << 4)
                    rol     temp,#1
                    xor     sample_temp,temp       '^(lfsr << 5)
                    rol     temp,#9
                    xor     sample_temp,temp       '^(lfsr << 14)
                    rol     temp,#1
                    xor     sample_temp,temp       '^(lfsr << 15)
                    rol     temp,#1
                    xor     sample_temp,temp       '^(lfsr << 16)
}
                    mov     lfsr_temp,sample_temp  'store new lfsr state
                    shr     sample_temp,#16        'return high 16-bits
'                    and     sample_temp,word_max   'return low 16-bits
                    jmp     #return_from_shape

generate_shape_pcm_8bit_11khz
                    add     active_channels,#1              'Increment number of active channels

                    movs    pcm_load_pcm_curr,pcm_curr_ptr
                    movs    pcm_cmp_end,pcm_end_ptr         'Do something useful instead of nop
pcm_load_pcm_curr   mov     temp,0

                    'I could just "rdlong" once every 4 samples, but that
                    'would require an extra long of storage per channel.
                    rdbyte  sample_temp,temp

                    'Setup the sample
                    shl     sample_temp,#24                 'Correctly place the sign bit by shifting to the high byte
                    sar     sample_temp,#16                 'Shift down to 16-bit

                    'Advance pointer
                    movd    pcm_store_pcm_curr,pcm_curr_ptr
                    xor     temp,bit_31                     'Increment 1-bit counter
                    test    temp,bit_31               wz
           if_z     add     temp,#1                         'Only increment ptr every other iteration (ie: 22KHz -> 11KHz)
pcm_cmp_end         cmp     temp,0                    wz    'Compare pcm_curr with pcm_end
           if_e     movd    pcm_stop,shape_ptr
pcm_store_pcm_curr  mov     0,temp
pcm_stop   if_e     mov     0,#SHAPE_SILENT-1

                    jmp     #return_from_shape

'// Sine/Cosine Lookup Function ///////////////////////////////////////
'// from Hydra Programmer's Manual
'
' Get sine/cosine
'
'      quadrant:  1             2             3             4
'         angle:  $0000..$07FF  $0800..$0FFF  $1000..$17FF  $1800..$1FFF
'   table index:  $0000..$07FF  $0800..$0001  $0000..$07FF  $0800..$0001
'        mirror:  +offset       -offset       +offset       -offset
'          flip:  +sample       +sample       -sample       -sample
'
' on entry: sin[12..0] holds angle (0° to just under 360°)
' on exit:  sin holds signed value ranging from $0000FFFF ('1') to $FFFF0001 ('-1')
'
getcos          add     sin,sin_90              'for cosine, add 90°
getsin          test    sin,sin_90      wc      'get quadrant 2|4 into c
                test    sin,sin_180     wz      'get quadrant 3|4 into nz
                negc    sin,sin                 'if quadrant 2|4, negate offset
                or      sin,sin_table           'or in sin table address >> 1
                shl     sin,#1                  'shift left to get final word address
                rdword  sin,sin                 'read word sample from $E000 to $F000
                negnz   sin,sin                 'if quadrant 3|4, negate sample
getsin_ret
getcos_ret      ret                             '39..54 clocks
                                                '(variance is due to HUB sync on RDWORD)


sin_90          long    $0800   
sin_180         long    $1000
sin_360         long    $2000
sin_table       long    $E000 >> 1              'sine table base shifted right

sin             long    0


'// Multiplication Functions //////////////////////////////////////
'// adapted from Hydra Programmer's Manual
'
' Multiply 8-bit mult_x[7..0] by 4-bit mult_y[3..0] (mult_y[31..4] must be 0)
' on exit, product in mult_y[11..0] (mult_y[31..12] are zeros)
'
multiply_8_by_4_bit      shl     mult_x,#24                   'get multiplicand into mult_x[31..24]
                         shr     mult_y,#1         wc         'get initial multiplier bit into c

                 if_c    add     mult_y,mult_x     wc         'if c set, add multiplicand into product
                         rcr     mult_y,#1         wc         'get next multiplier bit into c, shift product
                 if_c    add     mult_y,mult_x     wc         'if c set, add multiplicand into product
                         rcr     mult_y,#1         wc         'get next multiplier bit into c, shift product
                 if_c    add     mult_y,mult_x     wc         'if c set, add multiplicand into product
                         rcr     mult_y,#1         wc         'get next multiplier bit into c, shift product
                 if_c    add     mult_y,mult_x     wc         'if c set, add multiplicand into product
                         rcr     mult_y,#1         wc         'get next multiplier bit into c, shift product

                         shr     mult_y,#20                   'shift product from mult_y[31..20] to mult_y[11..0]
multiply_8_by_4_bit_ret  ret                                  'return with product in mult_y[11..0] (mult_y[31..12] are zeros)

'
' Multiply 16-bit mult_x[15..0] by 12-bit mult_y[11..0] (mult_y[31..12] must be 0)
' on exit, product in mult_y[27..0] (mult_y[31..28] are zeros)
'
multiply_16_by_12_bit    shl     mult_x,#16                   'get multiplicand into mult_x[31..16]
                         shr     mult_y,#1         wc         'get initial multiplier bit into c

                 if_c    add     mult_y,mult_x     wc         'if c set, add multiplicand into product
                         rcr     mult_y,#1         wc         'get next multiplier bit into c, shift product
                 if_c    add     mult_y,mult_x     wc         'if c set, add multiplicand into product
                         rcr     mult_y,#1         wc         'get next multiplier bit into c, shift product
                 if_c    add     mult_y,mult_x     wc         'if c set, add multiplicand into product
                         rcr     mult_y,#1         wc         'get next multiplier bit into c, shift product
                 if_c    add     mult_y,mult_x     wc         'if c set, add multiplicand into product
                         rcr     mult_y,#1         wc         'get next multiplier bit into c, shift product
                 if_c    add     mult_y,mult_x     wc         'if c set, add multiplicand into product
                         rcr     mult_y,#1         wc         'get next multiplier bit into c, shift product
                 if_c    add     mult_y,mult_x     wc         'if c set, add multiplicand into product
                         rcr     mult_y,#1         wc         'get next multiplier bit into c, shift product
                 if_c    add     mult_y,mult_x     wc         'if c set, add multiplicand into product
                         rcr     mult_y,#1         wc         'get next multiplier bit into c, shift product
                 if_c    add     mult_y,mult_x     wc         'if c set, add multiplicand into product
                         rcr     mult_y,#1         wc         'get next multiplier bit into c, shift product
                 if_c    add     mult_y,mult_x     wc         'if c set, add multiplicand into product
                         rcr     mult_y,#1         wc         'get next multiplier bit into c, shift product
                 if_c    add     mult_y,mult_x     wc         'if c set, add multiplicand into product
                         rcr     mult_y,#1         wc         'get next multiplier bit into c, shift product
                 if_c    add     mult_y,mult_x     wc         'if c set, add multiplicand into product
                         rcr     mult_y,#1         wc         'get next multiplier bit into c, shift product
                 if_c    add     mult_y,mult_x     wc         'if c set, add multiplicand into product
                         rcr     mult_y,#1         wc         'get next multiplier bit into c, shift product

                         shr     mult_y,#4                    'shift product from mult_y[31..4] to mult_y[27..0]
multiply_16_by_12_bit_ret ret                                 'return with product in mult_y[27..0] (mult_y[31..28] are zeros)


mult_x                   long    0
mult_y                   long    0

'// Data ///////////////////////////////////////////////////////////////

delay_amount            long    80_000_000/SAMPLE_RATE
dira_init               long    0
ctra_init               long    6<<26   'mode = duty single

active_channels         long    0       'The number of channels outputting a sound
mixed_sample            long    0       'The sum of samples from each channel

theta_ptr               long    channel_data+CHDAT_THETA        '$0000 = 0 degrees, $2000 = 360 degrees
theta_delta_ptr         long    channel_data+CHDAT_THETA_DELTA  'Formula: ($2000 * frequency) / SAMPLE_RATE
theta_cycled_ptr        long    channel_data+CHDAT_THETA_CYCLED '1 if theta has just completed a cycle, 0 otherwise
shape_ptr               long    channel_data+CHDAT_SHAPE        'Shape of the sound
stop_time_ptr           long    channel_data+CHDAT_STOP_TIME    'Stop the sound when sound_clock reaches this value, or 0 to play forever
volume_ptr              long    channel_data+CHDAT_VOLUME       'Volume in bits 0..7
amp_env_ptr             long    channel_data+CHDAT_AMP_ENV
env_seg_duration_ptr    long    channel_data+CHDAT_ENV_SEG_DURATION  'In sound ticks
lfsr_ptr                long    channel_data+CHDAT_LFSR         'Linear-Feedback Shift Register: Used to generate white noise
pcm_start_ptr           long    channel_data+CHDAT_PCM_START    'Address the PCM data starts at
pcm_end_ptr             long    channel_data+CHDAT_PCM_END      'Address the PCM data ends at (exclusive)
pcm_curr_ptr            long    channel_data+CHDAT_PCM_CURR     'Address of the current PCM sample

channel_data
                        long    0,0,0,0,0,0,0,0,21,0,0,0  'Channel 0
                        long    0,0,0,0,0,0,0,0,21,0,0,0  'Channel 1
                        long    0,0,0,0,0,0,0,0,21,0,0,0  'Channel 2
                        long    0,0,0,0,0,0,0,0,21,0,0,0  'Channel 3
                        long    0,0,0,0,0,0,0,0,21,0,0,0  'Channel 4
                        long    0,0,0,0,0,0,0,0,21,0,0,0  'Channel 5
end_of_channel_data

shape_jmp_ptr           long    0
shape_jmp_table         long    generate_shape_silent
                        long    generate_shape_sine
                        long    generate_shape_sawtooth
                        long    generate_shape_square
                        long    generate_shape_triangle
                        long    generate_shape_noise
                        long    generate_shape_pcm_8bit_11khz
                        
sound_clock             long    1                  'Increments at approx 22KHz (ie. once per driver iteration)
time_to_resume          long    0                  'Used with WAITCNT to synchronize iterations of main loop to 22KHz

curr_ch_param_index     long    INDEX_OF_CHANNEL0_PARAMS  'param_index of current channel

_pending_shape          long    0
_pending_freq           long    0
_pending_duration       long    0
_pending_volume         long    0
_pending_amp_env        long    0
_pending_pcm_start      long    0
_pending_pcm_end        long    0
_nothing_pending        long    0

'Literal Pool -
'A few commonly-needed values that are too big to use as an inline constant (ie. > 511)
long_max                long    $FFFF_FFFF   'The maximum value a long can hold
long_half               long    $7FFF_FFFF   'Half of the maximum value a long can hold
word_max                long    $0000_FFFF   'The maximum value a word can hold
word_half               long    $0000_7FFF   'Half of the maximum value a word can hold
bit_31                  long    1<<31        'Bit 31 = 1, the rest = 0
bit_28                  long    1<<28        'Bit 28 = 1, the rest = 0
bit_15                  long    1<<15        'Bit 15 = 1, the rest = 0
bit_12                  long    1<<12        'Bit 12 = 1, the rest = 0

duration_mask           long    $1FFF_FFFF   'Masks off the "current envelope segment" bits. Only needed when duration is infinite.
amp_env_sustain_set     long    AMP_ENV_SUSTAIN_SEG<<29

curr_env                long    0           'The current 4-bit volume scaler from the envelope
curr_channel            long    0           'The channel currently being processed

temp                    long    0           'Just a scratchpad for calculations
temp2                   long    0           'Just a scratchpad for calculations

sample_temp             long    0
theta_temp              long    0
theta_cycled_temp       long    0
lfsr_temp               long    0