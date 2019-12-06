''*********************************************
''*  S2 Music & Songs                         *
''*  Author: Ben Wirz, Element Products, Inc. *
''*  Copyright (c) 2010 Parallax, Inc.        *  
''*  See end of file for terms of use.        *
''*********************************************
{{
This file has been modified from the original Music.spin file. The
song tables and the ability to play entire songs have been removed
to gain code space.
}} 
  
OBJ

  s2   : "s2Mini" 

 
CON

   VERSION       = 1                                'Release Version Number
   SUBVERSION    = 2106                             'Internal Version Number
      
CON
  'Note Lengths - Fractions of a Whole Note
  WHOL                      = 1         'Whole Note
  HALF                      = 2         'Half Note
  QURT                      = 4         'Quarter Note
  EGTH                      = 8         'Eight Note
  SXTH                      = 16        'Sixteenth Note
  THSC                      = 32        'Thirty-secondth Note
  
  'Control Commands
  SONG_END                  = 255
  SET_VOL                   = 254
  SET_VOICES                = 253       
  SET_SYNC                  = 252
  SET_PAUSE                 = 251
  
  'Musical Note Index
  #1,A2,AS2,B2,C2,CS2,D2,DS2,E2,F2,FS2,G2,GS2,A3,AS3,B3,C3,CS3,D3,DS3,E3,F3,FS3,G3,GS3
  A4,AS4,B4,C4,CS4,D4,DS4,E4,F4,FS4,G4,GS4,A5,AS5,B5,C5,CS5,D5,DS5,E5,F5,FS5,G5,GS5
  A6,AS6,B6,C6,CS6,D6,DS6,E6,F6,FS6,G6,GS6

PUB play_note(len_index,note_a_index,note_b_index)
  ''Play a single note
  ''Whole Note = 2000 mS
  
  s2.set_voices(s2#SIN,s2#SIN)
  s2.set_volume(90)
  s2.play_tone(2000/len_index,WORD[@note_freq][note_a_index],WORD[@note_freq][note_b_index]) 

PUB freq(note_index)
  ''Return the frequency corresponding to a note
  
  return  WORD[@note_freq][note_index]
  
               
DAT
'Note Frequency Look Up Table
'A,A#,B,C,C#,D,D#,E,F,F#,G,G#
'Octaves 2-6 (A4 = 440 Hz)
note_freq     word      0
              word      110,117,123,131,139,147,156,165,175,185,196,208
              word      220,233,247,262,277,294,311,330,349,370,392,415
              word      440,466,494,523,554,587,622,659,698,740,784,831
              word      880,932,988,1047,1109,1175,1245,1319,1397,1480,1568,1661
              word      1760,1865,1976,2093,2217,2349,2489,2637,2794,2960,3136,3322
    
{{
+------------------------------------------------------------------------------------------------------------------------------+
¦                                                   TERMS OF USE: MIT License                                                  ¦                                                            
+------------------------------------------------------------------------------------------------------------------------------¦
¦Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    ¦ 
¦files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    ¦
¦modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software¦
¦is furnished to do so, subject to the following conditions:                                                                   ¦
¦                                                                                                                              ¦
¦The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.¦
¦                                                                                                                              ¦
¦THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          ¦
¦WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         ¦
¦COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   ¦
¦ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         ¦
+------------------------------------------------------------------------------------------------------------------------------+
}}               