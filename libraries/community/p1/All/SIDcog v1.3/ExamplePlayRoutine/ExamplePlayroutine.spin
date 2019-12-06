'
' SIDcog demonstartion.
' A minimalistic and stupid play routine playing a stupid little tune. ;)
 
CON _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000    

    playRate = 21 'Hz
    rightPin = 10  
    leftPin = 11
 
OBJ
  SID : "SIDcog"

PUB Main | i, note, channel, musicPointer

  SID.start(rightPin, leftPin)           'Start the emulated SID chip in one cog 
  SID.resetRegisters                     'Reset all SID registers
  SID.setVolume(15)                      'Set volume to max     

  SID.setWaveform(0, SID#SQUARE)         'Set waveform type on channel1 to square wave
  SID.setPulseWidth(0, 1928)             'Set the pulse width on channel1 to 47:53
  SID.setADSR(0, 2, 5, 9, 6)             'Set Envelope on channel1
  SID.setWaveform(1, SID#NOISE)          'Set waveform type on channel2 to noise (drum sound)  
  SID.setADSR(1, 0, 8, 4, 7)             'Set Envelope on channel2  
  SID.setWaveform(2, SID#SAW)            'Set waveform type on channel3 to saw wave
  SID.setADSR(2, 7, 4, 8, 9)             'Set Envelope on channel3  


                    'Lp     Bp    Hp    
  SID.setFilterType(true, false, false)  'Enable lowpass filter

                    'Ch1   Ch2   Ch3      
  SID.setFilterMask(true, false, false)  'Enable filter on the "bass channel" (channel1)

  SID.setResonance(15)                   'Set the resonance value to max

  
  musicPointer := -1
  repeat
    waitcnt(cnt + (clkfreq/playRate))
    
    repeat channel from 0 to 2
      note := music[++musicPointer]

      if note == 255                            ' Restart tune if note = 255   
        note := music[musicPointer := 0] 
      if note                                   ' Note on if note > 0   
        SID.noteOn(channel, note2freq(note))        
      else
        SID.noteOff(channel)                    ' Note off if note = 0

    SID.setCutoff(music[++musicPointer]<<3)     ' Update cutoff frequency
      
PUB note2freq(note) | octave
    octave := note/12
    note -= octave*12 
    return (noteTable[note]>>(8-octave))

DAT
noteTable word 16350, 17320, 18350, 19450, 20600, 21830, 23120, 24500, 25960, 27500, 29140, 30870
           
DAT
               'Ch1,Ch2,Ch3,cutoff 

music     byte  50,  0 , 0, 0
          byte  50,  0 , 0, 1
          byte  50,  0 , 0, 2
          byte  0 ,  0 , 0, 3
          byte  50,  0 , 0, 4
          byte  0 ,  0 , 0, 5
          byte  0 ,  0 , 0, 6
          byte  0 ,  0 , 0, 7
          byte  62,  0 , 0, 8
          byte  0 ,  0 , 0, 9
          byte  0 ,  0 , 0, 10
          byte  0 ,  0 , 0, 11
          byte  50,  0 , 0, 12
          byte  50,  0 , 0, 13
          byte  0 ,  0 , 0, 14
          byte  0 ,  0 , 0, 15
          byte  50,  0 , 0, 16
          byte  0 ,  0 , 0, 17
          byte  0 ,  0 , 0, 18
          byte  0 ,  0 , 0, 19
          byte  62,  0 , 0, 20
          byte  0 ,  0 , 0, 21
          byte  0 ,  0 , 0, 22
          byte  0 ,  0 , 0, 23
          byte  50,  0 , 0, 24
          byte  50,  0 , 0, 25
          byte  0 ,  0 , 0, 26
          byte  0 ,  0 , 0, 27
          byte  62,  0 , 0, 28
          byte  0 ,  0 , 0, 29
          byte  62,  0 , 0, 30
          byte  0 ,  0 , 0, 31
                         
          byte  55,  0 , 0, 32
          byte  55,  0 , 0, 33
          byte  55,  0 , 0, 34
          byte  0 ,  0 , 0, 35
          byte  55,  0 , 0, 36
          byte  0 ,  0 , 0, 37
          byte  0 ,  0 , 0, 38
          byte  0 ,  0 , 0, 39
          byte  65,  0 , 0, 40
          byte  0 ,  0 , 0, 41
          byte  0 ,  0 , 0, 42
          byte  0 ,  0 , 0, 43
          byte  55,  0 , 0, 44
          byte  55,  0 , 0, 45
          byte  0 ,  0 , 0, 46
          byte  0 ,  0 , 0, 47
          byte  55,  0 , 0, 48
          byte  0 ,  0 , 0, 49
          byte  0 ,  0 , 0, 50
          byte  0 ,  0 , 0, 51
          byte  65,  0 , 0, 52
          byte  0 ,  0 , 0, 53
          byte  0 ,  0 , 0, 54
          byte  0 ,  0 , 0, 55
          byte  55,  0 , 0, 56
          byte  55,  0 , 0, 57
          byte  0 ,  0 , 0, 58
          byte  0 ,  0 , 0, 59
          byte  62,  0 , 0, 60
          byte  0 ,  0 , 0, 61
          byte  55,  0 , 0, 62
          byte  0 ,  0 , 0, 63
                         
          byte  50,  0 , 0, 64
          byte  0 ,  0 , 0, 65
          byte  50,  0 , 0, 66
          byte  0 ,  0 , 0, 67
          byte  50,  0 , 0, 68
          byte  0 ,  0 , 0, 69
          byte  0 ,  0 , 0, 70
          byte  0 ,  0 , 0, 71
          byte  62,  0 , 0, 72
          byte  0 ,  0 , 0, 73
          byte  0 ,  0 , 0, 74
          byte  0 ,  0 , 0, 75
          byte  50,  0 , 0, 76
          byte  50,  0 , 0, 77
          byte  0 ,  0 , 0, 78
          byte  0 ,  0 , 0, 79
          byte  50,  0 , 0, 80
          byte  0 ,  0 , 0, 81
          byte  0 ,  0 , 0, 82
          byte  0 ,  0 , 0, 83
          byte  62,  0 , 0, 84
          byte  0 ,  0 , 0, 85
          byte  0 ,  0 , 0, 86
          byte  0 ,  0 , 0, 87
          byte  50,  0 , 0, 88
          byte  50,  0 , 0, 89
          byte  0 ,  0 , 0, 90
          byte  0 ,  0 , 0, 91
          byte  62,  0 , 0, 92
          byte  0 ,  0 , 0, 93
          byte  62,  0 , 0, 94
          byte  0 ,  0 , 0, 95

          byte  60,  0 , 0, 96
          byte  60,  0 , 0, 97
          byte  60,  0 , 0, 98
          byte  0 ,  0 , 0, 99
          byte  60,  0 , 0, 100
          byte  0 ,  0 , 0, 101
          byte  0 ,  0 , 0, 102
          byte  0 ,  0 , 0, 103
          byte  67,  0 , 0, 104
          byte  0 ,  0 , 0, 105
          byte  0 ,  0 , 0, 106
          byte  0 ,  0 , 0, 107
          byte  60,  0 , 0, 108
          byte  60,  0 , 0, 109
          byte  0 ,  0 , 0, 110
          byte  0 ,  0 , 0, 111
          byte  55,  0 , 0, 112
          byte  0 ,  0 , 0, 113
          byte  0 ,  0 , 0, 114
          byte  0 ,  0 , 0, 115
          byte  67,  0 , 0, 116
          byte  0 ,  0 , 0, 117
          byte  0 ,  0 , 0, 118
          byte  0 ,  0 , 0, 119
          byte  55,  0 , 0, 120
          byte  55,  0 , 0, 121
          byte  0 ,  0 , 0, 122
          byte  0 ,  0 , 0, 123
          byte  67,  0 , 0, 124
          byte  0 ,  0 , 0, 125
          byte  67,  0 , 0, 126
          byte  0 ,  0 , 0, 127
'------------------------------------  
          byte  50,  60, 0, 128
          byte  50,  60, 0, 129
          byte  50,  0 , 0, 130
          byte  0 ,  0 , 0, 131
          byte  50,  0 , 0, 132
          byte  0 ,  0 , 0, 133
          byte  0 ,  0 , 0, 134
          byte  0 ,  0 , 0, 135
          byte  62,  80, 0, 136
          byte  0 ,  0 , 0, 137
          byte  0 ,  0 , 0, 138
          byte  0 ,  0 , 0, 139
          byte  50,  0 , 0, 140
          byte  50,  0 , 0, 141
          byte  0 ,  0 , 0, 142
          byte  0 ,  0 , 0, 143
          byte  50,  60, 0, 144
          byte  0 ,  60, 0, 145
          byte  0 ,  0 , 0, 146
          byte  0 ,  0 , 0, 147
          byte  62,  60, 0, 148
          byte  0 ,  60, 0, 149
          byte  0 ,  0 , 0, 150
          byte  0 ,  0 , 0, 151
          byte  50,  80, 0, 152
          byte  50,  0 , 0, 153
          byte  0 ,  0 , 0, 154
          byte  0 ,  0 , 0, 155
          byte  62,  0 , 0, 156
          byte  0 ,  0 , 0, 157
          byte  62,  0 , 0, 158
          byte  0 ,  0 , 0, 159
                         
          byte  55,  60, 0, 160
          byte  55,  60, 0, 161
          byte  55,  0 , 0, 162
          byte  0 ,  0 , 0, 163
          byte  55,  0 , 0, 164
          byte  0 ,  0 , 0, 165
          byte  0 ,  0 , 0, 166
          byte  0 ,  0 , 0, 167
          byte  65,  80, 0, 168
          byte  0 ,  0 , 0, 169
          byte  0 ,  0 , 0, 170
          byte  0 ,  0 , 0, 171
          byte  55,  0 , 0, 172
          byte  55,  0 , 0, 173
          byte  0 ,  0 , 0, 174
          byte  0 ,  0 , 0, 175
          byte  55,  60, 0, 176
          byte  0 ,  60, 0, 177
          byte  0 ,  0 , 0, 178
          byte  0 ,  0 , 0, 179
          byte  65,  60, 0, 180
          byte  0 ,  60, 0, 181
          byte  0 ,  0 , 0, 182
          byte  0 ,  0 , 0, 183
          byte  55,  80, 0, 184
          byte  55,  0 , 0, 185
          byte  0 ,  0 , 0, 186
          byte  0 ,  0 , 0, 187
          byte  62,  80, 0, 188
          byte  0 ,  0 , 0, 189
          byte  55,  80, 0, 190
          byte  0 ,  0 , 0, 191
                         
          byte  50,  60, 0, 192
          byte  0 ,  60, 0, 193
          byte  50,  0 , 0, 194
          byte  0 ,  0 , 0, 195
          byte  50,  0 , 0, 196
          byte  0 ,  0 , 0, 197
          byte  0 ,  0 , 0, 198
          byte  0 ,  0 , 0, 199
          byte  62,  80, 0, 200
          byte  0 ,  0 , 0, 201
          byte  0 ,  0 , 0, 202
          byte  0 ,  0 , 0, 203
          byte  50,  0 , 0, 204
          byte  50,  0 , 0, 205
          byte  0 ,  0 , 0, 206
          byte  0 ,  0 , 0, 207
          byte  50,  60, 0, 208
          byte  0 ,  60, 0, 209
          byte  0 ,  0 , 0, 210
          byte  0 ,  0 , 0, 211
          byte  62,  60, 0, 212
          byte  0 ,  60, 0, 213
          byte  0 ,  0 , 0, 214
          byte  0 ,  0 , 0, 215
          byte  50,  80, 0, 216
          byte  50,  0 , 0, 217
          byte  0 ,  0 , 0, 218
          byte  0 ,  0 , 0, 219
          byte  62,  0 , 0, 220
          byte  0 ,  0 , 0, 221
          byte  62,  0 , 0, 222
          byte  0 ,  0 , 0, 223

          byte  60,  60, 0, 224
          byte  60,  60, 0, 225
          byte  60,  0 , 0, 226
          byte  0 ,  0 , 0, 227
          byte  60,  0 , 0, 228
          byte  0 ,  0 , 0, 229
          byte  0 ,  0 , 0, 230
          byte  0 ,  0 , 0, 231
          byte  67,  80, 0, 232
          byte  0 ,  0 , 0, 233
          byte  0 ,  0 , 0, 234
          byte  0 ,  0 , 0, 235
          byte  60,  0 , 0, 236
          byte  60,  0 , 0, 237
          byte  0 ,  0 , 0, 238
          byte  0 ,  0 , 0, 239
          byte  55,  60, 0, 240
          byte  0 ,  60, 0, 241
          byte  0 ,  0 , 0, 242
          byte  0 ,  0 , 0, 243
          byte  67,  0 , 0, 244
          byte  0 ,  0 , 0, 245
          byte  0 ,  60, 0, 246
          byte  0 ,  0 , 0, 247
          byte  55,  80, 0, 248
          byte  55,  0 , 0, 249
          byte  0 ,  60, 0, 250
          byte  0 ,  0 , 0, 251
          byte  67,  80, 0, 252
          byte  0 ,  0 , 0, 253
          byte  67,  80, 0, 254
          byte  0 ,  0 , 0, 255         
'------------------------------------ 
          byte  50,  60, 0 , 255
          byte  50,  60, 0 , 128
          byte  50,  0 , 0 , 64
          byte  0 ,  0 , 0 , 32
          byte  50,  0 , 0 , 255
          byte  0 ,  0 , 0 , 128
          byte  0 ,  0 , 0 , 64
          byte  0 ,  0 , 0 , 32
          byte  62,  80, 86, 255
          byte  0 ,  0 , 86, 128
          byte  0 ,  0 , 86, 64
          byte  0 ,  0 , 86, 32
          byte  50,  0 , 0 , 255
          byte  50,  0 , 0 , 128
          byte  0 ,  0 , 0 , 64
          byte  0 ,  0 , 0 , 32
          byte  50,  60, 86, 255
          byte  0 ,  60, 86, 128
          byte  0 ,  0 , 0 , 64
          byte  0 ,  0 , 0 , 32
          byte  62,  60, 93, 255
          byte  0 ,  60, 93, 128
          byte  0 ,  0 , 93, 64
          byte  0 ,  0 , 93, 32
          byte  50,  80, 93, 255
          byte  50,  0 , 93, 128
          byte  0 ,  0 , 93, 64
          byte  0 ,  0 , 93, 32
          byte  62,  0 , 93, 255
          byte  0 ,  0 , 93, 128
          byte  62,  0 , 0 , 255
          byte  0 ,  0 , 0 , 128
                           
          byte  55,  60, 79, 255
          byte  55,  60, 79, 128
          byte  55,  0 , 79, 64
          byte  0 ,  0 , 79, 32
          byte  55,  0 , 79, 255
          byte  0 ,  0 , 79, 128
          byte  0 ,  0 , 79, 64
          byte  0 ,  0 , 79, 32
          byte  65,  80, 0 , 255
          byte  0 ,  0 , 0 , 128
          byte  0 ,  0 , 0 , 64
          byte  0 ,  0 , 0 , 32
          byte  55,  0 , 0 , 255
          byte  55,  0 , 0 , 128
          byte  0 ,  0 , 0 , 64
          byte  0 ,  0 , 0 , 32
          byte  55,  60, 77, 255
          byte  0 ,  60, 77, 128
          byte  0 ,  0 , 77, 64
          byte  0 ,  0 , 77, 32
          byte  65,  60, 77, 255
          byte  0 ,  60, 77, 128
          byte  0 ,  0 , 0 , 64
          byte  0 ,  0 , 0 , 32
          byte  55,  80, 83, 255
          byte  55,  0 , 83, 128
          byte  0 ,  0 , 83, 64
          byte  0 ,  0 , 83, 32
          byte  62,  80, 0 , 255
          byte  0 ,  0 , 0 , 128
          byte  55,  80, 0 , 255
          byte  0 ,  0 , 0 , 128
                         
          byte  50,  60, 81, 255
          byte  0 ,  60, 81, 128
          byte  50,  0 , 81, 255
          byte  0 ,  0 , 81, 128
          byte  50,  0 , 81, 255
          byte  0 ,  0 , 81, 128
          byte  0 ,  0 , 81, 64
          byte  0 ,  0 , 81, 32
          byte  62,  80, 81, 255
          byte  0 ,  0 , 0 , 128
          byte  0 ,  0 , 0 , 64
          byte  0 ,  0 , 0 , 32
          byte  50,  0 , 79, 255
          byte  50,  0 , 79, 128
          byte  0 ,  0 , 79, 64
          byte  0 ,  0 , 79, 32
          byte  50,  60, 0 , 255
          byte  0 ,  60, 0 , 128
          byte  0 ,  0 , 0 , 64
          byte  0 ,  0 , 0 , 32
          byte  62,  60, 77, 255
          byte  0 ,  60, 77, 128
          byte  0 ,  0 , 77, 64
          byte  0 ,  0 , 77, 32
          byte  50,  80, 0 , 255
          byte  50,  0 , 0 , 128
          byte  0 ,  0 , 0 , 64
          byte  0 ,  0 , 0 , 32
          byte  62,  0 , 84, 255
          byte  0 ,  0 , 84, 128
          byte  62,  0 , 0 , 255
          byte  0 ,  0 , 0 , 128

          byte  60,  60, 86, 255
          byte  60,  60, 86, 128
          byte  60,  0 , 86, 64
          byte  0 ,  0 , 86, 32
          byte  60,  60, 86, 255
          byte  0 ,  60, 86, 128
          byte  0 ,  0 , 0 , 64
          byte  0 ,  0 , 0 , 32
          byte  67,  80, 86, 128
          byte  0 ,  0 , 86, 64
          byte  0 ,  0 , 0 , 32
          byte  0 ,  0 , 0 , 16
          byte  60,  0 , 0 , 255
          byte  60,  0 , 0 , 128
          byte  0 ,  0 , 0 , 64
          byte  0 ,  0 , 0 , 32
          byte  55,  60, 89, 255
          byte  0 ,  60, 89, 128
          byte  0 ,  0 , 89, 64
          byte  0 ,  0 , 89, 32
          byte  67,  0 , 0 , 255
          byte  0 ,  0 , 0 , 128
          byte  0 ,  0 , 0 , 64
          byte  0 ,  0 , 0 , 32
          byte  55,  80, 88, 255
          byte  55,  0 , 88, 128
          byte  0 ,  60, 88, 64
          byte  0 ,  0 , 88, 32
          byte  67,  80, 88, 255
          byte  0 ,  0 , 88, 128
          byte  67,  80, 88, 255
          byte  0 ,  0 , 88, 128

'------------------------------------------
          byte  50,  60, 88, 128
          byte  50,  60, 88, 64
          byte  50,  0 , 0 , 32
          byte  0 ,  0 , 0 , 16
          byte  50,  0 , 81, 128
          byte  0 ,  0 , 81, 64
          byte  0 ,  0 , 81, 32
          byte  0 ,  0 , 81, 16
          byte  62,  80, 90, 128
          byte  0 ,  0 , 89, 64
          byte  0 ,  0 , 0 , 32
          byte  0 ,  0 , 0 , 16
          byte  50,  0 , 81, 128
          byte  50,  0 , 81, 64
          byte  0 ,  0 , 0 , 32
          byte  0 ,  0 , 0 , 16
          byte  50,  60, 89, 128
          byte  0 ,  60, 88, 64
          byte  0 ,  0 , 0 , 32
          byte  0 ,  0 , 0 , 16
          byte  62,  60, 89, 128
          byte  0 ,  60, 89, 64
          byte  0 ,  0 , 0 , 32
          byte  0 ,  0 , 0 , 16
          byte  50,  80, 81, 128
          byte  50,  0 , 81, 64
          byte  0 ,  0 , 81, 32
          byte  0 ,  0 , 81, 16
          byte  62,  0 , 81, 128
          byte  0 ,  0 , 81, 64
          byte  62,  0 , 0 , 32
          byte  0 ,  0 , 0 , 16
                         
          byte  55,  60, 84, 128
          byte  55,  60, 84, 64
          byte  55,  0 , 84, 32
          byte  0 ,  0 , 84, 16
          byte  55,  0 , 84, 128
          byte  0 ,  0 , 84, 64
          byte  0 ,  0 , 84, 32
          byte  0 ,  0 , 84, 16
          byte  65,  80, 84, 128
          byte  0 ,  0 , 0 , 64
          byte  0 ,  0 , 0 , 32
          byte  0 ,  0 , 0 , 16
          byte  55,  0 , 0 , 128
          byte  55,  0 , 0 , 64
          byte  0 ,  0 , 0 , 32
          byte  0 ,  0 , 0 , 16
          byte  55,  60, 83, 128
          byte  0 ,  60, 83, 64
          byte  0 ,  0 , 0 , 32
          byte  0 ,  0 , 0 , 16
          byte  65,  60, 0 , 128
          byte  0 ,  60, 0 , 64
          byte  0 ,  0 , 0 , 32
          byte  0 ,  0 , 0 , 16
          byte  55,  80, 79, 128
          byte  55,  0 , 79, 64
          byte  0 ,  0 , 0 , 32
          byte  0 ,  0 , 0 , 16
          byte  62,  80, 0 , 128
          byte  0 ,  0 , 0 , 64
          byte  55,  80, 0 , 128
          byte  0 ,  0 , 0 , 64
                         
          byte  50,  60, 86, 255
          byte  0 ,  60, 86, 64                                                                                    '
          byte  50,  0 , 86, 255
          byte  0 ,  0 , 86, 64
          byte  50,  0 , 86, 255
          byte  0 ,  0 , 86, 128
          byte  0 ,  0 , 86, 64
          byte  0 ,  0 , 86, 32
          byte  62,  80, 86, 16
          byte  0 ,  0 , 86, 8
          byte  0 ,  0 , 86, 4
          byte  0 ,  0 , 86, 2
          byte  50,  0 , 0 , 2
          byte  50,  0 , 0 , 4
          byte  0 ,  0 , 0 , 16
          byte  0 ,  0 , 0 , 32
          byte  50,  60, 0 , 64
          byte  0 ,  60, 0 , 128
          byte  0 ,  0 , 0 , 192
          byte  0 ,  0 , 0 , 255
          byte  62,  60, 82, 255
          byte  0 ,  60, 81, 192
          byte  0 ,  0 , 81, 150
          byte  0 ,  0 , 81, 120
          byte  50,  80, 0 , 100
          byte  50,  0 , 0 , 80
          byte  0 ,  0 , 80, 100
          byte  0 ,  0 , 79, 120
          byte  62,  0 , 79, 150
          byte  0 ,  0 , 79, 192
          byte  62,  0 , 0 , 230
          byte  0 ,  0 , 0 , 255

          byte  60,  60, 82, 255
          byte  60,  60, 81, 248
          byte  60,  0 , 81, 240
          byte  0 ,  0 , 81, 232
          byte  60,  60, 81, 224
          byte  0 ,  60, 0 , 216
          byte  0 ,  0 , 0 , 208
          byte  0 ,  0 , 0 , 200
          byte  67,  80, 84, 192
          byte  0 ,  0 , 84, 184
          byte  0 ,  0 , 0 , 176
          byte  0 ,  0 , 0 , 168
          byte  60,  0 , 80, 160
          byte  60,  0 , 79, 152
          byte  0 ,  0 , 79, 144
          byte  0 ,  0 , 79, 136
          byte  55,  60, 0 , 128
          byte  0 ,  60, 0 , 120
          byte  0 ,  0 , 0 , 112
          byte  0 ,  0 , 0 , 104
          byte  67,  0 , 79, 96
          byte  0 ,  0 , 79, 88
          byte  0 ,  0 , 0 , 80
          byte  0 ,  0 , 0 , 72
          byte  55,  80, 77, 64
          byte  55,  0 , 77, 56
          byte  0 ,  60, 0 , 48
          byte  0 ,  0 , 0 , 40
          byte  67,  80, 72, 32
          byte  0 ,  0 , 72, 24
          byte  67,  80, 72, 16
          byte  0 ,  0 , 72, 8
        
          byte  255' Song end
           