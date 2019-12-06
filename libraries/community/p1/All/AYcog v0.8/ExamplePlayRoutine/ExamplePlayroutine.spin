'
' AYcog demonstartion.
' A minimalistic and stupid play routine playing a stupid little tune. ;)
 
CON _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000    

    playRate = 21 'Hz
    rightPin = 10  
    leftPin  = 11

VAR
  long volume[3]
  
OBJ
  AY : "AYcog"

PUB Main | i, note, channel, musicPointer

  ay.start(rightPin, leftPin)           'Start the emulated AY chip in one cog 
  ay.resetRegisters                     'Reset all AY registers

  ay.enableTone(true, false, true)      'Enable tone on channel 1 and 3 (bass and lead)
  ay.enableNoise(false, true, false)    'Enable noise on channel 2 (drum)
     
  ay.setEnvelope(0, 845)                'Envelope shape is "high to low" and rate is quite fast
 
  musicPointer := -1
  repeat
    waitcnt(cnt + (clkfreq/playRate))
    
    repeat channel from 0 to 2
      note := music[++musicPointer]             ' Get note

      if note == 255                            ' Restart tune if note = 255   
        note := music[musicPointer := 0]
        
      if note                                   ' Note on if note > 0
      
        ifnot channel == 1                      ' Handle bass and lead tone (channel 1 and 3)
          volume[channel] := 15
          ay.setFreq(channel, note2freq(note-43))
          
        else                                    ' Handle drum (channel 2)
          volume[1] := 16                       ' Enable the envelope on channel 2 by setting its volume to 16
          ay.triggerEnvelope                    ' Trigger envelope
          ay.setNoiseFreq(note)
        
      elseif channel <> 1                       ' Note off if note = 0
        volume[channel] -= 2                    ' Decrement the volume every iteration to simulate decay         
                            
        if volume[channel] < 0                  
          volume[channel] := 0
 
      ay.setVolume(channel, volume[channel])    '
                             
PUB note2freq(note) | octave
    octave := note/12
    note -= octave*12 
    return (noteTable[note]>>octave)

DAT
noteTable word 3087, 2914, 2750, 2596, 2450, 2312, 2183, 2060, 1945, 1835, 1732, 1635 
                            
DAT
               'Ch1,Ch2,Ch3 

music     byte  50,  0 , 0 
          byte  50,  0 , 0 
          byte  50,  0 , 0 
          byte  0 ,  0 , 0 
          byte  50,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  62,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  50,  0 , 0 
          byte  50,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  50,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  62,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  50,  0 , 0 
          byte  50,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  62,  0 , 0 
          byte  0 ,  0 , 0 
          byte  62,  0 , 0 
          byte  0 ,  0 , 0 
                         
          byte  55,  0 , 0 
          byte  55,  0 , 0 
          byte  55,  0 , 0 
          byte  0 ,  0 , 0 
          byte  55,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  65,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  55,  0 , 0 
          byte  55,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  55,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  65,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  55,  0 , 0 
          byte  55,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  62,  0 , 0 
          byte  0 ,  0 , 0 
          byte  55,  0 , 0 
          byte  0 ,  0 , 0 
                         
          byte  50,  0 , 0 
          byte  0 ,  0 , 0 
          byte  50,  0 , 0 
          byte  0 ,  0 , 0 
          byte  50,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  62,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  50,  0 , 0 
          byte  50,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  50,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  62,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  50,  0 , 0 
          byte  50,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  62,  0 , 0 
          byte  0 ,  0 , 0 
          byte  62,  0 , 0 
          byte  0 ,  0 , 0 

          byte  60,  0 , 0 
          byte  60,  0 , 0 
          byte  60,  0 , 0 
          byte  0 ,  0 , 0 
          byte  60,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  67,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  60,  0 , 0 
          byte  60,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  55,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  67,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  55,  0 , 0 
          byte  55,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  67,  0 , 0 
          byte  0 ,  0 , 0 
          byte  67,  0 , 0 
          byte  0 ,  0 , 0 
'------------------------------------  
          byte  50,  31, 0 
          byte  50,  0,  0 
          byte  50,  0 , 0 
          byte  0 ,  0 , 0 
          byte  50,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  62,  8, 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  50,  0 , 0 
          byte  50,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  50,  31, 0 
          byte  0 ,  0,  0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  62,  31, 0 
          byte  0 ,  0,  0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  50,  8,  0 
          byte  50,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  62,  0 , 0 
          byte  0 ,  0 , 0 
          byte  62,  0 , 0 
          byte  0 ,  0 , 0 
                         
          byte  55,  31, 0 
          byte  55,  0,  0 
          byte  55,  0 , 0 
          byte  0 ,  0 , 0 
          byte  55,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  65,  8 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  55,  0 , 0 
          byte  55,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  55,  31, 0 
          byte  0 ,  0,  0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  65,  31, 0 
          byte  0 ,  0,  0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  55,  8 , 0 
          byte  55,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  62,  8 , 0 
          byte  0 ,  0 , 0 
          byte  55,  8 , 0 
          byte  0 ,  0 , 0 
                         
          byte  50,  31, 0 
          byte  0 ,  0,  0 
          byte  50,  0 , 0 
          byte  0 ,  0 , 0 
          byte  50,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  62,  8 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  50,  0 , 0 
          byte  50,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  50,  31, 0 
          byte  0 ,  0,  0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  62,  31, 0 
          byte  0 ,  0,  0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  50,  8 , 0 
          byte  50,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  62,  0 , 0 
          byte  0 ,  0 , 0 
          byte  62,  0 , 0 
          byte  0 ,  0 , 0 

          byte  60,  31, 0 
          byte  60,  0,  0 
          byte  60,  0 , 0 
          byte  0 ,  0 , 0 
          byte  60,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  67,  8 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  60,  0 , 0 
          byte  60,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  55,  31, 0 
          byte  0 ,  0,  0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  67,  0 , 0 
          byte  0 ,  0 , 0 
          byte  0 ,  31, 0 
          byte  0 ,  0 , 0 
          byte  55,  8 , 0 
          byte  55,  0 , 0 
          byte  0 ,  31, 0 
          byte  0 ,  0 , 0 
          byte  67,  8 , 0 
          byte  0 ,  0 , 0 
          byte  67,  8 , 0 
          byte  0 ,  0 , 0         
'------------------------------------ 
          byte  50,  31, 0  
          byte  50,  0,  0  
          byte  50,  0 , 0  
          byte  0 ,  0 , 0  
          byte  50,  0 , 0  
          byte  0 ,  0 , 0  
          byte  0 ,  0 , 0  
          byte  0 ,  0 , 0  
          byte  62,  8 , 86 
          byte  0 ,  0 , 86 
          byte  0 ,  0 , 86 
          byte  0 ,  0 , 86 
          byte  50,  0 , 0 
          byte  50,  0 , 0  
          byte  0 ,  0 , 0  
          byte  0 ,  0 , 0  
          byte  50,  31, 86 
          byte  0 ,  0,  86 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0 
          byte  62,  31, 93 
          byte  0 ,  0,  93 
          byte  0 ,  0 , 93 
          byte  0 ,  0 , 93 
          byte  50,  8 , 93 
          byte  50,  0 , 93 
          byte  0 ,  0 , 93 
          byte  0 ,  0 , 93 
          byte  62,  0 , 93 
          byte  0 ,  0 , 93 
          byte  62,  0 , 0  
          byte  0 ,  0 , 0  
                           
          byte  55,  31, 79 
          byte  55,  0,  79 
          byte  55,  0 , 79 
          byte  0 ,  0 , 79 
          byte  55,  0 , 79 
          byte  0 ,  0 , 79 
          byte  0 ,  0 , 79 
          byte  0 ,  0 , 79 
          byte  65,  8 , 0 
          byte  0 ,  0 , 0  
          byte  0 ,  0 , 0  
          byte  0 ,  0 , 0  
          byte  55,  0 , 0  
          byte  55,  0 , 0  
          byte  0 ,  0 , 0  
          byte  0 ,  0 , 0  
          byte  55,  31, 77 
          byte  0 ,  0,  77 
          byte  0 ,  0 , 77 
          byte  0 ,  0 , 77 
          byte  65,  31, 77 
          byte  0 ,  0,  77 
          byte  0 ,  0 , 0  
          byte  0 ,  0 , 0  
          byte  55,  8 , 83 
          byte  55,  0 , 83 
          byte  0 ,  0 , 83 
          byte  0 ,  0 , 83 
          byte  62,  8 , 0  
          byte  0 ,  0 , 0  
          byte  55,  8 , 0 
          byte  0 ,  0 , 0  
                         
          byte  50,  31, 81 
          byte  0 ,  0,  81 
          byte  50,  0 , 81 
          byte  0 ,  0 , 81 
          byte  50,  0 , 81 
          byte  0 ,  0 , 81 
          byte  0 ,  0 , 81 
          byte  0 ,  0 , 81 
          byte  62,  8 , 81 
          byte  0 ,  0 , 0  
          byte  0 ,  0 , 0  
          byte  0 ,  0 , 0  
          byte  50,  0 , 79 
          byte  50,  0 , 79 
          byte  0 ,  0 , 79 
          byte  0 ,  0 , 79 
          byte  50,  31, 0  
          byte  0 ,  0,  0  
          byte  0 ,  0 , 0  
          byte  0 ,  0 , 0  
          byte  62,  31, 77 
          byte  0 ,  0,  77 
          byte  0 ,  0 , 77 
          byte  0 ,  0 , 77 
          byte  50,  8 , 0  
          byte  50,  0 , 0  
          byte  0 ,  0 , 0  
          byte  0 ,  0 , 0  
          byte  62,  0 , 84 
          byte  0 ,  0 , 84 
          byte  62,  0 , 0 
          byte  0 ,  0 , 0  

          byte  60,  31, 86 
          byte  60,  0,  86 
          byte  60,  0 , 86 
          byte  0 ,  0 , 86 
          byte  60,  31, 86 
          byte  0 ,  0,  86 
          byte  0 ,  0 , 0  
          byte  0 ,  0 , 0  
          byte  67,  8 , 86 
          byte  0 ,  0 , 86 
          byte  0 ,  0 , 0  
          byte  0 ,  0 , 0 
          byte  60,  0 , 0  
          byte  60,  0 , 0  
          byte  0 ,  0 , 0  
          byte  0 ,  0 , 0  
          byte  55,  31, 89 
          byte  0 ,  0,  89 
          byte  0 ,  0 , 89 
          byte  0 ,  0 , 89 
          byte  67,  0 , 0  
          byte  0 ,  0 , 0  
          byte  0 ,  0 , 0  
          byte  0 ,  0 , 0  
          byte  55,  8 , 88 
          byte  55,  0 , 88 
          byte  0 ,  31, 88 
          byte  0 ,  0 , 88 
          byte  67,  8 , 88 
          byte  0 ,  0 , 88 
          byte  67,  8 , 88 
          byte  0 ,  0 , 88 

'------------------------------------------
          byte  50,  31, 88 
          byte  50,  0,  88 
          byte  50,  0 , 0  
          byte  0 ,  0 , 0  
          byte  50,  0 , 81 
          byte  0 ,  0 , 81 
          byte  0 ,  0 , 81 
          byte  0 ,  0 , 81 
          byte  62,  8 , 90 
          byte  0 ,  0 , 89 
          byte  0 ,  0 , 0  
          byte  0 ,  0 , 0  
          byte  50,  0 , 81 
          byte  50,  0 , 81 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0  
          byte  50,  31, 89 
          byte  0 ,  0,  88 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0  
          byte  62,  31, 89 
          byte  0 ,  0,  89 
          byte  0 ,  0 , 0  
          byte  0 ,  0 , 0 
          byte  50,  8 , 81 
          byte  50,  0 , 81 
          byte  0 ,  0 , 81 
          byte  0 ,  0 , 81 
          byte  62,  0 , 81 
          byte  0 ,  0 , 81 
          byte  62,  0 , 0 
          byte  0 ,  0 , 0 
                         
          byte  55,  31, 84 
          byte  55,  0,  84 
          byte  55,  0 , 84 
          byte  0 ,  0 , 84 
          byte  55,  0 , 84 
          byte  0 ,  0 , 84 
          byte  0 ,  0 , 84 
          byte  0 ,  0 , 84 
          byte  65,  8 , 84 
          byte  0 ,  0 , 0  
          byte  0 ,  0 , 0  
          byte  0 ,  0 , 0 
          byte  55,  0 , 0  
          byte  55,  0 , 0  
          byte  0 ,  0 , 0  
          byte  0 ,  0 , 0 
          byte  55,  31, 83 
          byte  0 ,  0,  83 
          byte  0 ,  0 , 0  
          byte  0 ,  0 , 0 
          byte  65,  31, 0  
          byte  0 ,  0,  0 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0  
          byte  55,  8 , 79 
          byte  55,  0 , 79 
          byte  0 ,  0 , 0  
          byte  0 ,  0 , 0  
          byte  62,  8 , 0 
          byte  0 ,  0 , 0  
          byte  55,  8 , 0  
          byte  0 ,  0 , 0  
                         
          byte  50,  31, 86 
          byte  0 ,  0,  86                                                                                   '
          byte  50,  0 , 86 
          byte  0 ,  0 , 86 
          byte  50,  0 , 86 
          byte  0 ,  0 , 86 
          byte  0 ,  0 , 86 
          byte  0 ,  0 , 86 
          byte  62,  8 , 86 
          byte  0 ,  0 , 86 
          byte  0 ,  0 , 86 
          byte  0 ,  0 , 86 
          byte  50,  0 , 0  
          byte  50,  0 , 0  
          byte  0 ,  0 , 0  
          byte  0 ,  0 , 0  
          byte  50,  31, 0  
          byte  0 ,  0,  0  
          byte  0 ,  0 , 0  
          byte  0 ,  0 , 0  
          byte  62,  31, 82 
          byte  0 ,  0,  81 
          byte  0 ,  0 , 81 
          byte  0 ,  0 , 81 
          byte  50,  8 , 0  
          byte  50,  0 , 0  
          byte  0 ,  0 , 8  
          byte  0 ,  0 , 79 
          byte  62,  0 , 79 
          byte  0 ,  0 , 79 
          byte  62,  0 , 0  
          byte  0 ,  0 , 0  

          byte  60,  31, 82 
          byte  60,  0,  81 
          byte  60,  0 , 81 
          byte  0 ,  0 , 81 
          byte  60,  31, 81 
          byte  0 ,  0,  0  
          byte  0 ,  0 , 0  
          byte  0 ,  0 , 0  
          byte  67,  8 , 84 
          byte  0 ,  0 , 84 
          byte  0 ,  0 , 0 
          byte  0 ,  0 , 0  
          byte  60,  0 , 8  
          byte  60,  0 , 79 
          byte  0 ,  0 , 79 
          byte  0 ,  0 , 79 
          byte  55,  31, 0  
          byte  0 ,  0,  0  
          byte  0 ,  0 , 0  
          byte  0 ,  0 , 0  
          byte  67,  0 , 79 
          byte  0 ,  0 , 79 
          byte  0 ,  0 , 0  
          byte  0 ,  0 , 0  
          byte  55,  8 , 77 
          byte  55,  0 , 77 
          byte  0 ,  31, 0  
          byte  0 ,  0 , 0  
          byte  67,  8 , 72 
          byte  0 ,  0 , 72 
          byte  67,  8 , 72 
          byte  0 ,  0 , 72 
        
          byte  255' Song end
           