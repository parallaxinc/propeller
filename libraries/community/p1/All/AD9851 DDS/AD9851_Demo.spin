CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

OBJ

  DDS: "AD9851"

VAR

  Long Fout

PUB Main

  DDS.Reset

  Fout := 7_032_000
    
  DDS.Freq (Fout) 'Passes freq in Hz
  
 Repeat 'Sweep frequency in 1Hz steps

    Repeat until Fout == 7_034_000
      Fout++
      DDS.Freq (Fout)

    Repeat until Fout == 7_032_000
      Fout--
      DDS.Freq (Fout)
   
   

  
  
 

  