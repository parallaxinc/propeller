CON
  _CLKMODE = xtal1 + pll16x
  _XINFREQ = 5_000_000 
     
OBJ
  psg : "PropellerSignalGenerator"
 
PUB main | i

  'Start "Propeller Signal Generator" and output signal on pin 10 (inverted signal on pin 11)
  psg.start(10, 11, 32) ' Sync pin = 32 = No pin

  'Point to an 8 samples big (2^3) U16 waveform in memory           
  psg.setUserWaveform(@userWaveform, 3) 

  repeat

   'Generate a 200 Hz saw wave for 2 seconds
    psg.setParameters(psg#SAW, 200, 0, 0)
    waitcnt(cnt + 80_000_000 * 2)

   'Generate a 100 Hz sinus wave for 2 seconds
    psg.setParameters(psg#SINE, 100, 0, 0)
    waitcnt(cnt + 80_000_000 * 2)

   'Generate a 300 Hz user defined wave for 2 seconds
    psg.setParameters(psg#USER, 300, 0, 0)
    waitcnt(cnt + 80_000_000 * 2)

   'Generate a 1 kHz sample and hold noise wave for 2 seconds           
    psg.setParameters(psg#NOISE, 1000, 0, 0)
    waitcnt(cnt + 80_000_000 * 2)

   'Generate a 20 kHz sample and hold noise wave for 2 seconds           
    psg.setParameters(psg#NOISE, 20000, 0, 0)
    waitcnt(cnt + 80_000_000 * 2)

   'Generate a 500 Hz square wave with 25% pulse width for 2 seconds       
    psg.setParameters(psg#SQUARE, 500, 0, psg#PW25)
    waitcnt(cnt + 80_000_000 * 2)

   'Generate a 50 Hz square wave with 50% pulse width for 2 seconds       
    psg.setParameters(psg#SQUARE, 50, 0, psg#PW50)
    waitcnt(cnt + 80_000_000 * 2)
 
   'Modulate the pulse width for a few seconds
    repeat i from 0 to (1<<31) step (1<<14) 
      psg.setPulseWidth(i)

   'Generate a 80 Hz triangle wave for 2 seconds      
    psg.setParameters(psg#TRIANGLE, 80, 0, 0)
    waitcnt(cnt + 80_000_000 * 2)

   'Sweep the frequency from 20 to 20000 hz
    repeat i from 20 to 20000  
      psg.setFrequency(i)
      waitcnt(cnt + 10_000)

dat
userWaveform  word -$7FFF, $0000, $7FFF, $4444, $1111, $2222, $3333, $4444
              