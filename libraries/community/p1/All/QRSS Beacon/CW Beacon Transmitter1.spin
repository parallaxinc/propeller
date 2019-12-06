'//////////////////////////////////////////////////////////////////////

'QRSS Beacon
'By Richard G3CWI
'30 June 2012
'V1.1, 2 July - improved functionality

'Note: spectral purity is poor. Use a low pass filter and do not
'be tempted to amplify without checking spectrum.

'For beacon use the best bet would be to use a 10140kHz crystal for
'the propellor clock crystal. This could be trimmed to the correct TX
'freq and would give a better spurious response. If doing this, the
'code would need to be changed to make the timings correct.

'Runs about 10mW coupled by capacitor from Prop pin. This is adequate
'to span the Atlantic on 30m under good conditions.

'QRSS mailing list: http://mail.cnts.be/mailman/listinfo/knightsqrss_cnts.be
'QRSS grabbers:http://digilander.libero.it/i2ndt/grabber/grabber-compendium.htm

'//////////////////////////////////////////////////////////////////////

CON

  _clkmode      = xtal1 + pll16x
  _xinfreq      = 5_000_000
   '

  LED           = 0   'LED repeater
  TX_Pin        = 4   'RF pin
  

  Mode          = 6 'QRSS mode = dot length in seconds
  FSK_Shift     = 5 'Hz. Shift when sending CW
  Carrier_Freq  = 10_140_035-65 'Hz. Freq you want to TX on
  
  DELTA         = 32  'Hz. Crystal error - yours will be different!
                          'You will need to measure it.

  Test_Mode     = False 'If TRUE send super-size sawtooth
  
VAR
 
  long TX_Freq, dotrate

  word jx, ix, ltr, pntr, letter[60], count, sendltr , strlen

  Long TX_f, L2S
   
OBJ
      
  BEEP   : "synth"  'Sound/rf Driver

PUB Main | lt
 
Initialise

'Pattern options: sawtooth_pos, sawtooth_neg, diamond, rectangle,
'triangle_up, triangle_down, fwd_slash, back_slash, tx_off(seconds),
'heart, kiss (!) Example below shows how to insert patterns into 
'your transmission  

  If Test_Mode == False
   
    Repeat 'This is your transmitted message
    
        TX_Off(5)
        
          Repeat 3 'Send positive Sawtooth pattern
          
            Sawtooth_Pos
        
        'send dot matrix callsign from stored font
        'Let_dots are letters A to Z plus /
        'A = Let_dots[0], Z=Let_dots 25, /=Let_dots[26]
        'Num_dots are numbers. Num_dots[0] = 0
         
        TX_Off(5)
        Chr_shifter(Let_dots[6])  'G
        TX_Off(5)
        Chr_shifter(Num_dots[3])  '3
        TX_Off(5)
        Chr_shifter(Let_dots[2])  'C
        TX_Off(5)
        Chr_shifter(Let_dots[22]) 'W
        TX_Off(5)
        Chr_shifter(Let_dots[8])  'I
        TX_Off(5)
          
        Repeat 3 'Positive Sawtooth
          
           Sawtooth_Pos
           
        TX_Off(5)
             
        BEEP.synth("A", TX_Pin, TX_Freq - FSK_Shift) 'TX on
                
        'Send callsign etc in slow FSK CW
        send(" ")
        send("G")
        send("3")
        send("C")
        send("W")
        send("I")
        send(" ")
        send("8")
        send("d")
        send("b")
        send("m")
        send(" ")
        
  Else

        TestMode
 
Pri Initialise

  Load_Chr_Pointers

  dotrate := clkfreq * mode
    
  TX_Freq := Carrier_Freq + Delta 'correct for crystal error

  'waitcnt(clkfreq*30 + cnt) 'Wait 30 secs for crystal to stabilise

Pri TX_Off(secs)

    BEEP.synth("A", TX_Pin, 0)
    waitcnt(clkfreq * secs + cnt) 

Pri Sawtooth_Pos

 TX_Freq := Carrier_Freq + Delta

 repeat TX_f From TX_Freq to (TX_Freq+FSK_Shift) step 1
    BEEP.synth("A", TX_Pin, TX_f)
    waitcnt(clkfreq/2+cnt)
       
 repeat TX_f From (TX_Freq+FSK_Shift) to TX_Freq step 1
    BEEP.synth("A", TX_Pin, TX_f)
    waitcnt(clkfreq/2+cnt)
Pri Heart | ih

   repeat ih from 0 to 27
   
      BEEP.synth("A", TX_Pin, TX_Freq + Heart_dat[ih])
      waitcnt(clkfreq/2+cnt)

Pri I_letter | ii

   repeat ii from 0 to 4
   
      BEEP.synth("A", TX_Pin, TX_Freq + I_dat[ii]-5)
      waitcnt(clkfreq+cnt)
      

Pri QRSS | iq

   repeat iq from 0 to 11
   
      BEEP.synth("A", TX_Pin, TX_Freq + Q_dat[iq]-5)
      waitcnt(clkfreq+cnt)

   TX_off(5)   

   repeat iq from 0 to 13
   
      BEEP.synth("A", TX_Pin, TX_Freq + R_dat[iq]-5)
      waitcnt(clkfreq+cnt)

   TX_off(5)
      
   repeat iq from 0 to 12
   
      BEEP.synth("A", TX_Pin, TX_Freq + S_dat[iq]-5)
      waitcnt(clkfreq+cnt)

   TX_off(5)
      
   repeat iq from 0 to 12
   
      BEEP.synth("A", TX_Pin, TX_Freq + S_dat[iq]-5)
      waitcnt(clkfreq+cnt)
      
Pri Callsign | ic

  repeat ic from 0 to 13
   
      BEEP.synth("A", TX_Pin, TX_Freq + G_dat[ic]-5)
      waitcnt(clkfreq+cnt)
      
  TX_off(5)
  
  repeat ic from 0 to 11
   
      BEEP.synth("A", TX_Pin, TX_Freq + Three_dat[ic]-5)
      waitcnt(clkfreq+cnt)

  TX_off(5)
  
  repeat ic from 0 to 10
   
      BEEP.synth("A", TX_Pin, TX_Freq + C_dat[ic]-5)
      waitcnt(clkfreq+cnt)

  TX_off(5)
  
  repeat ic from 0 to 12
   
      BEEP.synth("A", TX_Pin, TX_Freq + W_dat[ic]-5)
      waitcnt(clkfreq+cnt)

  TX_off(5)
  
  repeat ic from 0 to 4
   
      BEEP.synth("A", TX_Pin, TX_Freq + I_dat[ic]-5)
      waitcnt(clkfreq+cnt)

Pri Kiss | ik
  
  repeat ik from 0 to 10
   
      BEEP.synth("A", TX_Pin, TX_Freq + Kiss_dat[ik]-5)
      waitcnt(clkfreq+cnt)

Pri Chr_shifter(letter_to_send) | shift

L2S := letter_to_send

Repeat 5

  Repeat shift from 0 to 4
  
        IF L2S & $80000000 <> 0
            
           BEEP.synth("A", TX_Pin, (TX_Freq - 5) + (shift * 3))      
      
    waitcnt(clkfreq+cnt)
      
    BEEP.synth("A", TX_Pin, 0)
    L2S <<= 1

Pri Fwd_slash

 TX_Freq := Carrier_Freq + Delta

 repeat TX_f From TX_Freq to (TX_Freq+FSK_Shift) step 1
    BEEP.synth("A", TX_Pin, TX_f)
    waitcnt(clkfreq/2+cnt)

Pri Back_slash

 TX_Freq := Carrier_Freq + Delta      
 repeat TX_f From (TX_Freq+FSK_Shift) to TX_Freq step 1
    BEEP.synth("A", TX_Pin, TX_f)
    waitcnt(clkfreq/2+cnt)

Pri Sawtooth_Neg

 TX_Freq := Carrier_Freq + Delta

 repeat TX_f From TX_Freq to (TX_Freq-FSK_Shift) step 1
    BEEP.synth("A", TX_Pin, TX_f)
    waitcnt(clkfreq/2+cnt)
       
 repeat TX_f From (TX_Freq-FSK_Shift) to TX_Freq step 1
    BEEP.synth("A", TX_Pin, TX_f)
    waitcnt(clkfreq/2+cnt)

Pri Triangle_down

 TX_Freq := Carrier_Freq + Delta

 repeat TX_f From TX_Freq to (TX_Freq-FSK_Shift) step 1
    BEEP.synth("A", TX_Pin, TX_f)
    waitcnt(clkfreq+cnt)
    
    IF Tx_Freq <> TX_f
      BEEP.synth("A", TX_Pin, TX_Freq)
      waitcnt(clkfreq+cnt) 
       
 repeat TX_f From (TX_Freq-FSK_Shift) to TX_Freq step 1
    BEEP.synth("A", TX_Pin, TX_f)
    waitcnt(clkfreq+cnt)
    
    IF Tx_Freq <> TX_f
      BEEP.synth("A", TX_Pin, TX_Freq)
      waitcnt(clkfreq+cnt)

Pri Triangle_up

 TX_Freq := Carrier_Freq + Delta

 repeat TX_f From TX_Freq to (TX_Freq+FSK_Shift) step 1
    BEEP.synth("A", TX_Pin, TX_f)
    waitcnt(clkfreq+cnt)
    
    IF Tx_Freq <> TX_f
      BEEP.synth("A", TX_Pin, TX_Freq)
      waitcnt(clkfreq+cnt)
       
 repeat TX_f From (TX_Freq+FSK_Shift) to TX_Freq step 1
    BEEP.synth("A", TX_Pin, TX_f)
    waitcnt(clkfreq+cnt)
    
    IF Tx_Freq <> TX_f
      BEEP.synth("A", TX_Pin, TX_Freq)
      waitcnt(clkfreq+cnt)

Pri Diamond | id

 TX_Freq := Carrier_Freq + Delta

 repeat id From 0 to FSK_Shift step 1
    BEEP.synth("A", TX_Pin, TX_Freq+id)
    waitcnt(clkfreq+cnt)
    BEEP.synth("A", TX_Pin, TX_Freq-id)
    waitcnt(clkfreq+cnt)
       
 repeat id From FSK_Shift to 0 step 1
    BEEP.synth("A", TX_Pin, TX_Freq+id)
    waitcnt(clkfreq+cnt)
    BEEP.synth("A", TX_Pin, TX_Freq-id)
    waitcnt(clkfreq+cnt)
    
PRI Rectangle | id

  TX_Freq := Carrier_Freq + Delta
 
    repeat id From 0 to FSK_Shift step 1
      BEEP.synth("A", TX_Pin, TX_Freq + id)
      waitcnt(clkfreq/3+cnt)

      BEEP.synth("A", TX_Pin, TX_Freq - id)
      waitcnt(clkfreq/3+cnt)

    repeat 15 'Two horizontal lines
   
      BEEP.synth("A", TX_Pin, TX_Freq + FSK_Shift)
      waitcnt(clkfreq+cnt)
 
      BEEP.synth("A", TX_Pin, TX_Freq - FSK_Shift)
      waitcnt(clkfreq+cnt)
    

    repeat id From FSK_Shift to 0 step 1
      BEEP.synth("A", TX_Pin, TX_Freq + id)
      waitcnt(clkfreq/3+cnt)

      BEEP.synth("A", TX_Pin, TX_Freq - id)
      waitcnt(clkfreq/3+cnt)


Pri TestMode

 TX_Freq := Carrier_Freq + Delta

      Repeat 'Test mode - super large sawtooth wave
             'Easy to spot but a bit antisocial!
             'Useful for initial freqency alignment
          
          repeat TX_f From TX_Freq to (TX_Freq + FSK_Shift*10) step 1
            BEEP.synth("A", TX_Pin, TX_f)
            waitcnt(clkfreq/2+cnt)
           
          repeat TX_f From (TX_Freq + FSK_Shift*10) to TX_Freq step 1
            BEEP.synth("A", TX_Pin, TX_f)
            waitcnt(clkfreq/2+cnt)
           
          repeat TX_f From TX_Freq to (TX_Freq - FSK_Shift*10) step 1
              BEEP.synth("A", TX_Pin, TX_f)
              waitcnt(clkfreq/2+cnt)
          
          repeat TX_f From (TX_Freq - FSK_Shift*10) to TX_Freq step 1
              BEEP.synth("A", TX_Pin, TX_f)
              waitcnt(clkfreq/2+cnt)

          BEEP.synth("A", TX_Pin, TX_Freq-FSK_Shift)        
          'Send callsign
          send(" ")
          send("G")
          send("3")
          send("C")
          send("W")
          send("I")
          send(" ") 


'/////////////////////////////////////////////////////////////////
'                After this comes all the CW code
'/////////////////////////////////////////////////////////////////
Pri Send(send_key)  
  pntr:=0
 case send_key
  "A", "a" : pntr:=1 
  "B", "b" : pntr:=2
  "C", "c" : pntr:=3 
  "D", "d" : pntr:=4
  "E", "e" : pntr:=5 
  "F", "f" : pntr:=6
  "G", "g" : pntr:=7 
  "H", "h" : pntr:=8
  "I", "i" : pntr:=9 
  "J", "j" : pntr:=10
  "K", "k" : pntr:=11
  "L", "l" : pntr:=12
  "M", "m" : pntr:=13
  "N", "n" : pntr:=14
  "O", "o" : pntr:=15
  "P", "p" : pntr:=16
  "Q", "q" : pntr:=17
  "R", "r" : pntr:=18
  "S", "s" : pntr:=19
  "T", "t" : pntr:=20
  "U", "u" : pntr:=21
  "V", "v" : pntr:=22
  "W", "w" : pntr:=23
  "X", "x" : pntr:=24
  "Y", "y" : pntr:=25
  "Z", "z" : pntr:=26
  " "      : pntr:=27           
  "1"      : pntr:=28           
  "2"      : pntr:=29           
  "3"      : pntr:=30           
  "4"      : pntr:=31           
  "5"      : pntr:=32           
  "6"      : pntr:=33           
  "7"      : pntr:=34           
  "8"      : pntr:=35           
  "9"      : pntr:=36           
  "0"      : pntr:=37           
  "."      : pntr:=38           
  ","      : pntr:=39           
  "?"      : pntr:=40           
  "+"      : pntr:=41           
  "!"      : pntr:=42           
  "="      : pntr:=43           
  "/"      : pntr:=44           
  ":"      : pntr:=45           
  ";"      : pntr:=46           
  "-"      : pntr:=47           
  "_"      : pntr:=48           
  "("      : pntr:=49           
  ")"      : pntr:=50           
  "'"      : pntr:=51           
  $22      : pntr:=52    ' quotation mark - hexadecimal value      
  "$"      : pntr:=53           
  "&"      : pntr:=54           
  "@"      : pntr:=55
'
'    This portion of the routine reads the string for each letter, number or
'    punctuation and sends the appropriate dots or dashes to the light and
'    sound.
'                                                                                          
 DIRA[LED] := 1
 ix:=0
 ltr:=BYTE[letter[pntr]]
 repeat
  if (ltr=="1")
   Dot
  if (ltr=="2")
   Dash
  ltr:=BYTE[letter[pntr]][++ix]
 until (ltr == 0)
 Endletter
 if (send_key == " ")   ' If you have a space, then let another two dot times go by.
  Endletter             ' This increases separation between Morse letters indication
                        ' that an end of word has occurred.

Pri Dot ' This routine sends a dot or "dit" followed by a space the same length 

 BEEP.synth("A", TX_Pin, TX_Freq)
 OUTA[LED] := 1
 waitcnt(CNT + dotrate)
 BEEP.synth("A", TX_Pin, TX_Freq-FSK_Shift)
 OUTA[LED] := 0
 waitcnt(CNT + dotrate)

Pri Dash  'This routine sends a dash or "dah" followed by a space as long as a dot

 BEEP.synth("A", TX_Pin, TX_Freq)
 OUTA[LED] := 1
 waitcnt(CNT + 3 * dotrate)
 BEEP.synth("A", TX_Pin, TX_Freq-FSK_Shift)
 OUTA[LED] := 0
 waitcnt(CNT + dotrate)

Pri EndLetter ' This routine waits for two dots worth of time - no sound, no light
 OUTA[LED] := 0
 waitcnt(CNT + 2 * dotrate)

Pri Load_Chr_Pointers

 ' get and store the address of each letter string into the letter array
  ' each letter has a string of letters where 1 equals a dot and 2 equals a dash
  ' each string ends in a zero - since the length of letters in Morse Code
  ' varies (an "e" is a single dot, and a "j" is one dot followed by three dashes)
  ' the address of the start of each string does not occur at a regular spacing
  ' so this array is an array of pointers to the start of each letter.
  letter[0]:=0
  letter[1]:=@A
  letter[2]:=@B
  letter[3]:=@C
  letter[4]:=@D
  letter[5]:=@E
  letter[6]:=@F
  letter[7]:=@G
  letter[8]:=@H
  letter[9]:=@I
  letter[10]:=@J
  letter[11]:=@K
  letter[12]:=@L
  letter[13]:=@M
  letter[14]:=@N
  letter[15]:=@O
  letter[16]:=@P
  letter[17]:=@Q
  letter[18]:=@R
  letter[19]:=@S
  letter[20]:=@T
  letter[21]:=@U
  letter[22]:=@V
  letter[23]:=@W
  letter[24]:=@X
  letter[25]:=@Y
  letter[26]:=@Z
  letter[27]:=@Space
  letter[28]:=@N1
  letter[29]:=@N2
  letter[30]:=@N3
  letter[31]:=@N4
  letter[32]:=@N5
  letter[33]:=@N6
  letter[34]:=@N7
  letter[35]:=@N8
  letter[36]:=@N9
  letter[37]:=@N0
  letter[38]:=@Pperiod
  letter[39]:=@Pcomma
  letter[40]:=@Pquestion
  letter[41]:=@Pplus
  letter[42]:=@Pexclam
  letter[43]:=@Pequals
  letter[44]:=@Pslash
  letter[45]:=@Pcolon
  letter[46]:=@Psemicolon
  letter[47]:=@Phyphen
  letter[48]:=@Punderscore
  letter[49]:=@Popenparen
  letter[50]:=@Pcloseparen
  letter[51]:=@Papostrophe
  letter[52]:=@Pquote
  letter[53]:=@Pdollar
  letter[54]:=@Pampersand
  letter[55]:=@Pat_sign
  
DAT

' Letters in Morse
'
  A     byte  "12",  0
  B     byte  "2111",0
  C     byte  "2121",0
  D     byte  "211", 0
  E     byte  "1",   0
  F     byte  "1121",0
  G     byte  "221", 0
  H     byte  "1111",0
  I     byte  "11",  0
  J     byte  "1222",0
  K     byte  "212", 0
  L     byte  "1211",0
  M     byte  "22",  0
  N     byte  "21",  0
  O     byte  "222", 0
  P     byte  "1221",0
  Q     byte  "2212",0
  R     byte  "121", 0
  S     byte  "111", 0
  T     byte  "2",   0
  U     byte  "112", 0
  V     byte  "1112",0
  W     byte  "122", 0
  X     byte  "2112",0
  Y     byte  "2122",0
  Z     byte  "2211",0
'
' Numbers in Morse
' 
  N1    byte  "12222",0
  N2    byte  "11222",0
  N3    byte  "11122",0
  N4    byte  "11112",0
  N5    byte  "11111",0
  N6    byte  "21111",0
  N7    byte  "22111",0
  N8    byte  "22211",0
  N9    byte  "22221",0
  N0    byte  "22222",0
'
' Punctuation in Morse
'  
  Pperiod        byte  "121212",0
  Pcomma         byte  "221122",0
  Pquestion      byte  "112211",0
  Pplus          byte  "12121",0
  Pexclam        byte  "212122",0 ' Exclaimation mark
  Pequals        byte  "21112",0  ' Double Dash or Prosign BT
  Pslash         byte  "21121",0
  Pcolon         byte  "222111",0
  Psemicolon     byte  "212121",0
  Phyphen        byte  "211112",0
  Punderscore    byte  "112212",0
  Popenparen     byte  "21221",0  ' Open Parenthesis (
  Pcloseparen    byte  "212212",0 ' Closed Parenthesis )
  Papostrophe    byte  "122221",0
  Pquote         byte  "121121",0 ' Quotation Mark
  Pdollar        byte  "1112112",0 ' Dollar Sign $
  Pampersand     byte  "12111",0 ' Ampersand "&" or Wait
  Pat_sign       byte  "122121",0 'The @ sign        
  Space byte  0,0

  Heart_dat long 1,2,3,0,4,-1,5,-2,5,-3,4,-4,3,-5,2,-4,3,-3,4,-2,5,-1,5,0,4,1,2,3
  'Font from http://www.searchfreefonts.com/free/5x5-dots.htm
  'Columns read bottom to top, left to right
  G_dat     long 2,4,6,0,8,0,8,0,4,8,0,2,4,8
  Three_dat long 0,8,0,8,0,4,8,0,4,8,2,6
  C_dat     long 2,4,6,0,8,0,8,0,8,0,8
  W_dat     long 8,6,4,2,0,2,4,2,0,2,4,6,8
  I_dat     long 0,2,4,8,9
  Q_dat     long 2,4,6,0,8,0,8,0,2,4,6,0
  R_dat     long 0,2,4,6,8,4,8,4,8,2,4,8,0,6
  S_dat     long 0,6,0,4,8,0,4,8,0,4,8,2,8
  Kiss_dat  long 0,5,1,4,2,3,2,3,1,4,0,5

  'Characters from 5 x 5 dot matrix stored as binary vertical scans
  'bottom to top, left to right. 27th Let_dots is /.

  Let_dots long $F14A5F00, $FD6B5500, $74631880, $FC631700, $07EB5A80
           long $F94A1080, $746B5E80, $F9084F80, $047F1000, $44231780 
           long $F90C5C00, $FC210800, $F8882F80, $F85D0F80, $74631700
           long $F94A5100, $7463E800, $F94AD900, $956B5480, $087E1080
           long $7C210780, $1B20C180, $FA088F80, $8A88A880, $19384180
           long $8E6B3880, $82082080
  
  Num_dots long $766B3700, $4BF00000, $CD6B5900, $AD6B5500, $19084F80
           long $BD6B5480, $756B5480, $0843D180, $556B5500, $116B5700
  
  