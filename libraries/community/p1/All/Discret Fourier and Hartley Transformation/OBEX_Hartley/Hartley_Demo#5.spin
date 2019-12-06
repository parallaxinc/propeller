{{ 20.09.2013 

}}


OBJ
  Display: "Display"
  Hartley: "Hartley"
  

CON

  _CLKMODE = XTAL1 + PLL16x
  _XINFREQ = 6144000


CON

   NH = 256
   NQ = NH

   fTakt    = Display#uInt          + 2<<8
   fHartley = Display#sFix + 22<<16 + 3<<8 + 10
   fFourier = Display#sFix + 22<<16 + 3<<8 + 10
   fBetrag  = Display#sFix + 22<<16 + 3<<8 + 10
   fPhase   = Display#sFix + 23<<16 + 3<<8 + 10

              'TTABCD
   HTcfg    = $1B0941

   
VAR

  long H [NH]
  word Q [NQ]
  word s 


PUB Demo | i,j,t

  s:= i:= j:= t:= 0

  Display.Init
  
  Hartley.Init( @H+NH<<16, @Q+NQ<<16, @s, HTcfg )

  Display.LfStr(string("Brackwell S. 235"))
  Display.LfStr(string("[1 2 3 4 5 6 7 8 9..256]"))


  repeat i from 0 to 255
    Q[i]:= i+1

    
  'i       We'S        Re       Im'S        Be       Ph°'C'S
  '0: 128.500     128.500    0.000     128.500    0.000°
  '1: -41.242'1    -0.500  -40.742'1    40.745  -90.703°
  '2: -20.868      -0.500  -20.368      20.374  -91.406°
  '3: -14.075      -0.500  -13.575      13.584  -92.109°
  '4: -10.678      -0.500  -10.178      10.190  -92.813°'2'2
  '5:  -8.639'8    -0.500   -8.139'8     8.154  -93.516°'7'5
  '6:  -7.278      -0.500   -6.778       6.797  -94.219°'8'20
  '7:  -6.306      -0.500   -5.806       5.828  -94.922°
  '8:  -5.577      -0.500   -5.077       5.101  -95.625°
  '9:  -5.009      -0.500   -4.509       4.536  -96.328°'30


' Anzeige Prozessortakt und Rechenzeit

 
  Display.Lf
  Display.LfDec(clkfreq/100000,fTakt)
  Display.Str(string(" MHz: "))
  i:= cnt
  Hartley.Trig
  Hartley.Wait
  j:= cnt
  t:= (j-i)/(clkfreq/1000000)
  Display.Dec(t,Display#uInt)
  Display.Str(string(" µs"))
  Display.LfStr(string("80.0 MHz: "))
  t:= t*(clkfreq/10000)/8000
  Display.Dec(t,Display#uInt)
  Display.Str(string(" µs"))


' Anzeigen der Spektrums oder der Fourier-Transformierten oder der Hartley-Transformierten


  Display.Wait(3)
  Display.Lf

  if HTcfg&3==0
    repeat i from 0 to 9
      Display.LfStr(string("BePh#"))
      Display.Dec(i,3)
      Display.Chr(":")
      Display.Dec(Hartley.Be(i),fBetrag)
      Display.Dec(Hartley.Ph(i),fPhase)
      Display.Str(string("°"))  


  if HTcfg&3==1
    repeat i from 0 to 9
      Display.LfStr(string("ReIm#"))
      Display.Dec(i,3)
      Display.Chr(":")
      Display.Dec(Hartley.Re(i),fFourier)
      Display.Dec(Hartley.Im(i),fFourier)


  if HTcfg&3==2
    repeat i from 0 to 9
      Display.LfStr(string("Wert#"))
      Display.Dec(i,3)
      Display.Chr(":")
      Display.Dec(Hartley.We(i),fHartley)


  Display.Wait(3)
  Display.Ff


  if HTcfg&3==0
    repeat i from 0 to 255
      Display.Pen(3)
      Display.Pix(i,64 + ~~Q[i]~>2)                     'Meßwert
      Display.Pen(1)
      Display.Pix(i,0)
      Display.Lin(0,Hartley.Be(i)>>21)                  'Betrag
      Display.Pen(2)
      Display.Pix(i,64 + Hartley.Ph(i)~>25)             'Phase
    repeat i from 0 to 255 step 64
      Display.Pen(2)
      Display.Pix(i,4)
      Display.Lin(0,-4)


  if HTcfg&3==1                                         
    repeat i from 0 to 255
      Display.Pen(3)
      Display.Pix(i,64 + ~~Q[i]~>2)                     'Meßwert
      Display.Pen(1)
      Display.Pix(i,64)
      Display.Lin(0,Hartley.Re(i)~>21 )                 'Realwert
      Display.Pen(2)
      Display.Pix(i,64)
      Display.Lin(0,Hartley.Im(i)~>21 )                 'Imaginärwert


  if HTcfg&3==2
    repeat i from 0 to 255
      Display.Pen(3)
      Display.Pix(i,64 + ~~Q[i]~>2)                     'Meßwert
      Display.Pen(1)
      Display.Pix(i,64)
      Display.Lin(0,Hartley.We(i)~>23 )                 'Hartleywert
    
    
    