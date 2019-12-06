{{ MusicMaker.spin, v1.1
   Copyright (c) 2009 Austin Bowen
   *See end of file for terms of use*
   
   This program allows you to play up to 2 musical notes at once per cog. Read each subroutine's
   documentation on how to use them. Nothing special about using this program:

   OBJ
     MM : "MusicMaker"
}}

OBJ
  SYNTH : "Synth"

VAR
  LONG PIN
  
PUB SET_PIN (_PIN)
{{ Sets the pin for PLAY_NOTE and PLAY_NOTES to use }}
  PIN := _PIN
  
PUB PLAY_NOTE (AB, NOTE) | X
{{ AB  : Which counter module to use, 0 for "A" or 1 for "B"
   NOTE: What musical note to play, for instance: STRING("C#").
         You can also chose the octave of the note by puting a number (0 - 7) at the very end
         of the note in the string ("C#4" would be an octave higher than "C#"). An octave of 3
         is normal so you don't have to put 3 on the end ("C#" = "C#3")
         Set this to 0 to stop whatever note is already playing, ie PLAY_NOTE(0, 0)
}} 
  AB := (AB #> 0 <# 1) + "A"
  IF NOT NOTE
    SYNTH.SYNTH(AB, PIN, 0)
  X~
  CASE BYTE[NOTE++]
    "A" :
      IF (BYTE[NOTE] == "#")
        X := 466
      ELSEIF (BYTE[NOTE] == "b")
        X := 415
      ELSE
        X := 440
    "B" :       
      IF (BYTE[NOTE] == "#")
        X := 262*2
      ELSEIF (BYTE[NOTE] == "b")
        X := 466
      ELSE
        X := 494
    "C" :             
      IF (BYTE[NOTE] == "#")
        X := 277
      ELSEIF (BYTE[NOTE] == "b")
        X := 494/2
      ELSE
        X := 262 
    "D" :              
      IF (BYTE[NOTE] == "#")
        X := 311
      ELSEIF (BYTE[NOTE] == "b")
        X := 277
      ELSE
        X := 294
    "E" :              
      IF (BYTE[NOTE] == "#")
        X := 349
      ELSEIF (BYTE[NOTE] == "b")
        X := 311
      ELSE
        X := 330
    "F" :              
      IF (BYTE[NOTE] == "#")
        X := 370
      ELSEIF (BYTE[NOTE] == "b")
        X := 330
      ELSE
        X := 349
    "G" :              
      IF (BYTE[NOTE] == "#")
        X := 415
      ELSEIF (BYTE[NOTE] == "b")
        X := 370
      ELSE
        X := 392

  IF (BYTE[NOTE] == "#") OR (BYTE[NOTE] == "b")
    NOTE++
        
  CASE BYTE[NOTE]
    "0" : X /= 8
    "1" : X /= 4
    "2" : X /= 2
    "4" : X *= 2
    "5" : X *= 4
    "6" : X *= 8
    "7" : X *= 16

  SYNTH.SYNTH(AB, PIN, X)  
          

PUB PLAY_NOTES (AB, NOTES, BPM, MEASURES) | X, TIMER
{{ AB   : Which counter module to use, 0 for "A" or 1 for "B"
   NOTES: What musical notes to play, for instance: STRING("A2 B2 - C E *"). You always have to end
          the string of notes with a "*". The "-" will hold for 1 beat. Every note/command has to
          be seperated by a space. You can chose the octave of each note by puting a number (0 - 7)
          at the very end of the note in the string ("C#4" would be an octave higher than "C#").
          An octave of 3 is normal so you don't have to put 3 on the end ("C#3" = "C#")
   BPM  : This is the Beats/Minute which provides the timing of when to switch to the next note.
   MEASURES: This devides the beat by its value, so a BPM of 60 with MEASURES set to 1 would
             go to the next note once a second. But with MEASURES set to 4, it would go 4 times a second.
             For example, PLAY_NOTES("A", STRING("A# *"), 60, 1) would do exactly the same thing as
             PLAY_NOTES("A", STRING("A# A# A# A# *"), 60, 4). More MEASURES gives you more resolution.
}}
  AB := AB #> 0 <# 1
  REPEAT STRSIZE(NOTES)
    TIMER := CNT
    IF (BYTE[NOTES] == "*")
      SYNTH.SYNTH(AB+"A", PIN, 0)
      RETURN
    IF (BYTE[NOTES] == "-")
      SYNTH.SYNTH(AB+"A", PIN, 0)
    ELSE
      PLAY_NOTE(AB, NOTES)
    REPEAT UNTIL (BYTE[NOTES++] == " ")  

    REPEAT UNTIL ((CNT-TIMER)/(CLKFREQ/BPM*60/MEASURES))

PUB FREQ (_PIN, AB, HERTZ)
{{ _PIN : What pin to play the frequency on. If it's set to -1 it will use the same pin from SET_PIN
   AB   : Which counter module to use, 0 for "A" or 1 for "B"
   HERTZ: What frequency to play. Set this to 0 to stop playing a frequency
}}
  AB := (AB #> 0 <# 1) + "A"
  IF (_PIN == -1)
    _PIN := PIN
  SYNTH.SYNTH(AB, _PIN, HERTZ)

{{Permission is hereby granted, free of charge, to any person obtaining a copy of this software
  and associated documentation files (the "Software"), to deal in the Software without restriction,
  including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
  and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
  subject to the following conditions: 
   
  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. 
   
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
  PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
  FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}}
