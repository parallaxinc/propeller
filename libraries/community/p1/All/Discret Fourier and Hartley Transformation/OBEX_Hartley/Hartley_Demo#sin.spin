{{ 20.09.2013 

}}


OBJ
  Display: "Display"
  Hartley: "Hartley"
  

CON

  _CLKMODE = XTAL1 + PLL16x
  _XINFREQ = 6144000


CON

   Ha = Hartley#Ha
   Fo = Hartley#Fo
   Sp = Hartley#Sp

   Tp = 27
   NA = 0
   NB = 12
   NC = 4
   DH = Sp
   NH = 256
   
   NQ = NH

   fTakt    = Display#uInt               + 2<<8
   fHartley = Display#sFix + (31-NB)<<16 + 3<<8 + 10
   fFourier = Display#sFix + (31-NB)<<16 + 3<<8 + 10
   fBetrag  = Display#sFix + (31-NB)<<16 + 3<<8 + 10
   fPhase   = Display#sFix + (31-8 )<<16 + 3<<8 + 10

   sizeH = NH<<16
   sizeQ = NQ<<16
   HTcfg = Tp<<16 + NA<<12 + NB<<8 + NC<<4 + DH

   
VAR

  long H [NH]
  word Q [NQ]
  word s {0..NQ-1}


PUB Demo | i,j,t

  i:= j:= t:= 0

  Display.Init

  s:= 0
  
  Hartley.Init( @H+sizeH, @Q+sizeQ, @s, HTcfg )

  repeat i from 0 to NH-1
    Q[i]:= sin(4*i)
    

' Anzeige Prozessortakt und Rechenzeit


  Display.LfStr(string("Sinusfunktion"))
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


' Anzeigen des Spektrums oder der Fourier-Transformierten oder der Hartley-Transformierten


  Display.Wait(3)
  Display.Lf


  if DH==Sp
    repeat i from 0 to 15
      Display.LfStr(string("BePh#"))
      Display.Dec(i,3)
      Display.Chr(":")
      Display.Dec(Hartley.Be(i),fBetrag)
      Display.Dec(Hartley.Ph(i),fPhase)
      Display.Str(string("°"))  


  if DH==Fo
    repeat i from 0 to 15
      Display.LfStr(string("ReIm#"))
      Display.Dec(i,3)
      Display.Chr(":")
      Display.Dec(Hartley.Re(i),fFourier)
      Display.Dec(Hartley.Im(i),fFourier)


  if DH==Ha
    repeat i from 0 to 15
      Display.LfStr(string("Wert#"))
      Display.Dec(i,3)
      Display.Chr(":")
      Display.Dec(Hartley.We(i),fHartley)


  Display.Wait(3)
  Display.Ff


  if DH==Sp
    repeat i from 0 to 255
      Display.Pen(3)
      Display.Pix(i,64 + ~~Q[i]~>7)                     'Meßwert
      Display.Pen(1)
      Display.Pix(i,0)
      Display.Lin(0,Hartley.Be(i)>>25)                  'Betrag
      Display.Pen(2)
      Display.Pix(i,64 + Hartley.Ph(i)~>25)             'Phase
    repeat i from 0 to 255 step 64
      Display.Pen(2)
      Display.Pix(i,4)
      Display.Lin(0,-4)


  if DH==Fo
    repeat i from 0 to 255
      Display.Pen(3)
      Display.Pix(i,64 + ~~Q[i]~>7)                     'Meßwert
      Display.Pen(1)
      Display.Pix(i,64)
      Display.Lin(0,Hartley.Re(i)~>21 )                 'Realwert
      Display.Pen(2)
      Display.Pix(i,64)
      Display.Lin(0,Hartley.Im(i)~>21 )                 'Imaginärwert


  if DH==Ha
    repeat i from 0 to 255
      Display.Pen(3)
      Display.Pix(i,64 + ~~Q[i]~>7)                     'Meßwert
      Display.Pen(1)
      Display.Pix(i,64)
      Display.Lin(0,Hartley.We(i)~>22 )                 'Hartleywert
    
    
PUB sin(i) {-4095..4095} | j

  i:= i & 1023
  j:= i<<4
  if i & 256
    j:= -j
  Result:= word[$E000|j]>>4 
  if i & 512
    Result:= -Result

    