{{Propeller Speech Comparison Program

  Author: Corbin Adkins (a.k.a "microcontroled")

  Version: 1.1

  Updated: 8/25/2009 - Compleated working voice recognition
           2/07/2010 - Put in object form and ready to be published

  Description: This program recieves voice through the "RecordBase" PUB and then you can record through
  the "WaitForCommand" PUB and compare it with the previously recorded sample. Can get it right 50% of the
  time. Since the command will only work with your (the recorders) voice this is more ideal for security
  programs then ones needing spoken commands. Mic in circuit is equivilent that of the one on the demo
  board. To cut down on memory use you can lower the "Samples" CON in the CON block. Adjust the other CONs
  as needed.

}}

CON

    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000       '80 MHz

    Samples = 6500
    AdcInputPin=8
    AdcOutputPin=9

    TriggerThreshold=150

  accuracy = 2000    '2000 works perfectly for my voice, it may have to be ajusted for higher voices.
  choke = 20


VAR

  word sound
  byte light
  
OBJ
  mic:  "dual_ADC1"     'for recording
  'text : "PC_Interface"
  tv   : "TV_Text"


PUB Main|n,i,j, rnd

  mic.start(9,AdcInputPin,AdcOutputPin,19,19,32,32,0,0) 'start digitizing microphone

PUB RecordBase |n, i, j, rnd  

  sound := 0
  rnd:=cnt
  ?rnd

  repeat
    Waitcnt(cnt+clkfreq/2)
    WaitForTrigger
    if (((?rnd)>>4)//2)>0  '50% chance
      Record(@Wav)
      waitcnt(clkfreq + cnt)
      WaitForCommand    

PUB WaitForTrigger|i
  'wait for trigger
  repeat
    i:=mic.GetAverageA>>1
    'text.dec(i)
    'text.out(32)
  until (i)=>TriggerThreshold

PRI Record(pWav)|n,i,rate,nextCnt,dcnt

  dira[18..21]~~
  rate:=8000
  dcnt:=10000 
  n:=Samples  
  n--
  i:=0
  NextCnt:=cnt+15000 
  repeat i from 0 to n
    'dira[18..21]~~  
    'outa[18]~~
    'outa[21]~
    NextCnt+=dcnt   ' need this to be 5000 for 16KSPS   @ 80 MHz
    waitcnt(NextCnt)
    byte[pWav+i]:=mic.GetAverageA>>1 


PUB WaitForCommand :bOK | n, i, nextCnt, rate, dcnt, j, rnd, s, temp, temp2

  'seed random
  rnd:=cnt
  ?rnd
  repeat
    WaitForTrigger
    if (((?rnd)>>4)//2)>0  '50% chance
      
      Record(@final)

      'Set up the counters
      CTRA:= %00110 << 26 + 0<<9 + 10         'NCO/PWM Single-Ended APIN=Pin (BPIN=0 always 0)
      CTRB:= %00110 << 26 + 0<<9 + 11         'NCO/PWM Single-Ended APIN=Pin (BPIN=0 always 0)   

      'get length
      n:=Samples'long[pWav+40]
      'get rate
      rate:=8000'long[pWav+24]
      case rate
        8000:
          dcnt:=10000
        16000:
          dcnt:=5000
        other:
          return false
      'jump over header    
      final+=44   'ignore rest of header (so you better have the right file format!)
      'Get ready for fast loop  
      n--
      i:=0
      NextCnt:=cnt+15000
      
      'Play loop
      repeat i from 0 to n
        NextCnt+=dcnt   ' need this to be 5000 for 16KSPS   @ 80 MHz
        waitcnt(NextCnt)
        temp2 := (byte[final+i])<<24
        temp := (byte[Wav+i])<<24
        if temp2 =< temp + choke and temp2 => temp - choke
          sound += 1
        
      if sound => accuracy
        return true
      else    
        return false
  
DAT

WAV   byte 0[Samples]
final byte 0[Samples]



{{
                            TERMS OF USE: MIT License

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
}}
       