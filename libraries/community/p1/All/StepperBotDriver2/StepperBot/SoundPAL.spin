'' Propeller SoundPAL Driver
''
''Copyright (C) 2007 Philip C. Pilgrim (PhiPi)
'' 
''This program is free software; you can redistribute it and/or modify
''it under the terms of the GNU General Public License, version 2, as
''published by the Free Software Foundation.
''
''This program is distributed in the hope that it will be useful,
''but WITHOUT ANY WARRANTY; without even the implied warranty of
''MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
''GNU General Public License for more details.
''
''You should have received a copy of the GNU General Public License
''along with this program; if not, write to the Free Software
''Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
''
''CONTACT
''
''  propeller AT phipi DOT com
''
''VERSION HISTORY
''
''  0.01 alpha: released 2007.11.23
''

CON

'' The constants in this block can either be used in the calling program from here
'' (e.g. sp#play, sp#rept, etc.), or copied and pasted into the program that uses
'' them, so they can be used without the "sp#".

'Commands

  play       = $01      'Play the segment at the following address ($01-$FF).                                               
  rept       = $02      'Begin a repeat block.                                                                              
                        '  Next arg is repeat count (1-254; 255 = endlessly).
  again      = $03      'End the repeat block.

'Playing styles.  
                                                                                
  marcato    = $04      'Normal, separated notes.                                                                           
  staccato   = $05      'Very short notes.                                                                                  
  legato     = $06      'Connected notes.                                                                                   
  glissando  = $07      'Connected, sliding notes.

'Tempos
                                                                          
  tmp0       = $08      'Quarter note =  133 beats/min.                                                                     
  tmp1       = $09      'Quarter note =  266 beats/min. (default)                                                           
  tmp2       = $0A      'Quarter note =  532 beats/min.                                                                     
  tmp3       = $0B      'Quarter note = 1064 beats/min.

'Octaves
                                                                     
  oct0       = $0C      'A_0 = 110Hz                                                                                        
  oct1       = $0D      'A_0 = 220Hz                                                                                        
  oct2       = $0E      'A_0 = 440Hz (default)                                                                              
  oct3       = $0F      'A_0 = 880Hz                                                                                        

'Slur or tie, connecting two subsequent notes only.

  slur       = $10                                                                                                          

'Glissando rates: gl1 is fastest; gl15 is slowest.

  gl1        = $11                                                                                                          
  gl2        = $12                                                                                                          
  gl3        = $13                                                                                                          
  gl4        = $14                                                                                                          
  gl5        = $15                                                                                                          
  gl6        = $16                                                                                                          
  gl7        = $17                                                                                                          
  gl8        = $18                                                                                                          
  gl9        = $19                                                                                                          
  gl10       = $1A                                                                                                          
  gl11       = $1B                                                                                                          
  gl12       = $1C                                                                                                          
  gl13       = $1D                                                                                                          
  gl14       = $1E                                                                                                          
  gl15       = $1F                                                                                                          

'Notes. When unmodified by addition of duration, these are all quarter notes.

  ZZZ        = $80      'Rest                                                                                               
  C_0        = $81      'Low C natural.    (Middle C in oct2.)                                                              
  Cs0        = $82      'Low C sharp.                                                                                       
  Df0        = $82      'Low D flat.                                                                                        
  D_0        = $83      'Low D natural.                                                                                     
  Ds0        = $84      'Low D sharp.                                                                                       
  Ef0        = $84      'Low E flat.                                                                                        
  E_0        = $85      'Low E natural.                                                                                     
  F_0        = $86      'Low F natural.                                                                                     
  Fs0        = $87      'Low F sharp.                                                                                       
  Gf0        = $87      'Low G flat.                                                                                        
  G_0        = $88      'Low G natural.                                                                                     
  Gs0        = $89      'Low G sharp.                                                                                       
  Af0        = $89      'Low A flat.                                                                                        
  A_0        = $8A      'Low A natural.                                                                                     
  As0        = $8B      'Low A sharp.                                                                                       
  Bf0        = $8B      'Low B flat.                                                                                        
  B_0        = $8C      'Low B natural.                                                                                     
  C_1        = $8D      'Medium C natural. (Middle C in oct1.)                                                              
  Cs1        = $8E      'Medium C sharp.                                                                                    
  Df1        = $8E      'Medium D flat.                                                                                     
  D_1        = $8F      'Medium D natural.                                                                                  
  Ds1        = $90      'Medium D sharp.                                                                                    
  Ef1        = $90      'Medium E flat.                                                                                     
  E_1        = $91      'Medium E natural.                                                                                  
  F_1        = $92      'Medium F natural.                                                                                  
  Fs1        = $93      'Medium F sharp.                                                                                    
  Gf1        = $93      'Medium G flat.                                                                                     
  G_1        = $94      'Medium G natural.                                                                                  
  Gs1        = $95      'Medium G sharp.                                                                                    
  Af1        = $95      'Medium A flat.                                                                                     
  A_1        = $96      'Medium A natural.                                                                                  
  As1        = $97      'Medium A sharp.                                                                                    
  Bf1        = $97      'Medium B flat.                                                                                     
  B_1        = $98      'Medium B natural.                                                                                  
  C_2        = $99      'High C natural.   (Middle C in oct0.)                                                              
  Cs2        = $9A      'High C sharp.                                                                                      
  Df2        = $9A      'High D flat.                                                                                       
  D_2        = $9B      'High D natural.                                                                                    
  Ds2        = $9C      'High D sharp.                                                                                      
  Ef2        = $9C      'High E flat.                                                                                       
  E_2        = $9D      'High E natural.                                                                                    
  F_2        = $9E      'High F natural.                                                                                    
  Fs2        = $9F      'High F sharp.                                                                                      
  Gf2        = $9F      'High G flat.

'Duration modifiers. Add value to note to change duration.

  s          = $20-$80  'Sixteenth note.                                                                                    
  e          = $40-$80  'Eighth note.                                                                                       
  de         = $60-$80  'Dotted eighth note.                                                                                
  q          = $80-$80  'Quarter note.                                                                                      
  dq         = $C0-$80  'Dotted quarter note.                                                                               
  h          = $A0-$80  'Half note.                                                                                         
  dh         = $E0-$80  'Dotted half note.

'Substitute end-of-string (high G-flat).                                                                                  

  EOF        = $FF

'Addresses of canned sequences.
                                                                                         
  charge     = $40      'Charge!                                                                                            
  taps       = $44      'Taps                                                                                               
  reveille   = $5D      'Reveille                                                                                           
  firstpost  = $7D      'First Post (horse race bugle call)                                                                 
  intro      = $8D      'Doo-doot doo doot doot DOOT                                                                        
  nyah       = $93      'Nyah nyah nyah nyah NYAH nyah!                                                                     
  dead       = $97      'Funeral dirge                                                                                      
  batthymn   = $9D      'Battle Hymn of the Republic                                                                        
  dixie      = $A5      'Dixie                                                                                              
  cucaracha  = $AC      'La Cucaracha                                                                                       
  popweasel  = $AF      'Pop! Goes the Weasel                                                                               
  marsell    = $B3      'Marsellaise                                                                                        
  rulebrit   = $B9      'Rule Brittania                                                                                     
  matilda    = $C0      'Walzing Matilda                                                                                    
  kradoucha  = $C6      'Kradoutcha ("There's a place in France...")                                                        
  wedding    = $CD      'Wedding March                                                                                      
  ode2joy    = $D2      'Ode to Joy                                                                                         
  dudu       = $DA      'Du, Du Liegst Mir im Herzen                                                                        
  notme      = $E1      'Rude sound                                                                                         
  uhoh       = $E5      'Uh oh!                                                                                             
  siren      = $E8      'American style siren. Infinite loop: reset to exit.                                                
  phone      = $EE      'Rings once.                                                                                        
  whistle    = $F3      'Wolf whistle.                                                                                      
  cricket    = $FA      'Play using oct3 for cricket; oct0 for frog.                                                        


VAR

  long  BaudClock
  long  IOPin

PUB start(pin)

'' Selects the IO pin and sets the output bit for that pin low. DIRA for that pin stays
'' low, since I/O is open drain. DIRA is thus controlled by the output routine.
'' Waits for pin to go high before returning, signifying that SoundpPAL is ready.

  BaudClock := clkfreq / 9600               'Set baurate to 9600.
  IOPin := pin                              'Set IOPin variable.
  dira[IOPin]~                              'Tristate IOPin.
  outa[IOPin]~                              'Set driven state of IOPin low.
  repeat until ina[IOPin]                   'Wait for SoundPAL to come out of hardware reset.
  reset                                     'Soft reset the soundPAL.
  return true

PUB reset | time

'' Reset the SoundPAL, halting any sequences that are playing.

  dira[IOPin]~~                             'Pull IOPin low.
  time := cnt
  repeat until cnt > time + clkfreq / 133   'Wait 7.5ms
  dira[IOPin]~                              'Release IOPin.

PUB sendstr(str_addr) | char

'' Send string to the SoundPAL. Because the SoundPAL's EOF and Spin's string
'' terminator are both the same character (0), the dotted-half high G-flat ($FF)
'' has been sacrificed to stand in as a substitute EOF for the SoundPAL.

  repeat strsize(str_addr)                  'Iterate over the string.
    if ((char := byte[str_addr++]) == $ff)  '  Substitute EOF?
      char~                                 '    Yes: Replace with real EOF (0).
    sendbyte(char)                          '  Send the character.

PUB waitdone | time, busy

'' Wait for the current sequence to finish.

  repeat                                    'Loop until not busy...
    sendbyte("?")                           '  Send enquiry.     
    time := cnt                             '  Set time.
    repeat
      busy := ina[IOPin]                    '  Look for start bit (NOT busy) from SoundPAL.
    while busy and cnt - time < clkfreq / 500 'Loop while still busy and elapsed time < 2ms.
  while busy                

PUB sendbyte(txbyte) | time

'' Send a single character with two stops bits.

  txbyte := (txbyte | $300) << 2            'Set up character with start and stop bits.
  time := cnt                               'Set initial time.
  repeat 11                                 'Send 11 bits total.
    waitcnt(time += BaudClock)              'Wait for next bit time.
    dira[IOPin] := ((txbyte >>= 1) & 1 == 0)'Send next bit via dira.