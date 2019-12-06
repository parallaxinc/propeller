CON

  _clkmode = xtal1+pll16x                               
  _xinfreq = 5_000_000
  
  CS=22
  RW=21
  RS=20
  OE=15
  D0=16
  D1=17
  D2=18
  D3=19
  LED=6
  
OBJ

  Debug : "FullDuplexSerial"                            
  DTMF  : "MT8880"

VAR
    
  Byte  code[3]                   ' For recieving 4 digits of DTMF.

PUB Main | temp, index            

  dira[LED]:=1                    'LED Pin output                
  outa[LED]:=0                    'LED Pin low               

  debug.start(31,30,0,57600)
  waitcnt (clkfreq/2+cnt)

  DTMF.init(CS,RW,RS,OE,D3,D2,D1,D0)
  debug.str(string(16,"Touch Tone Decoder Ready",13))    '                     
  temp:=0 
  repeat
    'waitcnt(clkfreq/4+cnt)
    if DTMF.status==1             ' Check status bit on MT8880
      code[temp]:=DTMF.Read       ' Put DTMF digit recieved into code array 
      debug.dec(code[temp])       ' Display last DTMF digit recieved
      debug.str(string(","))    
      temp+=1                     ' Goto next byte in Code array
      if temp==4                  ' Check known codes after recieving 4 DTMF digits
        debug.str(string("Match: "))                      
        debug.dec(CheckDTMF)      ' Compare code array to commands (CMDs) in DAT block                        
        debug.tx(13)                                      
        if CheckDTMF==0           ' No match for code entered.
          repeat index from 1 TO 8' Send tone 8 times
            DTMF.send (%0001)     ' Send low tones to signal no code found
            waitcnt(clkfreq/5+cnt)' Wait to dial next digit. 
        if CheckDTMF==1           ' Code 1 entered
          repeat index from 1 TO 4' Send tone 4 times
            DTMF.Send (%0000)     ' Send high tones to signal corect code entered
            waitcnt(clkfreq/5+cnt)' Wait to dial next digit.
          outa[LED]:=1            ' Turn LED on   
        if CheckDTMF==2           ' Code 2 entered
          repeat index from 1 TO 4' Send tone 4 times
            DTMF.Send (%0000)     ' Send high tones to signal corect code entered
            waitcnt(clkfreq/5+cnt)' Wait to dial next digit.
          outa[LED]:=0            ' Turn LED off   
        temp:=0                   ' Send code array back to 0 for next DTMF code input.             

PUB CheckDTMF|i,offset          ' Routine to find a matching CMDs

    'Thank you Beau Schwabe, This PUB block modified from his RFID object.
    
    repeat i from @START_OF_CMDs to @END_OF_CMDs step 4
      result~
      repeat offset from 0 to 3                         
        if byte[i+offset] == code[offset] 
           result++
      if result == 4                                   ' Match found
         result := ((i-@START_OF_CMDs)/4)+1
         quit
      else
         result~
    
DAT

  'Thank you Beau Schwabe, This DAT CMDs section modified from his RFID object.
  START_OF_CMDs '<--This Label required
  byte  1,2,3,12  '1,2,3,* LED On
  byte  4,5,6,12  '4,5,6,* LED Off
  END_OF_CMDs   '<--This Label required
              